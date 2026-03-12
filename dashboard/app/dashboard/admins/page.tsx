'use client';

import { useState, useEffect, useCallback } from 'react';
import { api } from '@/lib/api';
import { useToast } from '@/components/ToastProvider';

interface Admin {
    id: string;
    email: string;
    name: string;
    role: string;
    last_login?: string;
    created_at: string;
}

export default function ManageAdminsPage() {
    const [admins, setAdmins] = useState<Admin[]>([]);
    const [loading, setLoading] = useState(true);
    const [showForm, setShowForm] = useState(false);
    const [form, setForm] = useState({ email: '', name: '', password: '', role: 'admin' });
    const [showPassword, setShowPassword] = useState(false);
    const [submitting, setSubmitting] = useState(false);
    const { success, error: toastError, info } = useToast();

    const fetchAdmins = useCallback(async () => {
        try {
            setLoading(true);
            const data = await api.getAllAdmins();
            setAdmins(Array.isArray(data) ? data : []);
        } catch (e: any) {
            toastError(e.message || 'Failed to load admins');
        } finally {
            setLoading(false);
        }
    }, [toastError]);

    useEffect(() => { fetchAdmins(); }, [fetchAdmins]);

    const handleCreate = async (e: React.FormEvent) => {
        e.preventDefault();
        setSubmitting(true);
        try {
            await api.createAdmin(form);
            success('Admin created successfully!');
            setShowForm(false);
            setForm({ email: '', name: '', password: '', role: 'admin' });
            setShowPassword(false);
            fetchAdmins();
        } catch (e: any) {
            toastError(e.message || 'Failed to create admin');
        } finally {
            setSubmitting(false);
        }
    };

    const [adminToDelete, setAdminToDelete] = useState<Admin | null>(null);

    const handleDelete = async () => {
        if (!adminToDelete) return;
        info(`Deleting ${adminToDelete.email}…`);
        try {
            await api.deleteAdmin(adminToDelete.id);
            success(`Admin ${adminToDelete.email} removed.`);
            fetchAdmins();
        } catch (e: any) {
            toastError(e.message || 'Failed to delete');
        } finally {
            setAdminToDelete(null);
        }
    };

    const formatDate = (d?: string) => {
        if (!d) return '—';
        return new Date(d).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
    };

    const roleBadge = (role: string) => {
        const styles: Record<string, string> = {
            master_admin: 'bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300',
            admin: 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300',
            ngo: 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300',
        };
        return (
            <span className={`inline-block px-2 py-0.5 rounded-full text-xs font-bold uppercase tracking-wide ${styles[role] || 'bg-gray-100 text-gray-600'}`}>
                {role.replace('_', ' ')}
            </span>
        );
    };

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-[var(--foreground)]">Manage Admins</h1>
                    <p className="text-sm text-[var(--foreground)] opacity-60 mt-1">
                        Create and manage administrator accounts for this dashboard.
                    </p>
                </div>
                <button
                    type="button"
                    onClick={() => { setShowForm(!showForm); setShowPassword(false); }}
                    className="flex items-center gap-2 px-4 py-2 rounded-lg bg-[var(--primary)] text-white text-sm font-semibold hover:opacity-90 transition-opacity"
                >
                    <span>{showForm ? '✕ Cancel' : '+ New Admin'}</span>
                </button>
            </div>


            {/* Create Admin Form */}
            {showForm && (
                <div className="dashboard-card p-6">
                    <h2 className="text-lg font-semibold text-[var(--foreground)] mb-4">New Administrator</h2>
                    <form onSubmit={handleCreate} className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label className="block text-xs font-semibold text-[var(--foreground)] opacity-70 mb-1 uppercase tracking-wide">Full Name</label>
                            <input
                                required
                                value={form.name}
                                onChange={e => setForm({ ...form, name: e.target.value })}
                                placeholder="Jane Doe"
                                className="w-full px-3 py-2 border border-[var(--border)] bg-[var(--background)] text-[var(--foreground)] rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[var(--primary)]"
                            />
                        </div>
                        <div>
                            <label className="block text-xs font-semibold text-[var(--foreground)] opacity-70 mb-1 uppercase tracking-wide">Email</label>
                            <input
                                required type="email"
                                value={form.email}
                                onChange={e => setForm({ ...form, email: e.target.value })}
                                placeholder="jane@eduflow.org"
                                className="w-full px-3 py-2 border border-[var(--border)] bg-[var(--background)] text-[var(--foreground)] rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[var(--primary)]"
                            />
                        </div>
                        <div>
                            <label className="block text-xs font-semibold text-[var(--foreground)] opacity-70 mb-1 uppercase tracking-wide">Password</label>
                            <div className="relative">
                                <input
                                    required type={showPassword ? 'text' : 'password'} minLength={8}
                                    value={form.password}
                                    onChange={e => setForm({ ...form, password: e.target.value })}
                                    placeholder="Min. 8 characters"
                                    className="w-full px-3 py-2 pr-10 border border-[var(--border)] bg-[var(--background)] text-[var(--foreground)] rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[var(--primary)]"
                                />
                                <button type="button" onClick={() => setShowPassword(v => !v)}
                                    className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[var(--foreground)] opacity-40 hover:opacity-80 transition-opacity">
                                    {showPassword ? (
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}><path strokeLinecap="round" strokeLinejoin="round" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" /></svg>
                                    ) : (
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}><path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path strokeLinecap="round" strokeLinejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                                    )}
                                </button>
                            </div>
                        </div>
                        <div>
                            <label className="block text-xs font-semibold text-[var(--foreground)] opacity-70 mb-1 uppercase tracking-wide">Role</label>
                            <select
                                value={form.role}
                                onChange={e => setForm({ ...form, role: e.target.value })}
                                className="w-full px-3 py-2 border border-[var(--border)] bg-[var(--background)] text-[var(--foreground)] rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[var(--primary)]"
                            >
                                <option value="admin">Standard Admin</option>
                                <option value="master_admin">Master Admin</option>
                                <option value="ngo">NGO Viewer</option>
                            </select>
                        </div>
                        <div className="col-span-full flex justify-end gap-3 pt-2 border-t border-[var(--border)]">
                            <button
                                type="button"
                                onClick={() => setShowForm(false)}
                                className="px-4 py-2 text-sm font-medium text-[var(--foreground)] opacity-60 hover:opacity-100 transition-opacity"
                            >
                                Cancel
                            </button>
                            <button
                                type="submit"
                                disabled={submitting}
                                className="px-5 py-2 rounded-lg bg-[var(--primary)] text-white text-sm font-semibold hover:opacity-90 disabled:opacity-50 transition-opacity"
                            >
                                {submitting ? 'Creating...' : 'Create Admin'}
                            </button>
                        </div>
                    </form>
                </div>
            )}

            {/* Admin List */}
            {loading ? (
                <div className="dashboard-card p-12 flex items-center justify-center">
                    <div className="animate-spin w-8 h-8 border-4 border-[var(--primary)] border-t-transparent rounded-full" />
                </div>
            ) : (
                <div className="dashboard-card overflow-hidden">
                    <div className="px-6 py-4 border-b border-[var(--border)]">
                        <h2 className="text-sm font-semibold text-[var(--foreground)] opacity-70 uppercase tracking-wide">
                            {admins.length} Admin{admins.length !== 1 ? 's' : ''} registered
                        </h2>
                    </div>
                    <div className="overflow-x-auto">
                        <table className="w-full text-sm">
                            <thead>
                                <tr className="border-b border-[var(--border)] text-[var(--foreground)] opacity-50">
                                    <th className="text-left px-6 py-3 text-xs font-semibold uppercase tracking-wide">Name</th>
                                    <th className="text-left px-6 py-3 text-xs font-semibold uppercase tracking-wide">Email</th>
                                    <th className="text-left px-6 py-3 text-xs font-semibold uppercase tracking-wide">Role</th>
                                    <th className="text-left px-6 py-3 text-xs font-semibold uppercase tracking-wide">Last Login</th>
                                    <th className="text-left px-6 py-3 text-xs font-semibold uppercase tracking-wide">Created</th>
                                    <th className="text-right px-6 py-3 text-xs font-semibold uppercase tracking-wide">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {admins.map((a, i) => (
                                    <tr key={a.id} className={`border-b border-[var(--border)] hover:bg-[var(--background)] transition-colors ${i === admins.length - 1 ? 'border-b-0' : ''}`}>
                                        <td className="px-6 py-4 font-medium text-[var(--foreground)]">{a.name || '—'}</td>
                                        <td className="px-6 py-4 text-[var(--foreground)] opacity-80">{a.email}</td>
                                        <td className="px-6 py-4">{roleBadge(a.role)}</td>
                                        <td className="px-6 py-4 text-[var(--foreground)] opacity-60">{formatDate(a.last_login)}</td>
                                        <td className="px-6 py-4 text-[var(--foreground)] opacity-60">{formatDate(a.created_at)}</td>
                                        <td className="px-6 py-4 text-right">
                                            {a.role !== 'master_admin' && (
                                                <button
                                                    type="button"
                                                    onClick={() => setAdminToDelete(a)}
                                                    className="text-xs font-semibold text-red-500 hover:text-red-700 hover:underline transition-colors"
                                                >
                                                    Delete
                                                </button>
                                            )}
                                            {a.role === 'master_admin' && (
                                                <span className="text-xs text-[var(--foreground)] opacity-30">Protected</span>
                                            )}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
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
                                type="button"
                                onClick={() => setAdminToDelete(null)}
                                className="flex-1 px-4 py-2.5 text-sm font-semibold text-[var(--foreground)] bg-[var(--background)] border border-[var(--border)] rounded-lg hover:bg-[var(--border)] transition"
                            >
                                Cancel
                            </button>
                            <button
                                type="button"
                                onClick={handleDelete}
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
