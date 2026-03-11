const supabase = require('../config/supabase');
const communityService = require('../services/community.service');

/**
 * Get study groups
 */
exports.getStudyGroups = async (req, res, next) => {
    try {
        const { subject } = req.query;
        let query = supabase.from('study_groups').select('*, group_members(count)');

        if (subject) query = query.eq('subject', subject);

        const { data, error } = await query;

        if (error) throw error;
        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Create a study group
 */
exports.createStudyGroup = async (req, res, next) => {
    try {
        const { name, subject, max_members, is_public } = req.body;
        const { learnerId } = req.user;

        const { data, error } = await supabase
            .from('study_groups')
            .insert([{
                name,
                subject,
                creator_id: learnerId,
                max_members: max_members || 20,
                is_public: is_public !== undefined ? is_public : true
            }])
            .select()
            .single();

        if (error) throw error;

        // Automatically join the group as creator
        await supabase
            .from('group_members')
            .insert([{
                group_id: data.id,
                learner_id: learnerId
            }]);

        res.status(201).json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Get study group details
 */
exports.getStudyGroupDetails = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from('study_groups')
            .select('*, group_members(*, learners(id, language))')
            .eq('id', id)
            .single();

        if (error) throw error;
        if (!data) return res.status(404).json({ error: 'Group not found' });

        res.json(data);
    } catch (error) {
        next(error);
    }
};

/**
 * Join a study group
 */
exports.joinStudyGroup = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { learnerId } = req.user;

        // Check if group is full or already joined
        const { data: group, error: groupError } = await supabase
            .from('study_groups')
            .select('max_members, group_members(count)')
            .eq('id', id)
            .single();

        if (groupError || !group) return res.status(404).json({ error: 'Group not found' });
        
        if (group.group_members[0].count >= group.max_members) {
            return res.status(400).json({ error: 'Group is full' });
        }

        const { error } = await supabase
            .from('group_members')
            .insert([{
                group_id: id,
                learner_id: learnerId
            }]);

        if (error) {
            if (error.code === '23505') return res.status(400).json({ error: 'Already a member' });
            throw error;
        }

        res.json({ success: true });
    } catch (error) {
        next(error);
    }
};

/**
 * Find study peers
 */
exports.findPeers = async (req, res, next) => {
    try {
        const { learnerId } = req.user;
        const peers = await communityService.findPeers(learnerId);
        res.json(peers);
    } catch (error) {
        next(error);
    }
};
