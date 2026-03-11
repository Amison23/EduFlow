'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

export default function SettingsPage() {
    const [profile, setProfile] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [message, setMessage] = useState('');
    const [languages, setLanguages] = useState<any[]>([]);
    const [newLang, setNewLang] = useState({ code: '', name: '' });
    const [addingLang, setAddingLang] = useState(false);
    const [currentUser, setCurrentUser] = useState<any>(null);
    const [admins, setAdmins] = useState<any[]>([]);
    const [newAdmin, setNewAdmin] = useState({ email: '', password: '', name: '', role: 'admin' });
    const [creatingAdmin, setCreatingAdmin] = useState(false);

    useEffect(() => {
        const userJson = localStorage.getItem('adminUser');
        const user = userJson ? JSON.parse(userJson) : null;
        setCurrentUser(user);

        Promise.all([
            api.get('/auth/profile'),
            api.get('/languages'),
            user?.role === 'master_admin' ? api.getAllAdmins() : Promise.resolve([])
        ]).then(([profileData, langsData, adminsData]) => {
            setProfile(profileData);
            setLanguages(langsData);
            setAdmins(adminsData);
            setLoading(false);
        }).catch(() => setLoading(false));
    }, []);

    const handleAddLanguage = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!newLang.code || !newLang.name) return;
        setAddingLang(true);
        try {
            const added = await api.post('/languages', newLang);
            setLanguages([...languages, added]);
            setNewLang({ code: '', name: '' });
        } catch (err: any) {
            alert(err.message || 'Failed to add language');
        } finally {
            setAddingLang(false);
        }
    };

    const toggleLanguageStatus = async (lang: any) => {
        try {
            const updated = await api.updateLanguage(lang.id, { is_active: !lang.is_active });
            setLanguages(languages.map(l => l.id === lang.id ? updated : l));
        } catch (err: any) {
            alert(err.message || 'Failed to update language');
        }
    };

    const handleCreateAdmin = async (e: React.FormEvent) => {
        e.preventDefault();
        setCreatingAdmin(true);
        try {
            const added = await api.createAdmin(newAdmin);
            setAdmins([added, ...admins]);
            setNewAdmin({ email: '', password: '', name: '', role: 'admin' });
            alert('Admin created successfully');
        } catch (err: any) {
            alert(err.message || 'Failed to create admin');
        } finally {
            setCreatingAdmin(false);
        }
    };

    const handleDeleteAdmin = async (id: string) => {
        if (!confirm('Are you sure you want to revoke access for this admin?')) return;
        try {
            await api.deleteAdmin(id);
            setAdmins(admins.filter(a => a.id !== id));
        } catch (err: any) {
            alert(err.message || 'Failed to delete admin');
        }
    };

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
                                {languages.filter(l => l.is_active).map(lang => (
                                    <option key={lang.id} value={lang.code}>{lang.name}</option>
                                ))}
                            </select>
                        </div>
                    </div>
                </section>

                <section className="bg-white shadow-sm border border-gray-200 rounded-xl overflow-hidden">
                    <div className="p-6 border-b border-gray-100">
                        <h2 className="text-lg font-bold text-gray-900">Manage Supported Languages</h2>
                        <p className="text-sm text-gray-500">Add or deactivate languages for lesson contents and the learner app.</p>
                    </div>
                    <div className="p-6 space-y-6">
                        {/* Current Languages List */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            {languages.map((lang) => (
                                <div key={lang.id} className="flex items-center justify-between p-4 border border-gray-100 rounded-lg bg-gray-50">
                                    <div>
                                        <p className="font-bold text-gray-900">{lang.name}</p>
                                        <p className="text-xs text-gray-500 uppercase font-medium">{lang.code}</p>
                                    </div>
                                    <button 
                                        type="button"
                                        onClick={() => toggleLanguageStatus(lang)}
                                        className={`px-3 py-1 text-xs font-bold rounded-full transition ${
                                            lang.is_active 
                                            ? 'bg-green-100 text-green-700 hover:bg-green-200' 
                                            : 'bg-red-100 text-red-700 hover:bg-red-200'
                                        }`}
                                    >
                                        {lang.is_active ? 'Active' : 'Inactive'}
                                    </button>
                                </div>
                            ))}
                        </div>

                        {/* Add New Language Form */}
                        <div className="pt-6 border-t border-gray-100">
                            <h3 className="text-sm font-bold text-gray-900 mb-4">Add New Language</h3>
                            <div className="flex flex-col sm:flex-row gap-4">
                                <input 
                                    type="text" 
                                    placeholder="Language Name (e.g. Somali)"
                                    value={newLang.name}
                                    onChange={(e) => setNewLang({...newLang, name: e.target.value})}
                                    className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"
                                />
                                <input 
                                    type="text" 
                                    placeholder="Code (e.g. so)"
                                    value={newLang.code}
                                    onChange={(e) => setNewLang({...newLang, code: e.target.value})}
                                    className="w-full sm:w-32 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"
                                />
                                <button 
                                    type="button"
                                    onClick={handleAddLanguage}
                                    disabled={addingLang || !newLang.code || !newLang.name}
                                    className="px-6 py-2 bg-gray-900 text-white font-bold rounded-lg hover:bg-black transition disabled:opacity-50"
                                >
                                    {addingLang ? 'Adding...' : 'Add Language'}
                                </button>
                            </div>
                        </div>
                    </div>
                </section>

                {currentUser?.role === 'master_admin' && (
                    <section className="bg-white shadow-sm border border-gray-200 rounded-xl overflow-hidden">
                        <div className="p-6 border-b border-gray-100">
                            <h2 className="text-lg font-bold text-gray-900">Admin Management</h2>
                            <p className="text-sm text-gray-500">Master Admin: Enroll new staff or revoke access.</p>
                        </div>
                        <div className="p-6 space-y-6">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                {admins.map((admin) => (
                                    <div key={admin.id} className="flex items-center justify-between p-4 border border-gray-100 rounded-lg bg-gray-50 transition-all hover:border-gray-200">
                                        <div>
                                            <p className="font-bold text-gray-900">{admin.name || 'Unnamed Admin'}</p>
                                            <p className="text-xs text-gray-500 font-medium">{admin.email}</p>
                                            <div className="mt-1">
                                                <span className={`px-2 py-0.5 text-[10px] font-bold uppercase rounded ${
                                                    admin.role === 'master_admin' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'
                                                }`}>
                                                    {admin.role}
                                                </span>
                                            </div>
                                        </div>
                                        {admin.id !== currentUser?.id && (
                                            <button 
                                                type="button"
                                                onClick={() => handleDeleteAdmin(admin.id)}
                                                className="p-2 text-gray-400 hover:text-red-600 transition-colors"
                                                title="Revoke Access"
                                            >
                                                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                                </svg>
                                            </button>
                                        )}
                                    </div>
                                ))}
                            </div>

                            <div className="pt-6 border-t border-gray-100">
                                <h3 className="text-sm font-bold text-gray-900 mb-4">Enroll New Admin</h3>
                                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                    <input 
                                        type="text" 
                                        placeholder="Full Name"
                                        value={newAdmin.name}
                                        onChange={(e) => setNewAdmin({...newAdmin, name: e.target.value})}
                                        className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"
                                        required
                                    />
                                    <input 
                                        type="email" 
                                        placeholder="Email Address"
                                        value={newAdmin.email}
                                        onChange={(e) => setNewAdmin({...newAdmin, email: e.target.value})}
                                        className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"
                                        required
                                    />
                                    <input 
                                        type="password" 
                                        placeholder="Temporary Access Key"
                                        value={newAdmin.password}
                                        onChange={(e) => setNewAdmin({...newAdmin, password: e.target.value})}
                                        className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"
                                        required
                                    />
                                    <select 
                                        value={newAdmin.role}
                                        onChange={(e) => setNewAdmin({...newAdmin, role: e.target.value})}
                                        className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition font-medium"
                                    >
                                        <option value="admin">Standard Admin</option>
                                        <option value="master_admin">Master Admin</option>
                                    </select>
                                </div>
                                <div className="mt-4 flex justify-end">
                                    <button 
                                        type="button"
                                        onClick={handleCreateAdmin}
                                        disabled={creatingAdmin || !newAdmin.email || !newAdmin.password}
                                        className="px-6 py-2 bg-blue-600 text-white font-bold rounded-lg hover:bg-blue-700 transition shadow-md disabled:opacity-50"
                                    >
                                        {creatingAdmin ? 'Enrolling...' : 'Enroll Admin'}
                                    </button>
                                </div>
                            </div>
                        </div>
                    </section>
                )}

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
