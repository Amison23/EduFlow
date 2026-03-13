# EduFlow

> **Lifeline Learning for Africa's Displaced**

EduFlow is an **offline-first, AI-enhanced educational platform** engineered specifically for the unique challenges faced by displaced learners and marginalized communities across Africa.

### 🌐 Live Deployment
- **Backend API**: [https://eduflow-api-ms02.onrender.com](https://eduflow-api-ms02.onrender.com)
- **Admin Dashboard**: [https://dashboard-lilac-beta-95.vercel.app](https://dashboard-lilac-beta-95.vercel.app)

---

## 🌟 Core Capabilities & USPs

### 📱 Smartphone Learning (Flutter)
A feature-rich, high-fidelity learning experience designed for modern Android and iOS devices.
- **Offline-First Architecture**: Continuous learning without an active internet connection. Data syncs aggressively every **2 minutes** (and on startup) once a connection is detected.
- **AI-Driven Adaptive Quizzes**: Utilizing **TensorFlow Lite**, the app dynamically adjusts quiz difficulty based on learner performance to optimize retention.
- **Audio-Visual Lessons**: Multimedia-rich content packs that cater to diverse learning styles.
- **Gamified Engagement**: Built-in streaks, badges, and progress tracking to keep learners motivated.

### 📟 Feature Phone Integration (SMS/USSD)
Bypassing the need for smartphones or data plans, EduFlow brings education to the most basic devices.
- **SMS-Based Lessons**: Full curriculum delivery via standard text messaging.
- **Interactive USSD Quizzes**: Real-time assessments using simple dial-up menus.

### 📊 NGO Master Dashboard (Next.js)
A unified command center for organizations to manage, monitor, and scale educational programs.
- **Real-Time Analytics**: Visual heatmaps and engagement metrics to identify regional needs and student progress.
- **Learner CRM**: Comprehensive profile management with detailed sync status and learning history.
- **Content Studio**: A centralized hub for managing lessons, uploading audio directly (MP3), and versioning content packs.
- **System Health Monitor**: Live tracking of SMS gateway status and database performance.

---

## 🛠️ Technology Stack

| Component | Technology | Role |
|-----------|------------|------|
| **Mobile** | Flutter, BLoC, SQLite, TFLite | Cross-platform offline learning |
| **Backend** | Node.js (Express), Supabase | Scalable REST API & Auth |
| **Dashboard** | Next.js, Tailwind CSS, Vercel | Admin interface & Analytics |
| **Database** | PostgreSQL (Supabase) | Secure, relational data storage |
| **Gateway** | Africa's Talking | SMS & USSD delivery |

---

## 🚀 Getting Started

### Prerequisites
- **Mobile**: Flutter SDK (v3.10+)
- **Backend/Web**: Node.js (v18+)
- **Services**: Supabase Account, Africa's Talking API Key

### Quick Setup

1. **Environment Configuration**
   ```bash
   cp .env.example .env
   # Fill in your SUPABASE_URL, SUPABASE_SERVICE_KEY, and AFRICA_TALKING_API_KEY
   ```

2. **Backend & Dashboard**
   ```bash
   # In /backend and /dashboard
   npm install && npm run dev
   ```

3. **Mobile App**
   ```bash
   cd mobile
   flutter pub get && flutter run
   ```

---

## 📚 Documentation Index

Our documentation is structured to help you get the most out of the EduFlow ecosystem:

- 🏗️ **[Architecture & System Design](docs/PROJECT_DOCUMENTATION.md)**: Deep dive into the tech stack and data flows.
- 📖 **[Content Management Guide](docs/CONTENT_STRUCTURE.md)**: How to create and deploy new lesson packs.
- ⚙️ **[Operations & Hosting](docs/OPERATIONS_MANUAL.md)**: Deployment guides for Render, Vercel, and Supabase.
- 💬 **[SMS Gateway Setup & Testing](docs/SMS_TESTING_GUIDE.md)**: Detailed instructions for configuring and testing Africa's Talking.
- 🔒 **[Security & Privacy Policy](docs/OPERATIONS_MANUAL.md#security)**: Documentation of our data protection measures.

---

## 🌍 Impact
EduFlow is built with the mission of ensuring that **no learner is left behind**. By empowering NGOs with data and providing learners with flexible, resilient tools, we are building a bridge to a brighter future for Africa's displaced youth.

For support, reach out to **[dev@africaforward.org](mailto:dev@africaforward.org)**.
