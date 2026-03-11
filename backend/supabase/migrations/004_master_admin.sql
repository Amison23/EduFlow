-- Migration: Master Admin Setup
-- Description: Creates a dedicated admins table for secure dashboard access and seeds a default master admin.

-- 1. Create Admins table
CREATE TABLE IF NOT EXISTS admins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    name TEXT,
    role TEXT NOT NULL DEFAULT 'admin' CHECK (role IN ('admin', 'master_admin')),
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable RLS
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies (Admins can only see their own data, master_admin can see all)
CREATE POLICY "Admins can view their own profile" ON admins
    FOR SELECT USING (auth.uid() = id OR (SELECT role FROM admins WHERE id = auth.uid()) = 'master_admin');

-- 4. Seed initial Master Admin (Password: admin123 - hashed for simplicity in seed)
-- In a real production app, this would be done via a secure signup flow or CLI.
INSERT INTO admins (email, password_hash, name, role)
VALUES ('admin@eduflow.org', 'admin123_hash', 'Master Admin', 'master_admin')
ON CONFLICT (email) DO NOTHING;
