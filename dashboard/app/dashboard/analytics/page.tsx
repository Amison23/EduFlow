'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';
import { useToast } from '@/components/ToastProvider';

export default function AnalyticsPage() {
    const [data, setData] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const { error: toastError } = useToast();

    useEffect(() => {
        api.getDetailedAnalytics()
            .then(res => setData(res))
            .catch(e => toastError(e.message || 'Failed to load analytics'))
            .finally(() => setLoading(false));
    }, [toastError]);

    const Spinner = () => (
        <div className="flex justify-center items-center py-20">
            <div className="animate-spin w-8 h-8 border-4 border-[var(--primary)] border-t-transparent rounded-full" />
        </div>
    );

    const maxCount = Math.max(...(data?.engagement?.map((e: any) => e.count) || [1]));

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-2xl font-bold text-[var(--foreground)]">Learning Analytics</h1>
                <p className="text-sm text-[var(--foreground)] opacity-50 mt-1">Platform-wide engagement and performance metrics.</p>
            </div>

            {loading ? <Spinner /> : !data ? (
                <div className="dashboard-card p-16 text-center">
                    <div className="text-4xl mb-3">📊</div>
                    <p className="text-sm text-[var(--foreground)] opacity-50">No analytics data available yet.</p>
                </div>
            ) : (
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    {/* Engagement Bar Chart */}
                    <div className="dashboard-card p-6">
                        <h2 className="text-base font-semibold text-[var(--foreground)] mb-5">Learner Engagement (Weekly)</h2>
                        <div className="space-y-3">
                            {(data?.engagement || []).map((item: any) => (
                                <div key={item.day} className="flex items-center gap-3">
                                    <span className="text-xs font-semibold text-[var(--foreground)] opacity-50 w-8 shrink-0">{item.day?.slice(0, 3)}</span>
                                    <div className="flex-1 bg-[var(--border)] rounded-full h-2.5 overflow-hidden">
                                        <div
                                            className="h-2.5 rounded-full bg-gradient-to-r from-[var(--primary)] to-blue-400 transition-all duration-700"
                                            style={{ width: `${maxCount > 0 ? (item.count / maxCount) * 100 : 0}%` }}
                                        />
                                    </div>
                                    <span className="text-xs font-bold text-[var(--foreground)] w-10 text-right shrink-0">{item.count}</span>
                                </div>
                            ))}
                            {!(data?.engagement?.length) && (
                                <p className="text-sm text-[var(--foreground)] opacity-40 text-center py-4">No engagement data</p>
                            )}
                        </div>
                    </div>

                    {/* Completions */}
                    <div className="dashboard-card p-6">
                        <h2 className="text-base font-semibold text-[var(--foreground)] mb-5">Lesson Completions by Subject</h2>
                        <div className="grid grid-cols-2 gap-3">
                            {(data?.completions || []).map((item: any, i: number) => {
                                const colors = ['text-blue-600 bg-blue-500/10', 'text-green-600 bg-green-500/10', 'text-amber-600 bg-amber-500/10', 'text-purple-600 bg-purple-500/10'];
                                return (
                                    <div key={item.subject} className={`rounded-xl p-4 text-center ${colors[i % colors.length]}`}>
                                        <p className="text-3xl font-black">{item.count}</p>
                                        <p className="text-xs font-bold uppercase tracking-wide opacity-70 mt-1">{item.subject}</p>
                                    </div>
                                );
                            })}
                            {!(data?.completions?.length) && (
                                <p className="col-span-2 text-sm text-[var(--foreground)] opacity-40 text-center py-4">No completion data</p>
                            )}
                        </div>
                    </div>

                    {/* Regional Breakdown */}
                    <div className="dashboard-card p-6 lg:col-span-2">
                        <h2 className="text-base font-semibold text-[var(--foreground)] mb-5">Region-wise Performance</h2>
                        {!(data?.regional?.length) ? (
                            <p className="text-sm text-[var(--foreground)] opacity-40 text-center py-4">No regional data</p>
                        ) : (
                            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
                                {data.regional.map((r: any) => (
                                    <div key={r.region} className="p-4 rounded-xl border border-[var(--border)] bg-[var(--background)] hover:border-[var(--primary)] transition-colors">
                                        <p className="text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wide">{r.region}</p>
                                        <p className="text-3xl font-black text-[var(--foreground)] my-1">{r.active}</p>
                                        <p className="text-xs font-semibold text-emerald-600">↑ {r.growth}% growth</p>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            )}
        </div>
    );
}
