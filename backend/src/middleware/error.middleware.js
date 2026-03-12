const supabase = require('../config/supabase');

/**
 * Centralized error handler
 */
exports.errorHandler = async (err, req, res, _next) => {
    const statusCode = err.statusCode || 500;
    const message = err.message || 'An unexpected error occurred';

    // Log the detailed error server-side
    console.error(`[ERROR] ${new Date().toISOString()} - ${req.method} ${req.url}`);
    console.error(err.stack);

    // Save to database if it's a critical error (500)
    if (statusCode >= 500) {
        try {
            await supabase
                .from('app_logs')
                .insert([{
                    level: 'error',
                    message: message,
                    stack_trace: err.stack,
                    source: 'backend',
                    context: {
                        method: req.method,
                        url: req.url,
                        body: req.body,
                        params: req.params,
                        query: req.query,
                        user: req.user ? { id: req.user.id, role: req.user.role } : null
                    }
                }]);
        } catch (logError) {
            console.error('Failed to log error to database:', logError);
        }
    }

    // Return a generic message to the user
    res.status(statusCode).json({
        error: process.env.NODE_ENV === 'production' ? 'Internal Server Error' : message,
        success: false
    });
};
