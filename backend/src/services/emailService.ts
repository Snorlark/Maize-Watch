import { Resend } from 'resend';
import { logger } from '../utils/logger';

interface EmailOptions {
  to: string;
  subject: string;
  text?: string;
  html?: string;
  from?: string;
}

class EmailService {
  private resend: Resend;
  private defaultFrom: string;

  constructor() {
    const apiKey = process.env.RESEND_API_KEY || '';
    this.resend = new Resend(apiKey);
    this.defaultFrom = process.env.EMAIL_FROM || 'Maize-Watch <onboarding@resend.dev>';

    if (!apiKey) {
      logger.warn('RESEND_API_KEY is not set — emails will fail');
    } else {
      logger.info('Email service initialised (Resend HTTP API)');
    }
  }

  private async sendEmail(options: EmailOptions): Promise<void> {
    const { data, error } = await this.resend.emails.send({
      from: options.from || this.defaultFrom,
      to: [options.to],
      subject: options.subject,
      text: options.text,
      html: options.html,
    });

    if (error) {
      logger.error('Resend error:', error);
      throw new Error(`Failed to send email: ${error.message}`);
    }

    logger.info('Email sent successfully:', { messageId: data?.id, to: options.to, subject: options.subject });
  }

  async sendWelcomeEmail(email: string, fullName: string): Promise<void> {
    const subject = 'Welcome to Maize-Watch!';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #2c5530;">Welcome to Maize-Watch, ${fullName}!</h2>
        <p>Thank you for joining our agricultural monitoring platform.</p>
        <p>With Maize-Watch, you can:</p>
        <ul>
          <li>Monitor your farm's environmental conditions in real-time</li>
          <li>Receive alerts when conditions need attention</li>
          <li>Access detailed analytics and reports</li>
          <li>Optimize your crop yields with data-driven insights</li>
        </ul>
        <p>Get started by setting up your first farm and connecting your sensors.</p>
        <p>Happy farming!</p>
        <p><strong>The Maize-Watch Team</strong></p>
      </div>
    `;
    await this.sendEmail({ to: email, subject, html });
  }

  async sendEmailVerification(email: string, fullName: string, token: string): Promise<void> {
    const verificationUrl = `${process.env.FRONTEND_URL}/verify-email?token=${token}`;
    const subject = 'Verify Your Email Address - Maize-Watch';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #2c5530;">Email Verification Required</h2>
        <p>Hello ${fullName},</p>
        <p>Please verify your email address to complete your registration.</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${verificationUrl}" style="background-color: #4CAF50; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
            Verify Email Address
          </a>
        </div>
        <p>Or copy this link: <span style="word-break: break-all; color: #666;">${verificationUrl}</span></p>
        <p>This link expires in 24 hours.</p>
        <p><strong>The Maize-Watch Team</strong></p>
      </div>
    `;
    await this.sendEmail({ to: email, subject, html });
  }

  async sendPasswordReset(email: string, fullName: string, token: string): Promise<void> {
    const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;
    const subject = 'Password Reset Request - Maize-Watch';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #2c5530;">Password Reset Request</h2>
        <p>Hello ${fullName},</p>
        <p>We received a request to reset your Maize-Watch password.</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${resetUrl}" style="background-color: #ff6b6b; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
            Reset Password
          </a>
        </div>
        <p>Or copy this link: <span style="word-break: break-all; color: #666;">${resetUrl}</span></p>
        <p>This link expires in 10 minutes.</p>
        <p><strong>The Maize-Watch Team</strong></p>
      </div>
    `;
    await this.sendEmail({ to: email, subject, html });
  }

  async sendAlertNotification(
    email: string,
    fullName: string,
    farmName: string,
    alertType: string,
    alertMessage: string,
    severity: string
  ): Promise<void> {
    const severityColors: Record<string, string> = {
      low: '#ffc107', medium: '#ff9800', high: '#f44336', critical: '#d32f2f'
    };
    const color = severityColors[severity] || '#f44336';
    const subject = `🚨 ${severity.toUpperCase()} Alert: ${farmName} - Maize-Watch`;
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background-color: ${color}; color: white; padding: 20px; border-radius: 5px 5px 0 0;">
          <h2 style="margin: 0;">⚠️ Farm Alert Notification</h2>
        </div>
        <div style="padding: 20px; border: 1px solid #ddd; border-top: none; border-radius: 0 0 5px 5px;">
          <p>Hello ${fullName},</p>
          <div style="background-color: #f8f9fa; padding: 15px; border-left: 4px solid ${color}; margin: 20px 0;">
            <p><strong>Farm:</strong> ${farmName}</p>
            <p><strong>Alert Type:</strong> ${alertType}</p>
            <p><strong>Severity:</strong> ${severity.toUpperCase()}</p>
            <p><strong>Message:</strong> ${alertMessage}</p>
            <p><strong>Time:</strong> ${new Date().toLocaleString()}</p>
          </div>
          <p><strong>The Maize-Watch Team</strong></p>
        </div>
      </div>
    `;
    await this.sendEmail({ to: email, subject, html });
  }

  async sendWeeklyReport(email: string, fullName: string, reportData: any): Promise<void> {
    const subject = '📊 Weekly Farm Report - Maize-Watch';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #2c5530;">Weekly Farm Report</h2>
        <p>Hello ${fullName},</p>
        <div style="background-color: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">
          <p><strong>Active Farms:</strong> ${reportData.activeFarms || 0}</p>
          <p><strong>Total Sensors:</strong> ${reportData.totalSensors || 0}</p>
          <p><strong>Data Points Collected:</strong> ${reportData.dataPoints || 0}</p>
          <p><strong>Alerts Generated:</strong> ${reportData.alerts || 0}</p>
        </div>
        <p><strong>The Maize-Watch Team</strong></p>
      </div>
    `;
    await this.sendEmail({ to: email, subject, html });
  }

  async sendMaintenanceNotification(
    email: string,
    fullName: string,
    maintenanceDetails: string,
    scheduledTime: Date
  ): Promise<void> {
    const subject = '🔧 Scheduled Maintenance Notification - Maize-Watch';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #2c5530;">Scheduled Maintenance Notice</h2>
        <p>Hello ${fullName},</p>
        <div style="background-color: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0;">
          <p><strong>Details:</strong> ${maintenanceDetails}</p>
          <p><strong>Scheduled Time:</strong> ${scheduledTime.toLocaleString()}</p>
        </div>
        <p><strong>The Maize-Watch Team</strong></p>
      </div>
    `;
    await this.sendEmail({ to: email, subject, html });
  }

  async sendLoginOTP(
    email: string,
    fullName: string,
    otp: string,
    expiresInMinutes: number = 5
  ): Promise<void> {
    const subject = '🔐 Login Verification Code - Maize-Watch Admin';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background-color: #2c5530; color: white; padding: 20px; border-radius: 5px 5px 0 0; text-align: center;">
          <h2 style="margin: 0;">🔐 Login Verification</h2>
        </div>
        <div style="padding: 30px; border: 1px solid #ddd; border-top: none; border-radius: 0 0 5px 5px;">
          <p>Hello ${fullName},</p>
          <p>Use the code below to complete your login:</p>
          <div style="text-align: center; margin: 30px 0;">
            <div style="background-color: #f8f9fa; border: 2px dashed #4CAF50; padding: 20px; border-radius: 10px; display: inline-block;">
              <h1 style="color: #2c5530; font-size: 36px; letter-spacing: 8px; margin: 0; font-family: 'Courier New', monospace;">
                ${otp}
              </h1>
            </div>
          </div>
          <div style="background-color: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0;">
            <p style="margin: 0;"><strong>⏰ This code expires in ${expiresInMinutes} minutes.</strong></p>
          </div>
          <p>If you didn't attempt to log in, change your password immediately.</p>
          <p><strong>The Maize-Watch Security Team</strong></p>
        </div>
      </div>
    `;
    await this.sendEmail({ to: email, subject, html });
  }

  async sendForgotPasswordOTP(
    email: string,
    otp: string,
    fullName: string,
    expiresInMinutes: number = 5
  ): Promise<void> {
    const subject = '🔐 Password Reset Verification Code - Maize-Watch';
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background-color: #dc3545; color: white; padding: 20px; border-radius: 5px 5px 0 0; text-align: center;">
          <h2 style="margin: 0;">🔐 Password Reset Request</h2>
        </div>
        <div style="padding: 30px; border: 1px solid #ddd; border-top: none; border-radius: 0 0 5px 5px;">
          <p>Hello ${fullName},</p>
          <p>Use the code below to reset your password:</p>
          <div style="text-align: center; margin: 30px 0;">
            <div style="background-color: #f8f9fa; border: 2px dashed #dc3545; padding: 20px; border-radius: 10px; display: inline-block;">
              <h1 style="color: #dc3545; font-size: 36px; letter-spacing: 8px; margin: 0; font-family: 'Courier New', monospace;">
                ${otp}
              </h1>
            </div>
          </div>
          <div style="background-color: #f8d7da; padding: 15px; border-left: 4px solid #dc3545; margin: 20px 0;">
            <p style="margin: 0;"><strong>⏰ Expires in ${expiresInMinutes} minutes.</strong></p>
          </div>
          <p>If you didn't request this, ignore this email — your password won't change.</p>
          <p><strong>The Maize-Watch Security Team</strong></p>
        </div>
      </div>
    `;
    await this.sendEmail({ to: email, subject, html });
  }

  async sendCustomEmail(
    email: string,
    subject: string,
    message: string,
    isHtml: boolean = false
  ): Promise<void> {
    const emailOptions: EmailOptions = {
      to: email,
      subject: `${subject} - Maize-Watch`,
    };
    if (isHtml) {
      emailOptions.html = message;
    } else {
      emailOptions.text = message;
    }
    await this.sendEmail(emailOptions);
  }
}

export default new EmailService();
