import { Injectable, UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { PassportStrategy } from "@nestjs/passport";
import { ExtractJwt, Strategy } from "passport-jwt";
import { UsersService } from "../../users/users.service";

export interface JwtPayload {
  sub: string;
  email: string;
  role: string;
}

import { Request } from "express";

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private readonly configService: ConfigService,
    private readonly usersService: UsersService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromExtractors([
        ExtractJwt.fromAuthHeaderAsBearerToken(),
        (request: Request) => {
          return (
            request?.cookies?.["admin_token"] ||
            request?.cookies?.["token"] ||
            request?.cookies?.["accessToken"] ||
            request?.cookies?.["jwt"] ||
            null
          );
        },
      ]),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>("JWT_SECRET"),
    });
  }

  async validate(payload: JwtPayload) {
    const userWithProfile = await this.usersService.findByIdWithProfile(payload.sub);
    if (!userWithProfile || userWithProfile.status !== "ACTIVE") {
      throw new UnauthorizedException("Unauthorized access");
    }

    const { passwordHash: _, profile, ...result } = userWithProfile;

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
      (profile?.status === "APPROVED" || (profile?.status as string) === "APPROVED");

    return {
      ...result,
      hasProfile,
      isVerified,
      profileStatus: profile?.status ?? (hasProfile ? "PENDING" : "NOT_CREATED"),
      profileId: profile?.id ?? null,
    };
  }
}
