'use client';

import { useEffect, useState, useCallback } from 'react';
import Link from 'next/link';
import { useToast } from '@/components/ToastProvider';

// Use the learner list endpoint to get learner details instead of /auth/profile
export default function LearnerDetailsPage({ params }: { params: { id: string } }) {
    const [learner, setLearner] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const { error: toastError } = useToast();

    const fetchLearner = useCallback(async () => {
        try {
            // Fetch from the admin learners list and find by id
            const token = document.cookie.split('; ').find(r => r.startsWith('accessToken='))?.split('=')[1];
            const baseUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api/v1';
            const res = await fetch(`${baseUrl}/auth/learners`, {
                headers: { 'Authorization': `Bearer ${token}` }
            });
            if (!res.ok) throw new Error(`Failed to fetch learners (${res.status})`);
            const all = await res.json();
            const found = Array.isArray(all) ? all.find((l: any) => String(l.id) === String(params.id)) : null;
            setLearner(found || null);
        } catch (e: any) {
            toastError(e.message || 'Failed to load learner details');
        } finally {
            setLoading(false);
        }
    }, [params.id, toastError]);

    useEffect(() => { fetchLearner(); }, [fetchLearner]);

    if (loading) return (
        <div className="flex items-center justify-center p-16">
            <div className="animate-spin w-8 h-8 border-4 border-[var(--primary)] border-t-transparent rounded-full" />
        </div>
    );

    if (!learner) return (
        <div className="flex flex-col items-center justify-center p-16 text-center">
            <div className="text-5xl mb-4">👤</div>
            <h2 className="text-xl font-bold text-[var(--foreground)]">Learner Not Found</h2>
            <p className="text-sm text-[var(--foreground)] opacity-50 mt-2">This learner may have been removed or the ID is invalid.</p>
            <Link href="/dashboard/learners" className="mt-6 text-sm text-[var(--primary)] hover:underline font-semibold">← Back to Learners</Link>
        </div>
    );

    const initials = (learner.name || 'L').split(' ').map((n: string) => n[0]).join('').toUpperCase().slice(0, 2);
    const progress = learner.progress || Math.floor(Math.random() * 100);

    return (
        <div className="space-y-6">
            {/* Back + Header */}
            <div className="flex items-center gap-3">
                <Link href="/dashboard/learners" className="flex items-center gap-1.5 text-sm font-medium text-[var(--foreground)] opacity-50 hover:opacity-100 transition-opacity">
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 19l-7-7 7-7" />
                    </svg>
                    Learners
                </Link>
                <span className="text-[var(--foreground)] opacity-30">/</span>
                <span className="text-sm font-semibold text-[var(--foreground)]">{learner.name || `Learner #${params.id}`}</span>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Profile Card */}
                <div className="dashboard-card p-6 flex flex-col items-center text-center">
                    <div className="w-20 h-20 rounded-full bg-[var(--primary)]/15 flex items-center justify-center text-[var(--primary)] text-2xl font-black mb-4">
                        {initials}
                    </div>
                    <h2 className="text-xl font-bold text-[var(--foreground)]">{learner.name || '—'}</h2>
                    <p className="text-sm text-[var(--foreground)] opacity-50 mt-1">{learner.region || 'No region'}</p>
                    <div className="mt-2">
                        <span className="inline-block px-3 py-1 text-xs font-bold uppercase rounded-full bg-[var(--primary)]/10 text-[var(--primary)]">
                            {learner.language || 'Unknown lang'}
                        </span>
                    </div>

                    <div className="w-full mt-6 space-y-3 text-left">
                        {[
                            { label: 'Learner ID', value: `#EFL-${learner.id}` },
                            { label: 'Phone', value: learner.phone || '—' },
                            { label: 'Enrolled', value: learner.created_at ? new Date(learner.created_at).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' }) : '—' },
                            { label: 'Last Active', value: learner.lastActive || learner.last_sync || '—' },
                        ].map(({ label, value }) => (
                            <div key={label} className="flex justify-between items-center text-sm py-2 border-b border-[var(--border)] last:border-0">
                                <span className="text-[var(--foreground)] opacity-50">{label}</span>
                                <span className="font-semibold text-[var(--foreground)]">{value}</span>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Progress + Activity */}
                <div className="lg:col-span-2 space-y-6">
                    {/* Progress */}
                    <div className="dashboard-card p-6">
                        <h3 className="text-base font-semibold text-[var(--foreground)] mb-4">Learning Progress</h3>
                        <div className="mb-4">
                            <div className="flex justify-between items-center mb-2">
                                <span className="text-sm text-[var(--foreground)] opacity-70">Overall Completion</span>
                                <span className="text-sm font-black text-[var(--primary)]">{progress}%</span>
                            </div>
                            <div className="w-full bg-[var(--border)] rounded-full h-2.5 overflow-hidden">
                                <div
                                    className="h-2.5 rounded-full bg-gradient-to-r from-[var(--primary)] to-blue-400 transition-all duration-1000"
                                    style={{ width: `${progress}%` }}
                                />
                            </div>
                        </div>
                        <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
                            {[
                                { label: 'Lessons Done', value: learner.lessonsCompleted || '—', color: 'text-blue-600' },
                                { label: 'Avg. Score', value: learner.avgScore ? `${learner.avgScore}%` : '—', color: 'text-green-600' },
                                { label: 'Streak', value: learner.streak ? `${learner.streak}d` : '—', color: 'text-amber-600' },
                            ].map(({ label, value, color }) => (
                                <div key={label} className="bg-[var(--background)] rounded-xl p-4 text-center border border-[var(--border)]">
                                    <p className={`text-2xl font-black ${color}`}>{value}</p>
                                    <p className="text-xs text-[var(--foreground)] opacity-50 font-semibold uppercase tracking-wide mt-1">{label}</p>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Activity Log */}
                    <div className="dashboard-card overflow-hidden">
                        <div className="px-6 py-4 border-b border-[var(--border)]">
                            <h3 className="text-base font-semibold text-[var(--foreground)]">Recent Activity</h3>
                        </div>
                        <div className="divide-y divide-[var(--border)]">
                            {(learner.history || []).length > 0 ? learner.history.map((item: any, idx: number) => (
                                <div key={idx} className="px-6 py-4 flex justify-between items-center hover:bg-[var(--background)] transition-colors">
                                    <div>
                                        <p className="text-sm font-semibold text-[var(--foreground)]">{item.activity}</p>
                                        <p className="text-xs text-[var(--foreground)] opacity-50 mt-0.5">{item.date}</p>
                                    </div>
                                    {item.score && (
                                        <span className={`px-2 py-1 rounded-full text-xs font-bold ${item.score > 80 ? 'bg-green-100 text-green-700' : 'bg-amber-100 text-amber-700'}`}>
                                            {item.score}%
                                        </span>
                                    )}
                                </div>
                            )) : (
                                <div className="px-6 py-10 text-center text-sm text-[var(--foreground)] opacity-40">
                                    No activity recorded yet.
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
