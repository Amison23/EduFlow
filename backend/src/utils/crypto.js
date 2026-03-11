const crypto = require('crypto');

/**
 * Hash phone number using SHA-256
 */
exports.hashPhoneNumber = (phoneNumber) => {
    const normalized = phoneNumber
        .replace(/\s/g, '')
        .replace(/-/g, '')
        .replace(/\+/g, '');

    return crypto.createHash('sha256').update(normalized).digest('hex');
};

/**
 * Generate a random OTP
 */
exports.generateOtp = () => {
    const timestamp = Date.now();
    const otp = (timestamp % 900000) + 100000;
    return otp.toString();
};

/**
 * Verify OTP
 */
exports.verifyOtp = (provided, stored) => {
    return provided === stored;
};

/**
 * Generate HMAC signature
 */
exports.generateHmac = (data, secret) => {
    return crypto
        .createHmac('sha256', secret)
        .update(data)
        .digest('hex');
};

/**
 * Verify HMAC signature
 */
exports.verifyHmac = (data, signature, secret) => {
    const expectedSignature = exports.generateHmac(data, secret);
    return crypto.timingSafeEqual(
        Buffer.from(signature),
        Buffer.from(expectedSignature)
    );
};
/**
 * Hash password using SHA-256 (Simple for demo, should use bcrypt in production)
 */
exports.hashPassword = (password) => {
    return crypto.createHash('sha256').update(password).digest('hex');
};

/**
 * Compare password
 */
exports.comparePassword = (provided, stored) => {
    const providedHash = exports.hashPassword(provided);
    return providedHash === stored;
};
