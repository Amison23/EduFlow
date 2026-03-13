'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';
import Link from 'next/link';

export default function PacksPage() {
    const [packs, setPacks] = useState<any[]>([]);
    const [languages, setLanguages] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [selectedLanguage, setSelectedLanguage] = useState('all');
    const [showUploadModal, setShowUploadModal] = useState(false);
    const [newPack, setNewPack] = useState({
        subject: '',
        level: '1',
        language: 'en',
        storage_path: 'https://example.com/pack.zip' // Placeholder
    });
    const [uploading, setUploading] = useState(false);

    useEffect(() => {
        Promise.all([
            api.get('/lessons/packs'),
            api.get('/languages')
        ]).then(([packsData, langsData]) => {
            setPacks(packsData);
            setLanguages(langsData.filter((l: any) => l.is_active));
            setLoading(false);
        }).catch(() => setLoading(false));
    }, []);

    const handleUpload = async (e: React.FormEvent) => {
        e.preventDefault();
        setUploading(true);
        try {
            const added = await api.post('/lessons/packs', newPack);
            setPacks([added, ...packs]);
            setShowUploadModal(false);
            setNewPack({ subject: '', level: '1', language: 'en', storage_path: 'https://example.com/pack.zip' });
        } catch (err: any) {
            alert(err.message || 'Failed to upload pack');
        } finally {
            setUploading(false);
        }
    };

    const filteredPacks = selectedLanguage === 'all' 
        ? packs 
        : packs.filter(p => p.language === selectedLanguage);

    return (
        <div className="px-4 sm:px-0">
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-3xl font-bold text-gray-900 tracking-tight">Lesson Packs</h1>
                <div className="flex items-center space-x-4">
                    <select 
                        value={selectedLanguage}
                        onChange={(e) => setSelectedLanguage(e.target.value)}
                        className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition bg-white text-sm"
                    >
                        <option value="all">All Languages</option>
                        {languages.map(lang => (
                            <option key={lang.id} value={lang.code}>{lang.name}</option>
                        ))}
                    </select>
                    <button 
                        onClick={() => setShowUploadModal(true)}
                        className="bg-blue-600 text-white px-4 py-2 rounded-lg font-medium hover:bg-blue-700 transition shadow-sm"
                    >
                        Upload New Pack
                    </button>
                </div>
            </div>

            {loading ? (
                 <div className="py-12 text-center text-gray-500">Loading packs...</div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {filteredPacks.map((pack) => (
                        <div key={pack.id} className="bg-white shadow-sm border border-gray-200 rounded-xl p-6 hover:shadow-md transition group">
                            <div className="flex justify-between items-start mb-4">
                                <div>
                                    <h3 className="text-lg font-bold text-gray-900">{pack.subject}</h3>
                                    <p className="text-sm text-gray-500">Level {pack.level} • {pack.language.toUpperCase()}</p>
                                </div>
                                <span className="bg-blue-50 text-blue-600 text-xs font-bold px-2 py-1 rounded uppercase tracking-wider">LIVE</span>
                            </div>
                            <div className="mt-6 flex justify-between items-center">
                                <span className="text-xs text-gray-400">ID: {String(pack.id).substring(0, 8)}</span>
                                <div className="flex space-x-2">
                                    <button className="text-sm font-medium text-gray-600 hover:text-gray-900 px-3 py-1 rounded-md transition border border-gray-200">Edit</button>
                                    <Link 
                                        href={`/dashboard/packs/${pack.id}`}
                                        className="text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 px-3 py-1 rounded-md transition shadow-sm"
                                    >
                                        Manage
                                    </Link>
                                </div>
                            </div>
                        </div>
                    ))}
                    {packs.length === 0 && (
                         <div className="col-span-full py-12 text-center text-gray-500 bg-white rounded-xl border border-dashed border-gray-300">
                         No lesson packs available. Click &quot;Upload New Pack&quot; to get started.
                     </div>
                    )}
                </div>
            )}

            {/* Upload Modal */}
            {showUploadModal && (
                <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50 animate-in fade-in duration-200">
                    <div className="bg-white rounded-2xl shadow-xl max-w-md w-full overflow-hidden">
                        <div className="p-6 border-b border-gray-100">
                            <h2 className="text-xl font-bold text-gray-900">Upload New Lesson Pack</h2>
                            <p className="text-xs text-gray-500 mt-1">Add curated educational content for a specific group.</p>
                        </div>
                        <form onSubmit={handleUpload} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-1">Subject</label>
                                <input 
                                    type="text" 
                                    required
                                    value={newPack.subject}
                                    onChange={(e) => setNewPack({...newPack, subject: e.target.value})}
                                    placeholder="e.g. Mathematics"
                                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-semibold text-gray-700 mb-1">Level</label>
                                    <select 
                                        value={newPack.level}
                                        onChange={(e) => setNewPack({...newPack, level: e.target.value})}
                                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"
                                    >
                                        {[1, 2, 3, 4, 5, 6].map(l => (
                                            <option key={l} value={l}>Level {l}</option>
                                        ))}
                                    </select>
                                </div>
                                <div>
                                    <label className="block text-sm font-semibold text-gray-700 mb-1">Language</label>
                                    <select 
                                        value={newPack.language}
                                        onChange={(e) => setNewPack({...newPack, language: e.target.value})}
                                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"
                                    >
                                        {languages.map(lang => (
                                            <option key={lang.id} value={lang.code}>{lang.name}</option>
                                        ))}
                                    </select>
                                </div>
                            </div>
                            <div className="pt-4 flex justify-end space-x-3">
                                <button 
                                    type="button" 
                                    onClick={() => setShowUploadModal(false)}
                                    className="px-4 py-2 text-sm font-bold text-gray-600 hover:text-gray-900 transition"
                                >
                                    Cancel
                                </button>
                                <button 
                                    type="submit" 
                                    disabled={uploading}
                                    className="px-6 py-2 bg-blue-600 text-white font-bold rounded-lg hover:bg-blue-700 transition shadow-md disabled:opacity-50"
                                >
                                    {uploading ? 'Uploading...' : 'Upload Pack'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
