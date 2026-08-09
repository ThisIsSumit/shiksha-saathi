require('dotenv').config();
const { query, pool } = require('../config/database');
const { v4: uuidv4 } = require('uuid');
const logger = require('../utils/logger');

const seed = async () => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const { rows: existing } = await client.query("SELECT id FROM schools WHERE name = $1", ['Seed School']);
    if (existing[0]) {
      logger.info('Seed data already present (Seed School)');
      await client.query('ROLLBACK');
      return;
    }

    const schoolId = uuidv4();
    await client.query(`INSERT INTO schools (id,name,district,state,created_at) VALUES ($1,$2,$3,$4,NOW())`,
      [schoolId, 'Seed School', 'Shimla', 'Himachal Pradesh']);

    // teacher user
    const teacherUserId = uuidv4();
    await client.query(`INSERT INTO users (id,school_id,name,phone,password_hash,role,avatar_url,preferred_lang,created_at)
      VALUES ($1,$2,$3,$4,$5,'teacher',NULL,'hi',NOW())`,
      [teacherUserId, schoolId, 'Mr. Suresh Kumar', '9000000001', 'seed_hash']);

    const teacherId = uuidv4();
    await client.query(`INSERT INTO teachers (id,user_id,school_id,employee_id,qualification,subjects,grades,joining_date,created_at)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,NOW())`,
      [teacherId, teacherUserId, schoolId, 'EMP-001', 'B.Ed', ['Mathematics','Hindi'], [4,5], '2020-06-01']);

    // classes
    const class4Id = uuidv4();
    const class5Id = uuidv4();
    await client.query(`INSERT INTO classes (id,school_id,teacher_id,grade,section,name,created_at) VALUES
      ($1,$2,$3,4,'A','Class 4-A',NOW()),
      ($4,$2,$3,5,'A','Class 5-A',NOW())`, [class4Id, schoolId, teacherId, class5Id]);
    console.log('Inserted classes', class4Id, class5Id);

    // ensure subjects exist and fetch ids
    const { rows: subjRows } = await client.query(`SELECT id,name FROM subjects WHERE name IN ('Mathematics','Hindi','Science')`);
    const subjMap = {};
    subjRows.forEach((r) => { subjMap[r.name] = r.id; });

    // students and users
    const students = [
      { name: 'Rahul Kumar', phone: '9000000011', classId: class4Id },
      { name: 'Priya Sharma', phone: '9000000012', classId: class4Id },
      { name: 'Asha Devi', phone: '9000000013', classId: class5Id },
    ];

    // create a demo quiz for sample attempts
    const demoQuizId = uuidv4();
    await client.query(`INSERT INTO quizzes (id,teacher_id,class_id,subject_id,title,questions_json,total_marks,language,created_at)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,NOW())`, [demoQuizId, teacherId, class4Id, subjMap['Mathematics'] || null, 'Demo Quiz', JSON.stringify([]), 10, 'hi']);
    console.log('Inserted demo quiz', demoQuizId);

    for (const [i, s] of students.entries()) {
      const userId = uuidv4();
      await client.query(`INSERT INTO users (id,school_id,name,phone,password_hash,role,preferred_lang,created_at)
        VALUES ($1,$2,$3,$4,$5,'student','hi',NOW())`, [userId, schoolId, s.name, s.phone, 'seed_hash']);
      console.log('Inserted user', userId);
      const studentId = uuidv4();
      await client.query(`INSERT INTO students (id,user_id,school_id,class_id,roll_number,created_at)
        VALUES ($1,$2,$3,$4,$5,NOW())`, [studentId, userId, schoolId, s.classId, String(i + 1)]);
      console.log('Inserted student', studentId);

      // add a quiz_attempt for some students
      await client.query(`INSERT INTO quiz_attempts (id,quiz_id,student_id,answers_json,score,total_marks,percentage,submitted_at)
        VALUES ($1,$2,$3,$4,$5,$6,$7,NOW()-INTERVAL '10 days')`,
        [uuidv4(), demoQuizId, studentId, JSON.stringify({}), Math.floor(Math.random() * 8) + 2, 10, Math.floor(Math.random() * 60) + 30]);
    }

    // lesson plans for today
    const today = new Date().toISOString().split('T')[0];
    await client.query(`INSERT INTO lesson_plans (id,teacher_id,class_id,subject_id,title,topic,content_json,duration_mins,language,date_for,created_at)
      VALUES ($1,$2,$3,$4,$5,$6,$7,45,'hi',$8,NOW())`,
      [uuidv4(), teacherId, class4Id, subjMap['Mathematics'] || null, 'Fractions lesson', 'भिन्न', JSON.stringify({ sections: [] }), today]);
    console.log('Inserted lesson plan 1');
    await client.query(`INSERT INTO lesson_plans (id,teacher_id,class_id,subject_id,title,topic,content_json,duration_mins,language,date_for,created_at)
      VALUES ($1,$2,$3,$4,$5,$6,$7,45,'hi',$8,NOW())`,
      [uuidv4(), teacherId, class4Id, subjMap['Hindi'] || null, 'Nouns lesson', 'संज्ञा', JSON.stringify({ sections: [] }), today]);
    console.log('Inserted lesson plan 2');

    // attendance for today
    const { rows: studentsRows } = await client.query(`SELECT s.id, s.class_id, u.name FROM students s JOIN users u ON u.id = s.user_id WHERE s.school_id = $1`, [schoolId]);
    for (const s of studentsRows) {
      const status = s.name.includes('Priya') ? 'absent' : 'present';
      await client.query(`INSERT INTO attendance (id,class_id,student_id,teacher_id,date,status,marked_at) VALUES ($1,$2,$3,$4,$5,$6,NOW()) ON CONFLICT (student_id,date) DO NOTHING`,
        [uuidv4(), s.class_id, s.id, teacherId, today, status]);
      // if absent add an additional row with absent status
      if (status === 'absent') {
        await client.query(`UPDATE attendance SET status='absent', note='sick' WHERE student_id=$1 AND date=$2`, [s.id, today]);
      }
    }

    await client.query('COMMIT');
    logger.info('Sample seed data inserted');
  } catch (err) {
    await client.query('ROLLBACK');
    logger.error('Failed to seed sample data', err);
    throw err;
  } finally {
    client.release();
  }
};

if (require.main === module) {
  seed().then(() => process.exit(0)).catch(() => process.exit(1));
}

module.exports = { seed };
