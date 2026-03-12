const jwt = require('jsonwebtoken');
const config = require('../config/env');
const supabase = require('../config/supabase');

/**
 * Verify JWT token
 */
exports.verifyToken = (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.substring(7);

    try {
        const decoded = jwt.verify(token, config.jwtSecret);
        req.user = decoded;

        // Proactively update last_active_at for learners (fire and forget)
        if (decoded.learnerId) {
            supabase
                .from('learners')
                .update({ last_active_at: new Date().toISOString() })
                .eq('id', decoded.learnerId)
                .then(({ error }) => {
                    if (error) console.error('Error updating last_active_at:', error);
                });
        }

        next();
    } catch (error) {
        return res.status(401).json({ error: 'Invalid token' });
    }
};

/**
 * Optional auth - sets req.user if token provided
 */
exports.optionalAuth = (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return next();
    }

    const token = authHeader.substring(7);

    try {
        const decoded = jwt.verify(token, config.jwtSecret);
        req.user = decoded;
    } catch (error) {
        // Ignore invalid tokens for optional auth
    }

    next();
};

/**
 * Check if user has admin role
 */
exports.isAdmin = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({ error: 'Authentication required' });
    }

    if (req.user.role !== 'admin' && req.user.role !== 'ngo' && req.user.role !== 'master_admin') {
        return res.status(403).json({ error: 'Access denied: Admin privileges required' });
    }

    next();
};
/**
 * Check if user has master_admin role
 */
exports.isMasterAdmin = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({ error: 'Authentication required' });
    }

    if (req.user.role !== 'master_admin') {
        return res.status(403).json({ error: 'Access denied: Master Admin privileges required' });
    }

    next();
};
