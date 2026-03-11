/**
 * HMAC verification for webhooks (Africa's Talking etc.)
 */
exports.verifyHmac = (req, res, next) => {
    // Placeholder for real HMAC verification
    // In production, would use a secret key to hash the body and compare with header
    next();
};
