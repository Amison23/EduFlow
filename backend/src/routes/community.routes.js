const express = require('express');
const router = express.Router();
const communityController = require('../controllers/community.controller');
const { verifyToken } = require('../middleware/auth.middleware');

// GET /api/v1/community/groups - Get study groups
router.get('/groups', verifyToken, communityController.getStudyGroups);

// POST /api/v1/community/groups - Create a study group
router.post('/groups', verifyToken, communityController.createStudyGroup);

// GET /api/v1/community/groups/:id - Get study group details
router.get('/groups/:id', verifyToken, communityController.getStudyGroupDetails);

// POST /api/v1/community/groups/:id/join - Join a study group
router.post('/groups/:id/join', verifyToken, communityController.joinStudyGroup);

// GET /api/v1/community/peers - Find study peers
router.get('/peers', verifyToken, communityController.findPeers);

module.exports = router;
