const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { verifyToken, isAdmin } = require('../middleware/auth.middleware');
const { validate } = require('../utils/validation');

// POST /api/v1/auth/register - Request OTP
router.post('/register', validate('register'), authController.register);

// POST /api/v1/auth/verify-otp - Verify OTP and login
router.post('/verify-otp', validate('verifyOtp'), authController.verifyOtp);

// POST /api/v1/auth/refresh-token - Refresh token rotation
router.post('/refresh-token', authController.refreshToken);

// POST /api/v1/auth/resend-otp - Resend OTP
router.post('/resend-otp', validate('register'), authController.resendOtp);

// GET /api/v1/auth/profile - Get learner profile (auth required)
router.get('/profile', verifyToken, authController.getProfile);

// PUT /api/v1/auth/profile/:id - Update learner profile
router.put('/profile/:id', verifyToken, validate('updateProfile'), authController.updateProfile);

// POST /api/v1/auth/logout - Logout
router.post('/logout', verifyToken, authController.logout);

// NGO/Admin: Get all learners
router.get('/learners', verifyToken, isAdmin, authController.getLearners);
router.post('/update-profile', verifyToken, isAdmin, authController.updateProfile);

module.exports = router;
