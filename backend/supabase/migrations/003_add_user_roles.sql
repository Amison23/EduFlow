-- Migration: Add role column to learners table
-- Description: Adds a role field to support role-based access control (RBAC).

-- 1. Add the role column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='learners' AND column_name='role') THEN
        ALTER TABLE learners ADD COLUMN role TEXT DEFAULT 'learner';
    END IF;
END $$;

-- 2. Add check constraint to restrict role values
ALTER TABLE learners DROP CONSTRAINT IF EXISTS learners_role_check;
ALTER TABLE learners ADD CONSTRAINT learners_role_check CHECK (role IN ('learner', 'admin', 'ngo'));

-- 3. Pre-populate some admins (optional/internal discovery phase)
-- UPDATE learners SET role = 'admin' WHERE phone_hash = '...'; 
