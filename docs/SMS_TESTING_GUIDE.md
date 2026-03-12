# SMS & OTP Testing Guide

This guide explains how to test and debug SMS/OTP functionality using the Africa's Talking Sandbox.

## 1. Accessing the Sandbox
1.  Go to the [Africa's Talking Sandbox Dashboard](https://simulator.africastalking.com/).
2.  Log in with your Africa's Talking credentials.

## 2. Debugging OTPs
Since you are in the sandbox, physical SMS messages are not sent. Instead, you must use the simulator:
1.  Launch the **Android Simulator** (or use the web simulator) on the Africa's Talking dashboard.
2.  Ensure you have a "Sandbox App" configured.
3.  Enter your phone number in the EduFlow mobile app (using the format `+254...` or your local format).
4.  Check the simulator's **SMS Inbox** or the **Logs** tab on the Africa's Talking dashboard to see the incoming message.

## 3. Database Verification (Supabase)
If you don't see the OTP in the simulator:
1.  Open your Supabase project.
2.  Go to the `Table Editor` and look for the `app_logs` table.
3.  Filter by `level = 'info'` or search for the phone number. The OTP request might be logged there if successful.
4.  Check the `auth_tokens` (or similar) table if it exists to see if a record was created.

## 4. Deployed Backend URL
The app and backend are configured to use:
- **URL**: `https://eduflow-api-ms02.onrender.com`

## 5. Common Errors
- `failed to request otp network exception`: This usually happens if the backend is waking up (cold start). We have added retry logic and increased timeouts to mitigate this.
- `Invalid Phone Format`: Ensure you include the country code (e.g., `+254`).

## 6. Development Fallback
If the Render backend is unavailable, you can run the backend locally:
- Base URL: `http://10.0.2.2:5000/api/v1` (for Android Emulator)
