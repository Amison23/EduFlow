'use client';

import { useState, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Cookies from 'js-cookie';
import { api } from '@/lib/api';
import { ThemeToggle } from '../components/ThemeToggle';
import { useToast } from '../components/ToastProvider';

function LoginForm() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [loading, setLoading] = useState(false);
    const router = useRouter();
    const searchParams = useSearchParams();
    const sessionReason = searchParams.get('session');
    const { error: toastError } = useToast();

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        try {
            const data = await api.post('/admin/login', { email, password });
            Cookies.set('accessToken', data.token, { expires: 7 });
            localStorage.setItem('adminUser', JSON.stringify(data.admin));
            router.push('/dashboard');
        } catch (err: any) {
            toastError(err.message || 'Invalid credentials. Please try again.');
        } finally {
            setLoading(false);
        }
    };

    const inputClass = "block w-full px-4 py-3 border border-[var(--border)] bg-[var(--background)] text-[var(--foreground)] rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-[var(--primary)] focus:border-[var(--primary)] transition-all text-sm placeholder:opacity-40";

    return (
        <div className="min-h-screen flex items-center justify-center bg-[var(--background)] transition-colors duration-300 px-4">
            <div className="absolute top-4 right-4">
                <ThemeToggle />
            </div>

            <div className="w-full max-w-md">
                {/* Logo */}
                <div className="text-center mb-8">
                    <h1 className="text-4xl font-black text-[var(--primary)] tracking-tighter">EduFlow</h1>
                    <p className="text-[var(--foreground)] opacity-60 mt-2 text-sm">NGO Administration Portal</p>
                </div>

                <div className="bg-[var(--card)] rounded-2xl shadow-xl border border-[var(--border)] p-8 transition-colors duration-300">
                    {/* Session banners */}
                    {sessionReason === 'expired' && (
                        <div className="mb-6 bg-amber-50 text-amber-800 px-4 py-3 rounded-lg text-sm font-medium border border-amber-200 flex items-center gap-2">
                            <span>⏱</span>
                            <span>Your session expired. Please log in again to continue.</span>
                        </div>
                    )}
                    {sessionReason === 'unauthorized' && (
                        <div className="mb-6 bg-red-50 text-red-700 px-4 py-3 rounded-lg text-sm font-medium border border-red-200 flex items-center gap-2">
                            <span>🔒</span>
                            <span>Access denied. Please log in with an admin account.</span>
                        </div>
                    )}

                    <form onSubmit={handleLogin} className="space-y-5">
                        {/* Email */}
                        <div>
                            <label htmlFor="email" className="block text-xs font-semibold text-[var(--foreground)] opacity-70 uppercase tracking-wide mb-1.5">
                                Admin Email
                            </label>
                            <input
                                id="email"
                                type="email"
                                required
                                autoComplete="email"
                                value={email}
                                onChange={e => setEmail(e.target.value)}
                                className={inputClass}
                                placeholder="admin@example.com"
                            />
                        </div>

                        {/* Password with eye toggle */}
                        <div>
                            <label htmlFor="password" className="block text-xs font-semibold text-[var(--foreground)] opacity-70 uppercase tracking-wide mb-1.5">
                                Access Key
                            </label>
                            <div className="relative">
                                <input
                                    id="password"
                                    type={showPassword ? 'text' : 'password'}
                                    required
                                    autoComplete="current-password"
                                    value={password}
                                    onChange={e => setPassword(e.target.value)}
                                    className={inputClass + ' pr-12'}
                                    placeholder="••••••••"
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowPassword(v => !v)}
                                    className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--foreground)] opacity-40 hover:opacity-80 transition-opacity p-1"
                                    aria-label={showPassword ? 'Hide password' : 'Show password'}
                                >
                                    {showPassword ? (
                                        // Eye-off icon
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                                            <path strokeLinecap="round" strokeLinejoin="round" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
                                        </svg>
                                    ) : (
                                        // Eye icon
                                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                                            <path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                            <path strokeLinecap="round" strokeLinejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                        </svg>
                                    )}
                                </button>
                            </div>
                        </div>

                        <button
                            type="submit"
                            disabled={loading}
                            className="w-full py-3 px-4 rounded-lg font-semibold text-sm text-white bg-[var(--primary)] hover:opacity-90 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-[var(--primary)] transition-all disabled:opacity-50 shadow-md mt-2"
                        >
                            {loading ? (
                                <span className="flex items-center justify-center gap-2">
                                    <svg className="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24">
                                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                                    </svg>
                                    Authenticating…
                                </span>
                            ) : 'Authorize Access'}
                        </button>
                    </form>

                    <p className="mt-6 text-center text-xs text-[var(--foreground)] opacity-40">
                        Private administrative system. Unauthorized access is strictly prohibited.
                    </p>
                </div>
            </div>
        </div>
    );
}

export default function LoginPage() {
    return (
        <Suspense>
            <LoginForm />
        </Suspense>
    );
}
