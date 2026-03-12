'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { api } from '@/lib/api';
import { useToast } from '@/components/ToastProvider';

const STAT_ICONS = ['🎓', '👥', '📊', '📚'];
const STAT_COLORS = [
    'bg-blue-500/10 text-blue-600',
    'bg-green-500/10 text-green-600',
    'bg-amber-500/10 text-amber-600',
    'bg-purple-500/10 text-purple-600',
];

export default function DashboardOverview() {
    const [stats, setStats] = useState<any>(null);
    const [admin, setAdmin] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const { error: toastError } = useToast();

    useEffect(() => {
        try {
            const s = localStorage.getItem('adminUser');
            if (s) setAdmin(JSON.parse(s));
        } catch {}

        api.getAnalytics()
            .then(data => { setStats(data?.stats || data); })
            .catch(e => toastError(e.message || 'Failed to load analytics'))
            .finally(() => setLoading(false));
    }, [toastError]);

    const greeting = () => {
        const h = new Date().getHours();
        if (h < 12) return 'Good morning';
        if (h < 17) return 'Good afternoon';
        return 'Good evening';
    };

    const cards = [
        { label: 'Total Learners', value: stats?.totalLearners ?? '—', icon: '🎓', color: 'blue' },
        { label: 'Active Groups', value: stats?.activeStudyGroups ?? '—', icon: '👥', color: 'green' },
        { label: 'Sync Rate', value: stats ? `${stats.engagementRate ?? 0}%` : '—', icon: '📡', color: 'amber' },
        { label: 'Lesson Packs', value: stats?.totalPacks ?? stats?.monthlyLessons ?? '—', icon: '📚', color: 'purple' },
    ];

    const colorMap: Record<string, string> = {
        blue: 'bg-blue-500/10 text-blue-600 dark:bg-blue-500/20',
        green: 'bg-green-500/10 text-green-600 dark:bg-green-500/20',
        amber: 'bg-amber-500/10 text-amber-600 dark:bg-amber-500/20',
        purple: 'bg-purple-500/10 text-purple-600 dark:bg-purple-500/20',
    };

    const quickActions = [
        { label: 'Add Learner', href: '/dashboard/learners', icon: '➕' },
        { label: 'View Analytics', href: '/dashboard/analytics', icon: '📊' },
        { label: 'Manage Packs', href: '/dashboard/packs', icon: '📦' },
        { label: 'Data Manager', href: '/dashboard/database', icon: '🗄️' },
    ];

    return (
        <div className="space-y-8">
            {/* Greeting */}
            <div>
                <h1 className="text-2xl font-bold text-[var(--foreground)]">
                    {greeting()}, {admin?.name?.split(' ')[0] || 'Admin'} 👋
                </h1>
                <p className="text-sm text-[var(--foreground)] opacity-50 mt-1">
                    Here&apos;s what&apos;s happening on the EduFlow platform today.
                </p>
            </div>

            {/* Stats Grid */}
            {loading ? (
                <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                    {[...Array(4)].map((_, i) => (
                        <div key={i} className="dashboard-card p-6 animate-pulse">
                            <div className="w-10 h-10 bg-[var(--border)] rounded-xl mb-3" />
                            <div className="h-8 bg-[var(--border)] rounded w-16 mb-2" />
                            <div className="h-3 bg-[var(--border)] rounded w-24" />
                        </div>
                    ))}
                </div>
            ) : (
                <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                    {cards.map((card, i) => (
                        <div key={i} className="dashboard-card p-6 hover:shadow-md transition-shadow">
                            <div className={`w-10 h-10 rounded-xl flex items-center justify-center text-xl mb-3 ${colorMap[card.color]}`}>
                                {card.icon}
                            </div>
                            <p className="text-2xl font-black text-[var(--foreground)]">{card.value}</p>
                            <p className="text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wide mt-1">{card.label}</p>
                        </div>
                    ))}
                </div>
            )}

            {/* Quick Actions */}
            <div>
                <h2 className="text-sm font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wide mb-3">Quick Actions</h2>
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                    {quickActions.map(action => (
                        <Link key={action.href} href={action.href}
                            className="dashboard-card p-4 flex flex-col items-center text-center hover:shadow-md transition-all hover:border-[var(--primary)] group">
                            <span className="text-2xl mb-2 group-hover:scale-110 transition-transform">{action.icon}</span>
                            <span className="text-xs font-semibold text-[var(--foreground)] group-hover:text-[var(--primary)] transition-colors">{action.label}</span>
                        </Link>
                    ))}
                </div>
            </div>

            {/* Chart placeholder */}
            <div className="dashboard-card p-6">
                <div className="flex justify-between items-center mb-4">
                    <h2 className="text-base font-semibold text-[var(--foreground)]">Cohort Weekly Progress</h2>
                    <span className="text-xs text-[var(--primary)] font-semibold bg-[var(--primary)]/10 px-2 py-1 rounded-full">Live</span>
                </div>
                <div className="h-48 border border-dashed border-[var(--border)] rounded-xl flex flex-col items-center justify-center gap-2">
                    <span className="text-3xl">📈</span>
                    <p className="text-sm text-[var(--foreground)] opacity-40 font-medium">Chart integration active — connect a visualization library to display live data.</p>
                </div>
            </div>
        </div>
    );
}
