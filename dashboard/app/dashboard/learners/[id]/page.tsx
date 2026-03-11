'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { api } from '@/lib/api';

export default function LearnerDetailsPage({ params }: { params: { id: string } }) {
    const [learner, setLearner] = useState<any>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        api.get(`/auth/profile/${params.id}`)
            .then(data => {
                setLearner(data);
                setLoading(false);
            })
            .catch(() => setLoading(false));
    }, [params.id]);

    if (loading) return <div className="p-8 text-center text-gray-500">Loading profile...</div>;
    if (!learner) return <div className="p-8 text-center text-red-500">Learner not found</div>;

    return (
        <div className="px-4 sm:px-0">
            <div className="flex items-center space-x-4 mb-8">
                <Link href="/dashboard/learners" className="text-gray-500 hover:text-gray-900 transition flex items-center">
                    <svg className="w-5 h-5 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="15 19l-7-7 7-7" /></svg>
                    Back to List
                </Link>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Left Column: Profile Card */}
                <div className="lg:col-span-1">
                    <div className="bg-white shadow-sm border border-gray-200 rounded-2xl p-8 hover:shadow-md transition">
                        <div className="flex flex-col items-center text-center">
                            <div className="w-24 h-24 bg-blue-100 rounded-full flex items-center justify-center text-blue-600 text-3xl font-bold mb-4 shadow-inner">
                                L
                            </div>
                            <h2 className="text-2xl font-black text-gray-900 tracking-tight">{learner.name}</h2>
                            <p className="text-gray-500 font-medium mb-6">{learner.region}</p>
                            
                            <div className="w-full space-y-4">
                                <div className="flex justify-between text-sm border-b border-gray-50 pb-3">
                                    <span className="text-gray-500">ID</span>
                                    <span className="font-bold text-gray-900">#EFL-{learner.id}</span>
                                </div>
                                <div className="flex justify-between text-sm border-b border-gray-50 pb-3">
                                    <span className="text-gray-500">Language</span>
                                    <span className="font-bold text-gray-900">{learner.language}</span>
                                </div>
                                <div className="flex justify-between text-sm">
                                    <span className="text-gray-500">Last Active</span>
                                    <span className="font-bold text-gray-900">{learner.lastActive}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Right Column: Activity & Progress */}
                <div className="lg:col-span-2 space-y-8">
                    <div className="bg-white shadow-sm border border-gray-200 rounded-2xl p-8">
                        <h3 className="text-lg font-bold text-gray-900 mb-6">Learning Progress</h3>
                        <div className="mb-8">
                            <div className="flex justify-between items-center mb-2">
                                <span className="text-sm font-semibold text-gray-700">Overall Course Completion</span>
                                <span className="text-sm font-black text-blue-600">{learner.progress}%</span>
                            </div>
                            <div className="w-full bg-gray-100 rounded-full h-3 shadow-inner overflow-hidden">
                                <div className="bg-gradient-to-r from-blue-500 to-blue-600 h-3 rounded-full transition-all duration-1000" style={{ width: `${learner.progress}%` }}></div>
                            </div>
                        </div>
                        
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <div className="bg-blue-50/50 p-4 rounded-xl border border-blue-100/50">
                                <p className="text-xs font-bold text-blue-500 uppercase tracking-widest mb-1 text-center">Lessons Finished</p>
                                <p className="text-2xl font-black text-blue-700 text-center">42</p>
                            </div>
                            <div className="bg-green-50/50 p-4 rounded-xl border border-green-100/50">
                                <p className="text-xs font-bold text-green-500 uppercase tracking-widest mb-1 text-center">Avg. Quiz Score</p>
                                <p className="text-2xl font-black text-green-700 text-center">88%</p>
                            </div>
                        </div>
                    </div>

                    <div className="bg-white shadow-sm border border-gray-200 rounded-2xl overflow-hidden">
                        <div className="p-8 border-b border-gray-50">
                            <h3 className="text-lg font-bold text-gray-900">Recent Activity</h3>
                        </div>
                        <div className="divide-y divide-gray-50">
                            {learner.history?.map((item: any, idx: number) => (
                                <div key={idx} className="p-6 hover:bg-gray-50 transition-colors flex justify-between items-center">
                                    <div>
                                        <p className="text-sm font-bold text-gray-900">{item.activity}</p>
                                        <p className="text-xs text-gray-500 mt-1">{item.date}</p>
                                    </div>
                                    {item.score && (
                                        <span className={`px-3 py-1 rounded-full text-xs font-black ${item.score > 80 ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'}`}>
                                            {item.score}%
                                        </span>
                                    )}
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
