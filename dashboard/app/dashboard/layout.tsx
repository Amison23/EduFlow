'use client';

import Link from 'next/link';
import { ReactNode, useState } from 'react';

export default function DashboardLayout({ children }: { children: ReactNode }) {
    const [isMenuOpen, setIsMenuOpen] = useState(false);

    return (
        <div className="min-h-screen bg-gray-50 font-sans">
            <nav className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-50">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex justify-between h-16">
                        <div className="flex">
                            <div className="flex-shrink-0 flex items-center">
                                <span className="text-2xl font-black text-blue-600 tracking-tighter">EduFlow</span>
                            </div>
                            {/* Desktop Menu */}
                            <div className="hidden sm:ml-8 sm:flex sm:space-x-8">
                                <Link href="/dashboard" className="text-gray-900 inline-flex items-center px-1 pt-1 border-b-2 border-blue-500 text-sm font-semibold">Overview</Link>
                                <Link href="/dashboard/learners" className="text-gray-500 hover:text-gray-700 hover:border-gray-300 inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium transition-colors">Learners</Link>
                                <Link href="/dashboard/packs" className="text-gray-500 hover:text-gray-700 hover:border-gray-300 inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium transition-colors">Lesson Packs</Link>
                                <Link href="/dashboard/groups" className="text-gray-500 hover:text-gray-700 hover:border-gray-300 inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium transition-colors">Study Groups</Link>
                                <Link href="/dashboard/database" className="text-gray-500 hover:text-gray-700 hover:border-gray-300 inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium transition-colors">Database</Link>
                                <Link href="/dashboard/settings" className="text-gray-500 hover:text-gray-700 hover:border-gray-300 inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium transition-colors">Settings</Link>
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
                            <span className="text-xs font-bold uppercase tracking-wider text-gray-400 bg-gray-100 py-1 px-3 rounded-md">Demo NGO</span>
                            <Link href="/" className="text-sm font-medium text-gray-500 hover:text-red-600 transition-colors">Logout</Link>
                        </div>
                    </div>
                </div>

                {/* Mobile Menu Content */}
                {isMenuOpen && (
                    <div className="sm:hidden bg-white border-b border-gray-200 px-2 pt-2 pb-3 space-y-1 shadow-lg animate-in slide-in-from-top duration-200">
                        <Link href="/dashboard" className="block px-3 py-2 rounded-md text-base font-semibold text-gray-900 bg-gray-50">Overview</Link>
                        <Link href="/dashboard/learners" className="block px-3 py-2 rounded-md text-base font-medium text-gray-500 hover:text-gray-900 hover:bg-gray-50">Learners</Link>
                        <Link href="/dashboard/packs" className="block px-3 py-2 rounded-md text-base font-medium text-gray-500 hover:text-gray-900 hover:bg-gray-50">Lesson Packs</Link>
                        <Link href="/dashboard/groups" className="block px-3 py-2 rounded-md text-base font-medium text-gray-500 hover:text-gray-900 hover:bg-gray-50">Study Groups</Link>
                        <Link href="/dashboard/database" className="block px-3 py-2 rounded-md text-base font-medium text-gray-500 hover:text-gray-900 hover:bg-gray-50">Database</Link>
                        <Link href="/dashboard/settings" className="block px-3 py-2 rounded-md text-base font-medium text-gray-500 hover:text-gray-900 hover:bg-gray-50">Settings</Link>
                        <Link href="/" className="block px-3 py-2 rounded-md text-base font-medium text-red-500 hover:bg-red-50">Logout</Link>
                    </div>
                )}
            </nav>

            <main className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
                {children}
            </main>
        </div>
    );
}
