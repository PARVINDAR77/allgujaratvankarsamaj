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
Object.defineProperty(exports, "__esModule", { value: true });
exports.VerifyProfileContactOtpDto = exports.SendProfileContactOtpDto = exports.AdminOtpQueryDto = exports.VerifyResetOtpDto = exports.SendForgotPasswordOtpDto = exports.VerifyRegistrationOtpDto = exports.SendRegistrationOtpDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const client_1 = require("@prisma/client");
class SendRegistrationOtpDto {
}
exports.SendRegistrationOtpDto = SendRegistrationOtpDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "User full name for SMS greeting",
        example: "Ramesh Patel",
    }),
    (0, class_validator_1.IsNotEmpty)({ message: "નામ દાખલ કરો (Name is required)" }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], SendRegistrationOtpDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "10-digit mobile number",
        example: "9876543210",
    }),
    (0, class_validator_1.IsNotEmpty)({ message: "મોબાઇલ નંબર દાખલ કરો (Mobile number is required)" }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^[6-9]\d{9}$/, {
        message: "કૃપા કરીને માન્ય 10 અંકનો મોબાઈલ નંબર દાખલ કરો (Valid 10-digit Indian mobile number required)",
    }),
    __metadata("design:type", String)
], SendRegistrationOtpDto.prototype, "phone", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "User email address",
        example: "user@example.com",
    }),
    (0, class_validator_1.IsNotEmpty)({ message: "ઈમેઈલ સરનામું દાખલ કરો (Email is required)" }),
    (0, class_validator_1.IsEmail)({}, { message: "માન્ય ઈમેઈલ સરનામું દાખલ કરો (Valid email format required)" }),
    __metadata("design:type", String)
], SendRegistrationOtpDto.prototype, "email", void 0);
class VerifyRegistrationOtpDto {
}
exports.VerifyRegistrationOtpDto = VerifyRegistrationOtpDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "10-digit mobile number",
        example: "9876543210",
    }),
    (0, class_validator_1.IsNotEmpty)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], VerifyRegistrationOtpDto.prototype, "phone", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "User email address",
        example: "user@example.com",
    }),
    (0, class_validator_1.IsNotEmpty)(),
    (0, class_validator_1.IsEmail)(),
    __metadata("design:type", String)
], VerifyRegistrationOtpDto.prototype, "email", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "6-digit OTP code received on Mobile via SMS",
        example: "123456",
    }),
    (0, class_validator_1.IsNotEmpty)({ message: "મોબાઇલ OTP દાખલ કરો (Mobile OTP is required)" }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(6, 6, { message: "મોબાઇલ OTP 6 અંકનો હોવો જોઈએ (Mobile OTP must be 6 digits)" }),
    __metadata("design:type", String)
], VerifyRegistrationOtpDto.prototype, "phoneOtp", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "6-digit OTP code received on Email",
        example: "654321",
    }),
    (0, class_validator_1.IsNotEmpty)({ message: "ઈમેઈલ OTP દાખલ કરો (Email OTP is required)" }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(6, 6, { message: "ઈમેઈલ OTP 6 અંકનો હોવો જોઈએ (Email OTP must be 6 digits)" }),
    __metadata("design:type", String)
], VerifyRegistrationOtpDto.prototype, "emailOtp", void 0);
class SendForgotPasswordOtpDto {
}
exports.SendForgotPasswordOtpDto = SendForgotPasswordOtpDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "Registered mobile number or email address",
        example: "9876543210",
    }),
    (0, class_validator_1.IsNotEmpty)({ message: "મોબાઇલ નંબર અથવા ઈમેઈલ દાખલ કરો (Mobile or email is required)" }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], SendForgotPasswordOtpDto.prototype, "identifier", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Preferred delivery channel: SMS or EMAIL",
        enum: client_1.OtpChannel,
        default: client_1.OtpChannel.SMS,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(client_1.OtpChannel),
    __metadata("design:type", String)
], SendForgotPasswordOtpDto.prototype, "channel", void 0);
class VerifyResetOtpDto {
}
exports.VerifyResetOtpDto = VerifyResetOtpDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "Registered mobile number or email address",
        example: "9876543210",
    }),
    (0, class_validator_1.IsNotEmpty)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], VerifyResetOtpDto.prototype, "identifier", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "6-digit OTP code",
        example: "123456",
    }),
    (0, class_validator_1.IsNotEmpty)({ message: "OTP કોડ દાખલ કરો (OTP code is required)" }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(6, 6, { message: "OTP કોડ 6 અંકનો હોવો જોઈએ (OTP must be 6 digits)" }),
    __metadata("design:type", String)
], VerifyResetOtpDto.prototype, "code", void 0);
class AdminOtpQueryDto {
}
exports.AdminOtpQueryDto = AdminOtpQueryDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ default: 1 }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], AdminOtpQueryDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ default: 20 }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], AdminOtpQueryDto.prototype, "limit", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ enum: client_1.OtpChannel }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(client_1.OtpChannel),
    __metadata("design:type", String)
], AdminOtpQueryDto.prototype, "channel", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ enum: client_1.OtpPurpose }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(client_1.OtpPurpose),
    __metadata("design:type", String)
], AdminOtpQueryDto.prototype, "purpose", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Filter by date (YYYY-MM-DD)" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], AdminOtpQueryDto.prototype, "date", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Search recipient phone or email" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], AdminOtpQueryDto.prototype, "search", void 0);
class SendProfileContactOtpDto {
}
exports.SendProfileContactOtpDto = SendProfileContactOtpDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Recipient name" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], SendProfileContactOtpDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "10-digit mobile number" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], SendProfileContactOtpDto.prototype, "phone", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Email address" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], SendProfileContactOtpDto.prototype, "email", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Target channel: SMS, EMAIL, or BOTH", enum: ["SMS", "EMAIL", "BOTH"] }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], SendProfileContactOtpDto.prototype, "channel", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Optional user ID" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], SendProfileContactOtpDto.prototype, "userId", void 0);
class VerifyProfileContactOtpDto {
}
exports.VerifyProfileContactOtpDto = VerifyProfileContactOtpDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "10-digit mobile number" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], VerifyProfileContactOtpDto.prototype, "phone", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Email address" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], VerifyProfileContactOtpDto.prototype, "email", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "6-digit OTP code for Mobile" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], VerifyProfileContactOtpDto.prototype, "phoneOtp", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "6-digit OTP code for Email" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], VerifyProfileContactOtpDto.prototype, "emailOtp", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Optional user ID" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], VerifyProfileContactOtpDto.prototype, "userId", void 0);
//# sourceMappingURL=otp.dto.js.map