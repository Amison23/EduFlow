const supabase = require('../config/supabase');

/**
 * Get organization settings by key
 * Defaults to 'global_config'
 */
exports.getSettings = async (req, res, next) => {
    try {
        const key = req.query.key || 'global_config';
        const { data, error } = await supabase
            .from('organization_settings')
            .select('*')
            .eq('key', key)
            .single();

        if (error) {
            if (error.code === 'PGRST116') {
                return res.json({ key, value: {} });
            }
            throw error;
        }
        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Update organization settings
 */
exports.updateSettings = async (req, res, next) => {
    try {
        const { key, value } = req.body;

        if (!key || !value) {
            return res.status(400).json({ error: 'Key and Value are required' });
        }

        const { data, error } = await supabase
            .from('organization_settings')
            .upsert({ key, value, updated_at: new Date() }, { onConflict: 'key' })
            .select()
            .single();

        if (error) throw error;
        res.json(data);
    } catch (error) {
        next(error);
    }
};
