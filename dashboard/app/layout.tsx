import type { ReactNode } from 'react'
import './globals.css'

export const metadata = {
    title: 'EduFlow Dashboard',
    description: 'NGO Dashboard for managing learner cohorts',
}

export default function RootLayout({
    children,
}: {
    children: ReactNode
}) {
    return (
        <html lang="en">
            <body>{children}</body>
        </html>
    )
}
