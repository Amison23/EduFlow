import os
import json
import zipfile
import hashlib
from datetime import datetime
from urllib.request import Request, urlopen

# Configuration (Load from .env if possible)
def get_env_var(var_name, default=None):
    try:
        with open('.env', 'r') as f:
            for line in f:
                if line.startswith(f'{var_name}='):
                    return line.split('=')[1].strip()
    except:
        pass
    return os.environ.get(var_name, default)

SUPABASE_URL = get_env_var('SUPABASE_URL')
SUPABASE_KEY = get_env_var('SUPABASE_SERVICE_KEY')
BUCKET_NAME = 'lesson-packs'

def validate_lesson(content, file_path):
    """Simple schema validation for lessons"""
    required_fields = ['id', 'title', 'subject', 'level']
    for field in required_fields:
        if field not in content:
            raise ValueError(f"Missing required field '{field}' in {file_path}")
    return True

def pack_lessons():
    """
    Enhanced packaging: Validates content, generates a manifest, 
    and optionally uploads to Supabase.
    """
    content_root = 'lesson_content'
    output_dir = 'dist/packs'
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    pack_name = f'eduflow_lessons_{timestamp}.zip'
    pack_path = os.path.join(output_dir, pack_name)

    manifest = {
        "version": timestamp,
        "generated_at": datetime.now().isoformat(),
        "stats": {},
        "files": []
    }

    print(f"🔍 Validating and indexing lessons from {content_root}...")
    
    with zipfile.ZipFile(pack_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(content_root):
            for file in files:
                if file.endswith('.json'):
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, content_root)
                    
                    try:
                        with open(file_path, 'r', encoding='utf-8') as f:
                            content = json.load(f)
                            validate_lesson(content, file_path)
                            
                            # Build manifest stats
                            subject = content['subject']
                            level = str(content['level'])
                            manifest["stats"].setdefault(subject, {}).setdefault(level, 0)
                            manifest["stats"][subject][level] += 1
                            manifest["files"].append(arcname)
                            
                        # Add to zip
                        zipf.write(file_path, arcname)
                        print(f"  [OK] {arcname}")
                    except Exception as e:
                        print(f"  [ERR] {arcname}: {e}")
                        return

        # Add manifest to zip
        zipf.writestr('manifest.json', json.dumps(manifest, indent=2))
        print(f"  [+] manifest.json generated")

    print(f"\n✅ Pack created: {pack_path}")
    
    # Optional: Automated Upload
    if SUPABASE_URL and SUPABASE_KEY:
        print(f"🚀 Uploading to Supabase Storage ({BUCKET_NAME})...")
        try:
            upload_url = f"{SUPABASE_URL.rstrip('/')}/storage/v1/object/{BUCKET_NAME}/{pack_name}"
            with open(pack_path, 'rb') as f:
                data = f.read()
            
            headers = {
                'Authorization': f'Bearer {SUPABASE_KEY}',
                'Content-Type': 'application/zip'
            }
            
            req = Request(upload_url, data=data, headers=headers, method='POST')
            with urlopen(req) as response:
                if response.status in [200, 201]:
                    print(f"🌟 Successfully uploaded! URL: {upload_url}")
                    print(f"👉 Remember to update the 'lesson_packs' table with version {timestamp}")
                else:
                    print(f"⚠️ Upload failed status: {response.status}")
        except Exception as e:
            print(f"⚠️ Upload failed: {e} (Check credentials and bucket existence)")

if __name__ == "__main__":
    pack_lessons()
