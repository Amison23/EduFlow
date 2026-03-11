-- EduFlow Database Schema
-- Version 1.0

-- Learners table (PII-free: phone stored as hash)
CREATE TABLE IF NOT EXISTS learners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_hash TEXT UNIQUE NOT NULL,
    region TEXT,
    displacement TEXT CHECK (displacement IN ('conflict', 'climate', 'other')),
    language TEXT DEFAULT 'en',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
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
    learner_id UUID REFERENCES learners(id),
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
    creator_id UUID REFERENCES learners(id),
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

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_learners_phone_hash ON learners(phone_hash);
CREATE INDEX IF NOT EXISTS idx_lessons_pack ON lessons(pack_id);
CREATE INDEX IF NOT EXISTS idx_progress_learner ON progress_events(learner_id);
CREATE INDEX IF NOT EXISTS idx_progress_lesson ON progress_events(lesson_id);
CREATE INDEX IF NOT EXISTS idx_quiz_lesson ON quiz_questions(lesson_id);
