import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import logging
from typing import Optional
import os
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)


class EmailService:
    def __init__(self):
        self.smtp_server = "smtp.gmail.com"
        self.smtp_port = 465
        self.sender_email = os.getenv("EMAIL_SENDER", "deadbeefedfrfr@gmail.com")
        self.sender_password = os.getenv("EMAIL_PASSWORD", "clrvtwzjbhazwcqk")
        self.sender_name = os.getenv("EMAIL_SENDER_NAME", "Legal Platform")

    async def send_email(
            self,
            recipient: str,
            subject: str,
            html_content: str,
            text_content: Optional[str] = None
    ) -> bool:
        """
        Send email using Gmail SMTP

        Args:
            recipient: Recipient email address
            subject: Email subject
            html_content: HTML version of the email
            text_content: Plain text version (optional)

        Returns:
            bool: True if email sent successfully, False otherwise
        """
        try:
            # Create message
            msg = MIMEMultipart("alternative")
            msg["Subject"] = subject
            msg["From"] = f"{self.sender_name} <{self.sender_email}>"
            msg["To"] = recipient

            # Add text version if provided
            if text_content:
                text_part = MIMEText(text_content, "plain")
                msg.attach(text_part)

            # Add HTML version
            html_part = MIMEText(html_content, "html")
            msg.attach(html_part)

            # Send email
            with smtplib.SMTP_SSL(self.smtp_server, self.smtp_port) as server:
                server.login(self.sender_email, self.sender_password)
                server.send_message(msg)

            logger.info(f"Email sent successfully to {recipient}")
            return True

        except smtplib.SMTPAuthenticationError:
            logger.error("SMTP authentication failed. Check email credentials.")
            return False
        except smtplib.SMTPException as e:
            logger.error(f"SMTP error occurred: {e}")
            return False
        except Exception as e:
            logger.error(f"Failed to send email to {recipient}: {e}")
            return False

    async def send_password_reset_code(self, email: str, code: str) -> bool:
        """Send password reset verification code email"""
        subject = "Password Reset Verification Code"

        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {{
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    line-height: 1.6;
                    color: #333;
                    background-color: #f4f4f4;
                    margin: 0;
                    padding: 0;
                }}
                .container {{
                    max-width: 600px;
                    margin: 20px auto;
                    background-color: #ffffff;
                    border-radius: 10px;
                    overflow: hidden;
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                }}
                .header {{
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    padding: 30px 20px;
                    text-align: center;
                }}
                .header h1 {{
                    margin: 0;
                    font-size: 24px;
                    font-weight: 600;
                }}
                .content {{
                    padding: 40px 30px;
                }}
                .greeting {{
                    font-size: 16px;
                    margin-bottom: 20px;
                    color: #555;
                }}
                .code-box {{
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    border-radius: 10px;
                    padding: 30px;
                    text-align: center;
                    margin: 30px 0;
                    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
                }}
                .code {{
                    font-size: 40px;
                    font-weight: bold;
                    color: #ffffff;
                    letter-spacing: 10px;
                    font-family: 'Courier New', monospace;
                }}
                .code-label {{
                    color: #ffffff;
                    font-size: 14px;
                    margin-bottom: 10px;
                    opacity: 0.9;
                }}
                .expiry {{
                    background-color: #fff3cd;
                    border-left: 4px solid #ffc107;
                    padding: 15px;
                    margin: 20px 0;
                    border-radius: 4px;
                }}
                .expiry strong {{
                    color: #856404;
                }}
                .warning {{
                    background-color: #f8d7da;
                    border-left: 4px solid #dc3545;
                    padding: 15px;
                    margin: 20px 0;
                    border-radius: 4px;
                    font-size: 14px;
                }}
                .warning strong {{
                    color: #721c24;
                }}
                .info-text {{
                    font-size: 15px;
                    color: #666;
                    line-height: 1.8;
                }}
                .footer {{
                    background-color: #f8f9fa;
                    text-align: center;
                    padding: 20px;
                    font-size: 13px;
                    color: #6c757d;
                    border-top: 1px solid #dee2e6;
                }}
                .footer a {{
                    color: #667eea;
                    text-decoration: none;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🔐 Password Reset Request</h1>
                </div>
                <div class="content">
                    <p class="greeting">Hello,</p>
                    <p class="info-text">
                        You have requested to reset your password. Please use the verification code below to proceed with your password reset:
                    </p>

                    <div class="code-box">
                        <div class="code-label">YOUR VERIFICATION CODE</div>
                        <div class="code">{code}</div>
                    </div>

                    <div class="expiry">
                        <strong>⏱️ Important:</strong> This code will expire in <strong>15 minutes</strong> for security reasons.
                    </div>

                    <p class="info-text">
                        If you didn't request a password reset, please ignore this email and your password will remain unchanged. 
                        You may also want to check your account security.
                    </p>

                    <div class="warning">
                        <strong>⚠️ Security Notice:</strong><br>
                        • Never share this code with anyone, including our support team<br>
                        • We will never ask for your verification code via email or phone<br>
                        • If you suspect unauthorized access, change your password immediately
                    </div>
                </div>
                <div class="footer">
                    <p>This is an automated message from {self.sender_name}.</p>
                    <p>Please do not reply to this email.</p>
                    <p>© 2024 Legal Platform. All rights reserved.</p>
                </div>
            </div>
        </body>
        </html>
        """

        text_content = f"""
        Password Reset Request

        Hello,

        You have requested to reset your password. Please use the verification code below:

        VERIFICATION CODE: {code}

        This code will expire in 15 minutes.

        If you didn't request a password reset, please ignore this email or contact support if you have concerns.

        Security Notice:
        - Never share this code with anyone
        - Our team will never ask for your verification code

        This is an automated email. Please do not reply.

        © 2024 {self.sender_name}
        """

        return await self.send_email(email, subject, html_content, text_content)

    async def send_welcome_email(self, email: str, full_name: str) -> bool:
        """Send welcome email to new users"""
        subject = f"Welcome to {self.sender_name}!"

        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    color: #333;
                }}
                .container {{
                    max-width: 600px;
                    margin: 0 auto;
                    padding: 20px;
                }}
                .header {{
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    padding: 30px;
                    text-align: center;
                    border-radius: 10px 10px 0 0;
                }}
                .content {{
                    background-color: #f9f9f9;
                    padding: 30px;
                    border-radius: 0 0 10px 10px;
                }}
                .button {{
                    display: inline-block;
                    padding: 12px 30px;
                    background-color: #667eea;
                    color: white;
                    text-decoration: none;
                    border-radius: 5px;
                    margin: 20px 0;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Welcome to {self.sender_name}! 🎉</h1>
                </div>
                <div class="content">
                    <h2>Hello {full_name},</h2>
                    <p>Thank you for joining our platform! Your account has been successfully created.</p>
                    <p>You can now access all the features of our platform and start your journey with us.</p>
                    <p>If you have any questions, feel free to reach out to our support team.</p>
                    <p>Best regards,<br>The {self.sender_name} Team</p>
                </div>
            </div>
        </body>
        </html>
        """

        text_content = f"""
        Welcome to {self.sender_name}!

        Hello {full_name},

        Thank you for joining our platform! Your account has been successfully created.

        You can now access all the features of our platform and start your journey with us.

        If you have any questions, feel free to reach out to our support team.

        Best regards,
        The {self.sender_name} Team
        """

        return await self.send_email(email, subject, html_content, text_content)


# Create singleton instance
email_service = EmailService()