const supabase = require('../config/supabase');
const { hashPhoneNumber } = require('../utils/crypto');
const jwt = require('jsonwebtoken');
const config = require('../config/env');
const { nanoid } = require('nanoid');
const otpService = require('../services/otp.service');
const smsService = require('../services/sms.service');

/**
 * Register a new learner (request OTP)
 */
exports.register = async (req, res, next) => {
    try {
        const { phone, name } = req.body;

        if (!phone) {
            return res.status(400).json({ error: 'Phone number is required' });
        }

        const phoneHash = hashPhoneNumber(phone);

        // Generate OTP via service
        const { otp, expiry } = otpService.generate();

        // Check if learner exists
        const { data: existingLearner } = await supabase
            .from('learners')
            .select('*')
            .eq('phone_hash', phoneHash)
            .single();

        if (existingLearner) {
            // Update OTP and potentially name if provided and not already set
            const updates = { otp, otp_expiry: expiry.toISOString() };
            if (name && !existingLearner.name) updates.name = name;
            if (phone && !existingLearner.phone) updates.phone = phone;

            await supabase
                .from('learners')
                .update(updates)
                .eq('phone_hash', phoneHash);
        } else {
            // Create new learner
            await supabase
                .from('learners')
                .insert([{
                    phone_hash: phoneHash,
                    phone: phone,
                    name: name || null,
                    otp,
                    otp_expiry: expiry.toISOString(),
                    language: 'en'
                }]);
        }

        // Send OTP via SMS service
        await smsService.sendSms(phone, `Your EduFlow OTP is: ${otp}. Valid for 10 minutes.`);

        res.json({
            success: true,
            message: 'OTP sent successfully'
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Verify OTP and login
 */
exports.verifyOtp = async (req, res, next) => {
    try {
        const { phone, otp } = req.body;

        const phoneHash = hashPhoneNumber(phone);

        // Find learner
        const { data: learner, error } = await supabase
            .from('learners')
            .select('*')
            .eq('phone_hash', phoneHash)
            .single();

        if (error || !learner) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Verify OTP via service
        const isValid = otpService.verify(otp, learner.otp, learner.otp_expiry);

        if (!isValid) {
            return res.status(401).json({ error: 'Invalid or expired OTP' });
        }

        // Generate JWT (7 days)
        const token = jwt.sign(
            { 
                learnerId: learner.id, 
                phoneHash,
                role: learner.role || 'learner'
            },
            config.jwtSecret,
            { expiresIn: '7d' }
        );

        // Generate Refresh Token
        const refreshToken = nanoid(64);
        const refreshTokenExpiry = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days

        await supabase
            .from('refresh_tokens')
            .insert([{
                learner_id: learner.id,
                token: refreshToken,
                expires_at: refreshTokenExpiry.toISOString()
            }]);

        // Clear OTP
        await supabase
            .from('learners')
            .update({ otp: null, otp_expiry: null })
            .eq('phone_hash', phoneHash);

        res.json({
            success: true,
            token,
            refreshToken,
            learner_id: learner.id
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Refresh Token Rotation
 */
exports.refreshToken = async (req, res, next) => {
    try {
        const { refreshToken } = req.body;

        if (!refreshToken) {
            return res.status(400).json({ error: 'Refresh token is required' });
        }

        // Find and validate refresh token
        const { data: rtRecord, error } = await supabase
            .from('refresh_tokens')
            .select('*, learners(*)')
            .eq('token', refreshToken)
            .single();

        if (error || !rtRecord || new Date(rtRecord.expires_at) < new Date()) {
            return res.status(401).json({ error: 'Invalid or expired refresh token' });
        }

        // Rotate token: Delete old, create new
        await supabase
            .from('refresh_tokens')
            .delete()
            .eq('id', rtRecord.id);

        const newToken = jwt.sign(
            { 
                learnerId: rtRecord.learners.id, 
                phoneHash: rtRecord.learners.phone_hash,
                role: rtRecord.learners.role || 'learner'
            },
            config.jwtSecret,
            { expiresIn: '7d' }
        );

        const newRefreshToken = nanoid(64);
        const refreshTokenExpiry = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

        await supabase
            .from('refresh_tokens')
            .insert([{
                learner_id: rtRecord.learners.id,
                token: newRefreshToken,
                expires_at: refreshTokenExpiry.toISOString()
            }]);

        res.json({
            success: true,
            token: newToken,
            refreshToken: newRefreshToken
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Resend OTP
 */
exports.resendOtp = async (req, res, next) => {
    try {
        const { phone } = req.body;

        if (!phone) {
            return res.status(400).json({ error: 'Phone number is required' });
        }

        const phoneHash = hashPhoneNumber(phone);
        const { otp, expiry } = otpService.generate();

        await supabase
            .from('learners')
            .update({ otp, otp_expiry: expiry.toISOString() })
            .eq('phone_hash', phoneHash);

        await smsService.sendSms(phone, `Your new EduFlow OTP is: ${otp}`);

        res.json({
            success: true,
            message: 'OTP resent successfully'
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get all learners (Admin/NGO only)
 * Enhanced to provide all fields for dashboard monitoring
 */
exports.getLearners = async (req, res, next) => {
    try {
        const { data, error } = await supabase
            .from('learners')
            .select(`
                id,
                phone,
                phone_hash,
                name,
                region,
                displacement,
                language,
                role,
                points,
                completed_lessons,
                is_active,
                last_active_at,
                created_at,
                updated_at
            `)
            .order('last_active_at', { ascending: false, nullsFirst: false });

        if (error) throw error;
        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Get learner profile
 */
exports.getProfile = async (req, res, next) => {
    try {
        const { learnerId } = req.user;

        const { data: learner, error } = await supabase
            .from('learners')
            .select('*')
            .eq('id', learnerId)
            .single();

        if (error || !learner) {
            return res.status(404).json({ error: 'Learner not found' });
        }

        res.json(learner);
    } catch (error) {
        next(error);
    }
};

/**
 * Update learner profile
 */
exports.updateProfile = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { learnerId } = req.user;

        if (id !== learnerId) {
            return res.status(403).json({ error: 'Unauthorized' });
        }

        const { region, displacement, language } = req.body;

        const updates = {};
        if (region) updates.region = region;
        if (displacement) updates.displacement = displacement;
        if (language) updates.language = language;

        const { data, error } = await supabase
            .from('learners')
            .update(updates)
            .eq('id', id)
            .select()
            .single();

        if (error) {
            return res.status(400).json({ error: error.message });
        }

        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Logout
 */
exports.logout = async (req, res, next) => {
    try {
        // In production, you might want to blacklist the token
        res.json({ success: true, message: 'Logged out successfully' });
    } catch (error) {
        next(error);
    }
};
