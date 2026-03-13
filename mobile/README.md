# EduFlow Mobile App

> **Empowering Displaced Learners via High-Fidelity, Offline-First Education.**

The EduFlow mobile application is the primary interface for students. Built with Flutter, it provides a premium, responsive, and resilient learning experience tailored for environments with intermittent or non-existent internet connectivity.

---

## ✨ Key Features

- **📶 Offline-First Continuity**: Download entire lesson packs automatically. All progress and content are cached aggressively (2-minute sync cycles) in a local SQLite database, ensuring full accessibility even in remote areas and preventing data loss.
- **🧠 AI Adaptive Learning**: Integrates **TensorFlow Lite** to provide a personalized learning path. The app analyzes quiz performance in real-time to adjust question difficulty, ensuring learners are neither bored nor overwhelmed.
- **🎧 Multi-Modal Lessons**: Supports text-based content, high-quality audio narration for better accessibility, and visual diagrams.
- **🏆 Gamification & Motivation**: Features daily streaks, achievement badges, and a leaderboard to foster consistent learning habits.
- **🤝 Peer Study Groups**: An intelligent matching system that helps learners find study partners within their local displacement camp or region.
- **🌍 Multi-Language Support**: Fully localized in English, Swahili, and Amharic, with the ability to switch preferences on the fly.

---

## 🏗️ Technical Architecture

The app follows a strict **Clean Architecture** pattern combined with the **BLoC (Business Logic Component)** state management library to ensure scalability and testability.

- **Presentation Layer**: Flutter widgets and BLoC for state handling.
- **Domain Layer**: Pure Dart entities and use cases.
- **Data Layer**: Repositories that handle the logic of switching between local (SQLite via Drift/Floor) and remote (REST API) data sources.
- **Services**: Specialized modules for Audio playback, ML inference (TFLite), and Background Sync.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.10+)
- Android Studio / VS Code
- Android Emulator or physical device

### Installation
1. Navigate to the mobile directory:
   ```bash
   cd mobile
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure environment:
   Create a `.env` file in the root of the `mobile/` directory (refer to `.env.example`).
   ```env
   API_BASE_URL=https://your-api-url.com/api/v1
   SUPABASE_URL=your-supabase-url
   SUPABASE_ANON_KEY=your-anon-key
   ```
4. Run the app:
   ```bash
   flutter run
   ```

---

## 🛠️ Key Commands
- **Generate Localizations**: `flutter gen-l10n`
- **Run Tests**: `flutter test`
- **Build Release APK**: `flutter build apk --release`

---

## 📁 Project Structure
```text
lib/
├── core/           # Dependency injection, themes, network config
├── data/           # Models, DTOs, Local & Remote Data Sources
├── domain/         # Entities, Repository Interfaces, Use Cases
├── presentation/   # BLoCs, Screens, Widgets
└── services/       # ML, Sync, Audio, Notification services
```
