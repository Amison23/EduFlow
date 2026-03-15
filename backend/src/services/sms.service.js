const config = require('../config/env');

/**
 * Service for Africa's Talking SMS integration
 */
class SmsService {
    constructor() {
        // Africa's Talking credentials
        this.atOptions = {
            apiKey: config.africaTalkingApiKey,
            username: config.africaTalkingUsername
        };
        
        // Twilio credentials
        this.twilioOptions = {
            accountSid: config.twilioSid,
            authToken: config.twilioAuthToken,
            from: config.twilioPhoneNumber
        };

        this.at = null;
        this.twilio = null;
    }

    /**
     * Send an SMS via Africa's Talking and/or Twilio
     * @param {string} to - Phone number
     * @param {string} message - Content
     */
    async sendSms(to, message) {
        const results = {};

        if (config.nodeEnv === 'development') {
            console.log(`[SMS SIMULATOR] To: ${to}, Message: ${message}`);
            return { success: true, status: 'simulated' };
        }

        // Africa's Talking (Primary)
        try {
            if (!this.at && this.atOptions.apiKey) {
                const africastalking = require('africastalking')(this.atOptions);
                this.at = africastalking.SMS;
            }

            if (this.at) {
                const atResult = await this.at.send({
                    to: [to],
                    message: message,
                    from: config.smsShortcode
                });
                results.at = atResult;
                console.log('[AT SUCCESS]', atResult);
            }
        } catch (error) {
            console.error('[AT ERROR]', error.message);
            results.atError = error.message;
        }

        // Twilio (Secondary/Testing - Concurrent)
        try {
            if (!this.twilio && this.twilioOptions.accountSid) {
                this.twilio = require('twilio')(this.twilioOptions.accountSid, this.twilioOptions.authToken);
            }

            if (this.twilio) {
                const twilioResult = await this.twilio.messages.create({
                    body: message,
                    to: to,
                    from: this.twilioOptions.from
                });
                results.twilio = twilioResult.sid;
                console.log('[TWILIO SUCCESS]', twilioResult.sid);
            }
        } catch (error) {
            console.error('[TWILIO ERROR]', error.message);
            results.twilioError = error.message;
        }

        return results;
    }
}

module.exports = new SmsService();
