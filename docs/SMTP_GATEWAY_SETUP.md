# SMTP Gateway Setup Guide

This guide explains how to configure the SMTP gateway for EduFlow to enable system notifications and email alerts.

## 1. Prerequisites
You will need an SMTP server (e.g., SendGrid, Mailgun, Amazon SES, or a custom SMTP server).

## 2. Environment Configuration
Update your `.env` file in the `backend/` directory with the following variables:

```env
# SMTP Configuration
SMTP_HOST=smtp.yourprovider.com
SMTP_PORT=587
SMTP_USER=your_username@example.com
SMTP_PASS=your_secure_password
SMTP_FROM="EduFlow Support <support@eduflow.app>"
```

### Port Configuration:
-   **587**: Default for TLS (Recommended).
-   **465**: Default for SSL.
-   **25**: Non-secure (Not recommended).

## 3. Verification
Once configured, the backend will automatically attempt to verify the connection on startup.

Check the backend logs for:
-   `Successfully connected to SMTP server`: Configuration is correct.
-   `SMTP_HOST not configured. Email service will run in mock mode.`: Service is running in development/mock mode without sending real emails.

## 4. Usage in Code
To use the email service in other parts of the backend:

```javascript
const emailService = require('./services/email.service');

await emailService.sendEmail({
    to: 'user@example.com',
    subject: 'Welcome to EduFlow',
    text: 'Hello, welcome to our educational platform!',
});
```
