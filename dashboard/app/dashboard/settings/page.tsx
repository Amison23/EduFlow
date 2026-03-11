'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

export default function SettingsPage() {
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
    const [notifications, setNotifications] = useState({ lowSync: true, weeklyReports: true });

    useEffect(() => {
        const userJson = localStorage.getItem('adminUser');
        const user = userJson ? JSON.parse(userJson) : null;
        setCurrentUser(user);

        const requests: Promise<any>[] = [
            api.get('/languages'),
            user?.role === 'master_admin' ? api.getAllAdmins() : Promise.resolve([])
        ];

        Promise.all(requests).then(([langsData, adminsData]) => {
            setLanguages(Array.isArray(langsData) ? langsData : []);
            setAdmins(Array.isArray(adminsData) ? adminsData : []);
        }).catch(console.error).finally(() => setLoading(false));
    }, []);

    const handleAddLanguage = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!newLang.code || !newLang.name) return;
        setAddingLang(true);
        try {
            const added = await api.addLanguage(newLang);
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
            setMessage('Admin created successfully!');
        } catch (err: any) {
            setMessage(err.message || 'Failed to create admin');
        } finally {
            setCreatingAdmin(false);
        }
    };

    const handleDeleteAdmin = async (id: string) => {
        if (!confirm('Are you sure you want to revoke access for this admin?')) return;
        try {
            await api.deleteAdmin(id);
            setAdmins(admins.filter(a => a.id !== id));
            setMessage('Admin access revoked.');
        } catch (err: any) {
            setMessage(err.message || 'Failed to delete admin');
        }
    };

    const inputClass = "w-full px-4 py-2.5 border border-[var(--border)] bg-[var(--background)] text-[var(--foreground)] rounded-lg focus:ring-2 focus:ring-[var(--primary)] focus:border-[var(--primary)] outline-none transition text-sm";
    const sectionClass = "dashboard-card overflow-hidden";
    const sectionHeaderClass = "p-6 border-b border-[var(--border)]";

    if (loading) return (
        <div className="flex items-center justify-center p-12">
            <div className="animate-spin w-8 h-8 border-4 border-[var(--primary)] border-t-transparent rounded-full" />
        </div>
    );

    return (
        <div className="max-w-3xl mx-auto space-y-6">
            <div>
                <h1 className="text-2xl font-bold text-[var(--foreground)]">Settings</h1>
                <p className="text-sm text-[var(--foreground)] opacity-60 mt-1">
                    Manage platform configuration and preferences.
                </p>
            </div>

            {message && (
                <div className={`px-4 py-3 rounded-lg text-sm font-medium flex justify-between items-center ${
                    message.toLowerCase().includes('success') || message.toLowerCase().includes('revoked')
                        ? 'bg-green-50 border border-green-200 text-green-700'
                        : 'bg-red-50 border border-red-200 text-red-700'
                }`}>
                    {message}
                    <button onClick={() => setMessage('')} className="opacity-60 hover:opacity-100 ml-4">✕</button>
                </div>
            )}

            {/* Account Info */}
            <div className={sectionClass}>
                <div className={sectionHeaderClass}>
                    <h2 className="text-base font-semibold text-[var(--foreground)]">Account Information</h2>
                    <p className="text-xs text-[var(--foreground)] opacity-50 mt-0.5">Your admin account details.</p>
                </div>
                <div className="p-6 grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label className="block text-xs font-semibold text-[var(--foreground)] opacity-60 uppercase tracking-wide mb-1">Full Name</label>
                        <p className="text-sm font-semibold text-[var(--foreground)]">{currentUser?.name || '—'}</p>
                    </div>
                    <div>
                        <label className="block text-xs font-semibold text-[var(--foreground)] opacity-60 uppercase tracking-wide mb-1">Email</label>
                        <p className="text-sm font-semibold text-[var(--foreground)]">{currentUser?.email || '—'}</p>
                    </div>
                    <div>
                        <label className="block text-xs font-semibold text-[var(--foreground)] opacity-60 uppercase tracking-wide mb-1">Role</label>
                        <span className="inline-block px-2 py-0.5 text-xs font-bold uppercase tracking-wide rounded-full bg-[var(--primary)]/10 text-[var(--primary)]">
                            {currentUser?.role?.replace(/_/g, ' ') || '—'}
                        </span>
                    </div>
                </div>
            </div>

            {/* Notifications */}
            <div className={sectionClass}>
                <div className={sectionHeaderClass}>
                    <h2 className="text-base font-semibold text-[var(--foreground)]">Notifications</h2>
                    <p className="text-xs text-[var(--foreground)] opacity-50 mt-0.5">Configure alert preferences.</p>
                </div>
                <div className="p-6 space-y-3">
                    {[
                        { key: 'lowSync', label: 'Email alerts for low sync rates' },
                        { key: 'weeklyReports', label: 'Weekly performance reports' },
                    ].map(({ key, label }) => (
                        <label key={key} className="flex items-center gap-3 cursor-pointer group">
                            <div
                                onClick={() => setNotifications(n => ({ ...n, [key]: !n[key as keyof typeof n] }))}
                                className={`w-10 h-6 rounded-full transition-colors cursor-pointer flex-shrink-0 ${notifications[key as keyof typeof notifications] ? 'bg-[var(--primary)]' : 'bg-[var(--border)]'}`}
                            >
                                <div className={`w-4 h-4 bg-white rounded-full shadow transition-transform mt-1 ${notifications[key as keyof typeof notifications] ? 'translate-x-5' : 'translate-x-1'}`} />
                            </div>
                            <span className="text-sm text-[var(--foreground)] opacity-80 group-hover:opacity-100">{label}</span>
                        </label>
                    ))}
                </div>
            </div>

            {/* Language Management */}
            <div className={sectionClass}>
                <div className={sectionHeaderClass}>
                    <h2 className="text-base font-semibold text-[var(--foreground)]">Supported Languages</h2>
                    <p className="text-xs text-[var(--foreground)] opacity-50 mt-0.5">Add or toggle languages for the learner app.</p>
                </div>
                <div className="p-6 space-y-4">
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        {languages.length === 0 ? (
                            <p className="text-sm text-[var(--foreground)] opacity-50 col-span-2">No languages configured yet.</p>
                        ) : languages.map(lang => (
                            <div key={lang.id} className="flex items-center justify-between px-4 py-3 rounded-lg border border-[var(--border)] bg-[var(--background)]">
                                <div>
                                    <p className="text-sm font-semibold text-[var(--foreground)]">{lang.name}</p>
                                    <p className="text-[10px] uppercase font-bold text-[var(--foreground)] opacity-40 tracking-wide">{lang.code}</p>
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
                    <div className="pt-4 border-t border-[var(--border)]">
                        <h3 className="text-xs font-semibold uppercase tracking-wide text-[var(--foreground)] opacity-60 mb-3">Add New Language</h3>
                        <form onSubmit={handleAddLanguage} className="flex flex-col sm:flex-row gap-3">
                            <input type="text" placeholder="Language name (e.g. Somali)" value={newLang.name} onChange={e => setNewLang({ ...newLang, name: e.target.value })} className={inputClass + " flex-1"} />
                            <input type="text" placeholder="Code (e.g. so)" value={newLang.code} onChange={e => setNewLang({ ...newLang, code: e.target.value })} className={inputClass + " sm:w-28"} />
                            <button type="submit" disabled={addingLang || !newLang.code || !newLang.name}
                                className="px-5 py-2.5 bg-[var(--primary)] text-white text-sm font-semibold rounded-lg hover:opacity-90 disabled:opacity-50 transition-opacity whitespace-nowrap">
                                {addingLang ? 'Adding...' : '+ Add'}
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            {/* Admin Management — master_admin only */}
            {currentUser?.role === 'master_admin' && (
                <div className={sectionClass}>
                    <div className={sectionHeaderClass}>
                        <h2 className="text-base font-semibold text-[var(--foreground)]">Admin Management</h2>
                        <p className="text-xs text-[var(--foreground)] opacity-50 mt-0.5">Enroll new staff or revoke dashboard access.</p>
                    </div>
                    <div className="p-6 space-y-4">
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                            {admins.map(admin => (
                                <div key={admin.id} className="flex items-center justify-between px-4 py-3 rounded-lg border border-[var(--border)] bg-[var(--background)]">
                                    <div>
                                        <p className="text-sm font-semibold text-[var(--foreground)]">{admin.name || 'Unnamed'}</p>
                                        <p className="text-xs text-[var(--foreground)] opacity-50">{admin.email}</p>
                                        <span className={`inline-block mt-1 px-2 py-0.5 text-[10px] font-bold uppercase rounded-full ${
                                            admin.role === 'master_admin' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'
                                        }`}>{admin.role.replace('_', ' ')}</span>
                                    </div>
                                    {admin.id !== currentUser?.id && admin.role !== 'master_admin' && (
                                        <button type="button" onClick={() => handleDeleteAdmin(admin.id)}
                                            className="p-2 text-[var(--foreground)] opacity-30 hover:opacity-100 hover:text-red-500 transition-all" title="Revoke Access">
                                            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                            </svg>
                                        </button>
                                    )}
                                </div>
                            ))}
                        </div>
                        <div className="pt-4 border-t border-[var(--border)]">
                            <h3 className="text-xs font-semibold uppercase tracking-wide text-[var(--foreground)] opacity-60 mb-3">Enroll New Admin</h3>
                            <form onSubmit={handleCreateAdmin} className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                                <input required type="text" placeholder="Full Name" value={newAdmin.name} onChange={e => setNewAdmin({ ...newAdmin, name: e.target.value })} className={inputClass} />
                                <input required type="email" placeholder="Email Address" value={newAdmin.email} onChange={e => setNewAdmin({ ...newAdmin, email: e.target.value })} className={inputClass} />
                                <input required type="password" placeholder="Temporary Access Key" value={newAdmin.password} onChange={e => setNewAdmin({ ...newAdmin, password: e.target.value })} className={inputClass} />
                                <select value={newAdmin.role} onChange={e => setNewAdmin({ ...newAdmin, role: e.target.value })} className={inputClass}>
                                    <option value="admin">Standard Admin</option>
                                    <option value="master_admin">Master Admin</option>
                                </select>
                                <div className="col-span-full flex justify-end">
                                    <button type="submit" disabled={creatingAdmin || !newAdmin.email || !newAdmin.password}
                                        className="px-5 py-2.5 bg-[var(--primary)] text-white text-sm font-semibold rounded-lg hover:opacity-90 disabled:opacity-50 transition-opacity">
                                        {creatingAdmin ? 'Enrolling...' : 'Enroll Admin'}
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
