# EduFlow Backend API

> **The Reliable Engine Powering Multi-Modal Education Delivery.**

The EduFlow Backend is a robust **Node.js (Express)** REST API that bridges the gap between our database and various delivery channels, including the smartphone app and the SMS/USSD gateway. It is built for reliability, security, and performance in high-latency environments.

---

## ⚙️ Core Services

- **🔐 Secure Authentication**: Multi-factor authentication using OTP (One-Time Password) delivered via SMS.
- **🔄 Progress Synchronization**: A conflict-resolution engine that ensures learner progress is accurately merged from multiple offline devices.
- **📱 SMS/USSD Controller**: Integrated with **Africa's Talking**, enabling full curriculum delivery and interactive quizzes via simple feature phones.
- **🧩 Peer Matching Engine**: An intelligent algorithm that pairs learners based on region, subject, and learning level to create study groups.
- **🎧 Audio Content Management**: Secure MP3 upload handling and automatic pack versioning to trigger mobile updates via the NGO Dashboard.
- **🛡️ Privacy Protection**: Implements SHA-256 hashing for all personal identifiers (PII), ensuring learner safety and compliance with data protection standards.

---

## 🏗️ Technology Stack

- **Runtime**: [Node.js](https://nodejs.org/)
- **Framework**: [Express.js](https://expressjs.com/)
- **Database / Auth**: [Supabase](https://supabase.com/)
- **SMS Gateway**: [Africa's Talking](https://africastalking.com/)
- **Deployment**: [Render](https://render.com/) / Docker

---

## 🚀 Getting Started

### Prerequisites
- Node.js (v18+)
- Supabase Project URL, Service Role Key, and JWT Secret
- Africa's Talking API Key

### Installation & Local Development
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Configure environment:
   Create a `.env` file (refer to `.env.example`).
   ```env
   SUPABASE_URL=your-supabase-url
   SUPABASE_SERVICE_KEY=your-service-role-key
   JWT_SECRET=your-secret
   AFRICA_TALKING_API_KEY=your-at-key
   ```
4. Run the development server:
   ```bash
   npm run dev
   ```
   Server will start on [http://localhost:5000](http://localhost:5000).

---

## 📁 Project Structure
```text
src/
├── config/       # Environment & Supabase initialization
├── controllers/  # Request handlers (Auth, Lessons, Progress)
├── middleware/   # Authentication, Rate limiting, Error handling
├── routes/       # API endpoint definitions
├── services/     # Business logic (SMS, Sync, Peer Matching)
└── utils/        # Cryptography, Timing, Formatting
```
