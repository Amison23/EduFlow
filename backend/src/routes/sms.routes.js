const express = require('express');
const router = express.Router();
const smsController = require('../controllers/sms.controller');
const { verifyHmac } = require('../middleware/hmac.middleware');

// POST /api/v1/sms/inbound - Inbound SMS webhook (Africa's Talking)
router.post('/inbound', verifyHmac, smsController.handleInboundSms);

// POST /api/v1/sms/outbound - Send outbound SMS
router.post('/outbound', smsController.sendOutboundSms);

module.exports = router;
