const supabase = require('../config/supabase');

/**
 * Analytics Controller for NGO Dashboard
 */
exports.getOverview = async (req, res, next) => {
    try {
        // Total stats
        const { count: totalLearners } = await supabase.from('learners').select('*', { count: 'exact', head: true });
        const { count: activeStudyGroups } = await supabase.from('study_groups').select('*', { count: 'exact', head: true });
        
        // Lessons completed in last 30 days
        const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
        const { count: monthlyLessons } = await supabase
            .from('progress_events')
            .select('*', { count: 'exact', head: true })
            .eq('event_type', 'lesson_completed')
            .gte('server_ts', thirtyDaysAgo);

        // Region distribution
        const { data: regions } = await supabase.rpc('count_learners_by_region');

        res.json({
            stats: {
                totalLearners: totalLearners || 0,
                activeStudyGroups: activeStudyGroups || 0,
                monthlyLessons: monthlyLessons || 0,
                engagementRate: totalLearners ? Math.round((monthlyLessons / totalLearners) * 100) : 0
            },
            regions: regions || []
        });
    } catch (error) {
        next(error);
    }
};
