import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
  UnauthorizedException,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import * as bcrypt from "bcrypt";
import { ProfileStatus } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { UsersService } from "../users/users.service";
import { OtpService } from "../otp/otp.service";
import { LoginDto } from "./dto/login.dto";
import { RegisterDto } from "./dto/register.dto";
import {
  ForgotPasswordDto,
  VerifyResetCodeDto,
  ResetPasswordDto,
  UpdatePasswordDto,
} from "./dto/password-reset.dto";

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
    private readonly otpService: OtpService,
  ) {}

  async register(dto: RegisterDto) {
    let isEmailVerified = false;
    let isPhoneVerified = false;

    if (dto.registrationToken) {
      const isValid = await this.otpService.consumeRegistrationToken(
        dto.registrationToken,
        dto.phone || "",
        dto.email || "",
      );
      if (!isValid) {
        throw new BadRequestException(
          "અમાન્ય અથવા સમાપ્ત થયેલ ચકાસણી ટોકન. કૃપા કરીને ફરીથી ચકાસણી કરો (Invalid or expired verification token. Please verify again.)",
        );
      }
      isEmailVerified = true;
      isPhoneVerified = true;
    }

    // Check for existing user by email or phone - Candidate can use their email only ONE time
    if (dto.email) {
      const cleanEmail = dto.email.trim().toLowerCase();
      const existingByEmail = await this.usersService.findByEmail(cleanEmail);
      if (existingByEmail) {
        throw new ConflictException(
          "આ ઈમેઈલ સરનામું પહેલેથી જ વપરાયેલ છે. ઉમેદવાર માત્ર એક જ વાર ઈમેઈલનો ઉપયોગ કરી શકે છે. (This email is already registered. Candidates can use their email only once.)",
        );
      }

      // Check if email was used in any candidate profile
      const existingProfileEmail = await this.prisma.matrimonialProfile.findFirst({
        where: { contactEmail: cleanEmail },
      });
      if (existingProfileEmail) {
        throw new ConflictException(
          "આ ઈમેઈલ અન્ય ઉમેદવાર દ્વારા પહેલેથી જ વપરાયેલ છે. ઉમેદવાર માત્ર એક જ વાર ઈમેઈલનો ઉપયોગ કરી શકે છે. (This email is already in use by another candidate. Candidates can use their email only once.)",
        );
      }
    }
    if (dto.phone) {
      const cleanPhone = dto.phone.trim();
      const existingByPhone = await this.usersService.findByPhone(cleanPhone);
      if (existingByPhone) {
        throw new ConflictException(
          "આ મોબાઇલ નંબર પહેલેથી જ નોંધાયેલ છે. (This mobile number is already registered.)",
        );
      }
    }

    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(dto.password, saltRounds);

    const user = await this.usersService.createUser({
      email: dto.email,
      phone: dto.phone,
      name: dto.name,
      gender: dto.gender,
      passwordHash,
      isEmailVerified,
      isPhoneVerified,
    });

    const { passwordHash: _, ...safeUser } = user;
    return {
      ...safeUser,
      isVerified: false,
      hasProfile: false,
      profileStatus: "NOT_CREATED",
    };
  }

  async login(dto: LoginDto) {
    let user = dto.phone
      ? await this.usersService.findByPhone(dto.phone)
      : null;
    if (!user && dto.email) {
      user = await this.usersService.findByEmail(dto.email);
    }

    if (!user) {
      throw new UnauthorizedException(
        "અમાન્ય ઓળખપત્ર (Invalid email/phone or password)",
      );
    }

    const isPasswordValid = await bcrypt.compare(
      dto.password,
      user.passwordHash,
    );
    if (!isPasswordValid) {
      throw new UnauthorizedException(
        "અમાન્ય ઓળખપત્ર (Invalid email/phone or password)",
      );
    }

    if (user.status !== "ACTIVE") {
      throw new UnauthorizedException(
        "આ એકાઉન્ટ નિષ્ક્રિય છે (Account is deactivated)",
      );
    }

    const profile = await this.prisma.matrimonialProfile.findUnique({
      where: { userId: user.id },
    });

    const isStub =
      profile &&
      profile.firstName === "User" &&
      profile.lastName === "Member" &&
      !profile.religion &&
      !profile.education &&
      !profile.caste;

    const hasProfile = profile !== null && !isStub;

    const isVerified =
      hasProfile &&
      profile?.isVerified === true &&
      profile?.status === ProfileStatus.APPROVED;

    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      isVerified,
      hasProfile,
    };

    const expiresIn = this.configService.get<string>("JWT_EXPIRES_IN", "1d");
    const accessToken = this.jwtService.sign(payload);

    const { passwordHash: _, ...safeUser } = user;

    return {
      accessToken,
      user: {
        ...safeUser,
        isVerified,
        hasProfile,
        profileStatus: profile?.status ?? "PENDING",
      },
      tokenType: "Bearer",
      expiresIn,
    };
  }

  async forgotPassword(dto: ForgotPasswordDto, ipAddress?: string) {
    return this.otpService.sendForgotPasswordOtp(
      { identifier: dto.identifier },
      ipAddress,
    );
  }

  async verifyResetCode(dto: VerifyResetCodeDto) {
    return this.otpService.verifyResetOtp({
      identifier: dto.identifier,
      code: dto.code,
    });
  }

  async resetPassword(dto: ResetPasswordDto) {
    if (!dto.newPassword || dto.newPassword.length < 6) {
      throw new BadRequestException(
        "પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ (Password must be at least 6 characters)",
      );
    }

    const rawIdentifier = dto.identifier.trim();
    let user = await this.usersService.findByPhone(rawIdentifier);
    if (!user) {
      user = await this.usersService.findByEmail(rawIdentifier.toLowerCase());
    }

    if (!user) {
      throw new NotFoundException(
        "આ ઈમેઈલ અથવા મોબાઇલ નંબર સાથે કોઈ એકાઉન્ટ મળ્યું નથી (No account found with this email or mobile number)",
      );
    }

    // Validate reset token or code via OtpService
    const isTokenConsumed = await this.otpService.consumeResetToken(
      rawIdentifier,
      dto.code,
    );
    if (!isTokenConsumed) {
      // Fallback check if user passed OTP code directly
      const verifyRes = await this.otpService.verifyResetOtp({
        identifier: rawIdentifier,
        code: dto.code,
      });
      if (!verifyRes?.success) {
        throw new BadRequestException(
          "અમાન્ય અથવા સમાપ્ત થયેલ ચકાસણી કોડ (Invalid or expired verification code)",
        );
      }
      await this.otpService.consumeResetToken(rawIdentifier, verifyRes.resetToken);
    }

    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(dto.newPassword, saltRounds);

    await this.prisma.user.update({
      where: { id: user.id },
      data: { passwordHash },
    });

    return {
      success: true,
      message:
        "તમારો પાસવર્ડ સફળતાપૂર્વક બદલાઈ ગયો છે. હવે તમે નવા પાસવર્ડથી લોગિન કરી શકો છો (Password has been reset successfully. You can now login.)",
    };
  }

  async updatePassword(userId: string, dto: UpdatePasswordDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException("વપરાશકર્તા મળ્યા નથી (User not found)");
    }

    const isCurrentValid = await bcrypt.compare(dto.currentPassword, user.passwordHash);
    if (!isCurrentValid) {
      throw new BadRequestException("હાલનો પાસવર્ડ ખોટો છે (Current password is incorrect)");
    }

    if (dto.newPassword.length < 6) {
      throw new BadRequestException(
        "નવો પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ (New password must be at least 6 characters)",
      );
    }

    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(dto.newPassword, saltRounds);

    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash },
    });

    return {
      success: true,
      message: "પાસવર્ડ સફળતાપૂર્વક અપડેટ થયો છે (Password has been updated successfully)",
    };
  }
}

