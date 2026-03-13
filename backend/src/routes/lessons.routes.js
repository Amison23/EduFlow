const express = require('express');
const router = express.Router();
const lessonsController = require('../controllers/lessons.controller');
const { verifyToken, optionalAuth } = require('../middleware/auth.middleware');

const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });

// GET /api/v1/lessons/packs - Get all lesson packs
router.get('/packs', optionalAuth, lessonsController.getLessonPacks);
router.post('/packs', verifyToken, lessonsController.createLessonPack);

// GET /api/v1/lessons/packs/:id - Get lessons for a pack
router.get('/packs/:id/lessons', optionalAuth, lessonsController.getLessonsForPack);

// POST /api/v1/lessons/:id/audio - Upload audio for a lesson
router.post('/:id/audio', verifyToken, upload.single('audio'), lessonsController.uploadLessonAudio);

// GET /api/v1/lessons/:id - Get a specific lesson
router.get('/:id', optionalAuth, lessonsController.getLesson);

// GET /api/v1/lessons/:id/quiz - Get quiz questions for a lesson
router.get('/:id/quiz', optionalAuth, lessonsController.getQuizQuestions);

// GET /api/v1/lessons/quiz/adaptive - Get adaptive quiz
router.get('/quiz/adaptive', verifyToken, lessonsController.getAdaptiveQuiz);

// GET /api/v1/lessons/packs/download/:id - Download lesson pack
router.get('/packs/download/:id', verifyToken, lessonsController.downloadPack);

module.exports = router;
