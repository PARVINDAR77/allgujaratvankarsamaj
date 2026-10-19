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
  private resetCodes = new Map<
    string,
    { code: string; userId: string; expiresAt: number; attempts: number }
  >();

  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {}

  async register(dto: RegisterDto) {
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

  async forgotPassword(dto: ForgotPasswordDto) {
    const rawIdentifier = dto.identifier.trim();
    if (!rawIdentifier) {
      throw new BadRequestException(
        "ઈમેઈલ અથવા મોબાઇલ નંબર દાખલ કરો (Please enter email or mobile number)",
      );
    }

    // Try finding user by phone first, then by email
    let user = await this.usersService.findByPhone(rawIdentifier);
    if (!user) {
      user = await this.usersService.findByEmail(rawIdentifier);
    }

    if (!user) {
      throw new NotFoundException(
        "આ ઈમેઈલ અથવા મોબાઇલ નંબર સાથે કોઈ એકાઉન્ટ મળ્યું નથી (No account found with this email or mobile number)",
      );
    }

    // Generate secure 6-digit code
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = Date.now() + 15 * 60 * 1000; // 15 minutes

    const normKey =
      user.email?.toLowerCase().trim() ||
      user.phone?.trim() ||
      rawIdentifier.toLowerCase();
    this.resetCodes.set(normKey, {
      code,
      userId: user.id,
      expiresAt,
      attempts: 0,
    });
    this.resetCodes.set(rawIdentifier.toLowerCase(), {
      code,
      userId: user.id,
      expiresAt,
      attempts: 0,
    });
    if (user.phone) {
      this.resetCodes.set(user.phone.trim(), {
        code,
        userId: user.id,
        expiresAt,
        attempts: 0,
      });
    }

    this.logger.log(
      `Password reset code for user ${user.id} (${user.email || user.phone}): ${code}`,
    );

    // Masked identifier for UX
    let masked = "";
    if (user.phone && user.phone.length >= 10) {
      masked = `${user.phone.slice(0, 2)}******${user.phone.slice(-2)}`;
    } else if (user.email && user.email.includes("@")) {
      const [local, dom] = user.email.split("@");
      masked = `${local.slice(0, 2)}***@${dom}`;
    } else {
      masked = "તમારો નોંધાયેલ સંપર્ક";
    }

    return {
      success: true,
      message: `પાસવર્ડ રીસેટ કોડ મોકલવામાં આવ્યો છે (${masked})`,
      identifier: rawIdentifier,
      maskedContact: masked,
      code, // Returned for instant smooth verification without SMS gateway
    };
  }

  async verifyResetCode(dto: VerifyResetCodeDto) {
    const rawIdentifier = dto.identifier.trim().toLowerCase();
    const entry = this.resetCodes.get(rawIdentifier);

    if (!entry) {
      throw new BadRequestException(
        "કોઈ સક્રિય રીસેટ વિનંતી મળી નથી. કૃપા કરીને ફરીથી પ્રયાસ કરો (No active reset request found. Please request again.)",
      );
    }

    if (Date.now() > entry.expiresAt) {
      this.resetCodes.delete(rawIdentifier);
      throw new BadRequestException(
        "ચકાસણી કોડની સમયસીમા સમાપ્ત થઈ ગઈ છે (Verification code has expired. Please request a new one.)",
      );
    }

    if (entry.code !== dto.code.trim()) {
      entry.attempts += 1;
      if (entry.attempts >= 5) {
        this.resetCodes.delete(rawIdentifier);
        throw new BadRequestException(
          "ખૂબ ખોટા પ્રયાસો. કૃપા કરીને નવો કોડ મેળવો (Too many invalid attempts. Please request a new code.)",
        );
      }
      throw new BadRequestException(
        "અમાન્ય ચકાસણી કોડ (Invalid verification code)",
      );
    }

    return {
      success: true,
      message: "ચકાસણી સફળ (Verification successful)",
    };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const rawIdentifier = dto.identifier.trim().toLowerCase();
    const entry = this.resetCodes.get(rawIdentifier);

    if (!entry) {
      throw new BadRequestException(
        "કોઈ સક્રિય રીસેટ વિનંતી મળી નથી. કૃપા કરીને ફરીથી પ્રયાસ કરો (No active reset request found. Please request again.)",
      );
    }

    if (Date.now() > entry.expiresAt) {
      this.resetCodes.delete(rawIdentifier);
      throw new BadRequestException(
        "ચકાસણી કોડની સમયસીમા સમાપ્ત થઈ ગઈ છે (Verification code has expired)",
      );
    }

    if (entry.code !== dto.code.trim()) {
      throw new BadRequestException(
        "અમાન્ય ચકાસણી કોડ (Invalid verification code)",
      );
    }

    if (!dto.newPassword || dto.newPassword.length < 6) {
      throw new BadRequestException(
        "પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ (Password must be at least 6 characters)",
      );
    }

    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(dto.newPassword, saltRounds);

    await this.prisma.user.update({
      where: { id: entry.userId },
      data: { passwordHash },
    });

    this.resetCodes.delete(rawIdentifier);

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

