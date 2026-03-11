-- EduFlow Combined Database Schema
-- This file contains all tables, indexes, and RLS policies for a complete setup.

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-------------------------------------------------------------------------------
-- 1. TABLES
-------------------------------------------------------------------------------

-- Learners table (PII-free: phone stored as hash)
CREATE TABLE IF NOT EXISTS learners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_hash TEXT UNIQUE NOT NULL,
    otp TEXT,
    otp_expiry TIMESTAMPTZ,
    region TEXT,
    displacement TEXT CHECK (displacement IN ('conflict', 'climate', 'other')),
    language TEXT DEFAULT 'en',
    role TEXT DEFAULT 'learner' CHECK (role IN ('learner', 'admin', 'ngo')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Refresh Tokens table (for secure long-lived sessions)
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    token TEXT UNIQUE NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lesson Packs table
CREATE TABLE IF NOT EXISTS lesson_packs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject TEXT NOT NULL CHECK (subject IN ('math', 'english', 'swahili', 'digital')),
    level INT NOT NULL CHECK (level BETWEEN 1 AND 5),
    language TEXT NOT NULL,
    version INT NOT NULL DEFAULT 1,
    size_mb NUMERIC(5,2),
    storage_path TEXT,
    published_at TIMESTAMPTZ DEFAULT NOW()
);

-- Individual Lessons table
CREATE TABLE IF NOT EXISTS lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pack_id UUID REFERENCES lesson_packs(id) ON DELETE CASCADE,
    sequence INT NOT NULL,
    title TEXT NOT NULL,
    content TEXT,
    content_url TEXT,
    audio_url TEXT,
    duration_mins INT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Quiz Questions table
CREATE TABLE IF NOT EXISTS quiz_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_index INT NOT NULL,
    explanation TEXT,
    topic TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Progress Events table (append-only event log)
CREATE TABLE IF NOT EXISTS progress_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL CHECK (event_type IN ('lesson_started', 'lesson_completed', 'quiz_answered', 'quiz_completed')),
    score NUMERIC(5,2),
    device_ts TIMESTAMPTZ NOT NULL,
    server_ts TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB
);

-- SMS Sessions table (stateful quiz tracking)
CREATE TABLE IF NOT EXISTS sms_sessions (
    phone_hash TEXT PRIMARY KEY,
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    current_pack UUID REFERENCES lesson_packs(id),
    current_lesson UUID REFERENCES lessons(id),
    question_index INT DEFAULT 0,
    score INT DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Study Groups table
CREATE TABLE IF NOT EXISTS study_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    subject TEXT NOT NULL,
    creator_id UUID REFERENCES learners(id) ON DELETE SET NULL,
    max_members INT DEFAULT 20,
    is_public BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Group Members table
CREATE TABLE IF NOT EXISTS group_members (
    group_id UUID REFERENCES study_groups(id) ON DELETE CASCADE,
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (group_id, learner_id)
);

-------------------------------------------------------------------------------
-- 2. INDEXES
-------------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_learners_phone_hash ON learners(phone_hash);
CREATE INDEX IF NOT EXISTS idx_lessons_pack ON lessons(pack_id);
CREATE INDEX IF NOT EXISTS idx_progress_learner ON progress_events(learner_id);
CREATE INDEX IF NOT EXISTS idx_progress_lesson ON progress_events(lesson_id);
CREATE INDEX IF NOT EXISTS idx_quiz_lesson ON quiz_questions(lesson_id);
CREATE INDEX IF NOT EXISTS idx_rt_learner ON refresh_tokens(learner_id);
CREATE INDEX IF NOT EXISTS idx_rt_token ON refresh_tokens(token);

-------------------------------------------------------------------------------
-- 3. ROW LEVEL SECURITY (RLS)
-------------------------------------------------------------------------------

-- Enable RLS on all tables
ALTER TABLE learners ENABLE ROW LEVEL SECURITY;
ALTER TABLE refresh_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_packs ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

-- 3.1 Public Read Policies
CREATE POLICY "Public can view lesson packs" ON lesson_packs FOR SELECT USING (true);
CREATE POLICY "Public can view individual lessons" ON lessons FOR SELECT USING (true);
CREATE POLICY "Public can view quiz questions" ON quiz_questions FOR SELECT USING (true);

-- 3.2 Learner Policies
CREATE POLICY "Learners can manage their own profile" ON learners 
    FOR ALL USING (auth.uid() = id);

CREATE POLICY "Learners can manage their own progress" ON progress_events 
    FOR ALL USING (auth.uid() = learner_id);

CREATE POLICY "Learners can view and create study groups" ON study_groups
    FOR ALL USING (true);

CREATE POLICY "Members can view group membership" ON group_members
    FOR SELECT USING (true);

CREATE POLICY "Learners can join groups" ON group_members
    FOR INSERT WITH CHECK (auth.uid() = learner_id);

-- 3.3 Security Policies
CREATE POLICY "Service role only for refresh tokens" ON refresh_tokens 
    FOR ALL USING (false); -- Accessible only via Service Role Key (Server-side)

-------------------------------------------------------------------------------
-- 4. STORAGE SETUP (Manual Steps)
-------------------------------------------------------------------------------

-- The following commands should be run in the Supabase SQL Editor to setup buckets:
-- insert into storage.buckets (id, name, public) values ('lesson-packs', 'lesson-packs', true);
-- insert into storage.buckets (id, name, public) values ('learner-uploads', 'learner-uploads', false);
