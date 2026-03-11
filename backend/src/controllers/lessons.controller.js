const supabase = require('../config/supabase');

/**
 * Get all lesson packs
 */
exports.getLessonPacks = async (req, res, next) => {
    try {
        const { language, subject } = req.query;
        let query = supabase.from('lesson_packs').select('*');

        if (language) query = query.eq('language', language);
        if (subject) query = query.eq('subject', subject);

        const { data, error } = await query;

        if (error) throw error;
        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Get lessons for a pack
 */
exports.getLessonsForPack = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from('lessons')
            .select('*')
            .eq('pack_id', id)
            .order('sequence', { ascending: true });

        if (error) throw error;
        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Get a specific lesson
 */
exports.getLesson = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from('lessons')
            .select('*')
            .eq('id', id)
            .single();

        if (error) throw error;
        if (!data) return res.status(404).json({ error: 'Lesson not found' });

        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Get quiz questions for a lesson
 */
exports.getQuizQuestions = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from('quiz_questions')
            .select('*')
            .eq('lesson_id', id);

        if (error) throw error;
        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Get adaptive quiz
 */
exports.getAdaptiveQuiz = async (req, res, next) => {
    try {
        // Placeholder for adaptive logic
        // In a real app, this would use the learner's previous scores to pick questions
        const { data, error } = await supabase
            .from('quiz_questions')
            .select('*')
            .limit(10);

        if (error) throw error;
        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Download lesson pack
 */
exports.downloadPack = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { data: pack, error } = await supabase
            .from('lesson_packs')
            .select('storage_path')
            .eq('id', id)
            .single();

        if (error || !pack) return res.status(404).json({ error: 'Pack not found' });

        // In a real app, this might return a signed URL or stream the file
        res.json({ downloadUrl: pack.storage_path });
    } catch (error) {
        next(error);
    }
};
