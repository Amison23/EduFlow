# EduFlow - Complete Project Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Project Structure](#project-structure)
4. [Installation & Setup](#installation--setup)
5. [API Documentation](#api-documentation)
6. [Database Schema](#database-schema)
7. [SMS/USSD Integration](#smsussd-integration)
8. [Deployment Guide](#deployment-guide)
9. [Operations & Management](#operations--management)
10. [Troubleshooting](#troubleshooting)

---

## Project Overview

**EduFlow** (Lifeline Learning for Africa's Displaced) is an offline-first educational platform designed for displaced learners across Africa. The platform supports:

- **Smartphone App** (Flutter) - Full-featured learning experience
- **SMS/USSD** - Learning via basic feature phones
- **NGO Dashboard** - For organizations managing learner cohorts

### Key Features
- Offline-first architecture with automatic sync
- Adaptive quiz engine using TensorFlow Lite
- Multi-language support (English, Swahili, Amharic)
- Study groups and peer matching
- Progress tracking and analytics

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        LEARNER DEVICES                          │
│  ┌─────────────────────────┐    ┌──────────────────────────┐   │
│  │   Flutter Mobile App    │    │   Basic Feature Phone    │   │
│  │  (Android / iOS)        │    │   (SMS / USSD only)      │   │
│  └────────────┬────────────┘    └──────────────┬───────────┘   │
│               │ HTTPS                           │ SMS            │
│               │                                 │                │
│  ┌────────────┼─────────────────────────────────┼────────────┐   │
│  │            │        BACKEND (Render)          │            │   │
│  │            v                                  v            │   │
│  │  ┌────────────────────────┐    ┌─────────────────────┐   │   │
│  │  │   Node.js REST API     │    │   SMS Controller    │   │   │
│  │  └────────────┬───────────┘    └─────────────────────┘   │   │
│  │               │                                           │   │
│  │               v                                           │   │
│  │  ┌────────────────────────┐                              │   │
│  │  │   Supabase             │                              │   │
│  │  │   (PostgreSQL + RLS)   │                              │   │
│  └───────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────────┐
│              NGO MASTER DASHBOARD (Next.js / Vercel)            │
│  ┌─────────────────┐ ┌──────────────────┐ ┌──────────────────┐   │
│  │  Learner CRM    │ │  Content Studio  │ │ Database Explorer │   │
│  └─────────────────┘ └──────────────────┘ └──────────────────┘   │
└────────────────────────────────┬────────────────────────────────┘
                                 │ HTTPS / API
                                 v
┌─────────────────────────────────────────────────────────────────┐
│                        CENTRAL BACKEND                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
EduFlow/
├── mobile/                    # Flutter application
│   ├── lib/
│   │   ├── core/             # Constants, errors, network, theme
│   │   ├── data/             # Local DB, remote APIs, repositories
│   │   ├── domain/           # Entities, use cases
│   │   ├── presentation/    # BLoC, screens, widgets
│   │   └── services/         # Sync, audio, ML services
│   ├── assets/               # Audio, images, lesson packs
│   └── pubspec.yaml
│
├── backend/                   # Node.js REST API
│   ├── src/
│   │   ├── config/          # Supabase, environment
│   │   ├── routes/          # API routes
│   │   ├── controllers/     # Request handlers
│   │   ├── middleware/      # Auth, HMAC, rate limiting
│   │   ├── services/        # OTP, SMS, peer matching
│   │   └── utils/           # Crypto, timestamp
│   ├── supabase/            # Database migrations
│   └── package.json
│
├── dashboard/                 # Next.js NGO dashboard
│   ├── app/                  # Next.js app router
│   ├── components/           # React components
│   └── lib/                  # Supabase client, API calls
│
├── sms_gateway/              # SMS/USSD integration
│   ├── africastalking/       # Africa's Talking configs
│   └── templates/            # SMS message templates
│
├── lesson_content/           # Raw lesson content
│   ├── math/
│   ├── english/
│   ├── swahili/
│   └── digital_literacy/
│
└── docs/                     # This documentation
```

---

## Installation & Setup

### Prerequisites

- **Node.js** v18+
- **Flutter** v3.0+
- **Supabase** account
- **Africa's Talking** account (for SMS)

### Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your credentials:
# - SUPABASE_URL
# - SUPABASE_SERVICE_KEY
# - JWT_SECRET
# - AFRICA_TALKING_API_KEY (See [Setup Guide](AFRICA_TALKING_SETUP.md))

# Start development server
npm run dev
```

### Mobile App Setup

```bash
cd mobile

# Install Flutter dependencies
flutter pub get

# Run on device/emulator
flutter run
```

### Dashboard Setup

```bash
cd dashboard

# Install dependencies
npm install

# Copy environment file
cp .env.example .env.local

# Run development server
npm run dev
```

---

## API Documentation

### Base URL
`https://api.eduflow.app/v1`

### Authentication Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Request OTP |
| POST | `/auth/verify-otp` | Verify OTP and login |
| POST | `/auth/resend-otp` | Resend OTP |
| GET | `/auth/profile` | Get profile (requires auth) |
| PUT | `/auth/profile/:id` | Update profile |

### Lessons Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/lessons/packs` | Get all lesson packs |
| GET | `/lessons/packs/:id/lessons` | Get lessons for pack |
| GET | `/lessons/:id` | Get specific lesson |
| GET | `/lessons/:id/quiz` | Get quiz questions |
| GET | `/lessons/quiz/adaptive` | Get adaptive quiz |

### Progress Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/progress/sync` | Sync progress events |
| GET | `/progress/:learnerId` | Get learner progress |
| GET | `/progress/:learnerId/streak` | Get streak |

---

## Database Schema

### Key Tables

```sql
-- Learners (PII-free: phone stored as SHA-256 hash)
learners (
  id UUID PRIMARY KEY,
  phone_hash TEXT UNIQUE,
  region TEXT,
  displacement TEXT,
  language TEXT,
  created_at TIMESTAMPTZ
)

-- Lesson Packs
lesson_packs (
  id UUID PRIMARY KEY,
  subject TEXT,
  level INT,
  language TEXT,
  version INT,
  size_mb NUMERIC,
  storage_path TEXT
)

-- Progress Events (append-only)
progress_events (
  id UUID PRIMARY KEY,
  learner_id UUID,
  lesson_id UUID,
  event_type TEXT,
  score NUMERIC,
  device_ts TIMESTAMPTZ,
  server_ts TIMESTAMPTZ
)

-- SMS Sessions
sms_sessions (
  phone_hash TEXT PRIMARY KEY,
  learner_id UUID,
  current_lesson UUID,
  question_index INT,
  score INT
)
```

---

## SMS/USSD Integration

### How SMS Learning Works

1. Learner sends code (e.g., "MATH1") to shortcode
2. Backend receives SMS via Africa's Talking webhook
3. System looks up learner by phone hash
4. Sends lesson content + quiz question via SMS
5. Learner replies with answer (A/B/C/D)
6. System evaluates and sends next question or results

### SMS Commands

| Command | Description |
|---------|-------------|
| `START` | Start learning |
| `MATH1` | Get Math Level 1 lesson |
| `ENG1` | Get English Level 1 lesson |
| `HELP` | Get help menu |
| `STOP` | Stop SMS learning |

---

## Deployment Guide

### Backend (Render)

1. Connect GitHub repository to Render
2. Set environment variables:
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_KEY`
   - `JWT_SECRET`
   - `AFRICA_TALKING_API_KEY` (See [Setup Guide](AFRICA_TALKING_SETUP.md))
3. Deploy as Web Service

### Mobile App

```bash
# Build APK
flutter build apk --release

# Build for Play Store
flutter build appbundle --release
```

### Dashboard (Vercel)

1. Connect GitHub repository to Vercel
2. Set environment variables:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
3. Deploy

---

## Operations & Management

### Monitoring

- **Backend Logs**: Check Render dashboard logs
- **Database**: Use Supabase dashboard
- **SMS**: Use Africa's Talking dashboard

### Common Tasks

#### Add New Lesson Pack

1. Create JSON files in `lesson_content/`
2. Run `scripts/pack_lessons.py`
3. Upload to Supabase Storage
4. Add record to `lesson_packs` table

#### Reset Learner Progress

```sql
DELETE FROM progress_events WHERE learner_id = 'uuid';
```

#### View Learner Activity

```sql
SELECT * FROM progress_events 
WHERE learner_id = 'uuid' 
ORDER BY server_ts DESC;
```


---

## 🧠 Advanced Feature Deep-Dive

### 1. AI Adaptive Learning Engine (TensorFlow Lite)
The EduFlow mobile app includes a local machine learning inference engine that powers our adaptive assessments.
- **Model**: Custom-trained classification model deployed as a `.tflite` file.
- **Logic**: The engine analyzes the learner's response time, previous score, and current question difficulty.
- **Outcome**: It predicts the optimal difficulty level for the next question to maintain the "Flow State"—where the challenge matches the learner's skill level.
- **Offline Capability**: Since the model runs locally on the device, adaptive learning works 100% offline.

### 2. Intelligent Peer Matching Service
To combat isolation in displacement camps, EduFlow includes a social learning layer.
- **Algorithm**: When a learner signifies interest in a study group, the Backend service looks for others in the same `region` and `displacement_center` who are studying the same `subject` and `level`.
- **Connectivity**: Matches are delivered via the app for smartphone users and via SMS for feature phone users.
- **Anonymity**: Names are never shared; users are matched via internal UUIDs until they choose to meet in person at designated learning hubs.

### 3. Conflict-Resilient Data Sync
Our sync logic is designed for "vibrant but intermittent" connectivity.
- **Append-Only Logging**: All progress events (lesson started, quiz answered, score achieved) are stored as an immutable log locally.
- **Timestamping**: We use dual timestamps (`device_ts` and `server_ts`) to ensure that even if a device is offline for weeks, the historical data is merged in the correct chronological order.
- **Aggressive Sync Cycles**: The mobile app performs a full state reconciliation every **2 minutes** when online, ensuring the local cache is always fresh.

---

## 🔒 Security & Privacy Architecture

EduFlow is built on the principle of **Privacy by Design**, especially critical for vulnerable displaced populations.

### 1. PII Redaction (Phone Hashing)
We do not store raw phone numbers in our database.
- **Hashing**: All phone numbers are hashed using **SHA-256** before being stored.
- **Authentication**: OTPs are generated and sent via a secure third-party (Africa's Talking), and the system only interacts with the hash in the backend.
- **Risk Mitigation**: In the unlikely event of a data breach, no individual learner's phone number can be retrieved.

### 2. Row Level Security (RLS)
We leverage Supabase's PostgreSQL RLS to ensure data isolation.
- **Policy**: Each learner can only read/write their own progress data.
- **JWT Vetting**: Every API request is verified against a signed JWT issued during the OTP verification phase.

### 3. Secure Administrative Access
The NGO Dashboard accesses the database through a dedicated service role with audited permissions.
- **No Direct Deletion**: Admins can view and manage data but are restricted from bulk deletion of learner history without multi-factor approval.

---

## 📚 Features Guide & FAQ

For a detailed guide on how to use each feature of the platform, please refer to the **[Comprehensive Features Guide](FEATURES_GUIDE.md)**.

---

## 🌍 Impact Metrics tracking
The system is designed to provide NGOs with the following metrics:
- **Retention Rate**: Duration of active streaks.
- **Learning Velocity**: Speed of progression through content levels.
- **Community Engagement**: Number of successful peer matches and study group sessions.

---

## 🏗️ Support
For technical issues, please contact the development team at `dev@africaforward.org`.

---

## 📜 License

Copyright (c) 2024 Africa Forward. All rights reserved.
Licensed under the MIT License.
