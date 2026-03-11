const config = require('../config/env');
const { generateOtp } = require('../utils/crypto');

/**
 * Service for OTP management
 */
class OtpService {
    /**
     * Generate a code and expiry
     */
    generate() {
        const otp = generateOtp();
        const expiry = new Date(Date.now() + config.otpExpiryMinutes * 60 * 1000);
        return { otp, expiry };
    }

    /**
     * Verify if an OTP is valid
     * @param {string} userOtp - OTP provided by user
     * @param {string} storedOtp - OTP from DB
     * @param {Date} expiry - Expiry time from DB
     */
    verify(userOtp, storedOtp, expiry) {
        if (!storedOtp || !expiry) return false;
        if (userOtp !== storedOtp) return false;
        if (new Date(expiry) < new Date()) return false;
        return true;
    }
}

module.exports = new OtpService();
