'use client';

import Link from 'next/link';
import { ReactNode, useState, useEffect, useCallback } from 'react';
import { usePathname } from 'next/navigation';
import { ThemeToggle } from '../../components/ThemeToggle';
import { getTokenSecondsRemaining, isSessionExpired, forceLogout } from '../../lib/session';

interface AdminUser {
    id: string;
    email: string;
    name: string;
    role: string;
}

export default function DashboardLayout({ children }: { children: ReactNode }) {
    const pathname = usePathname();
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const [admin, setAdmin] = useState<AdminUser | null>(null);
    const [sessionWarning, setSessionWarning] = useState<number | null>(null); // seconds remaining

    const checkSession = useCallback(() => {
        if (isSessionExpired()) {
            forceLogout('expired');
            return;
        }
        const secs = getTokenSecondsRemaining();
        setSessionWarning(secs < 300 ? secs : null); // warn when <5 min left
    }, []);

    useEffect(() => {
        try {
            const stored = localStorage.getItem('adminUser');
            if (stored) setAdmin(JSON.parse(stored));
        } catch {}

        checkSession();
        const interval = setInterval(checkSession, 30_000); // check every 30s
        return () => clearInterval(interval);
    }, []);

    const isMasterAdmin = admin?.role === 'master_admin';

    const allNavLinks = [
        { href: '/dashboard', label: 'Overview', exact: true, masterOnly: false },
        { href: '/dashboard/learners', label: 'Learners', exact: false, masterOnly: true },
        { href: '/dashboard/analytics', label: 'Analytics', exact: false, masterOnly: false },
        { href: '/dashboard/packs', label: 'Lesson Packs', exact: false, masterOnly: false },
        { href: '/dashboard/groups', label: 'Study Groups', exact: false, masterOnly: false },
        { href: '/dashboard/admins', label: 'Manage Admins', exact: false, masterOnly: true },
        { href: '/dashboard/database', label: 'Data Manager', exact: false, masterOnly: true },
        { href: '/dashboard/settings', label: 'Settings', exact: false, masterOnly: false },
    ];

    const navLinks = allNavLinks.filter(l => !l.masterOnly || isMasterAdmin);

    const isActive = (href: string, exact: boolean) => {
        if (exact) return pathname === href;
        // Prevent '/dashboard' from matching '/dashboard/analytics'
        // by requiring the match to be followed by '/' or end-of-string
        return pathname === href || pathname.startsWith(href + '/');
    };

    const linkClass = (href: string, exact: boolean) =>
        `inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium transition-all duration-150 ${
            isActive(href, exact)
                ? 'border-[var(--primary)] text-[var(--primary)] font-semibold'
                : 'border-transparent text-[var(--foreground)] opacity-70 hover:opacity-100 hover:border-[var(--border)]'
        }`;

    const mobileLinkClass = (href: string, exact: boolean) =>
        `block px-4 py-2.5 rounded-lg text-sm font-medium transition-all duration-150 ${
            isActive(href, exact)
                ? 'bg-[var(--primary)]/10 text-[var(--primary)] font-semibold'
                : 'text-[var(--foreground)] opacity-70 hover:opacity-100 hover:bg-[var(--background)]'
        }`;

    const handleLogout = () => forceLogout();

    const fmtCountdown = (secs: number) => {
        const m = Math.floor(secs / 60);
        const s = secs % 60;
        return m > 0 ? `${m}m ${s}s` : `${s}s`;
    };

    return (
        <div className="min-h-screen bg-[var(--background)] text-[var(--foreground)] font-sans transition-colors duration-300">
            {/* Session expiry warning banner */}
            {sessionWarning !== null && (
                <div className="sticky top-0 z-[60] bg-amber-500 text-white px-4 py-2 flex items-center justify-between text-sm font-medium shadow-md">
                    <span>
                        ⚠️ Your session expires in <strong>{fmtCountdown(sessionWarning)}</strong>. Save your work.
                    </span>
                    <div className="flex items-center gap-3">
                        <button
                            onClick={() => forceLogout()}
                            className="underline font-bold hover:opacity-80 text-xs"
                        >
                            Logout now
                        </button>
                        <button onClick={() => setSessionWarning(null)} className="opacity-70 hover:opacity-100">✕</button>
                    </div>
                </div>
            )}
            <nav className="bg-[var(--card)] shadow-sm border-b border-[var(--border)] sticky top-0 z-50 transition-colors duration-300">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex justify-between h-16">
                        {/* Logo + Desktop Nav */}
                        <div className="flex items-center">
                            <Link href="/dashboard" className="flex-shrink-0">
                                <span className="text-xl font-black text-[var(--primary)] tracking-tighter">EduFlow</span>
                            </Link>
                            <div className="hidden sm:ml-8 sm:flex sm:space-x-1">
                                {navLinks.map(link => (
                                    <Link key={link.href} href={link.href} className={linkClass(link.href, link.exact)}>
                                        {link.label}
                                        {link.masterOnly && (
                                            <span className="ml-1 text-[10px] font-bold uppercase text-[var(--primary)] opacity-60">★</span>
                                        )}
                                    </Link>
                                ))}
                            </div>
                        </div>

                        {/* Right side: theme + user + logout */}
                        <div className="hidden sm:flex items-center gap-3">
                            <ThemeToggle />
                            <div className="flex flex-col items-end leading-tight">
                                <span className="text-sm font-semibold text-[var(--foreground)]">{admin?.name || 'Admin'}</span>
                                <span className="text-[10px] uppercase tracking-wider font-bold text-[var(--primary)] opacity-70">
                                    {admin?.role?.replace(/_/g, ' ') || 'admin'}
                                </span>
                            </div>
                            <button
                                onClick={handleLogout}
                                className="ml-1 text-xs font-semibold px-3 py-1.5 rounded-md border border-[var(--border)] text-[var(--foreground)] opacity-60 hover:opacity-100 hover:border-red-500 hover:text-red-500 transition-all"
                            >
                                Logout
                            </button>
                        </div>

                        {/* Mobile hamburger */}
                        <div className="sm:hidden flex items-center gap-2">
                            <ThemeToggle />
                            <button
                                onClick={() => setIsMenuOpen(!isMenuOpen)}
                                className="inline-flex items-center justify-center p-2 rounded-md text-[var(--foreground)] opacity-60 hover:opacity-100 focus:outline-none"
                                aria-label="Toggle menu"
                            >
                                <svg className="h-6 w-6" stroke="currentColor" fill="none" viewBox="0 0 24 24">
                                    {isMenuOpen
                                        ? <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                                        : <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />}
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>

                {/* Mobile Menu */}
                {isMenuOpen && (
                    <div className="sm:hidden bg-[var(--card)] border-t border-[var(--border)] px-3 pt-2 pb-4 space-y-1 shadow-lg">
                        <div className="flex items-center gap-2 px-4 py-3 mb-2 rounded-lg bg-[var(--background)] border border-[var(--border)]">
                            <div>
                                <p className="text-sm font-semibold text-[var(--foreground)]">{admin?.name || 'Admin'}</p>
                                <p className="text-[10px] uppercase tracking-wider font-bold text-[var(--primary)] opacity-70">
                                    {admin?.role?.replace(/_/g, ' ')}
                                </p>
                            </div>
                        </div>
                        {navLinks.map(link => (
                            <Link
                                key={link.href}
                                href={link.href}
                                onClick={() => setIsMenuOpen(false)}
                                className={mobileLinkClass(link.href, link.exact)}
                            >
                                {link.label}
                            </Link>
                        ))}
                        <div className="pt-2 border-t border-[var(--border)] mt-2">
                            <button
                                onClick={handleLogout}
                                className="w-full text-left px-4 py-2.5 rounded-lg text-sm font-medium text-red-500 hover:bg-red-500/10 transition-all"
                            >
                                Logout
                            </button>
                        </div>
                    </div>
                )}
            </nav>

            <main className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
                {children}
            </main>
        </div>
    );
}
