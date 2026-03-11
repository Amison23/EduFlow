# EduFlow Management Scripts

This directory contains utility scripts for managing the EduFlow ecosystem.

## `pack_lessons.py`

This script is the primary tool for bundling educational content into production-ready packages.

### Features
- **Validation**: Scans all JSON files in `lesson_content/` and verifies they meet the required schema (ID, Title, Subject, Level).
- **Manifest Generation**: Creates an internal `manifest.json` that provides the mobile app with a quick index of all lessons and subjects.
- **Compression**: Bundles all lessons into a version-stamped ZIP file.
- **Automated Deployment**: If Supabase credentials are found in the root `.env` file, it automatically uploads the package to the `lesson-packs` storage bucket.

### Usage

1. Ensure you have Python installed.
2. Place or edit your JSON lessons in the `lesson_content/` folder.
3. Run the script from the project root:
   ```bash
   python scripts/pack_lessons.py
   ```

### Requirements
- Python 3.x
- A valid `.env` file in the root directory (optional, for automated upload).

### Why use this script?
Directly fetching hundreds of individual JSON files over low-bandwidth connections (common for displaced learners) is inefficient. This script converts the "development" format into a "production" format optimized for bulk download and offline sync.
