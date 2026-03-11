const supabase = require('../config/supabase');

/**
 * Service for community-related logic (Groups, Peers)
 */
class CommunityService {
    /**
     * Find potential study peers for a learner
     * Matches by region first, then language
     */
    async findPeers(learnerId) {
        const { data: me, error: meError } = await supabase
            .from('learners')
            .select('region, language')
            .eq('id', learnerId)
            .single();

        if (meError || !me) throw new Error('Learner not found');

        // Logic: Same region AND Same language
        let { data, error } = await supabase
            .from('learners')
            .select('id, region, language')
            .neq('id', learnerId)
            .eq('region', me.region)
            .eq('language', me.language)
            .limit(5);

        // Fallback: Just same region
        if (!data || data.length === 0) {
            const { data: fallbackData } = await supabase
                .from('learners')
                .select('id, region, language')
                .neq('id', learnerId)
                .eq('region', me.region)
                .limit(5);
            data = fallbackData;
        }

        return data || [];
    }

    /**
     * Get group details with membership count
     */
    async getGroupStats(groupId) {
        const { data, error } = await supabase
            .from('study_groups')
            .select('*, group_members(count)')
            .eq('id', groupId)
            .single();
        
        if (error) throw error;
        return data;
    }
}

module.exports = new CommunityService();
