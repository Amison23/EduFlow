'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';
import { useToast } from '@/components/ToastProvider';

export default function SettingsPage() {
    const [loading, setLoading] = useState(true);
    const [languages, setLanguages] = useState<any[]>([]);
    const [newLang, setNewLang] = useState({ code: '', name: '' });
    const [addingLang, setAddingLang] = useState(false);
    const [currentUser, setCurrentUser] = useState<any>(null);
    const [admins, setAdmins] = useState<any[]>([]);
    const [newAdmin, setNewAdmin] = useState({ email: '', password: '', name: '', role: 'admin' });
    const [showAdminPassword, setShowAdminPassword] = useState(false);
    const [creatingAdmin, setCreatingAdmin] = useState(false);
    const [selectedLanguage, setSelectedLanguage] = useState('');
    const [notifications, setNotifications] = useState({ lowSync: true, weeklyReports: true });
    const { success, error: toastError, info } = useToast();

    const inputClass = "w-full px-4 py-2.5 border border-[var(--border)] bg-[var(--background)] text-[var(--foreground)] rounded-lg focus:ring-2 focus:ring-[var(--primary)] focus:border-[var(--primary)] outline-none transition text-sm placeholder:opacity-40";
    const labelClass = "block text-xs font-semibold text-[var(--foreground)] opacity-60 uppercase tracking-wide mb-1.5";

    useEffect(() => {
        const userJson = localStorage.getItem('adminUser');
        const user = userJson ? JSON.parse(userJson) : null;
        setCurrentUser(user);

        // Restore saved language preference
        const savedLang = localStorage.getItem('interfaceLanguage') || '';
        setSelectedLanguage(savedLang);

        // Restore notification preferences
        try {
            const savedNotifs = localStorage.getItem('notificationPrefs');
            if (savedNotifs) setNotifications(JSON.parse(savedNotifs));
        } catch {}

        const requests: Promise<any>[] = [
            api.getLanguages(),
            user?.role === 'master_admin' ? api.getAllAdmins() : Promise.resolve([])
        ];

        Promise.all(requests)
            .then(([langsData, adminsData]) => {
                setLanguages(Array.isArray(langsData) ? langsData : []);
                setAdmins(Array.isArray(adminsData) ? adminsData : []);
            })
            .catch(e => toastError(e.message || 'Failed to load settings'))
            .finally(() => setLoading(false));
    }, []);

    const handleSaveLanguage = () => {
        localStorage.setItem('interfaceLanguage', selectedLanguage);
        success('Interface language saved!');
    };

    const handleSaveNotifications = () => {
        localStorage.setItem('notificationPrefs', JSON.stringify(notifications));
        success('Notification preferences saved!');
    };

    const handleAddLanguage = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!newLang.code || !newLang.name) return;
        setAddingLang(true);
        try {
            const added = await api.addLanguage(newLang);
            setLanguages(prev => [...prev, added]);
            setNewLang({ code: '', name: '' });
            success(`Language "${newLang.name}" added!`);
        } catch (e: any) {
            toastError(e.message || 'Failed to add language');
        } finally {
            setAddingLang(false);
        }
    };

    const toggleLanguageStatus = async (lang: any) => {
        try {
            await api.updateLanguage(lang.id, { is_active: !lang.is_active });
            setLanguages(prev => prev.map(l => l.id === lang.id ? { ...l, is_active: !l.is_active } : l));
            info(`${lang.name} ${!lang.is_active ? 'activated' : 'deactivated'}`);
        } catch (e: any) {
            toastError(e.message || 'Failed to update language');
        }
    };

    const handleCreateAdmin = async (e: React.FormEvent) => {
        e.preventDefault();
        setCreatingAdmin(true);
        try {
            const added = await api.createAdmin(newAdmin);
            setAdmins(prev => [added, ...prev]);
            setNewAdmin({ email: '', password: '', name: '', role: 'admin' });
            setShowAdminPassword(false);
            success('Admin enrolled successfully!');
        } catch (e: any) {
            toastError(e.message || 'Failed to create admin');
        } finally {
            setCreatingAdmin(false);
        }
    };

    const handleDeleteAdmin = async (id: string, email: string) => {
        info(`Removing ${email}…`);
        try {
            await api.deleteAdmin(id);
            setAdmins(prev => prev.filter(a => a.id !== id));
            success(`Admin ${email} removed.`);
        } catch (e: any) {
            toastError(e.message || 'Failed to remove admin');
        }
    };

    const EyeIcon = ({ open }: { open: boolean }) => open ? (
        <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
        </svg>
    ) : (
        <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
            <path strokeLinecap="round" strokeLinejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
        </svg>
    );

    const Toggle = ({ checked, onChange }: { checked: boolean; onChange: () => void }) => (
        <button type="button" onClick={onChange}
            className={`w-10 h-6 rounded-full transition-colors flex-shrink-0 relative ${checked ? 'bg-[var(--primary)]' : 'bg-[var(--border)]'}`}>
            <span className={`absolute top-1 w-4 h-4 bg-white rounded-full shadow transition-all ${checked ? 'left-5' : 'left-1'}`} />
        </button>
    );

    if (loading) return (
        <div className="flex items-center justify-center p-16">
            <div className="animate-spin w-8 h-8 border-4 border-[var(--primary)] border-t-transparent rounded-full" />
        </div>
    );

    const Section = ({ title, subtitle, children }: { title: string; subtitle?: string; children: React.ReactNode }) => (
        <div className="dashboard-card overflow-hidden">
            <div className="px-6 py-4 border-b border-[var(--border)]">
                <h2 className="text-sm font-bold text-[var(--foreground)]">{title}</h2>
                {subtitle && <p className="text-xs text-[var(--foreground)] opacity-50 mt-0.5">{subtitle}</p>}
            </div>
            <div className="p-6">{children}</div>
        </div>
    );

    return (
        <div className="max-w-3xl space-y-6">
            <div>
                <h1 className="text-2xl font-bold text-[var(--foreground)]">Settings</h1>
                <p className="text-sm text-[var(--foreground)] opacity-50 mt-1">Configure platform preferences and access management.</p>
            </div>

            {/* Account Info */}
            <Section title="Account" subtitle="Your administrative account details">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    {[
                        { label: 'Full Name', value: currentUser?.name },
                        { label: 'Email', value: currentUser?.email },
                        { label: 'Role', value: currentUser?.role?.replace(/_/g, ' ') },
                        { label: 'Account ID', value: currentUser?.id ? `#${String(currentUser.id).slice(0, 8)}` : '—' },
                    ].map(({ label, value }) => (
                        <div key={label}>
                            <p className={labelClass}>{label}</p>
                            <p className="text-sm font-semibold text-[var(--foreground)]">{value || '—'}</p>
                        </div>
                    ))}
                </div>
            </Section>

            {/* Interface Language */}
            <Section title="Interface Language" subtitle="Choose the display language for the dashboard">
                <div className="flex flex-col sm:flex-row gap-3 items-end">
                    <div className="flex-1">
                        <label className={labelClass}>Language</label>
                        <select
                            value={selectedLanguage}
                            onChange={e => setSelectedLanguage(e.target.value)}
                            className={inputClass}
                        >
                            <option value="">System default (English)</option>
                            {languages.filter(l => l.is_active).map(lang => (
                                <option key={lang.id} value={lang.code}>{lang.name} ({lang.code})</option>
                            ))}
                        </select>
                    </div>
                    <button onClick={handleSaveLanguage}
                        className="px-5 py-2.5 bg-[var(--primary)] text-white text-sm font-semibold rounded-lg hover:opacity-90 transition whitespace-nowrap">
                        Save
                    </button>
                </div>
                {selectedLanguage && (
                    <p className="mt-2 text-xs text-[var(--foreground)] opacity-50">
                        Selected: <strong>{languages.find(l => l.code === selectedLanguage)?.name || selectedLanguage}</strong>
                    </p>
                )}
            </Section>

            {/* Notifications */}
            <Section title="Notifications" subtitle="Control which alerts you receive">
                <div className="space-y-4">
                    {[
                        { key: 'lowSync', label: 'Email alerts for low sync rates', desc: 'Get notified when learner sync drops below threshold' },
                        { key: 'weeklyReports', label: 'Weekly performance reports', desc: 'Receive a weekly email digest of platform metrics' },
                    ].map(({ key, label, desc }) => (
                        <div key={key} className="flex items-start gap-3">
                            <Toggle
                                checked={notifications[key as keyof typeof notifications]}
                                onChange={() => setNotifications(n => ({ ...n, [key]: !n[key as keyof typeof n] }))}
                            />
                            <div>
                                <p className="text-sm font-semibold text-[var(--foreground)]">{label}</p>
                                <p className="text-xs text-[var(--foreground)] opacity-50 mt-0.5">{desc}</p>
                            </div>
                        </div>
                    ))}
                </div>
                <div className="mt-4 flex justify-end">
                    <button onClick={handleSaveNotifications}
                        className="px-5 py-2 bg-[var(--primary)] text-white text-sm font-semibold rounded-lg hover:opacity-90 transition">
                        Save Preferences
                    </button>
                </div>
            </Section>

            {/* Language Management */}
            <Section title="Supported Languages" subtitle="Add or toggle languages available in the learner app">
                <div className="space-y-4">
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        {languages.length === 0 ? (
                            <p className="text-sm text-[var(--foreground)] opacity-40 col-span-2">No languages configured yet.</p>
                        ) : languages.map(lang => (
                            <div key={lang.id} className="flex items-center justify-between px-4 py-3 rounded-lg border border-[var(--border)] bg-[var(--background)]">
                                <div className="flex items-center gap-3">
                                    <div className="w-8 h-8 rounded-lg bg-[var(--primary)]/10 flex items-center justify-center">
                                        <span className="text-[10px] font-black text-[var(--primary)] uppercase">{lang.code}</span>
                                    </div>
                                    <div>
                                        <p className="text-sm font-semibold text-[var(--foreground)]">{lang.name}</p>
                                    </div>
                                </div>
                                <button onClick={() => toggleLanguageStatus(lang)}
                                    className={`px-3 py-1 text-xs font-bold rounded-full transition ${
                                        lang.is_active ? 'bg-emerald-100 text-emerald-700 hover:bg-emerald-200' : 'bg-red-100 text-red-700 hover:bg-red-200'
                                    }`}>
                                    {lang.is_active ? 'Active' : 'Inactive'}
                                </button>
                            </div>
                        ))}
                    </div>
                    <div className="pt-4 border-t border-[var(--border)]">
                        <p className={labelClass}>Add New Language</p>
                        <form onSubmit={handleAddLanguage} className="flex flex-col sm:flex-row gap-3">
                            <input type="text" placeholder="Language name (e.g. Somali)" value={newLang.name}
                                onChange={e => setNewLang({ ...newLang, name: e.target.value })} className={inputClass + ' flex-1'} />
                            <input type="text" placeholder="Code (e.g. so)" maxLength={5} value={newLang.code}
                                onChange={e => setNewLang({ ...newLang, code: e.target.value.toLowerCase() })} className={inputClass + ' sm:w-28'} />
                            <button type="submit" disabled={addingLang || !newLang.name || !newLang.code}
                                className="px-5 py-2.5 bg-[var(--primary)] text-white text-sm font-semibold rounded-lg hover:opacity-90 disabled:opacity-50 transition whitespace-nowrap">
                                {addingLang ? 'Adding…' : '+ Add'}
                            </button>
                        </form>
                    </div>
                </div>
            </Section>

            {/* Admin Management — master_admin only */}
            {currentUser?.role === 'master_admin' && (
                <Section title="Admin Management" subtitle="Enroll new staff or revoke dashboard access">
                    <div className="space-y-4">
                        {/* Admin list */}
                        <div className="space-y-2">
                            {admins.map(a => (
                                <div key={a.id} className="flex items-center justify-between px-4 py-3 rounded-lg border border-[var(--border)] bg-[var(--background)]">
                                    <div className="flex items-center gap-3">
                                        <div className="w-8 h-8 rounded-full bg-[var(--primary)]/15 flex items-center justify-center text-sm font-black text-[var(--primary)]">
                                            {(a.name || a.email || 'A')[0].toUpperCase()}
                                        </div>
                                        <div>
                                            <p className="text-sm font-semibold text-[var(--foreground)]">{a.name || '—'}</p>
                                            <p className="text-xs text-[var(--foreground)] opacity-50">{a.email}</p>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <span className={`px-2 py-0.5 text-[10px] font-black uppercase rounded-full ${
                                            a.role === 'master_admin' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'
                                        }`}>{a.role?.replace('_', ' ')}</span>
                                        {a.id !== currentUser?.id && a.role !== 'master_admin' && (
                                            <button onClick={() => handleDeleteAdmin(a.id, a.email)}
                                                className="text-xs text-red-500 hover:text-red-700 font-semibold transition-colors">
                                                Revoke
                                            </button>
                                        )}
                                    </div>
                                </div>
                            ))}
                        </div>

                        {/* Create admin form */}
                        <div className="pt-4 border-t border-[var(--border)]">
                            <p className={labelClass}>Enroll New Admin</p>
                            <form onSubmit={handleCreateAdmin} className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                                <div>
                                    <input required type="text" placeholder="Full Name" value={newAdmin.name}
                                        onChange={e => setNewAdmin({ ...newAdmin, name: e.target.value })} className={inputClass} />
                                </div>
                                <div>
                                    <input required type="email" placeholder="Email Address" value={newAdmin.email}
                                        onChange={e => setNewAdmin({ ...newAdmin, email: e.target.value })} className={inputClass} />
                                </div>
                                <div className="relative">
                                    <input required type={showAdminPassword ? 'text' : 'password'} placeholder="Temporary Access Key"
                                        value={newAdmin.password} onChange={e => setNewAdmin({ ...newAdmin, password: e.target.value })}
                                        className={inputClass + ' pr-10'} />
                                    <button type="button" onClick={() => setShowAdminPassword(v => !v)}
                                        className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--foreground)] opacity-40 hover:opacity-80">
                                        <EyeIcon open={showAdminPassword} />
                                    </button>
                                </div>
                                <div>
                                    <select value={newAdmin.role} onChange={e => setNewAdmin({ ...newAdmin, role: e.target.value })} className={inputClass}>
                                        <option value="admin">Standard Admin</option>
                                        <option value="master_admin">Master Admin</option>
                                    </select>
                                </div>
                                <div className="col-span-full flex justify-end">
                                    <button type="submit" disabled={creatingAdmin || !newAdmin.email || !newAdmin.password}
                                        className="px-5 py-2.5 bg-[var(--primary)] text-white text-sm font-semibold rounded-lg hover:opacity-90 disabled:opacity-50 transition">
                                        {creatingAdmin ? 'Enrolling…' : 'Enroll Admin'}
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </Section>
            )}
        </div>
    );
}
