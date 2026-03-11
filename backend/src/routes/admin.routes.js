const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const { verifyToken, isAdmin } = require('../middleware/auth.middleware');

// PROTECTED: Only NGO/Admins
router.post('/query', verifyToken, isAdmin, adminController.executeQuery);

module.exports = router;
