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

1. **Manual Update**:
   - Add or edit JSON files in the appropriate folder.
   - Run the packaging script (e.g., `scripts/pack_lessons.py`) to generate a production-ready bundle.
   - Upload the bundle to the Supabase Storage bucket (`lesson-packs`).
   - Update the `lesson_packs` table in the database with the new version number and size.

2. **Automation (Proposed)**:
   - **GitHub Actions**: Content updates can be automated. A workflow can be set up to trigger whenever files in `lesson_content/` are pushed to the `main` branch.
   - The workflow would run the packaging script and use the Supabase CLI to upload the assets and update the database metadata automatically.

## Content Guidelines

- **Simplicity**: Lessons must be readable on small screens (mobile) and via SMS.
- **Micro-learning**: Keep text brief and focused on one concept per lesson.
- **Accessibility**: Ensure language matches the target learner's profile (Turkana, Swahili, etc.).
- **Audio Assets**: If a lesson requires audio, the MP3 should be named after the lesson ID and uploaded to the `audio-content` storage bucket.
