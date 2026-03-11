const config = require('../config/env');

/**
 * Service for Africa's Talking SMS integration
 */
class SmsService {
    constructor() {
        // Initialize AT credentials if in production
        this.options = {
            apiKey: config.africaTalkingApiKey,
            username: config.africaTalkingUsername
        };
        
        // Lazy load AT to avoid issues if keys are missing
        this.at = null;
    }

    /**
     * Send an SMS via Africa's Talking
     * @param {string} to - Phone number (+254...)
     * @param {string} message - Content
     */
    async sendSms(to, message) {
        try {
            if (config.nodeEnv === 'development') {
                console.log(`[AT SIMULATOR] To: ${to}, Message: ${message}`);
                return { success: true, status: 'simulated' };
            }

            if (!this.at) {
                const africastalking = require('africastalking')(this.options);
                this.at = africastalking.SMS;
            }

            const result = await this.at.send({
                to: [to],
                message: message,
                from: config.smsShortcode
            });

            return result;
        } catch (error) {
            console.error('[AT ERROR]', error);
            throw new Error('Failed to send SMS via Africa\'s Talking');
        }
    }
}

module.exports = new SmsService();
