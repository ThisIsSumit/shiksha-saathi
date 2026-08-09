const router = require('express').Router();
const { body, query } = require('express-validator');
const service = require('./teacher.service');
const { authenticate, authorize } = require('../../middleware/auth.middleware');
const { validate, aiLimiter } = require('../../middleware');
const { success, paginated } = require('../../utils/response');
const db = require('../../config/database');

const wrap = (fn) => async (req, res, next) => {
  try { await fn(req, res, next); }
  catch (err) { err.statusCode ? res.status(err.statusCode).json({ success: false, message: err.message }) : next(err); }
};

// All teacher routes require auth + teacher role
router.use(authenticate, authorize('teacher', 'admin'));

// ── Profile ───────────────────────────────────────────────────────────────
router.get('/profile', wrap(async (req, res) => {
  const profile = await service.getTeacherProfile(req.user.id);
  success(res, profile);
}));

// ── Dashboard ─────────────────────────────────────────────────────────────
router.get('/dashboard', wrap(async (req, res) => {
  const { rows: teacher } = await db.query('SELECT id FROM teachers WHERE user_id=$1', [req.user.id]);
  const data = await service.getDashboard(teacher[0].id);
  success(res, data);
}));

// ── Lesson Plans ──────────────────────────────────────────────────────────
router.get('/lesson-plans', wrap(async (req, res) => {
  const { rows: t } = await db.query('SELECT id FROM teachers WHERE user_id=$1', [req.user.id]);
  const result = await service.getLessonPlans(t[0].id, req.query);
  paginated(res, result.plans, { total: result.total, page: +req.query.page || 1, limit: +req.query.limit || 10 });
}));

router.post('/lesson-plans',
  [body('class_id').isUUID(), body('title').trim().notEmpty(), body('topic').trim().notEmpty(),
   body('content_json').isObject().withMessage('content_json must be an object')],
  validate,
  wrap(async (req, res) => {
    const { rows: t } = await db.query('SELECT id FROM teachers WHERE user_id=$1', [req.user.id]);
    const plan = await service.createLessonPlan(t[0].id, req.body);
    success(res, plan, 'Lesson plan created', 201);
  })
);

router.put('/lesson-plans/:planId',
  [body('title').trim().notEmpty(), body('content_json').isObject()],
  validate,
  wrap(async (req, res) => {
    const { rows: t } = await db.query('SELECT id FROM teachers WHERE user_id=$1', [req.user.id]);
    const plan = await service.updateLessonPlan(t[0].id, req.params.planId, req.body);
    success(res, plan, 'Lesson plan updated');
  })
);

router.delete('/lesson-plans/:planId', wrap(async (req, res) => {
  const { rows: t } = await db.query('SELECT id FROM teachers WHERE user_id=$1', [req.user.id]);
  await service.deleteLessonPlan(t[0].id, req.params.planId);
  success(res, {}, 'Lesson plan deleted');
}));

// ── Attendance ─────────────────────────────────────────────────────────────
router.get('/classes/:classId/students', wrap(async (req, res) => {
  const { rows: t } = await db.query('SELECT id FROM teachers WHERE user_id=$1', [req.user.id]);
  const students = await service.getClassStudents(req.params.classId, t[0].id);
  success(res, students);
}));

router.get('/classes/:classId/attendance', wrap(async (req, res) => {
  const date = req.query.date || new Date().toISOString().split('T')[0];
  const data = await service.getAttendance(req.params.classId, date);
  success(res, data);
}));

router.post('/classes/:classId/attendance',
  [body('date').isDate(), body('attendanceList').isArray({ min: 1 })],
  validate,
  wrap(async (req, res) => {
    const { rows: t } = await db.query('SELECT id FROM teachers WHERE user_id=$1', [req.user.id]);
    const result = await service.markAttendance(t[0].id, req.params.classId, req.body.date, req.body.attendanceList);
    success(res, result, 'Attendance marked');
  })
);

// Convenience endpoint: POST /teacher/attendance
router.post('/attendance',
  [body('classId').isUUID(), body('date').isDate(), body('attendanceList').isArray({ min: 1 })],
  validate,
  wrap(async (req, res) => {
    const { rows: t } = await db.query('SELECT id FROM teachers WHERE user_id=$1', [req.user.id]);
    const { classId, date, attendanceList } = req.body;
    const result = await service.markAttendance(t[0].id, classId, date, attendanceList);
    success(res, result, 'Attendance marked');
  })
);

router.get('/classes/:classId/attendance/report', wrap(async (req, res) => {
  const { startDate = new Date(new Date().setDate(1)).toISOString().split('T')[0], endDate = new Date().toISOString().split('T')[0] } = req.query;
  const report = await service.getAttendanceReport(req.params.classId, startDate, endDate);
  success(res, report);
}));

// ── Worksheets ─────────────────────────────────────────────────────────────
router.get('/worksheets', wrap(async (req, res) => {
  const { rows: t } = await db.query('SELECT id FROM teachers WHERE user_id=$1', [req.user.id]);
  const worksheets = await service.getWorksheets(t[0].id, req.query.classId);
  success(res, worksheets);
}));

router.post('/worksheets',
  [body('class_id').isUUID(), body('title').trim().notEmpty(), body('questions_json').isArray({ min: 1 })],
  validate,
  wrap(async (req, res) => {
    const { rows: t } = await db.query('SELECT id FROM teachers WHERE user_id=$1', [req.user.id]);
    const ws = await service.createWorksheet(t[0].id, req.body);
    success(res, ws, 'Worksheet created', 201);
  })
);

// ── Parent SMS list ────────────────────────────────────────────────────────
router.get('/classes/:classId/parents', wrap(async (req, res) => {
  const { rows: t } = await db.query('SELECT id FROM teachers WHERE user_id=$1', [req.user.id]);
  const parents = await service.getClassParents(req.params.classId, t[0].id);
  success(res, parents);
}));

module.exports = router;
