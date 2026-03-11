'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

export default function StudyGroupsPage() {
    const [groups, setGroups] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        api.get('/community/groups')
            .then(data => {
                setGroups(data);
                setLoading(false);
            })
            .catch(() => setLoading(false));
    }, []);

    return (
        <div className="px-4 sm:px-0">
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-3xl font-bold text-gray-900 tracking-tight">Study Groups</h1>
                <div className="flex space-x-2">
                    <button className="bg-white border border-gray-200 text-gray-700 px-4 py-2 rounded-lg font-medium hover:bg-gray-50 transition shadow-sm">Map View</button>
                    <button className="bg-blue-600 text-white px-4 py-2 rounded-lg font-medium hover:bg-blue-700 transition shadow-sm">Export Report</button>
                </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {loading ? (
                    <div className="col-span-full py-12 text-center text-gray-500">Loading study groups...</div>
                ) : groups.length === 0 ? (
                    <div className="col-span-full py-12 text-center text-gray-500 bg-white rounded-xl border border-dashed border-gray-300">
                        No active study groups found.
                    </div>
                ) : (
                    groups.map((group) => (
                        <div key={group.id} className="bg-white shadow-sm border border-gray-200 rounded-xl p-6 hover:shadow-md transition">
                            <h3 className="text-lg font-bold text-gray-900 mb-2">{group.name || `Cohort #${String(group.id).substring(0, 4)}`}</h3>
                            <div className="flex items-center text-sm text-gray-500 mb-4">
                                <span className="bg-green-50 text-green-700 px-2 py-0.5 rounded text-xs font-bold mr-2">Active</span>
                                <span>{group.region || 'Offline Group'}</span>
                            </div>
                            <div className="flex justify-between items-center pt-4 border-t border-gray-50">
                                <div className="flex -space-x-2">
                                    {[1,2,3].map(i => (
                                        <div key={i} className="w-8 h-8 rounded-full bg-blue-100 border-2 border-white flex items-center justify-center text-[10px] font-bold text-blue-600">L</div>
                                    ))}
                                    <div className="w-8 h-8 rounded-full bg-gray-100 border-2 border-white flex items-center justify-center text-[10px] font-bold text-gray-400">+5</div>
                                </div>
                                <button className="text-blue-600 text-sm font-semibold hover:underline">Manage Group</button>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
}
