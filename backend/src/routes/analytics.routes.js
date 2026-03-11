const express = require('express');
const router = express.Router();
const analyticsController = require('../controllers/analytics.controller');
const { verifyToken } = require('../middleware/auth.middleware');

// In a real app, only NGO/Admins should access these.
// For now, we'll use same auth protection or basic API key.
router.get('/overview', verifyToken, analyticsController.getOverview);
router.get('/detailed', verifyToken, analyticsController.getDetailedAnalytics);

module.exports = router;
