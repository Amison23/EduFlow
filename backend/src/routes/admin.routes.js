const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const { verifyToken, isAdmin, isMasterAdmin } = require('../middleware/auth.middleware');

// Public Admin Route
router.post('/login', adminController.login);

// PROTECTED: Only NGO/Admins
router.post('/query', verifyToken, isAdmin, adminController.executeQuery);

// MASTER ADMIN ONLY: User Management
router.get('/admins', verifyToken, isMasterAdmin, adminController.getAdmins);
router.post('/admins', verifyToken, isMasterAdmin, adminController.createAdmin);
router.delete('/admins/:id', verifyToken, isMasterAdmin, adminController.deleteAdmin);

module.exports = router;
