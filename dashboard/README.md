# EduFlow NGO Master Dashboard

> **Centralized Management and Analytics for Educational Impact.**

The EduFlow Dashboard is a powerful, web-based administrative suite built with **Next.js** and **Tailwind CSS**. It serves as the single source of truth for NGOs to manage learners, distribute content, and monitor the health of their education programs across Africa.

---

## 🛠️ Key Administrator Features

- **📈 Real-Time Analytics Dashboard**: Monitor student enrollment, lesson completion rates, and regional hotspots via interactive charts and live data feeds.
- **👥 Learner CRM**: A full-featured management system to track individual learner progress, manage profiles, and verify data synchronization between mobile and backend.
- **🎨 Content Studio**: Upload and version lesson packs (JSON/Audio). Manage metadata and deploy updates to the mobile app and SMS gateway simultaneously.
- **🔍 Database Explorer**: Secure access to the Supabase database for complex queries and administrative troubleshooting, with built-in safety rails.
- **🏘️ Cohort Management**: Group learners into regional study cohorts or camps to better tailor educational resources and support.

---

## 🏗️ Technology Stack

- **Framework**: [Next.js](https://nextjs.org/) (App Router)
- **Styling**: [Tailwind CSS](https://tailwindcss.com/)
- **State & Data**: [Supabase SDK](https://supabase.com/docs/reference/javascript/introduction)
- **Authentication**: Supabase Auth (Magic Links & OAuth)
- **Deployment**: [Vercel](https://vercel.com/)

---

## 🚀 Getting Started

### Prerequisites
- Node.js (v18+)
- Supabase Project URL and Anon Key

### Installation & Local Development
1. Navigate to the dashboard directory:
   ```bash
   cd dashboard
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Configure environment:
   Create a `.env.local` file (refer to `.env.example`).
   ```env
   NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
   NEXT_PUBLIC_API_URL=http://localhost:5000/api/v1
   ```
4. Run the development server:
   ```bash
   npm run dev
   ```
   Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

---

## 📁 Project Structure
```text
app/          # Next.js App Router (Pages, Layouts)
components/   # Reusable UI components (Modals, Charts, Forms)
lib/          # Supabase client, Utility functions, API connectors
public/       # Static assets (Icons, Logos)
```
