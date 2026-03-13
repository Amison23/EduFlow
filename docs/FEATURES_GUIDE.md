# EduFlow Features Guide

This guide provides a comprehensive overview of the features available in the EduFlow ecosystem and how to use them effectively.

---

## 📖 For Learners

### 1. Smartphone App (Flutter)
- **Starting a Lesson**: Browse subjects on the home screen. Tap a subject to see available levels.
- **Taking a Quiz**: At the end of each lesson, you will be presented with an adaptive quiz.
- **Viewing Progress**: The 'Stats' tab shows your current streak, lessons completed, and badges earned.
- **Peer Matching**: Navigate to the 'Community' tab and tap 'Find Study Group' to be paired with local learners.
- **Offline Mode**: If you lose connection, a banner will appear. You can still access and complete *cached* lessons. Your progress and content will sync automatically every 2 minutes when you are back online.
- **Tutorials & Help**: Navigate to **Settings -> How to Use** for built-in instructions on all app features.

### 2. Feature Phone (SMS/USSD)
- **Registration**: SMS `START` to our shortcode to register your hashed profile.
- **Learning via SMS**: Reply with the lesson code (e.g., `MATH1`) to receive content.
- **Answering Quizzes**: Reply with `A`, `B`, `C`, or `D` to quiz questions sent via SMS.
- **Check Status**: SMS `MY PROGRESS` to see your current score and level.

---

## 🏢 For NGOs & Administrators

### 1. NGO Dashboard (Next.js)
- **Analytics Overview**: View the main dashboard for high-level metrics like "Total Active Learners" and "Average Quiz Scores."
- **Managing Learners**: Use the 'Learners' tab to search for specific student IDs, check their last sync time, and view their certificates.
- **Content & Audio Management**: 
    1. Navigate to **Lesson Packs**.
    2. Click the **Manage** button on a specific pack.
    3. View all lessons and their audio status.
    4. Click **Add/Update Audio** to upload an MP3 directly. This automatically bumps the pack version and triggers a mobile sync.
- **Database Access**: For advanced users, use the 'Explorer' tab to run read-only SQL queries against the learner database.

---

## ❓ Frequently Asked Questions (FAQ)

### How do I reset my password?
EduFlow uses **Passwordless Auth**. Simply enter your phone number, and you will receive an OTP via SMS to log in securely.

### Can I use EduFlow on multiple devices?
Yes! As long as you use the same phone number, your progress will synchronize across devices once they are connected to the internet.

### Is my data safe?
Absolutely. We use industry-standard SHA-256 hashing for all phone numbers and personal identifiers. Even we cannot see your raw phone number in our database.

### What if I don't receive an OTP?
Ensure your phone number is entered in the international format (e.g., `+254...`). If the problem persists, wait 2 minutes and tap 'Resend OTP'.

---

## 🛠️ Support
For further assistance, please reach out to your local program coordinator or email **support@eduflow.app**.
