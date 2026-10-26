"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var MailService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.MailService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
const nodemailer = require("nodemailer");
let MailService = MailService_1 = class MailService {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger(MailService_1.name);
        this.transporter = null;
        this.initTransporter();
    }
    initTransporter() {
        const host = process.env.SMTP_HOST;
        const port = parseInt(process.env.SMTP_PORT || "587", 10);
        const user = process.env.SMTP_USER;
        const pass = process.env.SMTP_PASS;
        if (host && user && pass) {
            try {
                this.transporter = nodemailer.createTransport({
                    host,
                    port,
                    secure: process.env.SMTP_SECURE === "true" || port === 465,
                    auth: { user, pass },
                    tls: { rejectUnauthorized: false },
                });
                this.logger.log(`SMTP Mailer initialized via ${host}:${port}`);
            }
            catch (err) {
                this.logger.warn(`Failed to initialize SMTP transporter: ${err.message}`);
                this.transporter = null;
            }
        }
        else {
            this.logger.warn("SMTP credentials not fully set (SMTP_HOST, SMTP_USER, SMTP_PASS). Outgoing emails will be logged to console until configured.");
        }
    }
    buildHtmlTemplate(params) {
        const isRegister = params.purpose === client_1.OtpPurpose.REGISTRATION;
        const title = isRegister
            ? "એકાઉન્ટ નોંધણી ચકાસણી (Account Verification)"
            : "પાસવર્ડ રીસેટ કોડ (Password Reset OTP)";
        const introGujarati = isRegister
            ? "ઓલ ગુજરાત વણકર સમાજમાં આપનું હાર્દિક સ્વાગત છે! તમારું ઈમેલ સરનામું ચકાસવા માટે નીચે આપેલ OTP કોડ દાખલ કરો:"
            : "તમારા એકાઉન્ટનો પાસવર્ડ રીસેટ કરવા માટે નીચે આપેલ ચકાસણી કોડ દાખલ કરો:";
        return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; background-color: #F4F6F9; margin: 0; padding: 20px; }
    .container { max-width: 580px; margin: 0 auto; background: #ffffff; border-radius: 14px; overflow: hidden; border: 1px solid #E2E8F0; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
    .header { background: linear-gradient(135deg, #041026 0%, #0d2247 100%); padding: 30px 24px; text-align: center; border-bottom: 3px solid #D4AF37; }
    .logo-text { color: #D4AF37; font-size: 20px; font-weight: 700; letter-spacing: 0.5px; margin: 0; }
    .sub-text { color: #ffffff; font-size: 13px; opacity: 0.85; margin-top: 6px; }
    .content { padding: 30px 28px; color: #1E293B; line-height: 1.6; }
    .otp-card { background: #07182E; border: 1.5px solid #D4AF37; border-radius: 12px; padding: 20px; text-align: center; margin: 24px 0; }
    .otp-code { font-size: 34px; font-weight: 800; color: #D4AF37; letter-spacing: 8px; margin: 6px 0; font-family: monospace; }
    .otp-note { color: #94A3B8; font-size: 12px; margin: 0; }
    .warning { background: #FFFBEB; border-left: 4px solid #F59E0B; padding: 12px 16px; border-radius: 6px; font-size: 12.5px; color: #92400E; margin-top: 20px; }
    .footer { background: #F8FAFC; padding: 20px; text-align: center; font-size: 11.5px; color: #64748B; border-top: 1px solid #E2E8F0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1 class="logo-text">ALL GUJARAT VANKAR SAMAJ</h1>
      <div class="sub-text">ઓલ ગુજરાત વણકર સમાજ એકતા અને વૈવાહિક મંચ</div>
    </div>
    <div class="content">
      <h2 style="color: #041026; font-size: 18px; margin-top: 0;">${title}</h2>
      <p style="font-size: 14px; color: #334155;">${introGujarati}</p>
      
      <div class="otp-card">
        <div style="color: #E2E8F0; font-size: 13px;">તમારો ચકાસણી કોડ (Your Verification Code)</div>
        <div class="otp-code">${params.otp}</div>
        <p class="otp-note">આ કોડ આગામી 10 મિનિટ માટે માન્ય છે (Valid for 10 minutes)</p>
      </div>

      <div class="warning">
        ⚠️ <strong>સલામતી સૂચના (Security Alert):</strong> આ OTP કોઈની પણ સાથે શેર કરશો નહીં. અમારા પ્રતિનિધિઓ ક્યારેય તમારી પાસે OTP માંગશે નહીં.
      </div>
    </div>
    <div class="footer">
      © ${new Date().getFullYear()} All Gujarat Vankar Samaj. All rights reserved.<br>
      આ એક સ્વચાલિત ઈમેલ છે, કૃપા કરીને આનો જવાબ આપશો નહીં.
    </div>
  </div>
</body>
</html>
    `;
    }
    async sendOtpEmail(params) {
        const cleanEmail = params.email.trim().toLowerCase();
        const fromAddress = process.env.SMTP_FROM ||
            '"All Gujarat Vankar Samaj" <noreply@allgujaratvankarsamaj.com>';
        const subject = params.purpose === client_1.OtpPurpose.REGISTRATION
            ? `[All Gujarat Vankar Samaj] Your Verification Code is ${params.otp}`
            : `[All Gujarat Vankar Samaj] Password Reset Code: ${params.otp}`;
        const html = this.buildHtmlTemplate(params);
        this.logger.log(`Dispatching Email OTP to ${cleanEmail} (Purpose: ${params.purpose})`);
        let status = client_1.OtpStatus.SENT;
        let messageId;
        let gatewayResp = "";
        try {
            if (this.transporter) {
                const info = await this.transporter.sendMail({
                    from: fromAddress,
                    to: cleanEmail,
                    subject,
                    html,
                });
                messageId = info.messageId;
                gatewayResp = `SMTP Success: messageId=${info.messageId}`;
                status = client_1.OtpStatus.DELIVERED;
                this.logger.log(`Email delivered to ${cleanEmail} (ID: ${messageId})`);
            }
            else {
                gatewayResp = `SMTP not configured in environment. Outputting OTP: ${params.otp}`;
                this.logger.warn(`EMAIL TO ${cleanEmail} (OTP: ${params.otp})`);
                status = client_1.OtpStatus.SENT;
            }
            await this.prisma.otpLog.create({
                data: {
                    channel: client_1.OtpChannel.EMAIL,
                    purpose: params.purpose,
                    recipient: cleanEmail,
                    ipAddress: params.ipAddress,
                    status,
                    gatewayId: messageId,
                    gatewayResp,
                },
            });
            return { success: true, messageId };
        }
        catch (error) {
            this.logger.error(`Failed to send email to ${cleanEmail}: ${error.message}`);
            try {
                await this.prisma.otpLog.create({
                    data: {
                        channel: client_1.OtpChannel.EMAIL,
                        purpose: params.purpose,
                        recipient: cleanEmail,
                        ipAddress: params.ipAddress,
                        status: client_1.OtpStatus.FAILED,
                        gatewayResp: `Error: ${error.message}`,
                    },
                });
            }
            catch (_) { }
            return { success: false, error: error.message };
        }
    }
};
exports.MailService = MailService;
exports.MailService = MailService = MailService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], MailService);
//# sourceMappingURL=mail.service.js.map