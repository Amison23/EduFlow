const Joi = require('joi');

/**
 * Validation schemas
 */
const schemas = {
    // Auth
    register: Joi.object({
        phone: Joi.string().pattern(/^\+?[1-9]\d{1,14}$/).required()
    }),
    verifyOtp: Joi.object({
        phone: Joi.string().pattern(/^\+?[1-9]\d{1,14}$/).required(),
        otp: Joi.string().length(6).required()
    }),
    
    // Profile
    updateProfile: Joi.object({
        region: Joi.string().max(100),
        displacement: Joi.string().valid('conflict', 'climate', 'other'),
        language: Joi.string().length(2)
    }).min(1),

    // Lessons
    syncProgress: Joi.object({
        events: Joi.array().items(Joi.object({
            lesson_id: Joi.string().uuid().required(),
            event_type: Joi.string().valid('lesson_started', 'lesson_completed', 'quiz_answered', 'quiz_completed').required(),
            score: Joi.number().min(0).max(100),
            device_ts: Joi.string().isoDate().required(),
            metadata: Joi.object()
        })).required()
    })
};

/**
 * Middleware to validate request body
 */
const validate = (schemaName) => {
    return (req, res, next) => {
        const schema = schemas[schemaName];
        if (!schema) {
             return next(new Error(`Schema ${schemaName} not found`));
        }

        const { error, value } = schema.validate(req.body, { 
            abortEarly: false, 
            stripUnknown: true 
        });

        if (error) {
            const errorMessage = error.details.map(detail => detail.message).join(', ');
            return res.status(400).json({ error: errorMessage });
        }

        req.body = value;
        next();
    };
};

module.exports = { validate, schemas };
