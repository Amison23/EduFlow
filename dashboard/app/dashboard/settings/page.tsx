'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

export default function SettingsPage() {
    const [profile, setProfile] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [message, setMessage] = useState('');

    useEffect(() => {
        // Since we are assuming the logged in user is the NGO/Admin
        // For now we use the general profile/learners endpoint or a dedicated NGO settings endpoint if implemented
        api.get('/auth/profile')
            .then(data => {
                setProfile(data);
                setLoading(false);
            })
            .catch(() => setLoading(false));
    }, []);

    const handleSave = async (e: React.FormEvent) => {
        e.preventDefault();
        setSaving(true);
        setMessage('');
        try {
            await api.post('/auth/update-profile', profile);
            setMessage('Settings saved successfully!');
        } catch (err: any) {
            setMessage(err.message || 'Failed to save settings');
        } finally {
            setSaving(false);
        }
    };

    if (loading) return <div className="p-8 text-center text-gray-500">Loading settings...</div>;

    return (
        <div className="max-w-4xl mx-auto px-4 sm:px-0">
            <h1 className="text-3xl font-bold text-gray-900 tracking-tight mb-8">Settings</h1>

            <form onSubmit={handleSave} className="space-y-8">
                <section className="bg-white shadow-sm border border-gray-200 rounded-xl overflow-hidden">
                    <div className="p-6 border-b border-gray-100">
                        <h2 className="text-lg font-bold text-gray-900">Organization Profile</h2>
                        <p className="text-sm text-gray-500">Manage your NGO information and public profile.</p>
                    </div>
                    <div className="p-6 space-y-4">
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-1">Region</label>
                            <input 
                                type="text" 
                                value={profile?.region || ''} 
                                onChange={(e) => setProfile({...profile, region: e.target.value})}
                                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition" 
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-1">Interface Language</label>
                            <select 
                                value={profile?.language || 'en'} 
                                onChange={(e) => setProfile({...profile, language: e.target.value})}
                                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition"
                            >
                                <option value="en">English</option>
                                <option value="sw">Swahili</option>
                                <option value="am">Amharic</option>
                            </select>
                        </div>
                    </div>
                </section>

                <section className="bg-white shadow-sm border border-gray-200 rounded-xl overflow-hidden">
                    <div className="p-6 border-b border-gray-100">
                        <h2 className="text-lg font-bold text-gray-900">Notifications</h2>
                        <p className="text-sm text-gray-500">Configure how you receive alerts and reports.</p>
                    </div>
                    <div className="p-6 space-y-4">
                        <label className="flex items-center space-x-3 cursor-pointer">
                            <input type="checkbox" defaultChecked className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500" />
                            <span className="text-sm text-gray-700 font-medium">Email alerts for low sync rates</span>
                        </label>
                        <label className="flex items-center space-x-3 cursor-pointer">
                            <input type="checkbox" defaultChecked className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500" />
                            <span className="text-sm text-gray-700 font-medium">Weekly performance reports</span>
                        </label>
                    </div>
                </section>

                {message && (
                    <p className={`text-sm font-bold ${message.includes('success') ? 'text-green-600' : 'text-red-600'}`}>{message}</p>
                )}

                <div className="flex justify-end space-x-4">
                    <button type="button" className="px-6 py-2 text-sm font-bold text-gray-600 hover:text-gray-900 transition">Cancel</button>
                    <button 
                        type="submit" 
                        disabled={saving}
                        className="px-6 py-2 text-sm font-bold text-white bg-blue-600 rounded-lg hover:bg-blue-700 transition shadow-md disabled:opacity-50"
                    >
                        {saving ? 'Saving...' : 'Save Changes'}
                    </button>
                </div>
            </form>
        </div>
    );
}
