const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const { verifyToken } = require('../middleware/auth.middleware');

// PROTECTED: Only NGO/Admins
router.post('/query', verifyToken, adminController.executeQuery);

module.exports = router;
