# Africa's Talking Setup Guide

This guide explains how to configure Africa's Talking (AT) credentials for the EduFlow platform to enable SMS and USSD functionalities.

## 1. Create an Africa's Talking Account

1.  Go to [Africa's Talking](https://africastalking.com/) and sign up for an account.
2.  Once registered, log in to the [AT Dashboard](https://dashboard.africastalking.com/).

## 2. Obtain Credentials

### API Key
1.  On the dashboard, go to **Settings** > **API Key**.
2.  Enter your password and click **Generate API Key**.
3.  **Copy this key immediately** and store it securely. You won't be able to see it again.

### Username
-   By default, your username is `sandbox` for testing.
-   For production, use the username you chose during registration or the one displayed in the top right corner of the dashboard.

## 3. Configure Environment Variables

Create or update your `.env` file in the project root with the following variables:

```env
# Africa's Talking Configuration
AFRICA_TALKING_API_KEY=your_generated_api_key
AFRICA_TALKING_USERNAME=sandbox # Use 'sandbox' for testing or your real username for production
SMS_SHORTCODE=your_shortcode # Optional: Use a specific shortcode or Sender ID
```

## 4. Sandbox vs. Production

### Sandbox (Testing)
-   **Username**: `sandbox`
-   **API Key**: Generate a separate key for the sandbox environment.
-   **Simulator**: Use the [AT Simulator](https://simulator.africastalking.com/) to test SMS and USSD without spending real credits.

### Production
-   **Username**: Your AT account username.
-   **API Key**: Use your live API key.
-   **Credits**: Ensure your account has sufficient balance to send messages.

## 5. Implementation Details

The EduFlow backend uses a dedicated service to handle SMS communication:
-   **Service**: `backend/src/services/sms.service.js`
-   **Configuration**: `sms_gateway/africastalking/shortcode_config.json`

In development mode (`NODE_ENV=development`), the SMS service will simulate sending messages to the console to prevent accidental credit usage.

## 6. Helpful Links
-   [AT Documentation](https://help.africastalking.com/en/)
-   [AT SDK for Node.js](https://github.com/AfricasTalkingLtd/africastalking-node.js)
