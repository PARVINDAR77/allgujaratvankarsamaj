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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const auth_service_1 = require("./auth.service");
const users_service_1 = require("../users/users.service");
const otp_service_1 = require("../otp/otp.service");
const otp_dto_1 = require("../otp/dto/otp.dto");
const login_dto_1 = require("./dto/login.dto");
const register_dto_1 = require("./dto/register.dto");
const password_reset_dto_1 = require("./dto/password-reset.dto");
const jwt_auth_guard_1 = require("./guards/jwt-auth.guard");
let AuthController = class AuthController {
    constructor(authService, usersService, otpService) {
        this.authService = authService;
        this.usersService = usersService;
        this.otpService = otpService;
    }
    async sendRegistrationOtp(req, dto) {
        const ip = req.headers["x-forwarded-for"] || req.socket.remoteAddress;
        return this.otpService.sendRegistrationOtp(dto, Array.isArray(ip) ? ip[0] : ip);
    }
    async sendRegistrationCodes(req, dto) {
        return this.sendRegistrationOtp(req, dto);
    }
    async verifyRegistrationOtp(dto) {
        return this.otpService.verifyRegistrationOtp(dto);
    }
    async verifyRegistrationCodes(dto) {
        return this.verifyRegistrationOtp(dto);
    }
    async sendProfileContactOtp(req, dto) {
        const ip = req.headers["x-forwarded-for"] || req.socket.remoteAddress;
        const userId = req.user?.sub || req.user?.id;
        return this.otpService.sendProfileContactOtp(userId, dto, Array.isArray(ip) ? ip[0] : ip);
    }
    async verifyProfileContactOtp(req, dto) {
        const userId = req.user?.sub || req.user?.id;
        return this.otpService.verifyProfileContactOtp(userId, dto);
    }
    async register(dto) {
        return this.authService.register(dto);
    }
    async login(dto, res) {
        const authResult = await this.authService.login(dto);
        res.cookie("admin_token", authResult.accessToken, {
            httpOnly: true,
            secure: process.env.NODE_ENV === "production",
            sameSite: "lax",
            maxAge: 24 * 60 * 60 * 1000,
        });
        return {
            message: "Login successful",
            user: authResult.user,
            accessToken: authResult.accessToken,
            tokenType: "Bearer",
            expiresIn: "1d",
        };
    }
    async logout(res) {
        res.clearCookie("admin_token");
        return { message: "Logout successful" };
    }
    async getProfile(req) {
        return req.user;
    }
    async forgotPassword(req, dto) {
        const ip = req.headers["x-forwarded-for"] || req.socket.remoteAddress;
        return this.authService.forgotPassword(dto, Array.isArray(ip) ? ip[0] : ip);
    }
    async verifyResetCode(dto) {
        return this.authService.verifyResetCode(dto);
    }
    async resetPassword(dto) {
        return this.authService.resetPassword(dto);
    }
    async changePassword(req, dto) {
        return this.authService.updatePassword(req.user.id, dto);
    }
    async updatePassword(req, dto) {
        return this.authService.updatePassword(req.user.id, dto);
    }
    async deleteMyAccount(req) {
        return this.usersService.deleteUserAccount(req.user.id);
    }
};
exports.AuthController = AuthController;
__decorate([
    (0, common_1.Post)("register/send-otp"),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: "Send OTP to mobile (DLT SMS) and email for registration" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Verification codes dispatched" }),
    (0, swagger_1.ApiResponse)({ status: 409, description: "Phone or email already registered" }),
    (0, swagger_1.ApiResponse)({ status: 429, description: "Too many attempts or lockout active" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, otp_dto_1.SendRegistrationOtpDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "sendRegistrationOtp", null);
__decorate([
    (0, common_1.Post)("register/send-codes"),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: "Alias for send-otp" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, otp_dto_1.SendRegistrationOtpDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "sendRegistrationCodes", null);
__decorate([
    (0, common_1.Post)("register/verify-otp"),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: "Verify mobile OTP and email OTP, return registrationToken" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Verification successful, token returned" }),
    (0, swagger_1.ApiResponse)({ status: 400, description: "Invalid code or expired" }),
    (0, swagger_1.ApiResponse)({ status: 429, description: "Exceeded 4 attempts, locked out" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [otp_dto_1.VerifyRegistrationOtpDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "verifyRegistrationOtp", null);
__decorate([
    (0, common_1.Post)("register/verify-codes"),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: "Alias for verify-otp" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [otp_dto_1.VerifyRegistrationOtpDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "verifyRegistrationCodes", null);
__decorate([
    (0, common_1.Post)("profile/send-contact-otp"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: "Send OTP to user's mobile and email for profile contact verification" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, otp_dto_1.SendRegistrationOtpDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "sendProfileContactOtp", null);
__decorate([
    (0, common_1.Post)("profile/verify-contact-otp"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: "Verify mobile OTP and email OTP for profile contact verification" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, otp_dto_1.VerifyRegistrationOtpDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "verifyProfileContactOtp", null);
__decorate([
    (0, common_1.Post)("register"),
    (0, swagger_1.ApiOperation)({ summary: "Register a new user" }),
    (0, swagger_1.ApiResponse)({
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
    }),
    (0, swagger_1.ApiResponse)({ status: 400, description: "Validation failed" }),
    (0, swagger_1.ApiResponse)({ status: 409, description: "User already exists" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [register_dto_1.RegisterDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "register", null);
__decorate([
    (0, common_1.Post)("login"),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: "User login" }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: "Login successful, sets HTTP-only cookie and returns user data",
    }),
    (0, swagger_1.ApiResponse)({ status: 400, description: "Validation failed" }),
    (0, swagger_1.ApiResponse)({ status: 401, description: "Invalid credentials" }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Res)({ passthrough: true })),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [login_dto_1.LoginDto, Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "login", null);
__decorate([
    (0, common_1.Post)("logout"),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: "User logout" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Logout successful" }),
    __param(0, (0, common_1.Res)({ passthrough: true })),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "logout", null);
__decorate([
    (0, common_1.Get)("me"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: "Get current authenticated user profile" }),
    (0, swagger_1.ApiResponse)({
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
    }),
    (0, swagger_1.ApiResponse)({ status: 401, description: "Unauthorized access" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "getProfile", null);
__decorate([
    (0, common_1.Post)("forgot-password"),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: "Request password reset code using registered email or mobile number",
    }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Verification code sent" }),
    (0, swagger_1.ApiResponse)({ status: 404, description: "No account found" }),
    (0, swagger_1.ApiResponse)({ status: 429, description: "Too many attempts or lockout active" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, password_reset_dto_1.ForgotPasswordDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "forgotPassword", null);
__decorate([
    (0, common_1.Post)("verify-reset-code"),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: "Verify password reset code",
    }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Verification code is valid" }),
    (0, swagger_1.ApiResponse)({ status: 400, description: "Invalid or expired code" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [password_reset_dto_1.VerifyResetCodeDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "verifyResetCode", null);
__decorate([
    (0, common_1.Post)("reset-password"),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: "Set new password using verified reset code",
    }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Password reset successful" }),
    (0, swagger_1.ApiResponse)({ status: 400, description: "Validation error or invalid code" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [password_reset_dto_1.ResetPasswordDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "resetPassword", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)("change-password"),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: "Change/Update account password for authenticated user",
    }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Password updated successfully" }),
    (0, swagger_1.ApiResponse)({ status: 400, description: "Current password incorrect or validation error" }),
    (0, swagger_1.ApiResponse)({ status: 401, description: "Unauthorized access" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, password_reset_dto_1.UpdatePasswordDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "changePassword", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)("update-password"),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: "Change/Update account password alias",
    }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, password_reset_dto_1.UpdatePasswordDto]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "updatePassword", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Delete)("account/me"),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: "Permanently delete user account and all associated personal data",
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: "User account and all data deleted permanently",
    }),
    (0, swagger_1.ApiResponse)({ status: 401, description: "Unauthorized access" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "deleteMyAccount", null);
exports.AuthController = AuthController = __decorate([
    (0, swagger_1.ApiTags)("Authentication"),
    (0, common_1.Controller)("auth"),
    __metadata("design:paramtypes", [auth_service_1.AuthService,
        users_service_1.UsersService,
        otp_service_1.OtpService])
], AuthController);
//# sourceMappingURL=auth.controller.js.map