const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const config = require('./config/env');

const authRoutes = require('./routes/auth.routes');
const lessonsRoutes = require('./routes/lessons.routes');
const progressRoutes = require('./routes/progress.routes');
const communityRoutes = require('./routes/community.routes');
const smsRoutes = require('./routes/sms.routes');

const { errorHandler } = require('./middleware/error.middleware');
const { requestLogger } = require('./middleware/logger.middleware');

const app = express();
const PORT = process.env.PORT || 3000;

// Set trust proxy for rate limiter to work correctly behind reverse proxies (like Render)
app.set('trust proxy', 1);

// Security middleware
app.use(helmet());
app.use(cors());

// Rate limiting
const generalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    message: { error: 'Too many requests, please try again later.' }
});

const authLimiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour window
    max: 10, // 10 attempts per hour
    message: { error: 'Too many login attempts, please try again after an hour.' }
});

app.use('/api/', generalLimiter);
app.use('/api/v1/auth', authLimiter);

// Body parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use(requestLogger);

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/lessons', lessonsRoutes);
app.use('/api/v1/progress', progressRoutes);
app.use('/api/v1/community', communityRoutes);
app.use('/api/v1/sms', smsRoutes);
app.use('/api/v1/analytics', require('./routes/analytics.routes'));
app.use('/api/v1/admin', require('./routes/admin.routes'));

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Not found' });
});

// Error handler
app.use(errorHandler);

// Start server (only if not being required as a module for tests)
if (require.main === module) {
    app.listen(PORT, () => {
        console.log(`EduFlow API server running on port ${PORT}`);
        console.log(`Environment: ${config.nodeEnv || 'development'}`);
    });
}

module.exports = app;
