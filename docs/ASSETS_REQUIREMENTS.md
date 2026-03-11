# EduFlow Asset Requirements

To ensure a premium and functional experience, please provide the following assets:

## 1. Brand & UI Identity
- **Logo**: Vector formats (`.svg`) for light/dark modes.
- **Favicon**: High-resolution `.png` (at least 512x512) for modern device scaling.
- **Typography**: Preferred Google Font files (`.ttf` or `.woff2`) if they differ from the default *Inter* or *Outfit*.

## 2. Educational Content
- **Lesson Packs**: Validated JSON bundles matching the schema in `docs/CONTENT_STRUCTURE.md`.
- **Media**: High-quality compressed audio (`.mp3` @ 128kbps) and cover art (`.webp` for bandwidth efficiency).

## 3. Infrastructure & Administrative Access
- **Supabase**: URL, `service_role` key (for backend), and `anon` key (for frontend).
- **Africa's Talking**: API Key, Username, and a registered Shortcode/SenderID for SMS.
- **Master Admin Credentials**: Secure initial password for the NGO program administrator.
- **SMTP Gateway**: Host, Port, Secure User, and Password for system alerts and weekly reports.

## 4. Platform (Mobile & Web)
- **Firebase Configuration**: `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
- **App Signing**: Production keystore files and key aliases for store deployment.
- **Vercel Access**: Deploy-hook URL or access token for CI/CD pipeline integration.
