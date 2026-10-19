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
exports.ResetPasswordDto = exports.VerifyResetCodeDto = exports.ForgotPasswordDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
class ForgotPasswordDto {
}
exports.ForgotPasswordDto = ForgotPasswordDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "Registered email address or 10-digit mobile number",
        example: "user@example.com",
    }),
    (0, class_validator_1.IsNotEmpty)({ message: "ઈમેઈલ અથવા મોબાઇલ નંબર જરૂરી છે (Email or mobile number is required)" }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ForgotPasswordDto.prototype, "identifier", void 0);
class VerifyResetCodeDto {
}
exports.VerifyResetCodeDto = VerifyResetCodeDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "Registered email address or 10-digit mobile number",
        example: "user@example.com",
    }),
    (0, class_validator_1.IsNotEmpty)({ message: "ઈમેઈલ અથવા મોબાઇલ નંબર જરૂરી છે (Email or mobile number is required)" }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], VerifyResetCodeDto.prototype, "identifier", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "6-digit verification code",
        example: "123456",
    }),
    (0, class_validator_1.IsNotEmpty)({ message: "ચકાસણી કોડ જરૂરી છે (Verification code is required)" }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], VerifyResetCodeDto.prototype, "code", void 0);
class ResetPasswordDto {
}
exports.ResetPasswordDto = ResetPasswordDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "Registered email address or 10-digit mobile number",
        example: "user@example.com",
    }),
    (0, class_validator_1.IsNotEmpty)({ message: "ઈમેઈલ અથવા મોબાઇલ નંબર જરૂરી છે (Email or mobile number is required)" }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ResetPasswordDto.prototype, "identifier", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "6-digit verification code",
        example: "123456",
    }),
    (0, class_validator_1.IsNotEmpty)({ message: "ચકાસણી કોડ જરૂરી છે (Verification code is required)" }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], ResetPasswordDto.prototype, "code", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "New password (minimum 6 characters)",
        example: "NewPassword123!",
    }),
    (0, class_validator_1.IsNotEmpty)({ message: "નવો પાસવર્ડ જરૂરી છે (New password is required)" }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(6, { message: "પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ (Password must be at least 6 characters)" }),
    __metadata("design:type", String)
], ResetPasswordDto.prototype, "newPassword", void 0);
//# sourceMappingURL=password-reset.dto.js.map