# EduFlow Content Structure & Management

This document explains how lesson content is structured in EduFlow and how to add or update content.

## Directory Structure

Lesson content is stored in the `lesson_content/` directory, organized by subject and level:

```
lesson_content/
├── math/
│   ├── level_1/
│   │   ├── lesson_01_addition.json
│   │   └── lesson_02_subtraction.json
│   └── level_2/
├── english/
├── swahili/
└── digital_literacy/
```

## Lesson File Format (.json)

Each lesson file should follow this schema:

```json
{
  "id": "uuid",
  "title": "Introduction to Fractions",
  "content": "A fraction represents a part of a whole...",
  "subject": "math",
  "level": 1,
  "language": "en",
  "quiz": [
    {
      "question": "What is 1/2 + 1/2?",
      "options": ["1/4", "1/2", "1", "2"],
      "answer_index": 2,
      "explanation": "Two halves make a whole."
    }
  ]
}
```

## How Content is Updated

EduFlow uses an **Offline-First** strategy. Content is not "hardcoded" after the first run; instead, it is cached in a local SQLite database and synchronized dynamically.

### Manual Update Workflow
To update lessons across all platforms:
1. **Edit JSON Source**: Update the files in `lesson_content/` (root) and `mobile/assets/lesson_packs/`.
2. **Version Bump**: Increment the `"version"` number in your JSON file and update the `lesson_packs` table in Supabase.
3. **Synchronization**: The mobile app checks for updates every **2 minutes** and refreshes its local cache automatically.

---

## Audio Synchronization (Dashboard Managed)

Adding audio to a lesson is now simplified through the **NGO Dashboard**. You no longer need to manage Supabase Storage buckets manually.

1. **Access Dashboard**: Log in to the [EduFlow Dashboard](https://dashboard-lilac-beta-95.vercel.app).
2. **Select Pack**: Go to **Lesson Packs** and click the **Manage** button on the desired subject/level.
3. **Upload MP3**: 
   - Find the specific lesson in the list.
   - Click **Add Audio** (or **Update Audio**).
   - Select your MP3 file.
4. **Automatic Processing**:
   - The dashboard uploads the file to the `audio-content` bucket.
   - The backend automatically updates the lesson's `audio_url`.
   - The backend **increments the pack version** automatically, triggering an instant sync for all online mobile users.

---

## Offline-First Architecture

- **Initial Fallback**: The JSON files in `mobile/assets/` are only used for the **very first launch** if the device is offline.
- **Dynamic Cache**: Once online, the app fetches the latest content and stores it in SQLite (`local_lessons`, `local_packs`, `local_quizzes`).
- **Aggressive Sync**: The `SyncService` performs a check every **2 minutes** and also triggers a sync immediately on app startup or when a connection is restored.
