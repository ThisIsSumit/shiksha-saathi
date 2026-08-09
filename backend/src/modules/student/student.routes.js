const router = require('express').Router();
const db = require('../../config/database');
const { withCache, TTL } = require('../../cache/redis');
const { authenticate, authorize } = require('../../middleware/auth.middleware');
const { success } = require('../../utils/response');

const wrap = (fn) => async (req, res, next) => {
  try { await fn(req, res, next); }
  catch (err) { err.statusCode ? res.status(err.statusCode).json({ success: false, message: err.message }) : next(err); }
};

router.use(authenticate, authorize('student', 'admin'));

// ── Dashboard ─────────────────────────────────────────────────────────────
router.get('/dashboard', wrap(async (req, res) => {
  const data = await withCache(`student:dashboard:${req.user.id}`, async () => {
    const { rows: student } = await db.query(
      `SELECT s.*, u.name, c.grade, c.section FROM students s
       JOIN users u ON u.id=s.user_id LEFT JOIN classes c ON c.id=s.class_id
       WHERE s.user_id=$1`, [req.user.id]
    );
    if (!student[0]) throw Object.assign(new Error('Student not found'), { statusCode: 404 });

    const [attendance, quizzes, streak] = await Promise.all([
      db.query(
        `SELECT COUNT(*) FILTER (WHERE status='present')::int as present,
                COUNT(*)::int as total,
                ROUND(COUNT(*) FILTER (WHERE status='present')::numeric/NULLIF(COUNT(*),0)*100,1) as pct
         FROM attendance WHERE student_id=$1 AND date >= NOW()-'30 days'::interval`,
        [student[0].id]
      ),
      db.query(
        `SELECT AVG(percentage)::numeric(5,2) as avg_score, COUNT(*)::int as total
         FROM quiz_attempts WHERE student_id=$1`, [student[0].id]
      ),
      db.query(
        'SELECT * FROM student_streaks WHERE student_id=$1', [student[0].id]
      ),
    ]);

    return {
      student: student[0],
      attendance: attendance.rows[0],
      quizPerformance: quizzes.rows[0],
      streak: streak.rows[0] || { current_streak: 0, total_points: 0, badges: [] },
    };
  }, TTL.SHORT);
  success(res, data);
}));

// ── Progress ──────────────────────────────────────────────────────────────
router.get('/progress', wrap(async (req, res) => {
  const { rows: student } = await db.query('SELECT id FROM students WHERE user_id=$1', [req.user.id]);
  const { rows } = await db.query(
    `SELECT sp.*, s.name as subject_name, s.name_hi
     FROM student_progress sp JOIN subjects s ON s.id=sp.subject_id
     WHERE sp.student_id=$1 ORDER BY sp.week_start DESC`, [student[0].id]
  );
  success(res, rows);
}));

// ── Quiz attempts ─────────────────────────────────────────────────────────
router.get('/quiz-attempts', wrap(async (req, res) => {
  const { rows: student } = await db.query('SELECT id FROM students WHERE user_id=$1', [req.user.id]);
  const { rows } = await db.query(
    `SELECT qa.*, q.title, q.topic, s.name as subject_name
     FROM quiz_attempts qa JOIN quizzes q ON q.id=qa.quiz_id
     LEFT JOIN subjects s ON s.id=q.subject_id
     WHERE qa.student_id=$1 ORDER BY qa.submitted_at DESC LIMIT 20`,
    [student[0].id]
  );
  success(res, rows);
}));

// ── Attendance history ────────────────────────────────────────────────────
router.get('/attendance', wrap(async (req, res) => {
  const { rows: student } = await db.query('SELECT id FROM students WHERE user_id=$1', [req.user.id]);
  const { month = new Date().getMonth() + 1, year = new Date().getFullYear() } = req.query;
  const { rows } = await db.query(
    `SELECT date, status FROM attendance WHERE student_id=$1
     AND EXTRACT(MONTH FROM date)=$2 AND EXTRACT(YEAR FROM date)=$3 ORDER BY date`,
    [student[0].id, month, year]
  );
  success(res, rows);
}));

module.exports = router;
