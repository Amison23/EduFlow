const express = require('express');
const router = express.Router();
const organizationController = require('../controllers/organization.controller');

// In a real app, middleware would be added here to restrict access to master admins for updates
router.get('/settings', organizationController.getSettings);
router.put('/settings', organizationController.updateSettings);

module.exports = router;
