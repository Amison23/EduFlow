const supabase = require('../config/supabase');
const { hashPhoneNumber } = require('../utils/crypto');
const smsService = require('../services/sms.service');

/**
 * Handle inbound SMS from Africa's Talking
 */
exports.handleInboundSms = async (req, res, next) => {
    try {
        const { from, text } = req.body;
        const phoneHash = hashPhoneNumber(from);

        // State machine logic for SMS learning
        // 1. Find or create session
        let { data: session } = await supabase
            .from('sms_sessions')
            .select('*')
            .eq('phone_hash', phoneHash)
            .single();

        if (!session) {
            const { data: learner } = await supabase
                .from('learners')
                .select('id')
                .eq('phone_hash', phoneHash)
                .single();
            
            if (!learner) {
                // Return generic message if learner not found
                return res.json({ response: "Welcome to EduFlow. Please register via the app first." });
            }

            const { data: newSession } = await supabase
                .from('sms_sessions')
                .insert([{ phone_hash: phoneHash, learner_id: learner.id }])
                .select()
                .single();
            session = newSession;
        }

        // 2. Parse command (e.g. "MATH1")
        const command = text.trim().toUpperCase();
        let response = "";

        if (command === "HELP") {
            response = "EduFlow HELP: Send MATH1, ENG1, or SWA1 to start a lesson. Send STOP to end session.";
        } else if (command === "STOP") {
            await supabase.from('sms_sessions').delete().eq('phone_hash', phoneHash);
            response = "EduFlow: Session ended. Thank you for learning with us!";
        } else {
            // Placeholder for lesson logic
            response = `EduFlow: You sent "${command}". We are preparing your lesson pack.`;
        }

        // Send response back via SMS service
        await smsService.sendSms(from, response);
        res.json({ success: true });
    } catch (error) {
        next(error);
    }
};

/**
 * Send outbound SMS
 */
exports.sendOutboundSms = async (req, res, next) => {
    try {
        const { to, message } = req.body;
        await smsService.sendSms(to, message);
        res.json({ success: true });
    } catch (error) {
        next(error);
    }
};
