'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';
import { useToast } from '@/components/ToastProvider';

const TABS = ['Learners', 'Languages', 'Lesson Packs', 'Admins'];

type TabName = 'Learners' | 'Languages' | 'Lesson Packs' | 'Admins';

export default function DataManagerPage() {
    const [activeTab, setActiveTab] = useState<TabName>('Languages');
    const { success, error: toastError, info } = useToast();

    // --- Languages ---
    const [languages, setLanguages] = useState<any[]>([]);
    const [langLoading, setLangLoading] = useState(false);
    const [newLang, setNewLang] = useState({ name: '', code: '' });
    const [addingLang, setAddingLang] = useState(false);

    // --- Learners ---
    const [learners, setLearners] = useState<any[]>([]);
    const [learnersLoading, setLearnersLoading] = useState(false);
    const [learnerSearch, setLearnerSearch] = useState('');

    // --- Packs ---
    const [packs, setPacks] = useState<any[]>([]);
    const [packsLoading, setPacksLoading] = useState(false);

    // --- Admins ---
    const [admins, setAdmins] = useState<any[]>([]);
    const [adminsLoading, setAdminsLoading] = useState(false);

    const inputClass = "w-full px-3 py-2 text-sm border border-[var(--border)] bg-[var(--background)] text-[var(--foreground)] rounded-lg focus:outline-none focus:ring-2 focus:ring-[var(--primary)] placeholder:opacity-40 transition";

    // Load data for each tab on first visit
    useEffect(() => {
        if (activeTab === 'Languages' && languages.length === 0) {
            setLangLoading(true);
            api.getLanguages().then(d => setLanguages(Array.isArray(d) ? d : [])).catch(e => toastError(e.message)).finally(() => setLangLoading(false));
        }
        if (activeTab === 'Learners' && learners.length === 0) {
            setLearnersLoading(true);
            api.getLearners().then(d => setLearners(Array.isArray(d) ? d : [])).catch(e => toastError(e.message)).finally(() => setLearnersLoading(false));
        }
        if (activeTab === 'Lesson Packs' && packs.length === 0) {
            setPacksLoading(true);
            api.getLessonPacks().then(d => setPacks(Array.isArray(d) ? d : [])).catch(e => toastError(e.message)).finally(() => setPacksLoading(false));
        }
        if (activeTab === 'Admins' && admins.length === 0) {
            setAdminsLoading(true);
            api.getAllAdmins().then(d => setAdmins(Array.isArray(d) ? d : [])).catch(e => toastError(e.message)).finally(() => setAdminsLoading(false));
        }
    }, [activeTab, admins.length, languages.length, learners.length, packs.length, toastError]);

    // --- Language operations ---
    const handleAddLanguage = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!newLang.code || !newLang.name) return;
        setAddingLang(true);
        try {
            const added = await api.addLanguage(newLang);
            setLanguages(prev => [...prev, added]);
            setNewLang({ name: '', code: '' });
            success(`Language "${newLang.name}" added!`);
        } catch (e: any) { toastError(e.message || 'Failed to add language'); }
        finally { setAddingLang(false); }
    };

    const [langToDelete, setLangToDelete] = useState<any>(null);

    const toggleLanguage = async (lang: any) => {
        try {
            const updated = await api.updateLanguage(lang.id, { is_active: !lang.is_active });
            setLanguages(prev => prev.map(l => l.id === lang.id ? { ...l, is_active: !l.is_active } : l));
            info(`${lang.name} ${!lang.is_active ? 'activated' : 'deactivated'}`);
        } catch (e: any) { toastError(e.message); }
    };

    const handleDeleteLanguage = async () => {
        if (!langToDelete) return;
        try {
            await api.deleteLanguage(langToDelete.id);
            setLanguages(prev => prev.filter(l => l.id !== langToDelete.id));
            success(`Language "${langToDelete.name}" deleted permanently.`);
        } catch (e: any) {
            toastError(e.message || 'Failed to delete language. It might be in use.');
        } finally {
            setLangToDelete(null);
        }
    };

    // --- Admins operations ---
    const [adminToDelete, setAdminToDelete] = useState<any>(null);

    const handleDeleteAdmin = async () => {
        if (!adminToDelete) return;
        info(`Removing ${adminToDelete.email}…`);
        try {
            await api.deleteAdmin(adminToDelete.id);
            setAdmins(prev => prev.filter(a => a.id !== adminToDelete.id));
            success(`Admin ${adminToDelete.email} removed.`);
        } catch (e: any) {
            toastError(e.message || 'Failed to remove admin');
        } finally {
            setAdminToDelete(null);
        }
    };

    // Filtered learners
    const filteredLearners = learners.filter(l =>
        !learnerSearch || (l.name || '').toLowerCase().includes(learnerSearch.toLowerCase()) ||
        (l.region || '').toLowerCase().includes(learnerSearch.toLowerCase())
    );

    const Spinner = () => (
        <div className="flex justify-center items-center py-16">
            <div className="animate-spin w-7 h-7 border-4 border-[var(--primary)] border-t-transparent rounded-full" />
        </div>
    );

    const EmptyState = ({ icon, label }: { icon: string; label: string }) => (
        <div className="text-center py-16 text-[var(--foreground)] opacity-40">
            <div className="text-4xl mb-3">{icon}</div>
            <p className="text-sm font-medium">{label}</p>
        </div>
    );

    return (
        <div className="space-y-6">
            {/* Header */}
            <div>
                <h1 className="text-2xl font-bold text-[var(--foreground)]">Data Manager</h1>
                <p className="text-sm text-[var(--foreground)] opacity-50 mt-1">
                    Browse, create, and manage all platform data entities.
                </p>
            </div>

            {/* Tabs */}
            <div className="flex gap-1 p-1 bg-[var(--background)] rounded-xl border border-[var(--border)] w-fit overflow-x-auto">
                {TABS.map(tab => (
                    <button
                        key={tab}
                        onClick={() => setActiveTab(tab as TabName)}
                        className={`px-4 py-2 rounded-lg text-sm font-semibold whitespace-nowrap transition-all ${
                            activeTab === tab
                                ? 'bg-[var(--primary)] text-white shadow-sm'
                                : 'text-[var(--foreground)] opacity-60 hover:opacity-100'
                        }`}
                    >
                        {tab}
                    </button>
                ))}
            </div>

            {/* ── LANGUAGES TAB ── */}
            {activeTab === 'Languages' && (
                <div className="space-y-4">
                    {/* Add form */}
                    <div className="dashboard-card p-5">
                        <h2 className="text-sm font-semibold text-[var(--foreground)] opacity-70 uppercase tracking-wide mb-3">Add Language</h2>
                        <form onSubmit={handleAddLanguage} className="flex flex-col sm:flex-row gap-3">
                            <input value={newLang.name} onChange={e => setNewLang({ ...newLang, name: e.target.value })} placeholder="Language name (e.g. Somali)" className={inputClass + ' flex-1'} />
                            <input value={newLang.code} onChange={e => setNewLang({ ...newLang, code: e.target.value.toLowerCase() })} placeholder="Code (e.g. so)" maxLength={5} className={inputClass + ' sm:w-32'} />
                            <button type="submit" disabled={addingLang || !newLang.name || !newLang.code}
                                className="px-5 py-2 bg-[var(--primary)] text-white text-sm font-semibold rounded-lg hover:opacity-90 disabled:opacity-50 transition whitespace-nowrap">
                                {addingLang ? 'Adding…' : '+ Add'}
                            </button>
                        </form>
                    </div>

                    {/* Language list */}
                    <div className="dashboard-card overflow-hidden">
                        <div className="px-6 py-4 border-b border-[var(--border)] flex justify-between items-center">
                            <h2 className="text-sm font-semibold text-[var(--foreground)] opacity-70 uppercase tracking-wide">{languages.length} Languages</h2>
                            <button onClick={() => { setLangLoading(true); api.getLanguages().then(d => setLanguages(Array.isArray(d) ? d : [])).finally(() => setLangLoading(false)); }}
                                className="text-xs text-[var(--primary)] hover:underline font-semibold">↻ Refresh</button>
                        </div>
                        {langLoading ? <Spinner /> : languages.length === 0 ? <EmptyState icon="🌐" label="No languages added yet" /> : (
                            <div className="divide-y divide-[var(--border)]">
                                {languages.map(lang => (
                                    <div key={lang.id} className="px-6 py-4 flex items-center justify-between hover:bg-[var(--background)] transition-colors">
                                        <div className="flex items-center gap-4">
                                            <div className="w-10 h-10 rounded-lg bg-[var(--primary)]/10 flex items-center justify-center">
                                                <span className="text-xs font-black text-[var(--primary)] uppercase">{lang.code}</span>
                                            </div>
                                            <div>
                                                <p className="text-sm font-semibold text-[var(--foreground)]">{lang.name}</p>
                                                <p className="text-xs text-[var(--foreground)] opacity-40 uppercase tracking-wide font-bold">{lang.code}</p>
                                            </div>
                                        </div>
                                        <div className="flex items-center gap-2">
                                            <button onClick={() => toggleLanguage(lang)}
                                                className={`px-3 py-1.5 rounded-full text-xs font-bold transition ${lang.is_active ? 'bg-emerald-100 text-emerald-700 hover:bg-emerald-200' : 'bg-red-100 text-red-700 hover:bg-red-200'}`}>
                                                {lang.is_active ? '● Active' : '○ Inactive'}
                                            </button>
                                            <button onClick={() => setLangToDelete(lang)}
                                                className="p-1.5 text-red-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                                                title="Delete language permanently">
                                                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                                </svg>
                                            </button>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            )}

            {/* Language Deletion Confirmation Modal */}
            {langToDelete && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in duration-200">
                    <div className="bg-[var(--card)] border border-[var(--border)] rounded-2xl p-6 max-w-sm w-full shadow-2xl animate-in zoom-in-95 duration-200">
                        <div className="w-12 h-12 rounded-full bg-red-100 flex items-center justify-center text-red-600 text-2xl mb-4">
                            ⚠️
                        </div>
                        <h3 className="text-lg font-bold text-[var(--foreground)] mb-2">Delete Language?</h3>
                        <p className="text-sm text-[var(--foreground)] opacity-60 mb-6">
                            Are you sure you want to delete <strong>{langToDelete.name}</strong>? This action is permanent and might affect learners using this language.
                        </p>
                        <div className="flex gap-3">
                            <button
                                onClick={() => setLangToDelete(null)}
                                className="flex-1 px-4 py-2.5 text-sm font-semibold text-[var(--foreground)] bg-[var(--background)] border border-[var(--border)] rounded-lg hover:bg-[var(--border)] transition"
                            >
                                Cancel
                            </button>
                            <button
                                onClick={handleDeleteLanguage}
                                className="flex-1 px-4 py-2.5 text-sm font-semibold text-white bg-red-600 rounded-lg hover:bg-red-700 transition shadow-lg shadow-red-600/20"
                            >
                                Delete
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* ── LEARNERS TAB ── */}
            {activeTab === 'Learners' && (
                <div className="space-y-4">
                    <div className="dashboard-card p-4 flex flex-col sm:flex-row gap-3">
                        <input value={learnerSearch} onChange={e => setLearnerSearch(e.target.value)} placeholder="Search by name or region…" className={inputClass + ' flex-1'} />
                        <span className="text-xs text-[var(--foreground)] opacity-50 self-center whitespace-nowrap">{filteredLearners.length} results</span>
                    </div>
                    <div className="dashboard-card overflow-hidden">
                        {learnersLoading ? <Spinner /> : filteredLearners.length === 0 ? <EmptyState icon="🎓" label="No learners found" /> : (
                            <div className="overflow-x-auto">
                                <table className="w-full text-sm">
                                    <thead>
                                        <tr className="border-b border-[var(--border)]">
                                            {['Learner', 'Region', 'Language', 'Progress', 'Enrolled'].map(h => (
                                                <th key={h} className="px-6 py-3 text-left text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wide">{h}</th>
                                            ))}
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-[var(--border)]">
                                        {filteredLearners.map(l => (
                                            <tr key={l.id} className="hover:bg-[var(--background)] transition-colors">
                                                <td className="px-6 py-4 font-medium text-[var(--foreground)]">{l.name || `#${l.id}`}</td>
                                                <td className="px-6 py-4 text-[var(--foreground)] opacity-70">{l.region || '—'}</td>
                                                <td className="px-6 py-4">
                                                    <span className="px-2 py-0.5 text-xs font-bold rounded-full bg-[var(--primary)]/10 text-[var(--primary)]">{l.language || '—'}</span>
                                                </td>
                                                <td className="px-6 py-4">
                                                    <div className="flex items-center gap-2">
                                                        <div className="w-20 h-1.5 bg-[var(--border)] rounded-full overflow-hidden">
                                                            <div className="h-1.5 bg-[var(--primary)] rounded-full" style={{ width: `${l.progress || 0}%` }} />
                                                        </div>
                                                        <span className="text-xs font-semibold text-[var(--foreground)] opacity-60">{l.progress || 0}%</span>
                                                    </div>
                                                </td>
                                                <td className="px-6 py-4 text-[var(--foreground)] opacity-50 text-xs">
                                                    {l.created_at ? new Date(l.created_at).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: '2-digit' }) : '—'}
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        )}
                    </div>
                </div>
            )}

            {/* ── LESSON PACKS TAB ── */}
            {activeTab === 'Lesson Packs' && (
                <div className="dashboard-card overflow-hidden">
                    {packsLoading ? <Spinner /> : packs.length === 0 ? <EmptyState icon="📦" label="No lesson packs found" /> : (
                        <div className="overflow-x-auto">
                            <table className="w-full text-sm">
                                <thead>
                                    <tr className="border-b border-[var(--border)]">
                                        {['Pack', 'Type', 'Lessons', 'Language', 'Status'].map(h => (
                                            <th key={h} className="px-6 py-3 text-left text-xs font-semibold text-[var(--foreground)] opacity-50 uppercase tracking-wide">{h}</th>
                                        ))}
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-[var(--border)]">
                                    {packs.map((p: any) => (
                                        <tr key={p.id} className="hover:bg-[var(--background)] transition-colors">
                                            <td className="px-6 py-4 font-semibold text-[var(--foreground)]">{p.name || p.title || '—'}</td>
                                            <td className="px-6 py-4 text-[var(--foreground)] opacity-70">{p.type || '—'}</td>
                                            <td className="px-6 py-4 text-[var(--foreground)] opacity-70">{p.lesson_count ?? p.lessons ?? '—'}</td>
                                            <td className="px-6 py-4">
                                                <span className="px-2 py-0.5 text-xs font-bold rounded-full bg-[var(--primary)]/10 text-[var(--primary)]">{p.language || '—'}</span>
                                            </td>
                                            <td className="px-6 py-4">
                                                <span className={`px-2 py-0.5 text-xs font-bold rounded-full ${p.is_active !== false ? 'bg-emerald-100 text-emerald-700' : 'bg-red-100 text-red-700'}`}>
                                                    {p.is_active !== false ? 'Active' : 'Inactive'}
                                                </span>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    )}
                </div>
            )}

            {/* ── ADMINS TAB ── */}
            {activeTab === 'Admins' && (
                <div className="dashboard-card overflow-hidden">
                    {adminsLoading ? <Spinner /> : admins.length === 0 ? <EmptyState icon="👤" label="No admins found" /> : (
                        <div className="divide-y divide-[var(--border)]">
                            {admins.map(a => (
                                <div key={a.id} className="px-6 py-4 flex items-center justify-between hover:bg-[var(--background)] transition-colors">
                                    <div className="flex items-center gap-4">
                                        <div className="w-9 h-9 rounded-full bg-[var(--primary)]/10 flex items-center justify-center text-[var(--primary)] text-sm font-black">
                                            {(a.name || a.email || 'A')[0].toUpperCase()}
                                        </div>
                                        <div>
                                            <p className="text-sm font-semibold text-[var(--foreground)]">{a.name || '—'}</p>
                                            <p className="text-xs text-[var(--foreground)] opacity-50">{a.email}</p>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-3">
                                        <span className={`px-2 py-0.5 text-[10px] font-black uppercase rounded-full ${
                                            a.role === 'master_admin' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'
                                        }`}>{a.role?.replace('_', ' ')}</span>
                                        {a.role !== 'master_admin' && (
                                            <button onClick={() => setAdminToDelete(a)}
                                                className="text-xs text-red-500 hover:text-red-700 font-semibold hover:underline transition-colors">
                                                Remove
                                            </button>
                                        )}
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>
            )}

            {/* Admin Deletion Confirmation Modal */}
            {adminToDelete && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-in fade-in duration-200">
                    <div className="bg-[var(--card)] border border-[var(--border)] rounded-2xl p-6 max-w-sm w-full shadow-2xl animate-in zoom-in-95 duration-200">
                        <div className="w-12 h-12 rounded-full bg-red-100 flex items-center justify-center text-red-600 text-2xl mb-4">
                            🚫
                        </div>
                        <h3 className="text-lg font-bold text-[var(--foreground)] mb-2">Remove Admin?</h3>
                        <p className="text-sm text-[var(--foreground)] opacity-60 mb-6">
                            Are you sure you want to revoke access for <strong>{adminToDelete.email}</strong>? They will no longer be able to access the dashboard.
                        </p>
                        <div className="flex gap-3">
                            <button
                                onClick={() => setAdminToDelete(null)}
                                className="flex-1 px-4 py-2.5 text-sm font-semibold text-[var(--foreground)] bg-[var(--background)] border border-[var(--border)] rounded-lg hover:bg-[var(--border)] transition"
                            >
                                Cancel
                            </button>
                            <button
                                onClick={handleDeleteAdmin}
                                className="flex-1 px-4 py-2.5 text-sm font-semibold text-white bg-red-600 rounded-lg hover:bg-red-700 transition shadow-lg shadow-red-600/20"
                            >
                                Revoke
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
