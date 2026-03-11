const nodemailer = require('nodemailer');
const config = require('../config/env');

/**
 * SMTP Email Service
 * Handles sending system emails, alerts, and notifications.
 */
class EmailService {
    constructor() {
        this.transporter = null;
        this.initialized = false;
    }

    /**
     * Initialize the SMTP transporter
     */
    async initialize() {
        if (this.initialized) return;

        try {
            // Only create transporter if host is configured
            if (!config.smtpHost) {
                console.warn('SMTP_HOST not configured. Email service will run in mock mode.');
                return;
            }

            this.transporter = nodemailer.createTransport({
                host: config.smtpHost,
                port: config.smtpPort,
                secure: config.smtpPort === 465, // true for 465, false for other ports
                auth: {
                    user: config.smtpUser,
                    pass: config.smtpPass,
                },
            });

            // Verify connection configuration
            await this.transporter.verify();
            this.initialized = true;
            console.log('Successfully connected to SMTP server');
        } catch (error) {
            console.error('Failed to initialize SMTP transporter:', error);
        }
    }

    /**
     * Send an email
     * @param {Object} options - Email options
     * @param {string} options.to - Recipient email
     * @param {string} options.subject - Email subject
     * @param {string} options.text - Plain text content
     * @param {string} [options.html] - HTML content
     */
    async sendEmail({ to, subject, text, html }) {
        if (!this.initialized) {
            await this.initialize();
        }

        if (!this.transporter) {
            console.log(`[Email Mock] To: ${to}, Subject: ${subject}`);
            console.log(`[Email Mock] Body: ${text}`);
            return { messageId: 'mock-id' };
        }

        const info = await this.transporter.sendMail({
            from: config.smtpFrom,
            to,
            subject,
            text,
            html: html || text,
        });

        console.log('Email sent: %s', info.messageId);
        return info;
    }
}

module.exports = new EmailService();
