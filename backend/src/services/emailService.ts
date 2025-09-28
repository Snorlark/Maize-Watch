import nodemailer from 'nodemailer';
import { logger } from '../utils/logger';
import { EMAIL_TEMPLATES } from '../utils/constants';

interface EmailConfig {
  host: string;
  port: number;
  secure: boolean;
  auth: {
    user: string;
    pass: string;
  };
}

interface EmailOptions {
  to: string;
  subject: string;
  text?: string;
  html?: string;
  from?: string;
}

class EmailService {
  private transporter: nodemailer.Transporter;

  constructor() {
    this.transporter = {} as nodemailer.Transporter; // Initialize to avoid TS error
    this.createTransporter();
  }

  private createTransporter(): void {
    const config: EmailConfig = {
      host: process.env.EMAIL_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.EMAIL_PORT || '587'),
      secure: false, // true for 465, false for other ports
      auth: {
        user: process.env.EMAIL_USER || '',
        pass: process.env.EMAIL_PASS || '',
      },
    };

    this.transporter = nodemailer.createTransport(config);

    // Verify connection configuration
    this.transporter.verify((error, success) => {
      if (error) {
        logger.error('Email service configuration error:', error);
      } else {
        logger.info('Email service is ready to send messages');
      }
    });
  }

  private async sendEmail(options: EmailOptions): Promise<void> {
    try {
      const mailOptions = {
        from: options.from || process.env.EMAIL_FROM || process.env.EMAIL_USER,
        to: options.to,
        subject: options.subject,
        text: options.text,
        html: options.html,
      };

      const info = await this.transporter.sendMail(mailOptions);
      logger.info('Email sent successfully:', {
        messageId: info.messageId,
        to: options.to,
        subject: options.subject,
      });
    } catch (error) {
      logger.error('Failed to send email:', error);
      throw new Error('Failed to send email');
    }
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
        <p>If you have any questions, feel free to contact our support team.</p>
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
        <p>Thank you for registering with Maize-Watch. Please verify your email address to complete your registration.</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${verificationUrl}" 
             style="background-color: #4CAF50; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
            Verify Email Address
          </a>
        </div>
        <p>If the button doesn't work, you can also copy and paste this link into your browser:</p>
        <p style="word-break: break-all; color: #666;">${verificationUrl}</p>
        <p>This verification link will expire in 24 hours.</p>
        <p>If you didn't create an account with Maize-Watch, please ignore this email.</p>
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
        <p>We received a request to reset your password for your Maize-Watch account.</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${resetUrl}" 
             style="background-color: #ff6b6b; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
            Reset Password
          </a>
        </div>
        <p>If the button doesn't work, you can also copy and paste this link into your browser:</p>
        <p style="word-break: break-all; color: #666;">${resetUrl}</p>
        <p>This password reset link will expire in 10 minutes for security reasons.</p>
        <p>If you didn't request a password reset, please ignore this email. Your password will remain unchanged.</p>
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
    const subject = `🚨 ${severity.toUpperCase()} Alert: ${farmName} - Maize-Watch`;
    
    const severityColors: Record<string, string> = {
      low: '#ffc107',
      medium: '#ff9800',
      high: '#f44336',
      critical: '#d32f2f'
    };

    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background-color: ${severityColors[severity] || '#f44336'}; color: white; padding: 20px; border-radius: 5px 5px 0 0;">
          <h2 style="margin: 0;">⚠️ Farm Alert Notification</h2>
        </div>
        <div style="padding: 20px; border: 1px solid #ddd; border-top: none; border-radius: 0 0 5px 5px;">
          <p>Hello ${fullName},</p>
          <p>We've detected an issue that requires your attention:</p>
          <div style="background-color: #f8f9fa; padding: 15px; border-left: 4px solid ${severityColors[severity] || '#f44336'}; margin: 20px 0;">
            <p><strong>Farm:</strong> ${farmName}</p>
            <p><strong>Alert Type:</strong> ${alertType}</p>
            <p><strong>Severity:</strong> ${severity.toUpperCase()}</p>
            <p><strong>Message:</strong> ${alertMessage}</p>
            <p><strong>Time:</strong> ${new Date().toLocaleString()}</p>
          </div>
          <p>Please check your farm dashboard for more details and take appropriate action.</p>
          <div style="text-align: center; margin: 30px 0;">
            <a href="${process.env.FRONTEND_URL}/dashboard" 
               style="background-color: #4CAF50; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
              View Dashboard
            </a>
          </div>
          <p>Stay connected with your farm's health!</p>
          <p><strong>The Maize-Watch Team</strong></p>
        </div>
      </div>
    `;

    await this.sendEmail({ to: email, subject, html });
  }

  async sendWeeklyReport(
    email: string, 
    fullName: string, 
    reportData: any
  ): Promise<void> {
    const subject = `📊 Weekly Farm Report - Maize-Watch`;
    
    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #2c5530;">Weekly Farm Report</h2>
        <p>Hello ${fullName},</p>
        <p>Here's your weekly farm summary:</p>
        <div style="background-color: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">
          <h3>Farm Statistics</h3>
          <p><strong>Active Farms:</strong> ${reportData.activeFarms || 0}</p>
          <p><strong>Total Sensors:</strong> ${reportData.totalSensors || 0}</p>
          <p><strong>Data Points Collected:</strong> ${reportData.dataPoints || 0}</p>
          <p><strong>Alerts Generated:</strong> ${reportData.alerts || 0}</p>
        </div>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${process.env.FRONTEND_URL}/reports" 
             style="background-color: #4CAF50; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
            View Detailed Report
          </a>
        </div>
        <p>Keep monitoring your farm's progress!</p>
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
        <p>We wanted to inform you about upcoming scheduled maintenance:</p>
        <div style="background-color: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0;">
          <p><strong>Maintenance Details:</strong> ${maintenanceDetails}</p>
          <p><strong>Scheduled Time:</strong> ${scheduledTime.toLocaleString()}</p>
        </div>
        <p>During this time, you may experience brief interruptions in service. We apologize for any inconvenience.</p>
        <p>We'll work quickly to minimize downtime and improve your experience.</p>
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
          <p>You are attempting to log in to your Maize-Watch Admin account. For security purposes, please use the verification code below:</p>
          
          <div style="text-align: center; margin: 30px 0;">
            <div style="background-color: #f8f9fa; border: 2px dashed #4CAF50; padding: 20px; border-radius: 10px; display: inline-block;">
              <h1 style="color: #2c5530; font-size: 36px; letter-spacing: 8px; margin: 0; font-family: 'Courier New', monospace;">
                ${otp}
              </h1>
            </div>
          </div>
          
          <div style="background-color: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0;">
            <p style="margin: 0;"><strong>⏰ Important:</strong> This code will expire in ${expiresInMinutes} minutes.</p>
          </div>
          
          <p>If you didn't attempt to log in, please:</p>
          <ul>
            <li>Ignore this email</li>
            <li>Change your password immediately if you suspect unauthorized access</li>
            <li>Contact our support team if you have concerns</li>
          </ul>
          
          <p>For your security, never share this code with anyone.</p>
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
