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
| `SUPABASE_SERVICE_KEY` role | Supabase service key | Yes |
| `JWT_SECRET` | JWT signing secret | Yes |
| `AFRICA_TALKING_API_KEY` | Africa's Talking API key | Yes (for SMS) |
| `AFRICA_TALKING_USERNAME` | Africa's Talking username | Yes (for SMS) |

## Managing the Platform via Master Dashboard

The **NGO Master Dashboard** (`/dashboard`) is the central hub for all administrative tasks.

1.  **Learner Management**
    - Use the **Learners** tab to view profiles, sync status, and individual progress.
    - Click on a learner ID to view their detailed activity history and scores.

2.  **Database Explorer** (Advanced)
    - Access the **Database** tab to run safe SQL queries (SELECT only) for custom reports.
    - Use this to verify raw data without needing direct Supabase access.

3.  **Study Groups**
    - Use the **Study Groups** tab to monitor regional cohorts and peer learning engagement.

4.  **Curriculum Management**
    - The **Lesson Packs** tab shows live content versions and storage paths.

---

## Content Management (CLI)

### Adding & Deploying New Lessons

1.  **Prepare Content**
    - Edit JSON files in `lesson_content/`.
    - Ensure they follow the schema in `docs/CONTENT_STRUCTURE.md`.

2.  **Bundle & Deploy**
    - Run the enhanced packager script from the root:
      ```bash
      python scripts/pack_lessons.py
      ```
    - This script automatically validates JSON, generates a manifest, and **uploads** the ZIP to Supabase if your `.env` is configured.

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| OTP not received | Check phone format (+254...) |
| Sync failing | Verify Supabase credentials |
| Lesson not loading | Check storage permissions |

### Logs

- Backend: Render dashboard logs
- Database: Supabase logs
- SMS: Africa's Talking dashboard

## Security & Operations

- **Phone Security**: All PII is hashed using SHA-256 before storage.
- **Session Security**: JWT tokens rotate every 7 days with seamless refresh.
- **Rate Limiting**: Public endpoints are protected (100 req/15 min).
- **Admin Access**: Protected via `verifyToken` middleware and Supabase RLS policies.

## Monitoring

1.  **Real-time Stats**: View engagement bars and completion heatmaps in the Dashboard's **Overview** and **Analytics** tabs.
2.  **System Health**: Backend logs are available in the Render/deployment dashboard.
3.  **SMS Status**: Outbound OTPs and lesson texts can be traced in the Africa's Talking dashboard.

---

## Support

For issues, contact: support@eduflow.app

---

Last Updated: March 2026
