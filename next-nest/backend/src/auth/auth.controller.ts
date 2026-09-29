import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Request,
  UseGuards,
  Res,
} from "@nestjs/common";
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from "@nestjs/swagger";
import { AuthService } from "./auth.service";
import { LoginDto } from "./dto/login.dto";
import { RegisterDto } from "./dto/register.dto";
import { JwtAuthGuard } from "./guards/jwt-auth.guard";

import { Response } from "express";

@ApiTags("Authentication")
@Controller("auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post("register")
  @ApiOperation({ summary: "Register a new user" })
  @ApiResponse({
    status: 201,
    description: "User successfully registered",
    schema: {
      example: {
        id: "123e4567-e89b-12d3-a456-426614174000",
        email: "user@example.com",
        role: "USER",
        status: "ACTIVE",
        createdAt: "2026-09-09T12:00:00.000Z",
        updatedAt: "2026-09-09T12:00:00.000Z",
      },
    },
  })
  @ApiResponse({ status: 400, description: "Validation failed" })
  @ApiResponse({ status: 409, description: "User already exists" })
  async register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post("login")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "User login" })
  @ApiResponse({
    status: 200,
    description: "Login successful, sets HTTP-only cookie and returns user data",
  })
  @ApiResponse({ status: 400, description: "Validation failed" })
  @ApiResponse({ status: 401, description: "Invalid credentials" })
  async login(@Body() dto: LoginDto, @Res({ passthrough: true }) res: Response) {
    const authResult = await this.authService.login(dto);
    
    res.cookie("admin_token", authResult.accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      maxAge: 24 * 60 * 60 * 1000, // 1 day
    });

    return {
      message: "Login successful",
      user: authResult.user,
      accessToken: authResult.accessToken, // Retained for Flutter compatibility
      tokenType: "Bearer",
      expiresIn: "1d",
    };
  }

  @Post("logout")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "User logout" })
  @ApiResponse({ status: 200, description: "Logout successful" })
  async logout(@Res({ passthrough: true }) res: Response) {
    res.clearCookie("admin_token");
    return { message: "Logout successful" };
  }

  @Get("me")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get current authenticated user profile" })
  @ApiResponse({
    status: 200,
    description: "Authenticated user profile details",
    schema: {
      example: {
        id: "123e4567-e89b-12d3-a456-426614174000",
        email: "user@example.com",
        role: "USER",
        status: "ACTIVE",
        createdAt: "2026-09-09T12:00:00.000Z",
        updatedAt: "2026-09-09T12:00:00.000Z",
      },
    },
  })
  @ApiResponse({ status: 401, description: "Unauthorized access" })
  async getProfile(@Request() req: any) {
    return req.user;
  }
}
