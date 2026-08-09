const router = require('express').Router();
const { body } = require('express-validator');
const ctrl = require('./auth.controller');
const { authenticate } = require('../../middleware/auth.middleware');
const { validate, authLimiter } = require('../../middleware');

const phoneRule = body('phone').customSanitizer((value) => String(value).trim()).isMobilePhone().withMessage('Valid phone number required');
const passwordRule = body('password').customSanitizer((value) => String(value)).isLength({ min: 6 }).withMessage('Password must be at least 6 characters');

router.post('/register', authLimiter,
  [body('name').trim().notEmpty().withMessage('Name is required'), phoneRule, passwordRule,
   body('role').isIn(['teacher', 'student', 'parent']).withMessage('Valid role required')],
  validate, ctrl.register
);

router.post('/verify-otp', authLimiter,
  [body('userId').isUUID().withMessage('Valid userId required'),
   body('otp').isLength({ min: 6, max: 6 }).withMessage('6-digit OTP required')],
  validate, ctrl.verifyOtp
);

router.post('/login', authLimiter, [phoneRule, passwordRule], validate, ctrl.login);

router.post('/refresh-token',
  [body('refreshToken').notEmpty().withMessage('Refresh token required')],
  validate, ctrl.refreshToken
);

router.post('/logout', authenticate, ctrl.logout);

router.post('/forgot-password', authLimiter, [phoneRule], validate, ctrl.forgotPassword);

router.post('/reset-password', authLimiter,
  [body('userId').isUUID(), body('otp').customSanitizer((value) => String(value)).isLength({ min: 6, max: 6 }), passwordRule],
  validate, ctrl.resetPassword
);

router.get('/profile', authenticate, ctrl.getProfile);

module.exports = router;
