-- Migration: Add OTP columns to learners
-- Description: Adds otp and otp_expiry to support phone-based authentication.

-- 1. Add columns
ALTER TABLE learners ADD COLUMN IF NOT EXISTS otp TEXT;
ALTER TABLE learners ADD COLUMN IF NOT EXISTS otp_expiry TIMESTAMPTZ;

-- 2. Add comment for documentation
COMMENT ON COLUMN learners.otp IS 'One-time password for login';
COMMENT ON COLUMN learners.otp_expiry IS 'Expiry timestamp for the OTP';
