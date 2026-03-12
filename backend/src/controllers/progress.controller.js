const supabase = require('../config/supabase');

/**
 * Sync progress events from device
 */
exports.syncProgress = async (req, res, next) => {
    try {
        const { events } = req.body;
        const { learnerId } = req.user;

        if (!events || !Array.isArray(events)) {
            return res.status(400).json({ error: 'Events array is required' });
        }

        const eventsToInsert = events.map(event => ({
            ...event,
            learner_id: learnerId,
            server_ts: new Date().toISOString()
        }));

        const { error } = await supabase
            .from('progress_events')
            .insert(eventsToInsert);

        if (error) throw error;

        res.json({ success: true, syncedCount: eventsToInsert.length });
    } catch (error) {
        next(error);
    }
};

/**
 * Get learner progress
 */
exports.getProgress = async (req, res, next) => {
    try {
        const { learnerId } = req.params;
        const { data, error } = await supabase
            .from('progress_events')
            .select('*, lessons(title, pack_id)')
            .eq('learner_id', learnerId)
            .order('server_ts', { ascending: false });

        if (error) throw error;
        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Get subject progress
 */
exports.getSubjectProgress = async (req, res, next) => {
    try {
        const { learnerId, subject } = req.params;
        
        const { data, error } = await supabase
            .from('progress_events')
            .select('*, lessons!inner(title, pack_id, lesson_packs!inner(subject))')
            .eq('learner_id', learnerId)
            .eq('lessons.lesson_packs.subject', subject);

        if (error) throw error;
        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Get learner streak
 */
exports.getStreak = async (req, res, next) => {
    try {
        const { learnerId } = req.params;
        
        // Simple streak logic: count consecutive days with at least one event
        const { data, error } = await supabase
            .from('progress_events')
            .select('server_ts')
            .eq('learner_id', learnerId)
            .order('server_ts', { ascending: false });

        if (error) throw error;

        // Implementation of streak calculation logic
        let streak = 0;
        if (data.length > 0) {
            streak = 1; // Simplified for now
        }

        res.json({ streak });
    } catch (error) {
        next(error);
    }
};

/**
 * Submit quiz answers
 */
exports.submitQuizAnswers = async (req, res, next) => {
    try {
        const { lessonId, score, metadata } = req.body;
        const { learnerId } = req.user;

        const { error } = await supabase
            .from('progress_events')
            .insert([{
                learner_id: learnerId,
                lesson_id: lessonId,
                event_type: 'quiz_completed',
                score: score,
                metadata: metadata,
                device_ts: new Date().toISOString(),
                server_ts: new Date().toISOString()
            }]);

        if (error) throw error;

        res.json({ success: true });
    } catch (error) {
        next(error);
    }
};

/**
 * Get leaderboard
 */
exports.getLeaderboard = async (req, res, next) => {
    try {
        // Get top learners based on completed lessons
        const { data, error } = await supabase
            .rpc('get_leaderboard'); // Assuming an RPC or manual grouping

        if (error) {
            // Fallback if RPC doesn't exist
            const { data: fallbackData, error: fallbackError } = await supabase
                .from('progress_events')
                .select('learner_id, score')
                .eq('event_type', 'quiz_completed')
                .limit(10);
            
            if (fallbackError) throw fallbackError;
            return res.json(fallbackData);
        }

        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Get detailed learner stats for dashboard
 */
exports.getLearnerStats = async (req, res, next) => {
    try {
        const { learnerId } = req.params;

        // 1. Get learner basic info
        const { data: learner, error: lError } = await supabase
            .from('learners')
            .select('id, name, points, completed_lessons, language, region, created_at')
            .eq('id', learnerId)
            .single();

        if (lError || !learner) return res.status(404).json({ error: 'Learner not found' });

        // 2. Get activity history
        const { data: history, error: hError } = await supabase
            .from('progress_events')
            .select('event_type, score, server_ts, lessons(title)')
            .eq('learner_id', learnerId)
            .order('server_ts', { ascending: false })
            .limit(20);

        // 3. Average Score
        const quizEvents = (history || []).filter(e => e.event_type === 'quiz_completed' && e.score !== null);
        const avgScore = quizEvents.length > 0 
            ? Math.round(quizEvents.reduce((acc, curr) => acc + parseFloat(curr.score), 0) / quizEvents.length)
            : 0;

        // 4. Total Lessons
        const { count: totalLessons } = await supabase
            .from('lessons')
            .select('*', { count: 'exact', head: true });

        res.json({
            ...learner,
            history: (history || []).map(h => ({
                activity: h.event_type.replace('_', ' '),
                subject: h.lessons?.title || 'General',
                score: h.score,
                date: new Date(h.server_ts).toLocaleDateString()
            })),
            avgScore,
            totalLessons: totalLessons || 0,
            progress: totalLessons > 0 ? Math.round((learner.completed_lessons / totalLessons) * 100) : 0,
            streak: 1, // Simple placeholder
            lessonsCompleted: learner.completed_lessons
        });
    } catch (error) {
        next(error);
    }
};
