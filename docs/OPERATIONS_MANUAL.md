# EduFlow Operations Manual

## Quick Start

### Running the Project

#### 1. Start Backend
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your Supabase credentials
npm run dev
```

#### 2. Start Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

#### 3. Start Dashboard
```bash
cd dashboard
npm install
npm run dev
```

## Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SUPABASE_URL` | Supabase project URL | Yes |
| `SUPABASE_SERVICE_KEY` | Supabase service key | Yes |
| `JWT_SECRET` | JWT signing secret | Yes |
| `AFRICA_TALKING_API_KEY` | Africa's Talking API key | Yes (for SMS) |
| `AFRICA_TALKING_USERNAME` | Africa's Talking username | Yes (for SMS) |

## Hosting & Deployment

### 🟢 Backend Hosting (Render)
- **Deployed URL**: `https://eduflow-api-ms02.onrender.com`
- **Service Type**: Web Service
- **Runtime**: Node.js 18+

### 🔵 Dashboard Hosting (Vercel)
- **Deployed URL**: `https://dashboard-lilac-beta-95.vercel.app`

## Managing the Platform via Master Dashboard

The **NGO Master Dashboard** is the central hub for administrative tasks.

1.  **Learner Management**: View profiles, sync status, and individual progress.
2.  **Database Explorer**: Run SQL queries to verify raw data.
3.  **Study Groups**: Monitor regional cohorts and peer learning engagement.
4.  **Curriculum Management**: Manage live content versions, lessons, and audio uploads directly.
    -   **Audio Uploads**: Upload MP3 files per lesson. This automatically handles Supabase Storage, updates the database, and bumps the pack version.

## Content Management

### Simplified Audio Workflow
Instead of manual CLI or Supabase console operations, administrative users can:
1.  Navigate to **Lesson Packs** in the Dashboard.
2.  Click **Manage** on a specific pack.
3.  Upload audio files per lesson.
4.  Devices will automatically sync the new audio within 2 minutes.

### CLI (Legacy/Bulk)

### Adding & Deploying New Lessons

1.  **Prepare Content**: Edit JSON files in `lesson_content/`.
2.  **Bundle & Deploy**:
    ```bash
    python scripts/pack_lessons.py
    ```

---

## Troubleshooting

### Logs
- **Backend**: Render dashboard logs or `app_logs` table in Supabase.
- **Database**: Supabase dashboard.
- **SMS**: Africa's Talking dashboard.

### Security
- **Data Privacy**: All PII is hashed (SHA-256).
- **Session**: JWT tokens rotate every 7 days.
- **Rate Limiting**: Public endpoints are limited (100 req/15 min).

Last Updated: March 2026
