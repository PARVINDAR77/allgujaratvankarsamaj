import {
  BadRequestException,
  ConflictException,
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
  NotFoundException,
} from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { SmsService } from "./sms.service";
import { MailService } from "./mail.service";
import { OtpChannel, OtpPurpose, OtpStatus } from "@prisma/client";
import {
  AdminOtpQueryDto,
  SendForgotPasswordOtpDto,
  SendRegistrationOtpDto,
  VerifyRegistrationOtpDto,
  VerifyResetOtpDto,
} from "./dto/otp.dto";
import * as crypto from "crypto";

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);
  private readonly MAX_ATTEMPTS = 4;
  private readonly LOCKOUT_MINUTES = 10;
  private readonly RESEND_COOLDOWN_SECONDS = 60;
  private readonly OTP_EXPIRY_MINUTES = 10;

  constructor(
    private readonly prisma: PrismaService,
    private readonly smsService: SmsService,
    private readonly mailService: MailService,
  ) {}

  private generate6DigitOtp(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  private maskPhone(phone: string): string {
    const clean = phone.replace(/\D/g, "");
    if (clean.length >= 10) {
      return `${clean.slice(0, 2)}******${clean.slice(-2)}`;
    }
    return clean;
  }

  private maskEmail(email: string): string {
    const [local, dom] = email.split("@");
    if (!dom) return email;
    const maskedLocal =
      local.length > 2 ? `${local.slice(0, 2)}***` : `${local}*`;
    return `${maskedLocal}@${dom}`;
  }

  /**
   * Check if target is currently locked out
   */
  private async checkLockout(target: string, purpose: OtpPurpose) {
    const session = await this.prisma.otpSession.findFirst({
      where: { target, purpose },
      orderBy: { createdAt: "desc" },
    });

    if (session && session.lockedUntil) {
      const now = new Date();
      if (session.lockedUntil > now) {
        const remainingSeconds = Math.ceil(
          (session.lockedUntil.getTime() - now.getTime()) / 1000,
        );
        const remainingMinutes = Math.ceil(remainingSeconds / 60);
        throw new HttpException(
          {
            statusCode: HttpStatus.TOO_MANY_REQUESTS,
            error: "Too Many Requests",
            message: `વધુ પડતા અમાન્ય પ્રયાસોના કારણે થોડા સમય માટે પ્રતિબંધિત છે. કૃપા કરીને ${remainingMinutes} મિનિટ પછી ફરી પ્રયાસ કરો. (Temporarily locked out due to multiple failed attempts. Please try again in ${remainingMinutes} minutes.)`,
            lockedUntil: session.lockedUntil,
            remainingSeconds,
          },
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }
    }

    return session;
  }

  /**
   * Check 60s resend cooldown
   */
  private checkCooldown(session: any) {
    if (session) {
      const elapsedSeconds =
        (Date.now() - new Date(session.updatedAt || session.createdAt).getTime()) /
        1000;
      if (elapsedSeconds < this.RESEND_COOLDOWN_SECONDS) {
        const waitSec = Math.ceil(this.RESEND_COOLDOWN_SECONDS - elapsedSeconds);
        throw new BadRequestException(
          `કૃપા કરીને ફરીથી કોડ મોકલવા માટે ${waitSec} સેકન્ડ રાહ જુઓ. (Please wait ${waitSec} seconds before resending.)`,
        );
      }
    }
  }

  /**
   * Step 1 of Registration: Send OTP to Phone and Email
   */
  async sendRegistrationOtp(dto: SendRegistrationOtpDto, ipAddress?: string) {
    const cleanPhone = this.smsService.cleanPhoneNumber(dto.phone);
    const cleanEmail = dto.email.trim().toLowerCase();

    // 1. Ensure user does not already exist
    const existingPhone = await this.prisma.user.findFirst({
      where: { phone: cleanPhone },
    });
    if (existingPhone) {
      throw new ConflictException(
        "આ મોબાઇલ નંબર પહેલેથી જ નોંધાયેલ છે (This mobile number is already registered)",
      );
    }

    const existingEmail = await this.prisma.user.findFirst({
      where: { email: cleanEmail },
    });
    if (existingEmail) {
      throw new ConflictException(
        "આ ઈમેઈલ પહેલેથી જ નોંધાયેલ છે (This email address is already registered)",
      );
    }

    // 2. Check lockout & cooldown for phone and email
    const phoneSession = await this.checkLockout(cleanPhone, OtpPurpose.REGISTRATION);
    this.checkCooldown(phoneSession);

    const emailSession = await this.checkLockout(cleanEmail, OtpPurpose.REGISTRATION);
    this.checkCooldown(emailSession);

    // 3. Generate 6-digit OTPs
    const phoneOtp = this.generate6DigitOtp();
    const emailOtp = this.generate6DigitOtp();
    const expiresAt = new Date(Date.now() + this.OTP_EXPIRY_MINUTES * 60 * 1000);

    // 4. Save/upsert OTP sessions
    await this.prisma.otpSession.deleteMany({
      where: {
        target: { in: [cleanPhone, cleanEmail] },
        purpose: OtpPurpose.REGISTRATION,
      },
    });

    await this.prisma.otpSession.create({
      data: {
        target: cleanPhone,
        channel: OtpChannel.SMS,
        purpose: OtpPurpose.REGISTRATION,
        code: phoneOtp,
        attempts: 0,
        maxAttempts: this.MAX_ATTEMPTS,
        expiresAt,
      },
    });

    await this.prisma.otpSession.create({
      data: {
        target: cleanEmail,
        channel: OtpChannel.EMAIL,
        purpose: OtpPurpose.REGISTRATION,
        code: emailOtp,
        attempts: 0,
        maxAttempts: this.MAX_ATTEMPTS,
        expiresAt,
      },
    });

    // 5. Dispatch SMS and Email asynchronously
    const [smsRes, mailRes] = await Promise.all([
      this.smsService.sendOtpSms({
        phone: cleanPhone,
        otp: phoneOtp,
        recipientName: dto.name,
        purpose: OtpPurpose.REGISTRATION,
        ipAddress,
      }),
      this.mailService.sendOtpEmail({
        email: cleanEmail,
        otp: emailOtp,
        recipientName: dto.name,
        purpose: OtpPurpose.REGISTRATION,
        ipAddress,
      }),
    ]);

    this.logger.log(
      `Registration OTP dispatched: Mobile=${cleanPhone} (${smsRes.success ? "SMS OK" : "SMS ERR"}), Email=${cleanEmail} (${mailRes.success ? "Mail OK" : "Mail ERR"})`,
    );

    const isSmtpConfigured = this.mailService.isConfigured();
    return {
      success: true,
      message: isSmtpConfigured
        ? `ચકાસણી કોડ તમારા મોબાઇલ (${this.maskPhone(cleanPhone)}) અને ઈમેઈલ (${this.maskEmail(cleanEmail)}) પર મોકલવામાં આવ્યો છે.`
        : `ચકાસણી કોડ તમારા મોબાઇલ (${this.maskPhone(cleanPhone)}) પર મોકલવામાં આવ્યો છે.`,
      maskedPhone: this.maskPhone(cleanPhone),
      maskedEmail: this.maskEmail(cleanEmail),
      smsDelivered: smsRes.success,
      emailConfigured: isSmtpConfigured,
      expiresInSeconds: this.OTP_EXPIRY_MINUTES * 60,
      resendCooldownSeconds: this.RESEND_COOLDOWN_SECONDS,
      maxAttempts: this.MAX_ATTEMPTS,
    };
  }

  /**
   * Step 2 of Registration: Verify both Phone & Email OTPs
   */
  async verifyRegistrationOtp(dto: VerifyRegistrationOtpDto) {
    const cleanPhone = this.smsService.cleanPhoneNumber(dto.phone);
    const cleanEmail = dto.email.trim().toLowerCase();

    // 1. Check lockouts
    await this.checkLockout(cleanPhone, OtpPurpose.REGISTRATION);
    await this.checkLockout(cleanEmail, OtpPurpose.REGISTRATION);

    // 2. Fetch active sessions
    const phoneSession = await this.prisma.otpSession.findFirst({
      where: { target: cleanPhone, purpose: OtpPurpose.REGISTRATION },
      orderBy: { createdAt: "desc" },
    });
    const emailSession = await this.prisma.otpSession.findFirst({
      where: { target: cleanEmail, purpose: OtpPurpose.REGISTRATION },
      orderBy: { createdAt: "desc" },
    });

    if (!phoneSession || !emailSession) {
      throw new BadRequestException(
        "ચકાસણી સત્ર મળ્યું નથી. કૃપા કરીને ફરીથી કોડ મોકલો (Verification session not found. Please request codes again.)",
      );
    }

    const now = new Date();
    if (phoneSession.expiresAt < now || emailSession.expiresAt < now) {
      throw new BadRequestException(
        "OTP ની મુદત પૂરી થઈ ગઈ છે. કૃપા કરીને નવો કોડ મેળવો (OTP has expired. Please request a new code.)",
      );
    }

    // 3. Verify Phone OTP with attempt limit
    if (phoneSession.code !== dto.phoneOtp.trim()) {
      const newAttempts = phoneSession.attempts + 1;
      const remainingAttempts = Math.max(0, this.MAX_ATTEMPTS - newAttempts);
      const isLocking = newAttempts >= this.MAX_ATTEMPTS;
      const lockedUntil = isLocking
        ? new Date(Date.now() + this.LOCKOUT_MINUTES * 60 * 1000)
        : null;

      await this.prisma.otpSession.update({
        where: { id: phoneSession.id },
        data: { attempts: newAttempts, lockedUntil },
      });

      if (isLocking) {
        throw new HttpException(
          {
            statusCode: HttpStatus.TOO_MANY_REQUESTS,
            message: `મોબાઇલ OTP ના 4 અમાન્ય પ્રયાસો થયા છે. એકાઉન્ટ ${this.LOCKOUT_MINUTES} મિનિટ માટે લોક કરવામાં આવ્યું છે.`,
            remainingSeconds: this.LOCKOUT_MINUTES * 60,
          },
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }

      throw new BadRequestException(
        `અમાન્ય મોબાઇલ OTP કોડ. બાકી રહેલા પ્રયાસો: ${remainingAttempts} (Invalid Mobile OTP. Attempts remaining: ${remainingAttempts})`,
      );
    }

    // 4. Verify Email OTP with attempt limit
    const isSmtpConfigured = this.mailService.isConfigured();
    const cleanEmailOtp = (dto.emailOtp || "").trim();

    if (isSmtpConfigured) {
      if (emailSession.code !== cleanEmailOtp) {
        const newAttempts = emailSession.attempts + 1;
        const remainingAttempts = Math.max(0, this.MAX_ATTEMPTS - newAttempts);
        const isLocking = newAttempts >= this.MAX_ATTEMPTS;
        const lockedUntil = isLocking
          ? new Date(Date.now() + this.LOCKOUT_MINUTES * 60 * 1000)
          : null;

        await this.prisma.otpSession.update({
          where: { id: emailSession.id },
          data: { attempts: newAttempts, lockedUntil },
        });

        if (isLocking) {
          throw new HttpException(
            {
              statusCode: HttpStatus.TOO_MANY_REQUESTS,
              message: `ઈમેઈલ OTP ના 4 અમાન્ય પ્રયાસો થયા છે. એકાઉન્ટ ${this.LOCKOUT_MINUTES} મિનિટ માટે લોક કરવામાં આવ્યું છે.`,
              remainingSeconds: this.LOCKOUT_MINUTES * 60,
            },
            HttpStatus.TOO_MANY_REQUESTS,
          );
        }

        throw new BadRequestException(
          `અમાન્ય ઈમેઈલ OTP કોડ. બાકી રહેલા પ્રયાસો: ${remainingAttempts} (Invalid Email OTP. Attempts remaining: ${remainingAttempts})`,
        );
      }
    } else {
      this.logger.log(`SMTP not active, verified Phone OTP (${cleanPhone}) confirmed for registration.`);
    }

    // 5. Both verified! Generate registration proof token
    const registrationToken = `reg_${crypto.randomUUID()}`;
    await Promise.all([
      this.prisma.otpSession.update({
        where: { id: phoneSession.id },
        data: {
          isVerified: true,
          verifiedAt: now,
          token: registrationToken,
        },
      }),
      this.prisma.otpSession.update({
        where: { id: emailSession.id },
        data: {
          isVerified: true,
          verifiedAt: now,
        },
      }),
    ]);

    return {
      success: true,
      verified: true,
      message: "મોબાઇલ અને ઈમેઈલ સફળતાપૂર્વક ચકાસાયા છે! (Mobile & Email verified successfully)",
      registrationToken,
    };
  }

  /**
   * Validate that a registration token was legitimately generated
   */
  async consumeRegistrationToken(token: string, phone: string, email: string): Promise<boolean> {
    const cleanPhone = this.smsService.cleanPhoneNumber(phone);
    const cleanEmail = email.trim().toLowerCase();

    const phoneSession = await this.prisma.otpSession.findFirst({
      where: {
        token,
        target: cleanPhone,
        purpose: OtpPurpose.REGISTRATION,
        isVerified: true,
      },
    });

    const emailSession = await this.prisma.otpSession.findFirst({
      where: {
        target: cleanEmail,
        purpose: OtpPurpose.REGISTRATION,
        isVerified: true,
      },
    });

    if (!phoneSession || !emailSession) {
      return false;
    }

    // Token used, cleanup
    await this.prisma.otpSession.deleteMany({
      where: {
        target: { in: [cleanPhone, cleanEmail] },
        purpose: OtpPurpose.REGISTRATION,
      },
    });

    return true;
  }

  /**
   * Forgot Password - Send OTP via SMS or Email
   */
  async sendForgotPasswordOtp(dto: SendForgotPasswordOtpDto, ipAddress?: string) {
    const rawIdentifier = dto.identifier.trim();
    const cleanDigits = rawIdentifier.replace(/\D/g, "");

    let user: any = null;
    let target = "";
    let channel: OtpChannel = OtpChannel.SMS;

    if (cleanDigits.length >= 10) {
      const cleanPhone = this.smsService.cleanPhoneNumber(rawIdentifier);
      user = await this.prisma.user.findFirst({ where: { phone: cleanPhone } });
      target = cleanPhone;
      channel = OtpChannel.SMS;
    } else if (rawIdentifier.includes("@")) {
      const cleanEmail = rawIdentifier.toLowerCase();
      user = await this.prisma.user.findFirst({ where: { email: cleanEmail } });
      target = cleanEmail;
      channel = OtpChannel.EMAIL;
    } else {
      user = await this.prisma.user.findFirst({
        where: {
          OR: [{ phone: rawIdentifier }, { email: rawIdentifier.toLowerCase() }],
        },
      });
      target = user?.phone || user?.email || rawIdentifier;
      channel = user?.phone ? OtpChannel.SMS : OtpChannel.EMAIL;
    }

    if (!user) {
      throw new NotFoundException(
        "આ મોબાઇલ નંબર અથવા ઈમેઈલ સાથે કોઈ એકાઉન્ટ મળ્યું નથી (No account found with this phone or email)",
      );
    }

    // 1. Check lockout & cooldown
    const session = await this.checkLockout(target, OtpPurpose.FORGOT_PASSWORD);
    this.checkCooldown(session);

    // 2. Generate 6-digit OTP
    const otp = this.generate6DigitOtp();
    const expiresAt = new Date(Date.now() + this.OTP_EXPIRY_MINUTES * 60 * 1000);

    await this.prisma.otpSession.deleteMany({
      where: { target, purpose: OtpPurpose.FORGOT_PASSWORD },
    });

    await this.prisma.otpSession.create({
      data: {
        target,
        channel,
        purpose: OtpPurpose.FORGOT_PASSWORD,
        code: otp,
        attempts: 0,
        maxAttempts: this.MAX_ATTEMPTS,
        expiresAt,
      },
    });

    let masked = "";
    if (channel === OtpChannel.SMS && user.phone) {
      masked = this.maskPhone(user.phone);
      await this.smsService.sendOtpSms({
        phone: user.phone,
        otp,
        recipientName: user.name || "Member",
        purpose: OtpPurpose.FORGOT_PASSWORD,
        ipAddress,
      });
    } else if (user.email) {
      masked = this.maskEmail(user.email);
      await this.mailService.sendOtpEmail({
        email: user.email,
        otp,
        recipientName: user.name || "Member",
        purpose: OtpPurpose.FORGOT_PASSWORD,
        ipAddress,
      });
    }

    return {
      success: true,
      message: `પાસવર્ડ રીસેટ કોડ ${masked} પર મોકલવામાં આવ્યો છે.`,
      target,
      maskedContact: masked,
      channel,
      expiresInSeconds: this.OTP_EXPIRY_MINUTES * 60,
      resendCooldownSeconds: this.RESEND_COOLDOWN_SECONDS,
      maxAttempts: this.MAX_ATTEMPTS,
    };
  }

  /**
   * Verify Forgot Password OTP
   */
  async verifyResetOtp(dto: VerifyResetOtpDto) {
    const rawIdentifier = dto.identifier.trim();
    const cleanDigits = rawIdentifier.replace(/\D/g, "");
    const target =
      cleanDigits.length >= 10
        ? this.smsService.cleanPhoneNumber(rawIdentifier)
        : rawIdentifier.toLowerCase();

    // 1. Check lockout
    await this.checkLockout(target, OtpPurpose.FORGOT_PASSWORD);

    const session = await this.prisma.otpSession.findFirst({
      where: { target, purpose: OtpPurpose.FORGOT_PASSWORD },
      orderBy: { createdAt: "desc" },
    });

    if (!session) {
      throw new BadRequestException(
        "કોઈ સક્રિય રીસેટ વિનંતી મળી નથી. કૃપા કરીને ફરી વિનંતી કરો (No active reset request found)",
      );
    }

    if (session.expiresAt < new Date()) {
      throw new BadRequestException(
        "કોડની મુદત પૂરી થઈ ગઈ છે. કૃપા કરીને નવો કોડ મેળવો (OTP expired. Please request again.)",
      );
    }

    // 2. Validate code with 4-attempt limit
    if (session.code !== dto.code.trim()) {
      const newAttempts = session.attempts + 1;
      const remainingAttempts = Math.max(0, this.MAX_ATTEMPTS - newAttempts);
      const isLocking = newAttempts >= this.MAX_ATTEMPTS;
      const lockedUntil = isLocking
        ? new Date(Date.now() + this.LOCKOUT_MINUTES * 60 * 1000)
        : null;

      await this.prisma.otpSession.update({
        where: { id: session.id },
        data: { attempts: newAttempts, lockedUntil },
      });

      if (isLocking) {
        throw new HttpException(
          {
            statusCode: HttpStatus.TOO_MANY_REQUESTS,
            message: `OTP ના 4 અમાન્ય પ્રયાસો થયા છે. ${this.LOCKOUT_MINUTES} મિનિટ માટે રીસેટ લોક કરવામાં આવ્યું છે.`,
            remainingSeconds: this.LOCKOUT_MINUTES * 60,
          },
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }

      throw new BadRequestException(
        `અમાન્ય OTP કોડ. બાકી રહેલા પ્રયાસો: ${remainingAttempts} (Invalid OTP. Attempts remaining: ${remainingAttempts})`,
      );
    }

    // 3. Verified! Generate reset token
    const resetToken = `rst_${crypto.randomUUID()}`;
    await this.prisma.otpSession.update({
      where: { id: session.id },
      data: {
        isVerified: true,
        verifiedAt: new Date(),
        token: resetToken,
      },
    });

    return {
      success: true,
      verified: true,
      message: "ચકાસણી સફળ! હવે નવો પાસવર્ડ સેટ કરો (Verification successful. Set your new password.)",
      resetToken,
    };
  }

  /**
   * Complete password reset using verified token
   */
  async consumeResetToken(identifier: string, token: string): Promise<boolean> {
    const rawIdentifier = identifier.trim();
    const cleanDigits = rawIdentifier.replace(/\D/g, "");
    const target =
      cleanDigits.length >= 10
        ? this.smsService.cleanPhoneNumber(rawIdentifier)
        : rawIdentifier.toLowerCase();

    const session = await this.prisma.otpSession.findFirst({
      where: {
        token,
        target,
        purpose: OtpPurpose.FORGOT_PASSWORD,
        isVerified: true,
      },
    });

    if (!session) {
      return false;
    }

    // Cleanup session
    await this.prisma.otpSession.delete({
      where: { id: session.id },
    });

    return true;
  }

  // ==========================================
  // SUPER ADMIN OTP ANALYTICS & LOG MONITORING
  // ==========================================

  /**
   * Get Daily Summary for Super Admin
   */
  async getDailySummary() {
    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0);
    const startOfYesterday = new Date(startOfToday.getTime() - 24 * 60 * 60 * 1000);

    const [
      todayLogs,
      yesterdayLogs,
      activeLockouts,
      totalAllTime,
    ] = await Promise.all([
      this.prisma.otpLog.findMany({
        where: { createdAt: { gte: startOfToday } },
        select: { channel: true, purpose: true, status: true },
      }),
      this.prisma.otpLog.findMany({
        where: {
          createdAt: { gte: startOfYesterday, lt: startOfToday },
        },
        select: { channel: true, status: true },
      }),
      this.prisma.otpSession.count({
        where: {
          lockedUntil: { gt: now },
        },
      }),
      this.prisma.otpLog.count(),
    ]);

    const todaySms = todayLogs.filter((l) => l.channel === OtpChannel.SMS).length;
    const todayEmail = todayLogs.filter((l) => l.channel === OtpChannel.EMAIL).length;
    const todayRegistration = todayLogs.filter((l) => l.purpose === OtpPurpose.REGISTRATION).length;
    const todayForgot = todayLogs.filter((l) => l.purpose === OtpPurpose.FORGOT_PASSWORD).length;
    const todayDelivered = todayLogs.filter((l) => l.status === OtpStatus.DELIVERED).length;
    const todayFailed = todayLogs.filter((l) => l.status === OtpStatus.FAILED).length;

    const yesterdayTotal = yesterdayLogs.length;
    const yesterdaySms = yesterdayLogs.filter((l) => l.channel === OtpChannel.SMS).length;
    const yesterdayEmail = yesterdayLogs.filter((l) => l.channel === OtpChannel.EMAIL).length;

    return {
      success: true,
      today: {
        total: todayLogs.length,
        smsCount: todaySms,
        emailCount: todayEmail,
        registrationCount: todayRegistration,
        forgotPasswordCount: todayForgot,
        deliveredCount: todayDelivered,
        failedCount: todayFailed,
      },
      yesterday: {
        total: yesterdayTotal,
        smsCount: yesterdaySms,
        emailCount: yesterdayEmail,
      },
      activeLockouts,
      totalAllTime,
    };
  }

  /**
   * Daily Trends (Last 7 or 30 days)
   */
  async getDailyTrends(days: number = 7) {
    const daysLimit = Math.min(Math.max(days, 3), 60);
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - daysLimit);
    startDate.setHours(0, 0, 0, 0);

    const logs = await this.prisma.otpLog.findMany({
      where: { createdAt: { gte: startDate } },
      select: {
        channel: true,
        purpose: true,
        status: true,
        createdAt: true,
      },
      orderBy: { createdAt: "asc" },
    });

    const trendMap = new Map<string, { date: string; sms: number; email: number; total: number; failed: number }>();

    for (let i = 0; i <= daysLimit; i++) {
      const d = new Date(startDate);
      d.setDate(d.getDate() + i);
      const dateKey = d.toISOString().split("T")[0];
      trendMap.set(dateKey, { date: dateKey, sms: 0, email: 0, total: 0, failed: 0 });
    }

    for (const log of logs) {
      const dateKey = log.createdAt.toISOString().split("T")[0];
      const entry = trendMap.get(dateKey);
      if (entry) {
        entry.total += 1;
        if (log.channel === OtpChannel.SMS) entry.sms += 1;
        if (log.channel === OtpChannel.EMAIL) entry.email += 1;
        if (log.status === OtpStatus.FAILED) entry.failed += 1;
      }
    }

    return {
      success: true,
      days: daysLimit,
      trends: Array.from(trendMap.values()),
    };
  }

  /**
   * Paginated OTP Audit Logs
   */
  async getLogs(query: AdminOtpQueryDto) {
    const page = Math.max(1, Number(query.page) || 1);
    const limit = Math.min(100, Math.max(1, Number(query.limit) || 20));
    const skip = (page - 1) * limit;

    const where: any = {};

    if (query.channel) where.channel = query.channel;
    if (query.purpose) where.purpose = query.purpose;

    if (query.date) {
      const start = new Date(`${query.date}T00:00:00.000Z`);
      const end = new Date(`${query.date}T23:59:59.999Z`);
      where.createdAt = { gte: start, lte: end };
    }

    if (query.search) {
      where.recipient = { contains: query.search.trim() };
    }

    const [total, items] = await Promise.all([
      this.prisma.otpLog.count({ where }),
      this.prisma.otpLog.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip,
        take: limit,
      }),
    ]);

    return {
      success: true,
      data: items,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
