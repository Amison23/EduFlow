import type { ReactNode } from 'react'
import './globals.css'

export const metadata = {
    title: 'EduFlow Dashboard',
    description: 'NGO Dashboard for managing learner cohorts',
}

import { ThemeProvider } from '../components/ThemeProvider'

export default function RootLayout({
    children,
}: {
    children: ReactNode
}) {
    return (
        <html lang="en" suppressHydrationWarning>
            <body>
                <ThemeProvider attribute="data-theme" defaultTheme="system" enableSystem>
                    {children}
                </ThemeProvider>
            </body>
        </html>
    )
}
