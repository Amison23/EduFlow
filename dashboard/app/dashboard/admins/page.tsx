'use client';

import { useState, useEffect } from 'react';
import { api } from '@/lib/api';

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
    const [error, setError] = useState('');
    const [showForm, setShowForm] = useState(false);
    const [form, setForm] = useState({ email: '', name: '', password: '', role: 'admin' });
    const [submitting, setSubmitting] = useState(false);
    const [formError, setFormError] = useState('');
    const [success, setSuccess] = useState('');

    const fetchAdmins = async () => {
        try {
            setLoading(true);
            const data = await api.getAllAdmins();
            setAdmins(Array.isArray(data) ? data : []);
        } catch (e: any) {
            setError(e.message || 'Failed to load admins');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => { fetchAdmins(); }, []);

    const handleCreate = async (e: React.FormEvent) => {
        e.preventDefault();
        setSubmitting(true);
        setFormError('');
        try {
            await api.createAdmin(form);
            setSuccess('Admin created successfully!');
            setShowForm(false);
            setForm({ email: '', name: '', password: '', role: 'admin' });
            fetchAdmins();
        } catch (e: any) {
            setFormError(e.message || 'Failed to create admin');
        } finally {
            setSubmitting(false);
        }
    };

    const handleDelete = async (id: string, email: string) => {
        if (!confirm(`Delete admin "${email}"? This cannot be undone.`)) return;
        try {
            await api.deleteAdmin(id);
            setSuccess(`Admin ${email} deleted.`);
            fetchAdmins();
        } catch (e: any) {
            setError(e.message || 'Failed to delete');
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
                    onClick={() => { setShowForm(!showForm); setFormError(''); setSuccess(''); }}
                    className="flex items-center gap-2 px-4 py-2 rounded-lg bg-[var(--primary)] text-white text-sm font-semibold hover:opacity-90 transition-opacity"
                >
                    <span>{showForm ? '✕ Cancel' : '+ New Admin'}</span>
                </button>
            </div>

            {/* Success banner */}
            {success && (
                <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg text-sm font-medium flex justify-between items-center">
                    {success}
                    <button onClick={() => setSuccess('')} className="opacity-60 hover:opacity-100">✕</button>
                </div>
            )}

            {/* Create Admin Form */}
            {showForm && (
                <div className="dashboard-card p-6">
                    <h2 className="text-lg font-semibold text-[var(--foreground)] mb-4">New Administrator</h2>
                    <form onSubmit={handleCreate} className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        {formError && (
                            <div className="col-span-full bg-red-50 border border-red-200 text-red-700 px-4 py-2 rounded-lg text-sm">
                                {formError}
                            </div>
                        )}
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
                            <input
                                required type="password" minLength={8}
                                value={form.password}
                                onChange={e => setForm({ ...form, password: e.target.value })}
                                placeholder="Min. 8 characters"
                                className="w-full px-3 py-2 border border-[var(--border)] bg-[var(--background)] text-[var(--foreground)] rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[var(--primary)]"
                            />
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
            ) : error ? (
                <div className="dashboard-card p-6 text-center text-[var(--foreground)] opacity-60">
                    <p className="text-red-500">{error}</p>
                    <button onClick={fetchAdmins} className="mt-2 text-[var(--primary)] text-sm hover:underline">Retry</button>
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
                                                    onClick={() => handleDelete(a.id, a.email)}
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
        </div>
    );
}
