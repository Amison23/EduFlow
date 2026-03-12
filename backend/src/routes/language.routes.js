const express = require('express');
const router = express.Router();
const languageController = require('../controllers/language.controller');
// In a real app, you'd add middleware here to ensure only NGO admins can modify languages
// const { authenticateNGO } = require('../middleware/auth');

router.get('/', languageController.getLanguages);
router.post('/', languageController.addLanguage);
router.put('/:id', languageController.updateLanguage);
router.delete('/:id', languageController.deleteLanguage);


module.exports = router;
