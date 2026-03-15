const path = require('path');
const dotenv = require('dotenv');

// Load environment variables
const envFile = process.env.NODE_ENV === 'test' ? '.env.test' : '.env';
dotenv.config({ path: path.resolve(__dirname, '../../', envFile) });

const config = {
    // Server
    port: process.env.PORT || 3000,
    nodeEnv: process.env.NODE_ENV || 'development',

    // Supabase
    supabaseUrl: process.env.SUPABASE_URL,
    supabaseKey: process.env.SUPABASE_SERVICE_KEY,
    supabaseAnonKey: process.env.SUPABASE_ANON_KEY,

    // JWT
    jwtSecret: process.env.JWT_SECRET,
    jwtExpiry: process.env.JWT_EXPIRY || '7d',

    // Africa's Talking
    africaTalkingApiKey: process.env.AFRICA_TALKING_API_KEY,
    africaTalkingUsername: process.env.AFRICA_TALKING_USERNAME,
    smsShortcode: process.env.SMS_SHORTCODE || '12345',

    // Twilio (Secondary/Testing)
    twilioSid: process.env.TWILIO_ACCOUNT_SID,
    twilioAuthToken: process.env.TWILIO_AUTH_TOKEN,
    twilioPhoneNumber: process.env.TWILIO_PHONE_NUMBER,

    // SMS OTP
    otpExpiryMinutes: parseInt(process.env.OTP_EXPIRY_MINUTES) || 10,
    otpLength: 6,

    // Rate limiting
    rateLimitWindow: 15 * 60 * 1000, // 15 minutes
    rateLimitMax: 100,

    // Sync
    syncBatchSize: 100,
    syncRetryAttempts: 3,

    // SMTP Gateway
    smtpHost: process.env.SMTP_HOST,
    smtpPort: parseInt(process.env.SMTP_PORT) || 587,
    smtpUser: process.env.SMTP_USER,
    smtpPass: process.env.SMTP_PASS,
    smtpFrom: process.env.SMTP_FROM || 'EduFlow <noreply@eduflow.app>',
};

// Validate required config
if (config.nodeEnv === 'production') {
    const required = [
        'supabaseUrl', 'supabaseKey', 'jwtSecret', 
        'africaTalkingApiKey', 'africaTalkingUsername'
    ];
    
    required.forEach(key => {
        if (!config[key]) {
            throw new Error(`Missing required configuration: ${key}`);
        }
    });

    if (config.jwtSecret && config.jwtSecret.length < 32) {
        throw new Error('JWT secret must be at least 32 characters long');
    }
}

module.exports = config;
