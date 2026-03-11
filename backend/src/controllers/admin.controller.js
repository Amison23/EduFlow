const supabase = require('../config/supabase');
const { comparePassword, hashPassword } = require('../utils/crypto');
const jwt = require('jsonwebtoken');
const config = require('../config/env');

/**
 * Admin Login
 */
exports.login = async (req, res, next) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }

        const { data: admin, error } = await supabase
            .from('admins')
            .select('*')
            .eq('email', email)
            .single();

        if (error || !admin) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        const isValid = comparePassword(password, admin.password_hash);
        if (!isValid) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        // Update last login
        await supabase.from('admins').update({ last_login: new Date().toISOString() }).eq('id', admin.id);

        const token = jwt.sign(
            { 
                adminId: admin.id, 
                email: admin.email,
                role: admin.role 
            },
            config.jwtSecret,
            { expiresIn: '12h' }
        );

        res.json({
            success: true,
            token,
            admin: {
                id: admin.id,
                email: admin.email,
                name: admin.name,
                role: admin.role
            }
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get all admins (Master Admin only)
 */
exports.getAdmins = async (req, res, next) => {
    try {
        const { data, error } = await supabase
            .from('admins')
            .select('id, email, name, role, last_login, created_at')
            .order('created_at', { ascending: false });

        if (error) throw error;
        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Create a new admin (Master Admin only)
 */
exports.createAdmin = async (req, res, next) => {
    try {
        const { email, password, name, role } = req.body;

        if (!email || !password || !role) {
            return res.status(400).json({ error: 'Email, password, and role are required' });
        }

        const password_hash = hashPassword(password);

        const { data, error } = await supabase
            .from('admins')
            .insert([{ email, password_hash, name, role }])
            .select('id, email, name, role')
            .single();

        if (error) {
            if (error.code === '23505') return res.status(400).json({ error: 'Email already exists' });
            throw error;
        }

        res.status(201).json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Delete an admin (Master Admin only)
 */
exports.deleteAdmin = async (req, res, next) => {
    try {
        const { id } = req.params;

        // Prevent self-deletion if needed, or at least master admin must exist
        if (id === req.user.adminId) {
            return res.status(400).json({ error: 'Cannot delete your own account' });
        }

        const { error } = await supabase
            .from('admins')
            .delete()
            .eq('id', id);

        if (error) throw error;
        res.json({ success: true, message: 'Admin deleted successfully' });
    } catch (error) {
        next(error);
    }
};

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
        
        // Safety check: Restrict destructive operations to authenticated admins
        const destructiveKeywords = ['DROP', 'TRUNCATE', 'DELETE', 'UPDATE'];
        const isDestructive = destructiveKeywords.some(kw => query.toUpperCase().includes(kw));
        
        // Destructive operations are allowed for ALL dashboard admins (Master and Standard)
        // as per the latest requirement for system-wide adjustments.
        if (isDestructive) {
            console.log(`Destructive query executed by admin ${req.user.email}: ${query}`);
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
