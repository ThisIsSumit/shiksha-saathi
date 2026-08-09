const router = require('express').Router();
const { body } = require('express-validator');
const service = require('./ai.service');
const { authenticate } = require('../../middleware/auth.middleware');
const { validate, aiLimiter } = require('../../middleware');
const { success } = require('../../utils/response');

const wrap = (fn) => async (req, res, next) => {
  try { await fn(req, res, next); }
  catch (err) { err.statusCode ? res.status(err.statusCode).json({ success: false, message: err.message }) : next(err); }
};

router.use(authenticate, aiLimiter);

router.post('/lesson-plan',
  [body('grade').isInt({ min: 1, max: 12 }), body('subject').trim().notEmpty(),
   body('topic').trim().notEmpty()],
  validate,
  wrap(async (req, res) => {
    const plan = await service.generateLessonPlan(req.body, req.user.id);
    success(res, plan, 'Lesson plan generated');
  })
);

router.post('/worksheet',
  [body('grade').isInt({ min: 1, max: 12 }), body('subject').trim().notEmpty(),
   body('topic').trim().notEmpty(), body('questionCount').optional().isInt({ min: 5, max: 20 })],
  validate,
  wrap(async (req, res) => {
    const ws = await service.generateWorksheet(req.body, req.user.id);
    success(res, ws, 'Worksheet generated');
  })
);

router.post('/doubt',
  [body('question').trim().notEmpty().isLength({ max: 500 })],
  validate,
  wrap(async (req, res) => {
    const answer = await service.solveDoubt({ ...req.body, role: req.user.role }, req.user.id);
    success(res, { answer });
  })
);

router.post('/parent-assistant',
  [body('question').trim().notEmpty().isLength({ max: 500 })],
  validate,
  wrap(async (req, res) => {
    const answer = await service.parentAssistant(req.body, req.user.id);
    success(res, { answer });
  })
);

router.post('/sms-draft',
  [body('topic').trim().notEmpty(), body('grade').isInt(), body('subject').trim().notEmpty()],
  validate,
  wrap(async (req, res) => {
    const message = await service.generateParentSms(req.body, req.user.id);
    success(res, { message });
  })
);

module.exports = router;
