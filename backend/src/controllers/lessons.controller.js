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
/**
 * Create a new lesson pack
 */
exports.createLessonPack = async (req, res, next) => {
    try {
        const { subject, level, language, version, size_mb, storage_path } = req.body;
        
        const { data, error } = await supabase
            .from('lesson_packs')
            .insert([{
                subject,
                level: parseInt(level),
                language,
                version: parseInt(version) || 1,
                size_mb: parseFloat(size_mb) || 0,
                storage_path
            }])
            .select()
            .single();

        if (error) throw error;
        res.status(201).json(data);
    } catch (error) {
        next(error);
    }
};

const storageService = require('../services/storage.service');

/**
 * Upload lesson audio
 */
exports.uploadLessonAudio = async (req, res, next) => {
    try {
        const { id } = req.params;
        const file = req.file;

        if (!file) {
            return res.status(400).json({ error: 'No audio file uploaded' });
        }

        // 1. Get lesson to find its pack_id
        const { data: lesson, error: lessonError } = await supabase
            .from('lessons')
            .select('pack_id, title')
            .eq('id', id)
            .single();

        if (lessonError || !lesson) {
            return res.status(404).json({ error: 'Lesson not found' });
        }

        // 2. Upload to Storage
        const fileName = `${id}_${Date.now()}.mp3`;
        const storagePath = `lessons/${fileName}`;
        const publicUrl = await storageService.uploadFile(
            'audio-content', 
            storagePath, 
            file.buffer, 
            file.mimetype
        );

        // 3. Update Lesson Database
        const { error: updateError } = await supabase
            .from('lessons')
            .update({ audio_url: publicUrl })
            .eq('id', id);

        if (updateError) throw updateError;

        // 4. Bump Pack Version (to trigger mobile sync)
        await supabase.rpc('increment_pack_version', { pack_id: lesson.pack_id });

        res.json({ 
            message: 'Audio uploaded successfully', 
            audioUrl: publicUrl,
            lessonTitle: lesson.title
        });
    } catch (error) {
        next(error);
    }
};

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
