const express = require('express');
const router = express.Router();
const analyticsController = require('../controllers/analytics.controller');
const { verifyToken, isAdmin } = require('../middleware/auth.middleware');

// In a real app, only NGO/Admins should access these.
// For now, we'll use same auth protection or basic API key.
router.get('/overview', verifyToken, isAdmin, analyticsController.getOverview);
router.get('/detailed', verifyToken, isAdmin, analyticsController.getDetailedAnalytics);

// Onboarding Analytics
router.post('/track-onboarding', analyticsController.trackOnboardingEvent); // Public for anonymous tracking
router.get('/onboarding-report', verifyToken, isAdmin, analyticsController.getOnboardingReport); // Admin only

module.exports = router;
