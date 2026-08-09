const db = require('../../config/database');
const { withCache, del, delPattern, TTL } = require('../../cache/redis');
const { v4: uuidv4 } = require('uuid');
const logger = require('../../utils/logger');

// ── Get teacher profile with classes ─────────────────────────────────────
const getTeacherProfile = async (userId) => {
  return withCache(`teacher:profile:${userId}`, async () => {
    const { rows } = await db.query(
      `SELECT t.*, u.name, u.phone, u.email, u.avatar_url, u.preferred_lang,
              s.name as school_name, s.district, s.state
       FROM teachers t
       JOIN users u ON u.id = t.user_id
       LEFT JOIN schools s ON s.id = t.school_id
       WHERE t.user_id = $1`, [userId]
    );
    if (!rows[0]) throw Object.assign(new Error('Teacher not found'), { statusCode: 404 });

    const { rows: classes } = await db.query(
      `SELECT c.*, COUNT(s.id)::int as student_count
       FROM classes c LEFT JOIN students s ON s.class_id = c.id
       WHERE c.teacher_id = $1 GROUP BY c.id ORDER BY c.grade`, [rows[0].id]
    );

    return { ...rows[0], classes };
  }, TTL.LONG);
};

// ── Lesson Plans ──────────────────────────────────────────────────────────
const getLessonPlans = async (teacherId, { classId, date, page = 1, limit = 10 }) => {
  const offset = (page - 1) * limit;
  const filters = ['lp.teacher_id = $1'];
  const params = [teacherId];
  let i = 2;

  if (classId) { filters.push(`lp.class_id = $${i++}`); params.push(classId); }
  if (date) { filters.push(`lp.date_for = $${i++}`); params.push(date); }

  const where = filters.join(' AND ');
  const { rows } = await db.query(
    `SELECT lp.*, s.name as subject_name, s.name_hi as subject_name_hi,
            c.grade, c.section
     FROM lesson_plans lp
     LEFT JOIN subjects s ON s.id = lp.subject_id
     LEFT JOIN classes c ON c.id = lp.class_id
     WHERE ${where} ORDER BY lp.date_for DESC, lp.created_at DESC
     LIMIT $${i} OFFSET $${i + 1}`, [...params, limit, offset]
  );

  const { rows: countRows } = await db.query(
    `SELECT COUNT(*)::int as total FROM lesson_plans WHERE teacher_id = $1`, [teacherId]
  );

  return { plans: rows, total: countRows[0].total, page, limit };
};

const createLessonPlan = async (teacherId, data) => {
  const id = uuidv4();
  const { rows } = await db.query(
    `INSERT INTO lesson_plans
     (id, teacher_id, class_id, subject_id, title, topic, topic_hindi,
      content_json, duration_mins, language, ai_generated, date_for)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
     RETURNING *`,
    [id, teacherId, data.class_id, data.subject_id, data.title, data.topic,
     data.topic_hindi || null, JSON.stringify(data.content_json),
     data.duration_mins || 45, data.language || 'hi', data.ai_generated ?? true,
     data.date_for || null]
  );
  await delPattern(`lessonplans:${teacherId}:*`);
  return rows[0];
};

const updateLessonPlan = async (teacherId, planId, data) => {
  const { rows } = await db.query(
    `UPDATE lesson_plans SET title=$1, topic=$2, content_json=$3, date_for=$4, updated_at=NOW()
     WHERE id=$5 AND teacher_id=$6 RETURNING *`,
    [data.title, data.topic, JSON.stringify(data.content_json), data.date_for, planId, teacherId]
  );
  if (!rows[0]) throw Object.assign(new Error('Lesson plan not found'), { statusCode: 404 });
  // Invalidate cached lesson plan lists for this teacher
  try { await delPattern(`lessonplans:${teacherId}:*`); } catch (err) { logger.warn('Failed to clear lessonplans cache', { err: err.message }); }
  return rows[0];
};

const deleteLessonPlan = async (teacherId, planId) => {
  await db.query('DELETE FROM lesson_plans WHERE id=$1 AND teacher_id=$2', [planId, teacherId]);
  try { await delPattern(`lessonplans:${teacherId}:*`); } catch (err) { logger.warn('Failed to clear lessonplans cache', { err: err.message }); }
};

// ── Attendance ─────────────────────────────────────────────────────────────
const getClassStudents = async (classId, teacherId) => {
  return withCache(`class:students:${classId}`, async () => {
    const { rows } = await db.query(
      `SELECT s.id, s.roll_number, u.name, u.avatar_url
       FROM students s JOIN users u ON u.id = s.user_id
       JOIN classes c ON c.id = s.class_id
       WHERE s.class_id = $1 AND c.teacher_id = $2
       ORDER BY s.roll_number, u.name`,
      [classId, teacherId]
    );
    return rows;
  }, TTL.MEDIUM);
};

const getAttendance = async (classId, date) => {
  return withCache(`attendance:${classId}:${date}`, async () => {
    const { rows } = await db.query(
      `SELECT a.*, u.name as student_name, s.roll_number
       FROM attendance a
       JOIN students s ON s.id = a.student_id
       JOIN users u ON u.id = s.user_id
       WHERE a.class_id = $1 AND a.date = $2
       ORDER BY s.roll_number`,
      [classId, date]
    );
    return rows;
  }, TTL.SHORT);
};

const markAttendance = async (teacherId, classId, date, attendanceList) => {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    for (const { studentId, status, note } of attendanceList) {
      await client.query(
        `INSERT INTO attendance (id, class_id, student_id, teacher_id, date, status, note)
         VALUES ($1,$2,$3,$4,$5,$6,$7)
         ON CONFLICT (student_id, date) DO UPDATE
         SET status=$6, note=$7, marked_at=NOW()`,
        [uuidv4(), classId, studentId, teacherId, date, status, note || null]
      );
    }
    await client.query('COMMIT');
    await del(`attendance:${classId}:${date}`);
    return { marked: attendanceList.length };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

const getAttendanceReport = async (classId, startDate, endDate) => {
  const { rows } = await db.query(
    `SELECT u.name, s.roll_number,
            COUNT(*) FILTER (WHERE a.status='present')::int as present_days,
            COUNT(*) FILTER (WHERE a.status='absent')::int as absent_days,
            COUNT(*) FILTER (WHERE a.status='late')::int as late_days,
            COUNT(*)::int as total_days,
            ROUND(COUNT(*) FILTER (WHERE a.status='present')::numeric / COUNT(*) * 100, 1) as pct
     FROM attendance a
     JOIN students s ON s.id = a.student_id
     JOIN users u ON u.id = s.user_id
     WHERE a.class_id=$1 AND a.date BETWEEN $2 AND $3
     GROUP BY u.name, s.roll_number ORDER BY s.roll_number`,
    [classId, startDate, endDate]
  );
  return rows;
};

// ── Worksheets ─────────────────────────────────────────────────────────────
const getWorksheets = async (teacherId, classId) => {
  return withCache(`worksheets:${teacherId}:${classId}`, async () => {
    const { rows } = await db.query(
      `SELECT w.*, s.name as subject_name, c.grade, c.section
       FROM worksheets w
       LEFT JOIN subjects s ON s.id = w.subject_id
       LEFT JOIN classes c ON c.id = w.class_id
       WHERE w.teacher_id=$1 AND ($2::uuid IS NULL OR w.class_id=$2)
       ORDER BY w.created_at DESC`,
      [teacherId, classId || null]
    );
    return rows;
  }, TTL.MEDIUM);
};

const createWorksheet = async (teacherId, data) => {
  const id = uuidv4();
  const { rows } = await db.query(
    `INSERT INTO worksheets
     (id, teacher_id, class_id, subject_id, title, topic, questions_json, language, ai_generated)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING *`,
    [id, teacherId, data.class_id, data.subject_id, data.title, data.topic,
     JSON.stringify(data.questions_json), data.language || 'hi', data.ai_generated ?? true]
  );
  await delPattern(`worksheets:${teacherId}:*`);
  return rows[0];
};

// ── Dashboard analytics ───────────────────────────────────────────────────
const getDashboard = async (teacherId) => {
  return withCache(`teacher:dashboard:${teacherId}`, async () => {
    const today = new Date().toISOString().split('T')[0];

    // basic class and student counts
    const classData = await db.query(
      `SELECT c.id, c.grade, c.section, c.name, COUNT(s.id)::int as students
       FROM classes c LEFT JOIN students s ON s.class_id=c.id
       WHERE c.teacher_id=$1 GROUP BY c.id ORDER BY c.grade, c.section`, [teacherId]
    );

    const studentCount = classData.rows.reduce((sum, r) => sum + (r.students || 0), 0);

    // today's attendance summary
    const todayAttendance = await db.query(
      `SELECT COUNT(*) FILTER (WHERE a.status='present')::int as present,
              COUNT(*) FILTER (WHERE a.status='absent')::int as absent,
              COUNT(*)::int as total
       FROM attendance a JOIN classes c ON c.id=a.class_id
       WHERE c.teacher_id=$1 AND a.date=$2`, [teacherId, today]
    );
    const present = (todayAttendance.rows[0] && todayAttendance.rows[0].present) || 0;
    const total = (todayAttendance.rows[0] && todayAttendance.rows[0].total) || 0;
    const attendancePct = total ? Math.round((present / total) * 1000) / 10 : null;

    // lessons scheduled for today
    const lessonsToday = await db.query(
      `SELECT lp.id, lp.title, lp.topic, lp.date_for, c.id as class_id, c.grade, c.section
       FROM lesson_plans lp JOIN classes c ON c.id = lp.class_id
       WHERE lp.teacher_id=$1 AND lp.date_for=$2 ORDER BY lp.date_for, lp.created_at`, [teacherId, today]
    );

    // students needing attention (low recent quiz scores or low attendance in 30 days)
    const studentsNeed = await db.query(
      `SELECT s.id, u.name, s.roll_number,
              COALESCE(q.avg_pct,0) as avg_score,
              COALESCE(a.att_pct,0) as attendance_pct
       FROM students s JOIN users u ON u.id = s.user_id
       JOIN classes c ON c.id = s.class_id AND c.teacher_id = $1
       LEFT JOIN (
         SELECT student_id, ROUND(AVG(percentage),1) as avg_pct
         FROM quiz_attempts WHERE submitted_at >= NOW() - '90 days'::interval GROUP BY student_id
       ) q ON q.student_id = s.id
       LEFT JOIN (
         SELECT student_id, ROUND( COUNT(*) FILTER (WHERE status='present')::numeric / NULLIF(COUNT(*),0) * 100,1) as att_pct
         FROM attendance WHERE date >= NOW() - '30 days'::interval GROUP BY student_id
       ) a ON a.student_id = s.id
       WHERE COALESCE(q.avg_pct,100) < 50 OR COALESCE(a.att_pct,100) < 75
       ORDER BY COALESCE(q.avg_pct,100) ASC, COALESCE(a.att_pct,100) ASC LIMIT 25`, [teacherId]
    );

    // last synced timestamp: latest update among lessons, attendance, worksheets
    const lastSyncedRes = await db.query(
      `SELECT GREATEST(
         COALESCE(MAX(lp.updated_at), TIMESTAMP '1970-01-01'),
         COALESCE(MAX(a.marked_at), TIMESTAMP '1970-01-01'),
         COALESCE(MAX(w.created_at), TIMESTAMP '1970-01-01')
       ) as last_synced
       FROM classes c
       LEFT JOIN lesson_plans lp ON lp.teacher_id = $1
       LEFT JOIN attendance a ON a.class_id = c.id
       LEFT JOIN worksheets w ON w.teacher_id = $1
       WHERE c.teacher_id = $1`, [teacherId]
    );

    const lastSynced = lastSyncedRes.rows[0] ? lastSyncedRes.rows[0].last_synced : null;

    // Detailed student list for teacher (limit to 500)
    const studentsDetail = await db.query(
      `SELECT s.id, u.name, s.roll_number, c.id as class_id, c.grade, c.section,
              COALESCE(q.avg_pct,0) as avg_score,
              COALESCE(a.att_pct,0) as attendance_pct
       FROM students s JOIN users u ON u.id = s.user_id
       JOIN classes c ON c.id = s.class_id AND c.teacher_id = $1
       LEFT JOIN (
         SELECT student_id, ROUND(AVG(percentage),1) as avg_pct
         FROM quiz_attempts WHERE submitted_at >= NOW() - '90 days'::interval GROUP BY student_id
       ) q ON q.student_id = s.id
       LEFT JOIN (
         SELECT student_id, ROUND( COUNT(*) FILTER (WHERE status='present')::numeric / NULLIF(COUNT(*),0) * 100,1) as att_pct
         FROM attendance WHERE date >= NOW() - '30 days'::interval GROUP BY student_id
       ) a ON a.student_id = s.id
       ORDER BY c.grade, c.section, s.roll_number LIMIT 500`, [teacherId]
    );

    // attendance summary by class for today
    const classIds = classData.rows.map((r) => r.id);
    let attendanceByClass = [];
    if (classIds.length) {
      const attRes = await db.query(
        `SELECT a.class_id,
                COUNT(*) FILTER (WHERE a.status='present')::int as present,
                COUNT(*) FILTER (WHERE a.status='absent')::int as absent,
                COUNT(*)::int as total
         FROM attendance a
         WHERE a.date=$1 AND a.class_id = ANY($2::uuid[])
         GROUP BY a.class_id`, [today, classIds]
      );
      attendanceByClass = attRes.rows;
    }

    return {
      student_count: studentCount,
      attendance_pct: attendancePct,
      lessons_today: lessonsToday.rows,
      todays_class_schedule: classData.rows,
      attendance_by_class: attendanceByClass,
      students: studentsDetail.rows,
      students_needing_attention: studentsNeed.rows,
      last_synced: lastSynced,
    };
  }, TTL.SHORT);
};

// ── Parent SMS ─────────────────────────────────────────────────────────────
const getClassParents = async (classId, teacherId) => {
  const { rows } = await db.query(
    `SELECT u.name as parent_name, u.phone, pu.name as student_name, psl.relation
     FROM parent_student_links psl
     JOIN parents p ON p.id = psl.parent_id
     JOIN users u ON u.id = p.user_id
     JOIN students s ON s.id = psl.student_id
     JOIN users pu ON pu.id = s.user_id
     JOIN classes c ON c.id = s.class_id
     WHERE s.class_id=$1 AND c.teacher_id=$2`,
    [classId, teacherId]
  );
  return rows;
};

module.exports = {
  getTeacherProfile, getLessonPlans, createLessonPlan, updateLessonPlan, deleteLessonPlan,
  getClassStudents, getAttendance, markAttendance, getAttendanceReport,
  getWorksheets, createWorksheet, getDashboard, getClassParents,
};
