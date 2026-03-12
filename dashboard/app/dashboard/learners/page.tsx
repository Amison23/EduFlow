'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { api } from '@/lib/api';

export default function LearnersPage() {
    const [learners, setLearners] = useState<any[]>([]);
    const [filteredLearners, setFilteredLearners] = useState<any[]>([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');

    useEffect(() => {
        api.getLearners()
            .then(data => {
                setLearners(data);
                setFilteredLearners(data);
                setLoading(false);
            })
            .catch(err => {
                setError(err.message);
                setLoading(false);
            });
    }, []);

    useEffect(() => {
        const lowerCaseSearch = searchTerm.toLowerCase();
        const filtered = learners.filter(learner => 
            (learner.name?.toLowerCase().includes(lowerCaseSearch)) ||
            (learner.region?.toLowerCase().includes(lowerCaseSearch)) ||
            (learner.phone_hash?.toLowerCase().includes(lowerCaseSearch)) ||
            (String(learner.id).toLowerCase().includes(lowerCaseSearch))
        );
        setFilteredLearners(filtered);
    }, [searchTerm, learners]);

    if (loading) return <div className="p-8 text-center text-gray-500">Loading learners...</div>;
    if (error) return <div className="p-8 text-center text-red-500">Error: {error}</div>;

    return (
        <div className="px-4 sm:px-0">
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
                <div>
                    <h1 className="text-3xl font-bold text-[var(--foreground)] tracking-tight">Learners Management</h1>
                    <p className="text-[var(--foreground)] opacity-60 text-sm mt-1">Track participation and performance across the platform</p>
                </div>
                <div className="flex gap-2 w-full md:w-auto">
                    <input 
                        type="text" 
                        placeholder="Search by name, region or ID..."
                        className="bg-[var(--card)] border border-[var(--border)] rounded-lg px-4 py-2 text-sm w-full md:w-64 focus:outline-none focus:ring-2 focus:ring-[var(--primary)]"
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                    />
                    <button className="bg-[var(--primary)] text-white px-4 py-2 rounded-lg font-medium hover:opacity-90 transition shadow-sm whitespace-nowrap">Export</button>
                </div>
            </div>

            <div className="bg-[var(--card)] shadow-sm border border-[var(--border)] rounded-xl overflow-hidden">
                <table className="min-w-full divide-y divide-[var(--border)]">
                    <thead className="bg-[var(--background)]">
                        <tr>
                            <th className="px-6 py-3 text-left text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wider">Learner</th>
                            <th className="px-6 py-3 text-left text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wider">Region</th>
                            <th className="px-6 py-3 text-left text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wider">Language</th>
                            <th className="px-6 py-3 text-center text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wider">Points</th>
                            <th className="px-6 py-3 text-left text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wider">Last Active</th>
                            <th className="px-6 py-3 text-right text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wider">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="bg-[var(--card)] divide-y divide-[var(--border)]">
                        {filteredLearners.length > 0 ? filteredLearners.map((learner) => (
                            <tr key={learner.id} className="hover:bg-[var(--background)] transition-colors">
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <div className="flex flex-col">
                                        <span className="text-sm font-semibold text-[var(--foreground)]">{learner.name || `User ${String(learner.id).substring(0, 5)}`}</span>
                                        <span className="text-xs text-[var(--foreground)] opacity-50 font-mono">#{String(learner.id).substring(0, 8)}</span>
                                    </div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-[var(--foreground)] opacity-80">{learner.region || 'Unknown'}</td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-[var(--foreground)] opacity-80">
                                    <span className="bg-[var(--border)] px-2 py-0.5 rounded text-xs uppercase">{learner.language}</span>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-center text-sm font-bold text-[var(--primary)]">
                                    {learner.points || 0}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-[var(--foreground)] opacity-50 italic">
                                    {learner.last_active_at ? new Date(learner.last_active_at).toLocaleDateString() : 'Never'}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                    <Link href={`/dashboard/learners/${learner.id}`} className="text-[var(--primary)] hover:underline px-3 py-1 rounded-md hover:bg-[var(--background)] transition border border-transparent hover:border-[var(--border)]">Details</Link>
                                </td>
                            </tr>
                        )) : (
                            <tr>
                                <td colSpan={6} className="px-6 py-12 text-center text-[var(--foreground)] opacity-40">No learners found matching your search.</td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            <div className="mt-4 flex justify-between items-center text-sm text-[var(--foreground)] opacity-50">
                <span>Showing {filteredLearners.length} of {learners.length} learners</span>
            </div>
        </div>
    );
}
