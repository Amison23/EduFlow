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
        } else if (command.startsWith("MATH") || command.startsWith("ENG") || command.startsWith("SWA")) {
            // Find appropriate lesson pack
            const subject = command.startsWith("MATH") ? "math" : (command.startsWith("ENG") ? "english" : "swahili");
            const level = parseInt(command.replace(/[A-Z]/g, '')) || 1;

            const { data: pack } = await supabase
                .from('lesson_packs')
                .select('id, subject, level')
                .eq('subject', subject)
                .eq('level', level)
                .eq('language', session.language || 'en')
                .single();

            if (pack) {
                // Get first lesson
                const { data: lesson } = await supabase
                    .from('lessons')
                    .select('id, title, content')
                    .eq('pack_id', pack.id)
                    .order('sequence', { ascending: true })
                    .limit(1)
                    .single();

                if (lesson) {
                    await supabase
                        .from('sms_sessions')
                        .update({ current_pack: pack.id, current_lesson: lesson.id, question_index: 0 })
                        .eq('phone_hash', phoneHash);
                    
                    response = `EduFlow ${subject.toUpperCase()} L${level}: ${lesson.title}\n${lesson.content}\n\nReply NEXT for the quiz.`;
                } else {
                    response = "EduFlow: No lessons found in this pack.";
                }
            } else {
                response = `EduFlow: Could not find ${subject} level ${level}.`;
            }
        } else if (command === "NEXT" && session.current_lesson) {
            // Get quiz question
            const { data: questions } = await supabase
                .from('quiz_questions')
                .select('*')
                .eq('lesson_id', session.current_lesson)
                .order('created_at', { ascending: true });

            if (questions && questions.length > session.question_index) {
                const q = questions[session.question_index];
                const options = q.options.map((o, i) => `${i+1}. ${o}`).join('\n');
                response = `EduFlow QUIZ: ${q.question}\n${options}\n\nReply with the option number.`;
            } else {
                response = "EduFlow: No more questions. Send HELP for another lesson!";
            }
        } else {
            response = `EduFlow: You sent "${command}". Send HELP to see available commands.`;
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
