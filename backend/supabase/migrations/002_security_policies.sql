-- RLS Policies for EduFlow

-- 1. Storage Buckets
-- Run this in Supabase SQL editor:
-- insert into storage.buckets (id, name, public) values ('lesson-packs', 'lesson-packs', true);
-- insert into storage.buckets (id, name, public) values ('learner-uploads', 'learner-uploads', false);

-- 2. Tables RLS
ALTER TABLE learners ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_packs ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_groups ENABLE ROW LEVEL SECURITY;

-- 3. Public Policies (Read-only)
CREATE POLICY "Public can view lesson packs" ON lesson_packs FOR SELECT USING (true);
CREATE POLICY "Public can view individual lessons" ON lessons FOR SELECT USING (true);

-- 4. Learner Specific Policies
CREATE POLICY "Learners can manage their own profile" ON learners 
    FOR ALL USING (auth.uid() = id);

CREATE POLICY "Learners can view and create their own progress" ON progress_events 
    FOR ALL USING (auth.uid() = learner_id);

CREATE POLICY "Learners can view and create study groups" ON study_groups
    FOR ALL USING (true); -- Optional: add more restrictive check

-- 5. Refresh Tokens Table (New)
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    token TEXT UNIQUE NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE refresh_tokens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Service role only" ON refresh_tokens FOR ALL USING (false);
