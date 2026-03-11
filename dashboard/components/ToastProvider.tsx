'use client';

import { createContext, useCallback, useContext, useState, ReactNode } from 'react';

type ToastType = 'success' | 'error' | 'info' | 'warning';

interface Toast {
    id: string;
    type: ToastType;
    message: string;
    duration?: number;
}

interface ToastContextValue {
    toast: (message: string, type?: ToastType, duration?: number) => void;
    success: (message: string) => void;
    error: (message: string) => void;
    info: (message: string) => void;
    warning: (message: string) => void;
}

const ToastContext = createContext<ToastContextValue | null>(null);

const ICONS: Record<ToastType, string> = {
    success: '✓',
    error: '✕',
    info: 'ℹ',
    warning: '⚠',
};

const STYLES: Record<ToastType, string> = {
    success: 'bg-emerald-600 text-white',
    error: 'bg-red-600 text-white',
    info: 'bg-blue-600 text-white',
    warning: 'bg-amber-500 text-white',
};

export function ToastProvider({ children }: { children: ReactNode }) {
    const [toasts, setToasts] = useState<Toast[]>([]);

    const dismiss = useCallback((id: string) => {
        setToasts(prev => prev.filter(t => t.id !== id));
    }, []);

    const toast = useCallback((message: string, type: ToastType = 'info', duration = 4000) => {
        const id = Math.random().toString(36).slice(2);
        setToasts(prev => [...prev, { id, type, message, duration }]);
        setTimeout(() => dismiss(id), duration);
    }, [dismiss]);

    const success = useCallback((msg: string) => toast(msg, 'success'), [toast]);
    const error   = useCallback((msg: string) => toast(msg, 'error', 5000), [toast]);
    const info    = useCallback((msg: string) => toast(msg, 'info'), [toast]);
    const warning = useCallback((msg: string) => toast(msg, 'warning'), [toast]);

    return (
        <ToastContext.Provider value={{ toast, success, error, info, warning }}>
            {children}
            {/* Toast Container */}
            <div
                aria-live="polite"
                className="fixed bottom-4 right-4 z-[9999] flex flex-col gap-2 max-w-sm w-full pointer-events-none"
            >
                {toasts.map(t => (
                    <div
                        key={t.id}
                        className={`flex items-start gap-3 px-4 py-3 rounded-xl shadow-2xl pointer-events-auto
                            animate-in slide-in-from-bottom-2 fade-in duration-300
                            ${STYLES[t.type]}`}
                        role="alert"
                    >
                        <span className="flex-shrink-0 w-5 h-5 rounded-full bg-white/20 flex items-center justify-center text-xs font-bold mt-0.5">
                            {ICONS[t.type]}
                        </span>
                        <p className="text-sm font-medium flex-1 leading-snug">{t.message}</p>
                        <button
                            onClick={() => dismiss(t.id)}
                            className="flex-shrink-0 opacity-70 hover:opacity-100 text-lg leading-none mt-0.5"
                            aria-label="Dismiss"
                        >
                            ×
                        </button>
                    </div>
                ))}
            </div>
        </ToastContext.Provider>
    );
}

export function useToast(): ToastContextValue {
    const ctx = useContext(ToastContext);
    if (!ctx) throw new Error('useToast must be used inside <ToastProvider>');
    return ctx;
}
