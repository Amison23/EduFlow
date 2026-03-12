# EduFlow Asset Management Guide

This guide explains how to manage and update the educational assets for the EduFlow mobile application.

## 1. Lesson Packs (`/lesson_packs`)
Lesson packs are the primary educational content. They are bundled as JSON files.

### Workflow
1. **Source of Truth**: All lessons and quizzes are authored in the root `/lesson_content` folder of the project.
2. **Modular Structure**: Lessons (`XX_title.json`) and Quizzes (`XX_title_quiz.json`) are kept separate for easier editing.
3. **Bundling**: Run the automation script from the project root:
   ```powershell
   python scripts/bundle_lessons.py
   ```
   This script will automatically merge lessons and quizzes and output the final JSON packs into this directory.

### IMPORTANT
Do **not** edit JSON files in this directory directly, as they will be overwritten the next time the bundling script is run.

---

## 2. Audio Narrations (`/audio`)
This folder is used for localized audio files when serving them via the cloud isn't feasible or for pre-packaged offline content.

- **Format**: MP3 (Mono, 64kbps recommended to save space).
- **Naming**: Match the lesson ID (e.g., `math_level1_01.mp3`).
- **Linking**: The `audio_url` in the lesson JSON can point to a local asset:
  ```json
  "audio_url": "assets/audio/math_level1_01.mp3"
  ```
  The `AudioService` handles both remote URLs and local assets.

---

## 3. Images (`/images`)
- **App Graphics**: Store onboarding illustrations and subject icons here.
- **Subject Icons**: We currently use Material Icons defined in `AppTheme.getSubjectIcon`. For custom SVG/PNG icons, verify they are registered in `pubspec.yaml`.

---

## 4. Registering New Assets
Whenever you add a new file to these directories, ensure it is registered in `mobile/pubspec.yaml` under the `assets` section:

```yaml
flutter:
  assets:
    - assets/lesson_packs/
    - assets/audio/
    - assets/images/
```
Running `flutter pub get` after changes ensures the app can access them.

---

## 5. Quick Example: Adding a New Lesson
Follow these steps to add "Lesson 2" to Level 1 Math.

### Step A: Create the Lesson Source
Create `lesson_content/math/level_1/02_addition.json`:
```json
{
    "id": "math-level1-02",
    "pack_id": "math-pack-level1",
    "sequence": 2,
    "title": "Basic Addition",
    "content": "# Basic Addition\n\nLearning to add two numbers...",
    "audio_url": "assets/audio/math_level1_02.mp3",
    "duration_mins": 15
}
```

### Step B: Create the Quiz Source
Create `lesson_content/math/level_1/02_addition_quiz.json`:
```json
{
    "questions": [
        {
            "question": "What is 1 + 1?",
            "options": ["1", "2", "3", "4"],
            "correct_index": 1
        }
    ]
}
```

### Step C: Add the Audio File
Place your recorded MP3 file here: `mobile/assets/audio/math_level1_02.mp3`.

### Step D: Bundle the Content
Run the following in your terminal from the project root:
```powershell
python scripts/bundle_lessons.py
```
The script will detect the new files, merge them, and update `mobile/assets/lesson_packs/math_level1.json` automatically.

---

## 6. Example 2: Adding a Swahili Lesson
Adding "Lesson 1" to Level 1 Swahili (`swahili_level1.json`).

### Step A: Create Lesson Source
Create `lesson_content/swahili/level_1/01_salam_na_utambulisho.json`:
```json
{
    "id": "swahili-level1-01",
    "pack_id": "swahili-pack-level1",
    "sequence": 1,
    "title": "Salamu Na Utambulisho",
    "content": "# Salamu\n\nKatika somo hili, tutajifunza jinsi ya kusalimia...\n\n1. **Habari** (How are you)\n2. **Nzuri** (Fine)",
    "audio_url": "assets/audio/swahili_level1_01.mp3",
    "duration_mins": 10
}
```

### Step B: Create Quiz Source
Create `lesson_content/swahili/level_1/01_salam_na_utambulisho_quiz.json`:
```json
{
    "questions": [
        {
            "question": "Je, unajibu nini ukisaliwa 'Habari'?",
            "options": ["Nzuri", "Asante", "Hujambo", "Kwaheri"],
            "correct_index": 0
        }
    ]
}
```

### Step C: Add Audio
Place `swahili_level1_01.mp3` in `mobile/assets/audio/`.

### Step D: Sync
Run `python scripts/bundle_lessons.py`. This will create or update `mobile/assets/lesson_packs/swahili_level1.json`.
