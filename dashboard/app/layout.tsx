import type { ReactNode } from 'react'
import './globals.css'

export const metadata = {
    title: 'EduFlow Dashboard',
    description: 'NGO Dashboard for managing learner cohorts',
}

import { ThemeProvider } from '../components/ThemeProvider'
import { ToastProvider } from '../components/ToastProvider'

export default function RootLayout({
    children,
}: {
    children: ReactNode
}) {
    return (
        <html lang="en" suppressHydrationWarning>
            <body>
                <ThemeProvider attribute="data-theme" defaultTheme="system" enableSystem>
                    <ToastProvider>
                        {children}
                    </ToastProvider>
                </ThemeProvider>
            </body>
        </html>
    )
}
