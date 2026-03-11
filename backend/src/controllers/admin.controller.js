const supabase = require('../config/supabase');

/**
 * Run raw SQL (Administrative only)
 * WARNING: Extremely powerful, should be restricted to super-admins
 */
exports.executeQuery = async (req, res, next) => {
    try {
        const { query } = req.body;
        
        if (!query) {
            return res.status(400).json({ error: 'Query is required' });
        }

        // We use supabase.rpc to execute raw SQL if a function like 'exec_sql' exists,
        // otherwise we use the direct client for table operations.
        // For a true "Database Explorer", we'll implement a restricted proxy.
        
        // Safety check: Prevent destructive operations in this demo endpoint
        const restrictedKeywords = ['DROP', 'TRUNCATE', 'DELETE', 'UPDATE'];
        const isRestricted = restrictedKeywords.some(kw => query.toUpperCase().includes(kw));
        
        if (isRestricted) {
            return res.status(403).json({ error: 'Destructive queries are not allowed via this UI.' });
        }

        // For discovery: Get list of tables
        if (query.toUpperCase() === 'LIST_TABLES') {
            const { data, error } = await supabase.rpc('get_table_names'); // Assuming this RPC exists
            if (error) {
                // Fallback: Just return known tables
                return res.json({ tables: ['learners', 'lesson_packs', 'lessons', 'study_groups', 'progress_events'] });
            }
            return res.json({ tables: data });
        }

        // Generic SELECT proxy
        const tableMatch = query.match(/FROM\s+([a-zA-Z0-9_]+)/i);
        if (tableMatch) {
            const tableName = tableMatch[1];
            const { data, error } = await supabase.from(tableName).select('*').limit(50);
            if (error) throw error;
            return res.json({ results: data });
        }

        res.status(400).json({ error: 'Invalid or unsupported query format' });
    } catch (error) {
        next(error);
    }
};
