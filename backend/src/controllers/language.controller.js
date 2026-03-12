const supabase = require('../config/supabase');

/**
 * Get all supported languages
 */
exports.getLanguages = async (req, res, next) => {
    try {
        const { data, error } = await supabase
            .from('supported_languages')
            .select('*')
            .order('name', { ascending: true });

        if (error) throw error;
        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Add a new supported language
 */
exports.addLanguage = async (req, res, next) => {
    try {
        const { code, name } = req.body;

        if (!code || !name) {
            return res.status(400).json({ error: 'Code and Name are required' });
        }

        const { data, error } = await supabase
            .from('supported_languages')
            .insert([{ code, name }])
            .select()
            .single();

        if (error) {
            if (error.code === '23505') {
                return res.status(400).json({ error: 'Language code already exists' });
            }
            throw error;
        }

        res.status(201).json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Update a supported language
 */
exports.updateLanguage = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { name, is_active } = req.body;

        const updates = {};
        if (name) updates.name = name;
        if (is_active !== undefined) updates.is_active = is_active;

        const { data, error } = await supabase
            .from('supported_languages')
            .update(updates)
            .eq('id', id)
            .select()
            .single();

        if (error) throw error;
        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Delete a supported language
 */
exports.deleteLanguage = async (req, res, next) => {
    try {
        const { id } = req.params;

        const { error } = await supabase
            .from('supported_languages')
            .delete()
            .eq('id', id);

        if (error) throw error;
        res.status(204).send();
    } catch (error) {
        next(error);
    }
};
