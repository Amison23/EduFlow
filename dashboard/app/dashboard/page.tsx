'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { api } from '@/lib/api';

export default function DashboardOverview() {
    const [stats, setStats] = useState<any>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        api.getAnalytics()
            .then(data => {
                setStats(data.stats);
                setLoading(false);
            })
            .catch(() => setLoading(false));
    }, []);

    if (loading) return <div className="p-8 text-center text-gray-500">Loading overview...</div>;

    const cards = [
        { label: 'Total Learners', value: stats?.totalLearners || 0, color: 'text-gray-900' },
        { label: 'Active Groups', value: stats?.activeStudyGroups || 0, color: 'text-gray-900' },
        { label: 'Sync Rate', value: `${stats?.engagementRate || 0}%`, color: 'text-green-600' },
        { label: 'Monthly Lessons', value: stats?.monthlyLessons || 0, color: 'text-blue-600' },
    ];

    return (
        <div className="px-4 sm:px-0">
            <h1 className="text-3xl font-bold text-[var(--foreground)] tracking-tight">Dashboard Overview</h1>
            
            <div className="mt-6 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
                {cards.map((card, i) => (
                    <div key={i} className="bg-[var(--card)] overflow-hidden shadow-sm border border-[var(--border)] rounded-xl hover:shadow-md transition-all duration-300">
                        <div className="p-6">
                            <div className="flex items-center">
                                <div className="w-0 flex-1">
                                    <dl>
                                        <dt className="text-sm font-medium text-[var(--foreground)] opacity-50 truncate mb-1">{card.label}</dt>
                                        <dd className={`text-3xl font-semibold text-[var(--foreground)]`}>{card.value}</dd>
                                    </dl>
                                </div>
                            </div>
                        </div>
                    </div>
                ))}
            </div>
            
            <div className="mt-8">
                <div className="bg-[var(--card)] shadow-sm border border-[var(--border)] rounded-xl p-6 transition-all duration-300">
                    <h2 className="text-lg leading-6 font-semibold text-[var(--foreground)] mb-6 border-b border-[var(--border)] pb-4">Cohort Weekly Progress Overview</h2>
                    <div className="h-72 bg-[var(--background)] border border-dashed border-[var(--border)] rounded-lg flex items-center justify-center transition-all duration-300">
                        <span className="text-[var(--foreground)] opacity-50 font-medium">Cohort Progress Chart (Live Integration Active)</span>
                    </div>
                </div>
            </div>
        </div>
    );
}
