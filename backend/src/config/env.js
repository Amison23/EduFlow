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
    jwtExpiry: '7d',

    // Africa's Talking
    africaTalkingApiKey: process.env.AFRICA_TALKING_API_KEY,
    africaTalkingUsername: process.env.AFRICA_TALKING_USERNAME,
    smsShortcode: process.env.SMS_SHORTCODE || '12345',

    // SMS OTP
    otpExpiryMinutes: 10,
    otpLength: 6,

    // Rate limiting
    rateLimitWindow: 15 * 60 * 1000, // 15 minutes
    rateLimitMax: 100,

    // Sync
    syncBatchSize: 100,
    syncRetryAttempts: 3,
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
