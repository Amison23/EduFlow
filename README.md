# EduFlow

> Lifeline Learning for Africa's Displaced

This repository contains the full EduFlow suite designed for displaced learners, featuring a Flutter mobile app, an Express backend, and a Next.js dashboard.

## Services & Credentials Required

For **full functionality**, you need to ensure the following services are fully configured:

1. **Supabase (Database, Auth & Storage)**
   - **Status:** Create a project via the Supabase and populated the URL and Anon Key across `.env` and `dashboard/.env.local`.
   - **Action Required**: Obtain the `service_role` key from your [Supabase Dashboard](https://supabase.com/dashboard/projects) under **Project Settings > API** and paste it into the `SUPABASE_SERVICE_KEY` field in the root `.env`.

2. **Africa's Talking (SMS Gateway)**
   - **Action Required**: Create an account at [Africa's Talking](https://africastalking.com/). Refer to the [Africa's Talking Setup Guide](docs/AFRICA_TALKING_SETUP.md) for detailed instructions on obtaining an API Key and setting up your credentials.

3. **Vercel (Dashboard Hosting)**
   - **Status**: The project can be deployed seamlessly to Vercel. Connect your GitHub repository to Vercel, and paste the Vercel Access Token you possess into your Vercel CLI or environment secrets if deploying via CI/CD. Ensure `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` are provided in your Vercel project settings.


##  NGO Master Dashboard

The EduFlow NGO Dashboard is a unified management suite at `/dashboard`. It is designed for program administrators to oversee learners, content, and system health.

### Key Management Features:
- **Real-time Analytics**: Monitor learner engagement, completion rates, and regional hotspots.
- **Learner CRM**: Manage learner profiles, track individual progress, and verify sync status.
- **Content Studio**: Upload and manage lesson packs, track publishing versions, and audit curriculum updates.
- **Database Explorer**: Direct (but safe) database access for administrative queries and troubleshooting.
- **Community Hub**: Manage peer study groups and regional learning cohorts.

---

## Installation & Local Development

### Prerequisites
- Node.js (v18+)
- Flutter SDK
- Supabase Account
- Africa's Talking API Credentials

### 1. Root Configuration
Copy `.env.example` to `.env` in the root and fill in your credentials.
```bash
cp .env.example .env
```

### 2. Backend Setup
```bash
cd backend
npm install
npm run dev # Starts on http://localhost:5000
```

### 3. Dashboard Setup
```bash
cd dashboard
npm install
npm run dev # Starts on http://localhost:3000
```

### 4. Mobile App Setup
```bash
cd mobile
flutter pub get
flutter run
```

### 5. Dependency Management
> [!IMPORTANT]
> When running `npm install`, you may see security vulnerability warnings from `npm audit`. **Please ignore these for now.** 
> Many of these are false positives or related to development-only dependencies. Running `npm audit fix` automatically can silently upgrade packages and break the application's core logic or dashboard routing. Only update dependencies if required by future feature updates.

### 6. Local vs. Deployed Testing (Environments)
Both the Mobile App and the Dashboard use environment variables to locate the Backend API. You can switch between testing locally or against your live deployment by updating the `.env` files.

#### Mobile App Configuration
Edit `mobile/.env` and update `API_BASE_URL`:
- **Local (Android Emulator):** `API_BASE_URL=http://10.0.2.2:5000/api/v1`
- **Local (iOS Simulator/Web):** `API_BASE_URL=http://localhost:5000/api/v1`
- **Live Deployment:** `API_BASE_URL=https://eduflow-api-ms02.onrender.com/api/v1`
*(Run `flutter run` or hot restart after changing the file)*

#### Dashboard Configuration
Edit `dashboard/.env.local` and update `NEXT_PUBLIC_API_URL`:
- **Local:** `NEXT_PUBLIC_API_URL=http://localhost:5000/api/v1`
- **Live Deployment:** Set this environment variable in your Vercel Project Settings to point to your live Render backend URL.


---

## Documentation Index

- [Project Architecture & Design](docs/PROJECT_DOCUMENTATION.md)
- [Content Structure & Management](docs/CONTENT_STRUCTURE.md)
- [Operations & Troubleshooting](docs/OPERATIONS_MANUAL.md)
- [Asset Requirements](docs/ASSETS_REQUIREMENTS.md)
- [Africa's Talking Setup Guide](docs/AFRICA_TALKING_SETUP.md)

---

## Support & Contributions
For technical support, please refer to the [Operations Manual](docs/OPERATIONS_MANUAL.md) or contact the dev team at `dev@africaforward.org`.
