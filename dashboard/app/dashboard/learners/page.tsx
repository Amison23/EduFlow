'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { api } from '@/lib/api';

export default function LearnersPage() {
    const [learners, setLearners] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');

    useEffect(() => {
        api.getLearners()
            .then(data => {
                setLearners(data);
                setLoading(false);
            })
            .catch(err => {
                setError(err.message);
                setLoading(false);
            });
    }, []);

    if (loading) return <div className="p-8 text-center text-gray-500">Loading learners...</div>;
    if (error) return <div className="p-8 text-center text-red-500">Error: {error}</div>;

    return (
        <div className="px-4 sm:px-0">
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-3xl font-bold text-[var(--foreground)] tracking-tight">Learners Management</h1>
                <button className="bg-[var(--primary)] text-white px-4 py-2 rounded-lg font-medium hover:opacity-90 transition shadow-sm">Export Data</button>
            </div>

            <div className="bg-[var(--card)] shadow-sm border border-[var(--border)] rounded-xl overflow-hidden">
                <table className="min-w-full divide-y divide-[var(--border)]">
                    <thead className="bg-[var(--background)]">
                        <tr>
                            <th className="px-6 py-3 text-left text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wider">Learner ID</th>
                            <th className="px-6 py-3 text-left text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wider">Region</th>
                            <th className="px-6 py-3 text-left text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wider">Language</th>
                            <th className="px-6 py-3 text-left text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wider">Created At</th>
                            <th className="px-6 py-3 text-right text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wider">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="bg-[var(--card)] divide-y divide-[var(--border)]">
                        {learners.map((learner) => (
                            <tr key={learner.id} className="hover:bg-[var(--background)] transition-colors">
                                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-[var(--primary)]">#{String(learner.id).substring(0, 8)}</td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-[var(--foreground)] opacity-80">{learner.region || 'Unknown'}</td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-[var(--foreground)] opacity-80">{learner.language}</td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-[var(--foreground)] opacity-50">{new Date(learner.created_at).toLocaleDateString()}</td>
                                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                    <Link href={`/dashboard/learners/${learner.id}`} className="text-[var(--primary)] hover:underline px-3 py-1 rounded-md hover:bg-[var(--background)] transition">View Details</Link>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
