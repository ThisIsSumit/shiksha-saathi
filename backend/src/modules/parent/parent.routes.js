const router = require('express').Router();
const db = require('../../config/database');
const { withCache, TTL } = require('../../cache/redis');
const { authenticate, authorize } = require('../../middleware/auth.middleware');
const { success } = require('../../utils/response');

const wrap = (fn) => async (req, res, next) => {
  try { await fn(req, res, next); }
  catch (err) { err.statusCode ? res.status(err.statusCode).json({ success: false, message: err.message }) : next(err); }
};

router.use(authenticate, authorize('parent', 'admin'));

// ── Get linked children ───────────────────────────────────────────────────
router.get('/children', wrap(async (req, res) => {
  const { rows: parent } = await db.query('SELECT id FROM parents WHERE user_id=$1', [req.user.id]);
  const { rows } = await db.query(
    `SELECT s.id, u.name, s.roll_number, c.grade, c.section, psl.relation,
            sc.name as school_name
     FROM parent_student_links psl
     JOIN students s ON s.id=psl.student_id
     JOIN users u ON u.id=s.user_id
     LEFT JOIN classes c ON c.id=s.class_id
     LEFT JOIN schools sc ON sc.id=s.school_id
     WHERE psl.parent_id=$1`, [parent[0].id]
  );
  success(res, rows);
}));

// ── Child progress dashboard ──────────────────────────────────────────────
router.get('/children/:studentId/progress', wrap(async (req, res) => {
  const { rows: parent } = await db.query('SELECT id FROM parents WHERE user_id=$1', [req.user.id]);
  // Verify parent-child link
  const { rows: link } = await db.query(
    'SELECT id FROM parent_student_links WHERE parent_id=$1 AND student_id=$2',
    [parent[0].id, req.params.studentId]
  );
  if (!link[0]) throw Object.assign(new Error('Child not linked to your account'), { statusCode: 403 });

  const data = await withCache(`parent:child:${req.params.studentId}`, async () => {
    const [attendance, quizzes, recentActivity] = await Promise.all([
      db.query(
        `SELECT COUNT(*) FILTER (WHERE status='present')::int as present,
                COUNT(*)::int as total,
                ROUND(COUNT(*) FILTER (WHERE status='present')::numeric/NULLIF(COUNT(*),0)*100,1) as pct
         FROM attendance WHERE student_id=$1 AND date >= NOW()-'30 days'::interval`,
        [req.params.studentId]
      ),
      db.query(
        `SELECT q.title, q.topic, qa.score, qa.total_marks, qa.percentage, qa.submitted_at,
                s.name as subject_name
         FROM quiz_attempts qa JOIN quizzes q ON q.id=qa.quiz_id
         LEFT JOIN subjects s ON s.id=q.subject_id
         WHERE qa.student_id=$1 ORDER BY qa.submitted_at DESC LIMIT 5`,
        [req.params.studentId]
      ),
      db.query(
        `SELECT date, status FROM attendance WHERE student_id=$1
         ORDER BY date DESC LIMIT 30`, [req.params.studentId]
      ),
    ]);

    return {
      attendance: attendance.rows[0],
      recentQuizzes: quizzes.rows,
      attendanceHistory: recentActivity.rows,
    };
  }, TTL.SHORT);

  success(res, data);
}));

// ── Notifications ─────────────────────────────────────────────────────────
router.get('/notifications', wrap(async (req, res) => {
  const { rows } = await db.query(
    `SELECT * FROM notifications WHERE user_id=$1 ORDER BY created_at DESC LIMIT 50`,
    [req.user.id]
  );
  success(res, rows);
}));

router.patch('/notifications/:id/read', wrap(async (req, res) => {
  await db.query('UPDATE notifications SET is_read=true WHERE id=$1 AND user_id=$2', [req.params.id, req.user.id]);
  success(res, {}, 'Marked as read');
}));

module.exports = router;
