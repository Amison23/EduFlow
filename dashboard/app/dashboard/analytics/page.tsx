'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

export default function AnalyticsPage() {
    const [data, setData] = useState<any>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        api.getDetailedAnalytics()
            .then(res => {
                setData(res);
                setLoading(false);
            })
            .catch(() => setLoading(false));
    }, []);

    if (loading) return <div className="p-8 text-center text-gray-500">Loading detailed analytics...</div>;

    return (
        <div className="px-4 sm:px-0">
            <h1 className="text-3xl font-bold text-gray-900 tracking-tight mb-6">Learning Analytics</h1>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                {/* Engagement Chart */}
                <div className="bg-white shadow-sm border border-gray-200 rounded-xl p-6 h-96 flex flex-col">
                    <h3 className="text-lg font-bold text-gray-900 mb-4">Learner Engagement (Weekly)</h3>
                    <div className="flex-1 space-y-4">
                        {data?.engagement.map((item: any) => (
                            <div key={item.day} className="space-y-1">
                                <div className="flex justify-between text-xs font-semibold text-gray-500">
                                    <span>{item.day}</span>
                                    <span>{item.count} lessons</span>
                                </div>
                                <div className="w-full bg-gray-100 rounded-full h-2">
                                    <div className="bg-blue-600 h-2 rounded-full" style={{ width: `${Math.min(item.count * 10, 100)}%` }}></div>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>

                {/* Completion Rate */}
                <div className="bg-white shadow-sm border border-gray-200 rounded-xl p-6 h-96 flex flex-col text-center">
                    <h3 className="text-lg font-bold text-gray-900 mb-4">Lesson Completion Rate</h3>
                    <div className="flex-1 flex flex-col justify-center space-y-6">
                        {data?.completions.map((item: any) => (
                            <div key={item.subject}>
                                <div className="text-2xl font-black text-blue-600">{item.count}</div>
                                <div className="text-xs font-bold text-gray-400 uppercase tracking-widest">{item.subject}</div>
                            </div>
                        ))}
                        {data?.completions.length === 0 && <p className="text-gray-400">No data available yet</p>}
                    </div>
                </div>

                {/* Regional Performance */}
                <div className="bg-white shadow-sm border border-gray-200 rounded-xl p-6 lg:col-span-2">
                    <h3 className="text-lg font-bold text-gray-900 mb-4">Region-wise Performance</h3>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                        {data?.regional.map((r: any) => (
                            <div key={r.region} className="p-4 bg-gray-50 rounded-lg border border-gray-100">
                                <div className="text-sm font-bold text-gray-900">{r.region}</div>
                                <div className="text-2xl font-black text-blue-700 my-1">{r.active}</div>
                                <div className="text-xs text-green-600 font-bold">+{r.growth}% growth</div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
}
