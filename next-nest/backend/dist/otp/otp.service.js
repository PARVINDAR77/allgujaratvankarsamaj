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
var OtpService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.OtpService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const sms_service_1 = require("./sms.service");
const mail_service_1 = require("./mail.service");
const client_1 = require("@prisma/client");
const crypto = require("crypto");
let OtpService = OtpService_1 = class OtpService {
    constructor(prisma, smsService, mailService) {
        this.prisma = prisma;
        this.smsService = smsService;
        this.mailService = mailService;
        this.logger = new common_1.Logger(OtpService_1.name);
        this.MAX_ATTEMPTS = 4;
        this.LOCKOUT_MINUTES = 10;
        this.RESEND_COOLDOWN_SECONDS = 60;
        this.OTP_EXPIRY_MINUTES = 10;
    }
    generate6DigitOtp() {
        return Math.floor(100000 + Math.random() * 900000).toString();
    }
    maskPhone(phone) {
        const clean = phone.replace(/\D/g, "");
        if (clean.length >= 10) {
            return `${clean.slice(0, 2)}******${clean.slice(-2)}`;
        }
        return clean;
    }
    maskEmail(email) {
        const [local, dom] = email.split("@");
        if (!dom)
            return email;
        const maskedLocal = local.length > 2 ? `${local.slice(0, 2)}***` : `${local}*`;
        return `${maskedLocal}@${dom}`;
    }
    async checkLockout(target, purpose) {
        const session = await this.prisma.otpSession.findFirst({
            where: { target, purpose },
            orderBy: { createdAt: "desc" },
        });
        if (session && session.lockedUntil) {
            const now = new Date();
            if (session.lockedUntil > now) {
                const remainingSeconds = Math.ceil((session.lockedUntil.getTime() - now.getTime()) / 1000);
                const remainingMinutes = Math.ceil(remainingSeconds / 60);
                throw new common_1.HttpException({
                    statusCode: common_1.HttpStatus.TOO_MANY_REQUESTS,
                    error: "Too Many Requests",
                    message: `વધુ પડતા અમાન્ય પ્રયાસોના કારણે થોડા સમય માટે પ્રતિબંધિત છે. કૃપા કરીને ${remainingMinutes} મિનિટ પછી ફરી પ્રયાસ કરો. (Temporarily locked out due to multiple failed attempts. Please try again in ${remainingMinutes} minutes.)`,
                    lockedUntil: session.lockedUntil,
                    remainingSeconds,
                }, common_1.HttpStatus.TOO_MANY_REQUESTS);
            }
        }
        return session;
    }
    checkCooldown(session) {
        if (session) {
            const elapsedSeconds = (Date.now() - new Date(session.updatedAt || session.createdAt).getTime()) /
                1000;
            if (elapsedSeconds < this.RESEND_COOLDOWN_SECONDS) {
                const waitSec = Math.ceil(this.RESEND_COOLDOWN_SECONDS - elapsedSeconds);
                throw new common_1.BadRequestException(`કૃપા કરીને ફરીથી કોડ મોકલવા માટે ${waitSec} સેકન્ડ રાહ જુઓ. (Please wait ${waitSec} seconds before resending.)`);
            }
        }
    }
    async sendRegistrationOtp(dto, ipAddress) {
        const cleanPhone = this.smsService.cleanPhoneNumber(dto.phone);
        const cleanEmail = dto.email.trim().toLowerCase();
        const existingPhone = await this.prisma.user.findFirst({
            where: { phone: cleanPhone },
        });
        if (existingPhone && (existingPhone.isPhoneVerified || existingPhone.isEmailVerified)) {
            throw new common_1.ConflictException("આ મોબાઇલ નંબર પહેલેથી જ નોંધાયેલ છે (This mobile number is already registered)");
        }
        const existingEmail = await this.prisma.user.findFirst({
            where: { email: cleanEmail },
        });
        if (existingEmail && (existingEmail.isPhoneVerified || existingEmail.isEmailVerified)) {
            throw new common_1.ConflictException("આ ઈમેઈલ પહેલેથી જ નોંધાયેલ છે (This email address is already registered)");
        }
        const phoneSession = await this.checkLockout(cleanPhone, client_1.OtpPurpose.REGISTRATION);
        this.checkCooldown(phoneSession);
        const emailSession = await this.checkLockout(cleanEmail, client_1.OtpPurpose.REGISTRATION);
        this.checkCooldown(emailSession);
        const phoneOtp = this.generate6DigitOtp();
        const emailOtp = this.generate6DigitOtp();
        const expiresAt = new Date(Date.now() + this.OTP_EXPIRY_MINUTES * 60 * 1000);
        await this.prisma.otpSession.deleteMany({
            where: {
                target: { in: [cleanPhone, cleanEmail] },
                purpose: client_1.OtpPurpose.REGISTRATION,
            },
        });
        await this.prisma.otpSession.create({
            data: {
                target: cleanPhone,
                channel: client_1.OtpChannel.SMS,
                purpose: client_1.OtpPurpose.REGISTRATION,
                code: phoneOtp,
                attempts: 0,
                maxAttempts: this.MAX_ATTEMPTS,
                expiresAt,
            },
        });
        await this.prisma.otpSession.create({
            data: {
                target: cleanEmail,
                channel: client_1.OtpChannel.EMAIL,
                purpose: client_1.OtpPurpose.REGISTRATION,
                code: emailOtp,
                attempts: 0,
                maxAttempts: this.MAX_ATTEMPTS,
                expiresAt,
            },
        });
        const [smsRes, mailRes] = await Promise.all([
            this.smsService.sendOtpSms({
                phone: cleanPhone,
                otp: phoneOtp,
                recipientName: dto.name,
                purpose: client_1.OtpPurpose.REGISTRATION,
                ipAddress,
            }),
            this.mailService.sendOtpEmail({
                email: cleanEmail,
                otp: emailOtp,
                recipientName: dto.name,
                purpose: client_1.OtpPurpose.REGISTRATION,
                ipAddress,
            }),
        ]);
        this.logger.log(`Registration OTP dispatched: Mobile=${cleanPhone} (${smsRes.success ? "SMS OK" : "SMS ERR"}), Email=${cleanEmail} (${mailRes.success ? "Mail OK" : "Mail ERR"})`);
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
    async verifyRegistrationOtp(dto) {
        const cleanPhone = this.smsService.cleanPhoneNumber(dto.phone);
        const cleanEmail = dto.email.trim().toLowerCase();
        await this.checkLockout(cleanPhone, client_1.OtpPurpose.REGISTRATION);
        await this.checkLockout(cleanEmail, client_1.OtpPurpose.REGISTRATION);
        const phoneSession = await this.prisma.otpSession.findFirst({
            where: { target: cleanPhone, purpose: client_1.OtpPurpose.REGISTRATION },
            orderBy: { createdAt: "desc" },
        });
        const emailSession = await this.prisma.otpSession.findFirst({
            where: { target: cleanEmail, purpose: client_1.OtpPurpose.REGISTRATION },
            orderBy: { createdAt: "desc" },
        });
        if (!phoneSession || !emailSession) {
            throw new common_1.BadRequestException("ચકાસણી સત્ર મળ્યું નથી. કૃપા કરીને ફરીથી કોડ મોકલો (Verification session not found. Please request codes again.)");
        }
        const now = new Date();
        if (phoneSession.expiresAt < now || emailSession.expiresAt < now) {
            throw new common_1.BadRequestException("OTP ની મુદત પૂરી થઈ ગઈ છે. કૃપા કરીને નવો કોડ મેળવો (OTP has expired. Please request a new code.)");
        }
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
                throw new common_1.HttpException({
                    statusCode: common_1.HttpStatus.TOO_MANY_REQUESTS,
                    message: `મોબાઇલ OTP ના 4 અમાન્ય પ્રયાસો થયા છે. એકાઉન્ટ ${this.LOCKOUT_MINUTES} મિનિટ માટે લોક કરવામાં આવ્યું છે.`,
                    remainingSeconds: this.LOCKOUT_MINUTES * 60,
                }, common_1.HttpStatus.TOO_MANY_REQUESTS);
            }
            throw new common_1.BadRequestException(`અમાન્ય મોબાઇલ OTP કોડ. બાકી રહેલા પ્રયાસો: ${remainingAttempts} (Invalid Mobile OTP. Attempts remaining: ${remainingAttempts})`);
        }
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
                    throw new common_1.HttpException({
                        statusCode: common_1.HttpStatus.TOO_MANY_REQUESTS,
                        message: `ઈમેઈલ OTP ના 4 અમાન્ય પ્રયાસો થયા છે. એકાઉન્ટ ${this.LOCKOUT_MINUTES} મિનિટ માટે લોક કરવામાં આવ્યું છે.`,
                        remainingSeconds: this.LOCKOUT_MINUTES * 60,
                    }, common_1.HttpStatus.TOO_MANY_REQUESTS);
                }
                throw new common_1.BadRequestException(`અમાન્ય ઈમેઈલ OTP કોડ. બાકી રહેલા પ્રયાસો: ${remainingAttempts} (Invalid Email OTP. Attempts remaining: ${remainingAttempts})`);
            }
        }
        else {
            this.logger.log(`SMTP not active, verified Phone OTP (${cleanPhone}) confirmed for registration.`);
        }
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
        try {
            await this.prisma.user.updateMany({
                where: {
                    OR: [{ phone: cleanPhone }, { email: cleanEmail }],
                },
                data: {
                    isPhoneVerified: true,
                    isEmailVerified: true,
                },
            });
        }
        catch (_) { }
        return {
            success: true,
            verified: true,
            message: "મોબાઇલ અને ઈમેઈલ સફળતાપૂર્વક ચકાસાયા છે! (Mobile & Email verified successfully)",
            registrationToken,
        };
    }
    async sendProfileContactOtp(userId, dto, ipAddress) {
        if (!dto) {
            throw new common_1.BadRequestException("અમાન્ય વિનંતી (Invalid request)");
        }
        const rawPhone = dto.phone ? this.smsService.cleanPhoneNumber(dto.phone) : "";
        const rawEmail = dto.email ? dto.email.trim().toLowerCase() : "";
        const wantsSms = dto.channel === "SMS" || dto.channel === "BOTH" || !dto.channel;
        const wantsEmail = dto.channel === "EMAIL" || dto.channel === "BOTH" || !dto.channel;
        const hasPhone = rawPhone.length >= 10 && wantsSms;
        const hasEmail = rawEmail.includes("@") && wantsEmail;
        if (!hasPhone && !hasEmail) {
            throw new common_1.BadRequestException("કૃપા કરીને માન્ય 10-અંકનો મોબાઇલ નંબર અથવા ઈમેઈલ સરનામું દાખલ કરો.");
        }
        let phoneOtp;
        let emailOtp;
        const expiresAt = new Date(Date.now() + this.OTP_EXPIRY_MINUTES * 60 * 1000);
        if (hasPhone) {
            if (userId) {
                const otherPhone = await this.prisma.user.findFirst({
                    where: {
                        phone: rawPhone,
                        id: { not: userId },
                        isPhoneVerified: true,
                    },
                });
                if (otherPhone) {
                    throw new common_1.ConflictException("આ મોબાઇલ નંબર અન્ય ખાતામાં ચકાસાયેલ છે (This mobile number is already verified by another account)");
                }
            }
            const session = await this.checkLockout(rawPhone, client_1.OtpPurpose.REGISTRATION);
            this.checkCooldown(session);
            phoneOtp = this.generate6DigitOtp();
            await this.prisma.otpSession.deleteMany({
                where: { target: rawPhone, purpose: client_1.OtpPurpose.REGISTRATION },
            });
            await this.prisma.otpSession.create({
                data: {
                    target: rawPhone,
                    channel: client_1.OtpChannel.SMS,
                    purpose: client_1.OtpPurpose.REGISTRATION,
                    code: phoneOtp,
                    attempts: 0,
                    maxAttempts: this.MAX_ATTEMPTS,
                    expiresAt,
                },
            });
        }
        if (hasEmail) {
            if (userId) {
                const otherEmail = await this.prisma.user.findFirst({
                    where: {
                        email: rawEmail,
                        id: { not: userId },
                        isEmailVerified: true,
                    },
                });
                if (otherEmail) {
                    throw new common_1.ConflictException("આ ઈમેઈલ અન્ય ખાતામાં ચકાસાયેલ છે (This email is already verified by another account)");
                }
            }
            const session = await this.checkLockout(rawEmail, client_1.OtpPurpose.REGISTRATION);
            this.checkCooldown(session);
            emailOtp = this.generate6DigitOtp();
            await this.prisma.otpSession.deleteMany({
                where: { target: rawEmail, purpose: client_1.OtpPurpose.REGISTRATION },
            });
            await this.prisma.otpSession.create({
                data: {
                    target: rawEmail,
                    channel: client_1.OtpChannel.EMAIL,
                    purpose: client_1.OtpPurpose.REGISTRATION,
                    code: emailOtp,
                    attempts: 0,
                    maxAttempts: this.MAX_ATTEMPTS,
                    expiresAt,
                },
            });
        }
        const dispatchPromises = [];
        if (hasPhone && phoneOtp) {
            dispatchPromises.push(this.smsService.sendOtpSms({
                phone: rawPhone,
                otp: phoneOtp,
                recipientName: dto.name,
                purpose: client_1.OtpPurpose.REGISTRATION,
                ipAddress,
            }));
        }
        if (hasEmail && emailOtp) {
            dispatchPromises.push(this.mailService.sendOtpEmail({
                email: rawEmail,
                otp: emailOtp,
                recipientName: dto.name,
                purpose: client_1.OtpPurpose.REGISTRATION,
                ipAddress,
            }));
        }
        const [smsRes, mailRes] = await Promise.all(dispatchPromises);
        let message = "";
        if (hasPhone && hasEmail) {
            message = `ચકાસણી કોડ તમારા મોબાઇલ (${this.maskPhone(rawPhone)}) અને ઈમેઈલ (${this.maskEmail(rawEmail)}) પર મોકલવામાં આવ્યો છે.`;
        }
        else if (hasPhone) {
            message = `ચકાસણી કોડ મોબાઇલ નંબર (${this.maskPhone(rawPhone)}) પર SMS દ્વારા મોકલવામાં આવ્યો છે.`;
        }
        else {
            message = `ચકાસણી કોડ ઈમેઈલ (${this.maskEmail(rawEmail)}) પર મોકલવામાં આવ્યો છે.`;
        }
        return {
            success: true,
            message,
            maskedPhone: hasPhone ? this.maskPhone(rawPhone) : undefined,
            maskedEmail: hasEmail ? this.maskEmail(rawEmail) : undefined,
            channel: hasPhone && hasEmail ? "BOTH" : (hasPhone ? "SMS" : "EMAIL"),
            smsDelivered: smsRes ? smsRes.success : undefined,
            emailConfigured: true,
            expiresInSeconds: this.OTP_EXPIRY_MINUTES * 60,
            resendCooldownSeconds: this.RESEND_COOLDOWN_SECONDS,
            maxAttempts: this.MAX_ATTEMPTS,
        };
    }
    async verifyProfileContactOtp(userId, dto) {
        if (!dto) {
            throw new common_1.BadRequestException("અમાન્ય વિનંતી (Invalid request)");
        }
        const rawPhone = dto.phone ? this.smsService.cleanPhoneNumber(dto.phone) : "";
        const rawEmail = dto.email ? dto.email.trim().toLowerCase() : "";
        const phoneOtp = (dto.phoneOtp || "").trim();
        const emailOtp = (dto.emailOtp || "").trim();
        if (!phoneOtp && !emailOtp) {
            throw new common_1.BadRequestException("કૃપા કરીને ચકાસણી કોડ (OTP) દાખલ કરો.");
        }
        const userDataToUpdate = {};
        const now = new Date();
        if (phoneOtp) {
            if (!rawPhone || rawPhone.length < 10) {
                throw new common_1.BadRequestException("માન્ય મોબાઇલ નંબર જરૂરી છે.");
            }
            await this.checkLockout(rawPhone, client_1.OtpPurpose.REGISTRATION);
            const session = await this.prisma.otpSession.findFirst({
                where: { target: rawPhone, purpose: client_1.OtpPurpose.REGISTRATION },
                orderBy: { createdAt: "desc" },
            });
            if (!session) {
                throw new common_1.BadRequestException("મોબાઇલ ચકાસણી સત્ર મળ્યું નથી. કૃપા કરીને ફરીથી કોડ મોકલો.");
            }
            if (session.expiresAt < now) {
                throw new common_1.BadRequestException("મોબાઇલ OTP ની મુદત પૂરી થઈ ગઈ છે. કૃપા કરીને નવો કોડ મેળવો.");
            }
            if (session.code !== phoneOtp) {
                const newAttempts = session.attempts + 1;
                const remaining = Math.max(0, this.MAX_ATTEMPTS - newAttempts);
                await this.prisma.otpSession.update({
                    where: { id: session.id },
                    data: { attempts: newAttempts },
                });
                throw new common_1.BadRequestException(`અમાન્ય મોબાઇલ OTP કોડ. બાકી રહેલા પ્રયાસો: ${remaining}`);
            }
            await this.prisma.otpSession.update({
                where: { id: session.id },
                data: { isVerified: true, verifiedAt: now },
            });
            userDataToUpdate.phone = rawPhone;
            userDataToUpdate.isPhoneVerified = true;
        }
        if (emailOtp) {
            if (!rawEmail || !rawEmail.includes("@")) {
                throw new common_1.BadRequestException("માન્ય ઈમેઈલ સરનામું જરૂરી છે.");
            }
            await this.checkLockout(rawEmail, client_1.OtpPurpose.REGISTRATION);
            const session = await this.prisma.otpSession.findFirst({
                where: { target: rawEmail, purpose: client_1.OtpPurpose.REGISTRATION },
                orderBy: { createdAt: "desc" },
            });
            if (!session) {
                throw new common_1.BadRequestException("ઈમેઈલ ચકાસણી સત્ર મળ્યું નથી. કૃપા કરીને ફરીથી કોડ મોકલો.");
            }
            if (session.expiresAt < now) {
                throw new common_1.BadRequestException("ઈમેઈલ OTP ની મુદત પૂરી થઈ ગઈ છે. કૃપા કરીને નવો કોડ મેળવો.");
            }
            if (session.code !== emailOtp) {
                const newAttempts = session.attempts + 1;
                const remaining = Math.max(0, this.MAX_ATTEMPTS - newAttempts);
                await this.prisma.otpSession.update({
                    where: { id: session.id },
                    data: { attempts: newAttempts },
                });
                throw new common_1.BadRequestException(`અમાન્ય ઈમેઈલ OTP કોડ. બાકી રહેલા પ્રયાસો: ${remaining}`);
            }
            await this.prisma.otpSession.update({
                where: { id: session.id },
                data: { isVerified: true, verifiedAt: now },
            });
            userDataToUpdate.email = rawEmail;
            userDataToUpdate.isEmailVerified = true;
        }
        let targetUserId = userId;
        if (!targetUserId && (rawPhone || rawEmail)) {
            const matchConditions = [];
            if (rawPhone)
                matchConditions.push({ phone: rawPhone });
            if (rawEmail)
                matchConditions.push({ email: rawEmail });
            const matchedUser = await this.prisma.user.findFirst({
                where: { OR: matchConditions },
            });
            if (matchedUser) {
                targetUserId = matchedUser.id;
            }
        }
        if (targetUserId && Object.keys(userDataToUpdate).length > 0) {
            try {
                await this.prisma.user.update({
                    where: { id: targetUserId },
                    data: userDataToUpdate,
                });
                if (userDataToUpdate.email) {
                    await this.prisma.matrimonialProfile.updateMany({
                        where: { userId: targetUserId },
                        data: { contactEmail: rawEmail },
                    });
                }
            }
            catch (err) {
                this.logger.error(`Error updating verified user contact: ${err}`);
            }
        }
        let successMsg = "ચકાસણી સફળ થઈ!";
        if (userDataToUpdate.isPhoneVerified && userDataToUpdate.isEmailVerified) {
            successMsg = "મોબાઇલ નંબર અને ઈમેઈલ સફળતાપૂર્વક ચકાસાયેલ છે! (Mobile & Email verified!)";
        }
        else if (userDataToUpdate.isPhoneVerified) {
            successMsg = "મોબાઇલ નંબર સફળતાપૂર્વક ચકાસાયેલ છે! (Mobile number verified!)";
        }
        else if (userDataToUpdate.isEmailVerified) {
            successMsg = "ઈમેઈલ સરનામું સફળતાપૂર્વક ચકાસાયેલ છે! (Email address verified!)";
        }
        return {
            success: true,
            verified: true,
            isPhoneVerified: userDataToUpdate.isPhoneVerified === true,
            isEmailVerified: userDataToUpdate.isEmailVerified === true,
            message: successMsg,
        };
    }
    async consumeRegistrationToken(token, phone, email) {
        const cleanPhone = this.smsService.cleanPhoneNumber(phone);
        const cleanEmail = email.trim().toLowerCase();
        const phoneSession = await this.prisma.otpSession.findFirst({
            where: {
                token,
                target: cleanPhone,
                purpose: client_1.OtpPurpose.REGISTRATION,
                isVerified: true,
            },
        });
        const emailSession = await this.prisma.otpSession.findFirst({
            where: {
                target: cleanEmail,
                purpose: client_1.OtpPurpose.REGISTRATION,
                isVerified: true,
            },
        });
        if (!phoneSession || !emailSession) {
            return false;
        }
        await this.prisma.otpSession.deleteMany({
            where: {
                target: { in: [cleanPhone, cleanEmail] },
                purpose: client_1.OtpPurpose.REGISTRATION,
            },
        });
        return true;
    }
    async sendForgotPasswordOtp(dto, ipAddress) {
        const rawIdentifier = dto.identifier.trim();
        const cleanDigits = rawIdentifier.replace(/\D/g, "");
        let user = null;
        let target = "";
        let channel = client_1.OtpChannel.SMS;
        if (cleanDigits.length >= 10) {
            const cleanPhone = this.smsService.cleanPhoneNumber(rawIdentifier);
            user = await this.prisma.user.findFirst({ where: { phone: cleanPhone } });
            target = cleanPhone;
            channel = client_1.OtpChannel.SMS;
        }
        else if (rawIdentifier.includes("@")) {
            const cleanEmail = rawIdentifier.toLowerCase();
            user = await this.prisma.user.findFirst({ where: { email: cleanEmail } });
            target = cleanEmail;
            channel = client_1.OtpChannel.EMAIL;
        }
        else {
            user = await this.prisma.user.findFirst({
                where: {
                    OR: [{ phone: rawIdentifier }, { email: rawIdentifier.toLowerCase() }],
                },
            });
            target = user?.phone || user?.email || rawIdentifier;
            channel = user?.phone ? client_1.OtpChannel.SMS : client_1.OtpChannel.EMAIL;
        }
        if (!user) {
            throw new common_1.NotFoundException("આ મોબાઇલ નંબર અથવા ઈમેઈલ સાથે કોઈ એકાઉન્ટ મળ્યું નથી (No account found with this phone or email)");
        }
        const session = await this.checkLockout(target, client_1.OtpPurpose.FORGOT_PASSWORD);
        this.checkCooldown(session);
        const otp = this.generate6DigitOtp();
        const expiresAt = new Date(Date.now() + this.OTP_EXPIRY_MINUTES * 60 * 1000);
        await this.prisma.otpSession.deleteMany({
            where: { target, purpose: client_1.OtpPurpose.FORGOT_PASSWORD },
        });
        await this.prisma.otpSession.create({
            data: {
                target,
                channel,
                purpose: client_1.OtpPurpose.FORGOT_PASSWORD,
                code: otp,
                attempts: 0,
                maxAttempts: this.MAX_ATTEMPTS,
                expiresAt,
            },
        });
        let masked = "";
        if (channel === client_1.OtpChannel.SMS && user.phone) {
            masked = this.maskPhone(user.phone);
            await this.smsService.sendOtpSms({
                phone: user.phone,
                otp,
                recipientName: user.name || "Member",
                purpose: client_1.OtpPurpose.FORGOT_PASSWORD,
                ipAddress,
            });
        }
        else if (user.email) {
            masked = this.maskEmail(user.email);
            await this.mailService.sendOtpEmail({
                email: user.email,
                otp,
                recipientName: user.name || "Member",
                purpose: client_1.OtpPurpose.FORGOT_PASSWORD,
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
    async verifyResetOtp(dto) {
        const rawIdentifier = dto.identifier.trim();
        const cleanDigits = rawIdentifier.replace(/\D/g, "");
        const target = cleanDigits.length >= 10
            ? this.smsService.cleanPhoneNumber(rawIdentifier)
            : rawIdentifier.toLowerCase();
        await this.checkLockout(target, client_1.OtpPurpose.FORGOT_PASSWORD);
        const session = await this.prisma.otpSession.findFirst({
            where: { target, purpose: client_1.OtpPurpose.FORGOT_PASSWORD },
            orderBy: { createdAt: "desc" },
        });
        if (!session) {
            throw new common_1.BadRequestException("કોઈ સક્રિય રીસેટ વિનંતી મળી નથી. કૃપા કરીને ફરી વિનંતી કરો (No active reset request found)");
        }
        if (session.expiresAt < new Date()) {
            throw new common_1.BadRequestException("કોડની મુદત પૂરી થઈ ગઈ છે. કૃપા કરીને નવો કોડ મેળવો (OTP expired. Please request again.)");
        }
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
                throw new common_1.HttpException({
                    statusCode: common_1.HttpStatus.TOO_MANY_REQUESTS,
                    message: `OTP ના 4 અમાન્ય પ્રયાસો થયા છે. ${this.LOCKOUT_MINUTES} મિનિટ માટે રીસેટ લોક કરવામાં આવ્યું છે.`,
                    remainingSeconds: this.LOCKOUT_MINUTES * 60,
                }, common_1.HttpStatus.TOO_MANY_REQUESTS);
            }
            throw new common_1.BadRequestException(`અમાન્ય OTP કોડ. બાકી રહેલા પ્રયાસો: ${remainingAttempts} (Invalid OTP. Attempts remaining: ${remainingAttempts})`);
        }
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
    async consumeResetToken(identifier, token) {
        const rawIdentifier = identifier.trim();
        const cleanDigits = rawIdentifier.replace(/\D/g, "");
        const target = cleanDigits.length >= 10
            ? this.smsService.cleanPhoneNumber(rawIdentifier)
            : rawIdentifier.toLowerCase();
        const session = await this.prisma.otpSession.findFirst({
            where: {
                token,
                target,
                purpose: client_1.OtpPurpose.FORGOT_PASSWORD,
                isVerified: true,
            },
        });
        if (!session) {
            return false;
        }
        await this.prisma.otpSession.delete({
            where: { id: session.id },
        });
        return true;
    }
    async getDailySummary() {
        const now = new Date();
        const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0);
        const startOfYesterday = new Date(startOfToday.getTime() - 24 * 60 * 60 * 1000);
        const [todayLogs, yesterdayLogs, activeLockouts, totalAllTime,] = await Promise.all([
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
        const todaySms = todayLogs.filter((l) => l.channel === client_1.OtpChannel.SMS).length;
        const todayEmail = todayLogs.filter((l) => l.channel === client_1.OtpChannel.EMAIL).length;
        const todayRegistration = todayLogs.filter((l) => l.purpose === client_1.OtpPurpose.REGISTRATION).length;
        const todayForgot = todayLogs.filter((l) => l.purpose === client_1.OtpPurpose.FORGOT_PASSWORD).length;
        const todayDelivered = todayLogs.filter((l) => l.status === client_1.OtpStatus.DELIVERED).length;
        const todayFailed = todayLogs.filter((l) => l.status === client_1.OtpStatus.FAILED).length;
        const yesterdayTotal = yesterdayLogs.length;
        const yesterdaySms = yesterdayLogs.filter((l) => l.channel === client_1.OtpChannel.SMS).length;
        const yesterdayEmail = yesterdayLogs.filter((l) => l.channel === client_1.OtpChannel.EMAIL).length;
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
    async getDailyTrends(days = 7) {
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
        const trendMap = new Map();
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
                if (log.channel === client_1.OtpChannel.SMS)
                    entry.sms += 1;
                if (log.channel === client_1.OtpChannel.EMAIL)
                    entry.email += 1;
                if (log.status === client_1.OtpStatus.FAILED)
                    entry.failed += 1;
            }
        }
        return {
            success: true,
            days: daysLimit,
            trends: Array.from(trendMap.values()),
        };
    }
    async getLogs(query) {
        const page = Math.max(1, Number(query.page) || 1);
        const limit = Math.min(100, Math.max(1, Number(query.limit) || 20));
        const skip = (page - 1) * limit;
        const where = {};
        if (query.channel)
            where.channel = query.channel;
        if (query.purpose)
            where.purpose = query.purpose;
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
};
exports.OtpService = OtpService;
exports.OtpService = OtpService = OtpService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        sms_service_1.SmsService,
        mail_service_1.MailService])
], OtpService);
//# sourceMappingURL=otp.service.js.map