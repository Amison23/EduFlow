import Link from 'next/link';
import { ReactNode, useState } from 'react';
import Cookies from 'js-cookie';
import { ThemeToggle } from '../../components/ThemeToggle';

export default function DashboardLayout({ children }: { children: ReactNode }) {
    const [isMenuOpen, setIsMenuOpen] = useState(false);

    return (
        <div className="min-h-screen bg-[var(--background)] text-[var(--foreground)] font-sans transition-colors duration-300">
            <nav className="bg-[var(--card)] shadow-sm border-b border-[var(--border)] sticky top-0 z-50 transition-colors duration-300">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex justify-between h-16">
                        <div className="flex">
                            <div className="flex-shrink-0 flex items-center">
                                <span className="text-2xl font-black text-[var(--primary)] tracking-tighter">EduFlow</span>
                            </div>
                            {/* Desktop Menu */}
                            <div className="hidden sm:ml-8 sm:flex sm:space-x-8">
                                <Link href="/dashboard" className="text-[var(--foreground)] inline-flex items-center px-1 pt-1 border-b-2 border-[var(--primary)] text-sm font-semibold">Overview</Link>
                                <Link href="/dashboard/learners" className="text-[var(--foreground)] opacity-60 hover:opacity-100 inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium transition-colors">Learners</Link>
                                <Link href="/dashboard/packs" className="text-[var(--foreground)] opacity-60 hover:opacity-100 inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium transition-colors">Lesson Packs</Link>
                                <Link href="/dashboard/groups" className="text-[var(--foreground)] opacity-60 hover:opacity-100 inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium transition-colors">Study Groups</Link>
                                <Link href="/dashboard/database" className="text-[var(--foreground)] opacity-60 hover:opacity-100 inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium transition-colors">Database</Link>
                                <Link href="/dashboard/settings" className="text-[var(--foreground)] opacity-60 hover:opacity-100 inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium transition-colors">Settings</Link>
                            </div>
                        </div>

                        {/* Mobile Menu Button */}
                        <div className="sm:hidden flex items-center">
                            <button 
                                onClick={() => setIsMenuOpen(!isMenuOpen)}
                                className="inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none"
                            >
                                <svg className="h-6 w-6" stroke="currentColor" fill="none" viewBox="0 0 24 24">
                                    {isMenuOpen ? (
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                                    ) : (
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />
                                    )}
                                </svg>
                            </button>
                        </div>

                        <div className="hidden sm:flex items-center space-x-4">
                            <ThemeToggle />
                            <span className="text-xs font-bold uppercase tracking-wider text-[var(--foreground)] opacity-40 bg-[var(--background)] py-1 px-3 rounded-md">Demo NGO</span>
                            <button 
                                onClick={() => {
                                    Cookies.remove('accessToken');
                                    Cookies.remove('refreshToken');
                                    localStorage.removeItem('adminUser');
                                    window.location.href = '/';
                                }}
                                className="text-sm font-medium text-[var(--foreground)] opacity-60 hover:text-red-600 transition-colors"
                            >
                                Logout
                            </button>
                        </div>
                    </div>
                </div>

                {/* Mobile Menu Content */}
                {isMenuOpen && (
                    <div className="sm:hidden bg-[var(--card)] border-b border-[var(--border)] px-2 pt-2 pb-3 space-y-1 shadow-lg animate-in slide-in-from-top duration-200">
                        <div className="flex justify-between items-center px-3 py-2">
                            <span className="text-sm font-medium">Theme</span>
                            <ThemeToggle />
                        </div>
                        <Link href="/dashboard" className="block px-3 py-2 rounded-md text-base font-semibold text-[var(--foreground)] bg-[var(--background)]">Overview</Link>
                        <Link href="/dashboard/learners" className="block px-3 py-2 rounded-md text-base font-medium text-[var(--foreground)] opacity-60 hover:opacity-100 hover:bg-[var(--background)]">Learners</Link>
                        <Link href="/dashboard/packs" className="block px-3 py-2 rounded-md text-base font-medium text-[var(--foreground)] opacity-60 hover:opacity-100 hover:bg-[var(--background)]">Lesson Packs</Link>
                        <Link href="/dashboard/groups" className="block px-3 py-2 rounded-md text-base font-medium text-[var(--foreground)] opacity-60 hover:opacity-100 hover:bg-[var(--background)]">Study Groups</Link>
                        <Link href="/dashboard/database" className="block px-3 py-2 rounded-md text-base font-medium text-[var(--foreground)] opacity-60 hover:opacity-100 hover:bg-[var(--background)]">Database</Link>
                        <Link href="/dashboard/settings" className="block px-3 py-2 rounded-md text-base font-medium text-[var(--foreground)] opacity-60 hover:opacity-100 hover:bg-[var(--background)]">Settings</Link>
                        <button 
                            onClick={() => {
                                Cookies.remove('accessToken');
                                Cookies.remove('refreshToken');
                                localStorage.removeItem('adminUser');
                                window.location.href = '/';
                            }}
                            className="block w-full text-left px-3 py-2 rounded-md text-base font-medium text-red-500 hover:bg-red-50/10"
                        >
                            Logout
                        </button>
                    </div>
                )}
            </nav>

            <main className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
                {children}
            </main>
        </div>
    );
}
