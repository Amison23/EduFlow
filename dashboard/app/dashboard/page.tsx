'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { api } from '@/lib/api';
import { useToast } from '@/components/ToastProvider';
import { 
    AreaChart, 
    Area, 
    XAxis, 
    YAxis, 
    CartesianGrid, 
    Tooltip, 
    ResponsiveContainer 
} from 'recharts';
import { 
    Users, 
    GraduationCap, 
    BarChart3, 
    Library, 
    UserPlus, 
    Package, 
    Database,
    Activity
} from 'lucide-react';

const STAT_CONFIG = [
    { icon: GraduationCap, color: 'text-blue-600 bg-blue-500/10 dark:bg-blue-500/20' },
    { icon: Users, color: 'text-green-600 bg-green-500/10 dark:bg-green-500/20' },
    { icon: Activity, color: 'text-amber-600 bg-amber-500/10 dark:bg-amber-500/20' },
    { icon: Library, color: 'text-purple-600 bg-purple-500/10 dark:bg-purple-500/20' },
];

export default function DashboardOverview() {
    const [stats, setStats] = useState<any>(null);
    const [trends, setTrends] = useState<any[]>([]);
    const [admin, setAdmin] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const { error: toastError } = useToast();

    useEffect(() => {
        try {
            const s = localStorage.getItem('adminUser');
            if (s) setAdmin(JSON.parse(s));
        } catch {}

        Promise.all([
            api.getAnalytics(),
            api.getDetailedAnalytics()
        ])
            .then(([analyticsData, detailedData]) => {
                setStats(analyticsData?.stats || analyticsData);
                setTrends(detailedData?.trends || []);
            })
            .catch(e => toastError(e.message || 'Failed to load dashboard data'))
            .finally(() => setLoading(false));
    }, [toastError]);

    const greeting = () => {
        const h = new Date().getHours();
        if (h < 12) return 'Good morning';
        if (h < 17) return 'Good afternoon';
        return 'Good evening';
    };

    const cards = [
        { label: 'Total Learners', value: stats?.totalLearners ?? '—', ...STAT_CONFIG[0] },
        { label: 'Active Groups', value: stats?.activeStudyGroups ?? '—', ...STAT_CONFIG[1] },
        { label: 'Sync Rate', value: stats ? `${stats.engagementRate ?? 0}%` : '—', ...STAT_CONFIG[2] },
        { label: 'Lesson Packs', value: stats?.totalPacks ?? stats?.monthlyLessons ?? '—', ...STAT_CONFIG[3] },
    ];

    const quickActions = [
        { label: 'Add Learner', href: '/dashboard/learners', icon: UserPlus, color: 'text-blue-500' },
        { label: 'View Analytics', href: '/dashboard/analytics', icon: BarChart3, color: 'text-emerald-500' },
        { label: 'Manage Packs', href: '/dashboard/packs', icon: Package, color: 'text-amber-500' },
        { label: 'Data Manager', href: '/dashboard/database', icon: Database, color: 'text-purple-500' },
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
                            <div className={`w-10 h-10 rounded-xl flex items-center justify-center mb-3 ${card.color}`}>
                                <card.icon size={20} />
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
                            <span className={`mb-2 group-hover:scale-110 transition-transform ${action.color}`}>
                                <action.icon size={24} />
                            </span>
                            <span className="text-xs font-semibold text-[var(--foreground)] group-hover:text-[var(--primary)] transition-colors">{action.label}</span>
                        </Link>
                    ))}
                </div>
            </div>

            {/* Performance Chart */}
            <div className="dashboard-card p-6 overflow-hidden">
                <div className="flex justify-between items-center mb-6">
                    <div>
                        <h2 className="text-base font-bold text-[var(--foreground)]">Cohort Performance Trends</h2>
                        <p className="text-xs text-[var(--foreground)] opacity-40">Monthly growth and completion rates</p>
                    </div>
                    <span className="text-[10px] uppercase tracking-tighter font-bold text-[var(--primary)] bg-[var(--primary)]/10 px-2 py-1 rounded-md border border-[var(--primary)]/20">Live Analysis</span>
                </div>
                
                <div className="h-64 w-full">
                    {loading ? (
                        <div className="w-full h-full bg-[var(--border)] opacity-10 animate-pulse rounded-lg" />
                    ) : (
                        <ResponsiveContainer width="100%" height="100%">
                            <AreaChart data={trends} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                                <defs>
                                    <linearGradient id="colorLearners" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor="var(--primary)" stopOpacity={0.3}/>
                                        <stop offset="95%" stopColor="var(--primary)" stopOpacity={0}/>
                                    </linearGradient>
                                </defs>
                                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="var(--border)" opacity={0.5} />
                                <XAxis 
                                    dataKey="name" 
                                    axisLine={false} 
                                    tickLine={false} 
                                    tick={{ fill: 'var(--foreground)', opacity: 0.5, fontSize: 11 }}
                                    dy={10}
                                />
                                <YAxis 
                                    axisLine={false} 
                                    tickLine={false} 
                                    tick={{ fill: 'var(--foreground)', opacity: 0.5, fontSize: 11 }}
                                />
                                <Tooltip 
                                    contentStyle={{ 
                                        backgroundColor: 'var(--card)', 
                                        borderColor: 'var(--border)',
                                        borderRadius: '12px',
                                        fontSize: '12px',
                                        fontWeight: 'bold',
                                        color: 'var(--foreground)'
                                    }}
                                />
                                <Area 
                                    type="monotone" 
                                    dataKey="learners" 
                                    stroke="var(--primary)" 
                                    strokeWidth={3}
                                    fillOpacity={1} 
                                    fill="url(#colorLearners)" 
                                />
                            </AreaChart>
                        </ResponsiveContainer>
                    )}
                </div>
            </div>
        </div>
    );
}
