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
const logRoutes = require('./routes/log.routes');

const { errorHandler } = require('./middleware/error.middleware');
const { requestLogger } = require('./middleware/logger.middleware');

const app = express();
const PORT = process.env.PORT || 3000;

// Set trust proxy for rate limiter to work correctly behind reverse proxies (like Render)
app.set('trust proxy', 1);

// Security middleware
app.use(helmet());
app.use(cors({
    origin: [
        'http://localhost:3000',
        'http://localhost:5000',
        'https://dashboard-lilac-beta-95.vercel.app',
        /\.vercel\.app$/,
    ],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Rate limiting
const generalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    message: { error: 'Too many requests, please try again later.' }
});

const authLimiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour window
    max: 20, // 20 attempts per hour
    message: { error: 'Too many login attempts, please try again after an hour.' }
});

app.use('/api/', generalLimiter);
app.use('/api/v1/auth', authLimiter);

// Body parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use(requestLogger);

// Root status
app.get('/', (req, res) => {
    res.json({
        name: 'EduFlow API',
        status: 'running',
        version: '1.0.0',
        message: 'Welcome to the EduFlow Backend System',
        environment: config.nodeEnv || 'development'
    });
});

// Ignore favicon requests to prevent 404 logs in browsers
app.get('/favicon.ico', (req, res) => res.status(204).end());

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
app.use('/api/v1/languages', require('./routes/language.routes'));
app.use('/api/v1/analytics', require('./routes/analytics.routes'));
app.use('/api/v1/admin', require('./routes/admin.routes'));
app.use('/api/v1/organization', require('./routes/organization.routes'));
app.use('/api/v1/logs', logRoutes);


// API Base v1 details
app.get('/api/v1', (req, res) => {
    res.json({
        message: 'EduFlow API v1',
        status: 'running',
        endpoints: ['/auth', '/lessons', '/progress', '/community', '/sms', '/analytics']
    });
});

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
