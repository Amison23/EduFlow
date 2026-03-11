'use client';

import { useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Cookies from 'js-cookie';
import { api } from '@/lib/api';
import { ThemeToggle } from '../components/ThemeToggle';

export default function LoginPage() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const router = useRouter();
    const searchParams = useSearchParams();
    const sessionReason = searchParams.get('session');


    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        try {
            const data = await api.post('/admin/login', { email, password });
            Cookies.set('accessToken', data.token, { expires: 7 });
            localStorage.setItem('adminUser', JSON.stringify(data.admin));
            router.push('/dashboard');
        } catch (err: any) {
            setError(err.message || 'Invalid credentials');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-[var(--background)] transition-colors duration-300">
            <div className="absolute top-4 right-4">
                <ThemeToggle />
            </div>
            <div className="max-w-md w-full p-8 mx-auto bg-[var(--card)] rounded-lg shadow-lg border border-[var(--border)] transition-colors duration-300">
                <div className="text-center mb-8">
                    <h1 className="text-3xl font-extrabold text-[var(--primary)] tracking-tighter">EduFlow</h1>
                    <p className="text-[var(--foreground)] opacity-70 mt-2">NGO Administration Portal</p>
                </div>

                <form onSubmit={handleLogin} className="space-y-6">
                    {sessionReason === 'expired' && (
                        <div className="bg-amber-50 text-amber-800 p-3 rounded-md text-sm font-medium border border-amber-200 flex items-center gap-2">
                            <span>⏱</span>
                            <span>Your session expired. Please log in again to continue.</span>
                        </div>
                    )}
                    {sessionReason === 'unauthorized' && (
                        <div className="bg-red-50 text-red-700 p-3 rounded-md text-sm font-medium border border-red-200 flex items-center gap-2">
                            <span>🔒</span>
                            <span>Access denied. Please log in with an admin account.</span>
                        </div>
                    )}
                    {error && (
                        <div className="bg-red-50 text-red-600 p-3 rounded-md text-sm font-medium border border-red-100 animate-in fade-in slide-in-from-top-1">
                            {error}
                        </div>
                    )}
                    <div>
                        <label htmlFor="email" className="block text-sm font-medium text-[var(--foreground)] opacity-80">Admin Email</label>
                        <input
                            id="email"
                            type="email"
                            required
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            className="mt-1 block w-full px-3 py-2 border border-[var(--border)] bg-[var(--background)] text-[var(--foreground)] rounded-md shadow-sm focus:outline-none focus:ring-[var(--primary)] focus:border-[var(--primary)] transition-all"
                            placeholder="admin@example.com"
                        />
                    </div>

                    <div>
                        <label htmlFor="password" className="block text-sm font-medium text-[var(--foreground)] opacity-80">Access Key</label>
                        <input
                            id="password"
                            type="password"
                            required
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            className="mt-1 block w-full px-3 py-2 border border-[var(--border)] bg-[var(--background)] text-[var(--foreground)] rounded-md shadow-sm focus:outline-none focus:ring-[var(--primary)] focus:border-[var(--primary)] transition-all"
                            placeholder="••••••••"
                        />
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-[var(--primary)] hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-[var(--primary)] transition-all disabled:opacity-50"
                    >
                        {loading ? 'Authenticating...' : 'Authorize Access'}
                    </button>
                </form>

                <div className="mt-8 pt-6 border-t border-[var(--border)] text-center">
                    <p className="text-xs text-[var(--foreground)] opacity-50">
                        This is a private administrative system. Unauthorized access is strictly prohibited.
                    </p>
                </div>
            </div>
        </div>
    );
}
