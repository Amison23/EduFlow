import os
import json
import glob

def bundle_lessons():
    """
    Bundles modular lessons from lesson_content/ into aggregated mobile asset packs.
    """
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    source_dir = os.path.join(root_dir, 'lesson_content')
    target_dir = os.path.join(root_dir, 'mobile', 'assets', 'lesson_packs')

    if not os.path.exists(target_dir):
        os.makedirs(target_dir)

    # Subjects to scan
    subjects = [d for d in os.listdir(source_dir) if os.path.isdir(os.path.join(source_dir, d))]

    for subject in subjects:
        subject_path = os.path.join(source_dir, subject)
        levels = [d for d in os.listdir(subject_path) if os.path.isdir(os.path.join(subject_path, d))]

        for level_dir in levels:
            level_num = int(level_dir.split('_')[-1])
            level_path = os.path.join(subject_path, level_dir)
            
            # Find all lesson JSON files (excluding quiz files)
            lesson_files = sorted(glob.glob(os.path.join(level_path, "[0-9][0-9]_*.json")))
            
            lessons = []
            for lesson_file in lesson_files:
                if lesson_file.endswith('_quiz.json'):
                    continue
                
                with open(lesson_file, 'r', encoding='utf-8') as f:
                    lesson_data = json.load(f)
                
                # Look for a corresponding quiz file
                quiz_file = lesson_file.replace('.json', '_quiz.json')
                if os.path.exists(quiz_file):
                    with open(quiz_file, 'r', encoding='utf-8') as f:
                        quiz_data = json.load(f)
                    lesson_data['quiz'] = quiz_data.get('questions', [])
                
                lessons.append(lesson_data)

            if lessons:
                pack_id = f"{subject}-pack-level{level_num}"
                pack = {
                    "id": pack_id,
                    "subject": subject,
                    "level": level_num,
                    "language": "en", # Default to English, could be parameterized
                    "version": 1,
                    "size_mb": round(len(json.dumps(lessons)) / (1024 * 1024), 2),
                    "lessons": lessons
                }

                target_file = os.path.join(target_dir, f"{subject}_level{level_num}.json")
                with open(target_file, 'w', encoding='utf-8') as f:
                    json.dump(pack, f, indent=4)
                
                print(f"Bundled {len(lessons)} lessons into {target_file}")

if __name__ == "__main__":
    bundle_lessons()
