const express = require('express');
const router = express.Router();
const logController = require('../controllers/log.controller');

// POST /api/v1/logs - Create a new log entry
router.post('/', logController.createLog);

module.exports = router;
