import nodemailer from 'nodemailer';
import { logger } from './logger';

export interface EmailOptions {
  to: string;
  subject: string;
  html: string;
  text?: string;
}

class EmailService {
  private transporter: nodemailer.Transporter | null = null;

  private createTransporter(): nodemailer.Transporter {
    if (!this.transporter) {
      this.transporter = nodemailer.createTransport({
        host: process.env.EMAIL_HOST || 'smtp.gmail.com',
        port: parseInt(process.env.EMAIL_PORT || '587'),
        secure: false,
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS,
        },
      });
    }
    return this.transporter;
  }

  async sendEmail(options: EmailOptions): Promise<boolean> {
    try {
      // Check if email credentials are configured
      if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
        logger.warn('Email service not configured - skipping email send');
        return false;
      }

      const transporter = this.createTransporter();
      const mailOptions = {
        from: process.env.EMAIL_FROM || process.env.EMAIL_USER,
        to: options.to,
        subject: options.subject,
        html: options.html,
        text: options.text,
      };

      await transporter.sendMail(mailOptions);
      logger.info('Email sent successfully', { to: options.to, subject: options.subject });
      return true;
    } catch (error) {
      logger.error('Failed to send email:', error);
      return false;
    }
  }

  async sendPasswordResetEmail(email: string, resetToken: string): Promise<boolean> {
    const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;
    
    return this.sendEmail({
      to: email,
      subject: 'Password Reset Request - Maize Watch',
      html: `
        <h2>Password Reset Request</h2>
        <p>You requested a password reset. Click the link below to reset your password:</p>
        <a href="${resetUrl}">Reset Password</a>
        <p>This link will expire in 1 hour.</p>
        <p>If you didn't request this, please ignore this email.</p>
      `,
      text: `Password reset link: ${resetUrl}`,
    });
  }

  async sendVerificationEmail(email: string, verificationToken: string): Promise<boolean> {
    const verificationUrl = `${process.env.FRONTEND_URL}/verify-email?token=${verificationToken}`;
    
    return this.sendEmail({
      to: email,
      subject: 'Email Verification - Maize Watch',
      html: `
        <h2>Email Verification</h2>
        <p>Please verify your email address by clicking the link below:</p>
        <a href="${verificationUrl}">Verify Email</a>
        <p>This link will expire in 24 hours.</p>
      `,
      text: `Email verification link: ${verificationUrl}`,
    });
  }

  async sendAlertNotification(
    email: string,
    fullName: string,
    farmName: string,
    alertType: string,
    message: string,
    severity: 'low' | 'medium' | 'high' | 'critical'
  ): Promise<boolean> {
    const severityColors = {
      low: '#28a745',
      medium: '#ffc107', 
      high: '#fd7e14',
      critical: '#dc3545'
    };

    const subject = `🚨 ${severity.toUpperCase()} Alert: ${alertType} - ${farmName}`;
    
    return this.sendEmail({
      to: email,
      subject,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: ${severityColors[severity]};">Farm Alert Notification</h2>
          <p>Hello ${fullName},</p>
          <p>An alert has been triggered for your farm <strong>${farmName}</strong>:</p>
          <div style="background-color: #f8f9fa; padding: 20px; border-left: 4px solid ${severityColors[severity]}; margin: 20px 0;">
            <p><strong>Alert Type:</strong> ${alertType}</p>
            <p><strong>Severity:</strong> ${severity.toUpperCase()}</p>
            <p><strong>Message:</strong> ${message}</p>
          </div>
          <div style="text-align: center; margin: 30px 0;">
            <a href="${process.env.FRONTEND_URL}/dashboard" 
               style="background-color: #4CAF50; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
              View Dashboard
            </a>
          </div>
          <p>Please check your farm monitoring dashboard for more details.</p>
          <p><strong>The Maize-Watch Team</strong></p>
        </div>
      `,
      text: `Alert: ${alertType} - ${message}. Check your dashboard at ${process.env.FRONTEND_URL}/dashboard`,
    });
  }
}

export default new EmailService();
