const supabase = require('../config/supabase');

/**
 * Create a new log entry
 */
exports.createLog = async (req, res, next) => {
    try {
        const { level, message, stackTrace, context, source, userId } = req.body;

        if (!level || !message || !source) {
            return res.status(400).json({ error: 'Missing required log fields' });
        }

        const { error } = await supabase
            .from('app_logs')
            .insert([{
                level,
                message,
                stack_trace: stackTrace,
                context: {
                    ...context,
                    userAgent: req.headers['user-agent'],
                    ip: req.ip,
                    timestamp: new Date().toISOString()
                },
                source,
                user_id: userId || (req.user ? req.user.id : null)
            }]);

        if (error) {
            console.error('Failed to save app_log:', error);
            // We don't want the client request to fail because logging failed, 
            // but we should provide feedback if it's a direct log request.
            return res.status(500).json({ error: 'Failed to record log' });
        }

        res.status(201).json({ success: true });
    } catch (error) {
        next(error);
    }
};
