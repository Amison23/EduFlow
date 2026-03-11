'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

export default function PacksPage() {
    const [packs, setPacks] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        api.get('/lessons/packs')
            .then(data => {
                setPacks(data);
                setLoading(false);
            })
            .catch(() => setLoading(false));
    }, []);

    return (
        <div className="px-4 sm:px-0">
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-3xl font-bold text-gray-900 tracking-tight">Lesson Packs</h1>
                <button className="bg-blue-600 text-white px-4 py-2 rounded-lg font-medium hover:bg-blue-700 transition shadow-sm">Upload New Pack</button>
            </div>

            {loading ? (
                 <div className="py-12 text-center text-gray-500">Loading packs...</div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {packs.map((pack) => (
                        <div key={pack.id} className="bg-white shadow-sm border border-gray-200 rounded-xl p-6 hover:shadow-md transition group">
                            <div className="flex justify-between items-start mb-4">
                                <div>
                                    <h3 className="text-lg font-bold text-gray-900">{pack.subject}</h3>
                                    <p className="text-sm text-gray-500">Level {pack.level} • {pack.language}</p>
                                </div>
                                <span className="bg-blue-50 text-blue-600 text-xs font-bold px-2 py-1 rounded uppercase tracking-wider">LIVE</span>
                            </div>
                            <div className="mt-6 flex justify-between items-center">
                                <span className="text-xs text-gray-400">ID: {String(pack.id).substring(0, 8)}</span>
                                <div className="flex space-x-2">
                                    <button className="text-sm font-medium text-gray-600 hover:text-gray-900 px-3 py-1 rounded-md transition border border-gray-200">Edit</button>
                                    <button className="text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 px-3 py-1 rounded-md transition shadow-sm">Manage</button>
                                </div>
                            </div>
                        </div>
                    ))}
                    {packs.length === 0 && (
                         <div className="col-span-full py-12 text-center text-gray-500 bg-white rounded-xl border border-dashed border-gray-300">
                         No lesson packs available. Click "Upload New Pack" to get started.
                     </div>
                    )}
                </div>
            )}
        </div>
    );
}
