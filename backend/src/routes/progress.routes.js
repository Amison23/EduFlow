const express = require('express');
const router = express.Router();
const progressController = require('../controllers/progress.controller');
const { verifyToken } = require('../middleware/auth.middleware');
const { validate } = require('../utils/validation');

// POST /api/v1/progress/sync - Sync progress events
router.post('/sync', verifyToken, validate('syncProgress'), progressController.syncProgress);

// GET /api/v1/progress/:learnerId - Get learner progress
router.get('/:learnerId', verifyToken, progressController.getProgress);

// GET /api/v1/progress/:learnerId/:subject - Get subject progress
router.get('/:learnerId/:subject', verifyToken, progressController.getSubjectProgress);

// GET /api/v1/progress/:learnerId/streak - Get learner streak
router.get('/:learnerId/streak', verifyToken, progressController.getStreak);

// GET /api/v1/progress/:learnerId/stats - Get full stats for dashboard
router.get('/:learnerId/stats', verifyToken, progressController.getLearnerStats);

// POST /api/v1/progress/quiz/submit - Submit quiz answers
router.post('/quiz/submit', verifyToken, progressController.submitQuizAnswers);

// GET /api/v1/progress/leaderboard - Get leaderboard
router.get('/leaderboard', progressController.getLeaderboard);

module.exports = router;
