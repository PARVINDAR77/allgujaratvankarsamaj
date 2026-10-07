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
exports.CreateDesignationDto = exports.CreateDepartmentDto = exports.AdminStatusGovtEmpDto = exports.AdminFeatureGovtEmpDto = exports.AdminVerifyGovtEmpDto = exports.GovtEmployeeSearchQueryDto = exports.SubmitVerificationDto = exports.UpdateGovtEmploymentDto = exports.CreateGovtEmploymentDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const client_1 = require("@prisma/client");
class CreateGovtEmploymentDto {
}
exports.CreateGovtEmploymentDto = CreateGovtEmploymentDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        enum: client_1.GovtEmploymentType,
        example: client_1.GovtEmploymentType.STATE_GOVT,
    }),
    (0, class_validator_1.IsEnum)(client_1.GovtEmploymentType),
    __metadata("design:type", String)
], CreateGovtEmploymentDto.prototype, "employmentType", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: "dept-uuid-001" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateGovtEmploymentDto.prototype, "departmentId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: "desig-uuid-001" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateGovtEmploymentDto.prototype, "designationId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: "Collectorate, Gandhinagar" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateGovtEmploymentDto.prototype, "officeLocation", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: 2018 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(1970),
    (0, class_validator_1.Max)(2030),
    __metadata("design:type", Number)
], CreateGovtEmploymentDto.prototype, "joiningYear", void 0);
class UpdateGovtEmploymentDto {
}
exports.UpdateGovtEmploymentDto = UpdateGovtEmploymentDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ enum: client_1.GovtEmploymentType }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(client_1.GovtEmploymentType),
    __metadata("design:type", String)
], UpdateGovtEmploymentDto.prototype, "employmentType", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateGovtEmploymentDto.prototype, "departmentId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateGovtEmploymentDto.prototype, "designationId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], UpdateGovtEmploymentDto.prototype, "officeLocation", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsInt)(),
    __metadata("design:type", Number)
], UpdateGovtEmploymentDto.prototype, "joiningYear", void 0);
class SubmitVerificationDto {
}
exports.SubmitVerificationDto = SubmitVerificationDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: "GOVT_ID_CARD" }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], SubmitVerificationDto.prototype, "documentType", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: "https://storage.vankarsamaj.com/proofs/emp-123.jpg",
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], SubmitVerificationDto.prototype, "documentUrl", void 0);
const base_profile_query_dto_1 = require("../../profiles/dto/base-profile-query.dto");
class GovtEmployeeSearchQueryDto extends base_profile_query_dto_1.BaseProfileQueryDto {
}
exports.GovtEmployeeSearchQueryDto = GovtEmployeeSearchQueryDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], GovtEmployeeSearchQueryDto.prototype, "departmentId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)(),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], GovtEmployeeSearchQueryDto.prototype, "designationId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: "STATE_GOVT" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], GovtEmployeeSearchQueryDto.prototype, "employmentType", void 0);
class AdminVerifyGovtEmpDto {
}
exports.AdminVerifyGovtEmpDto = AdminVerifyGovtEmpDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: "APPROVE" }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], AdminVerifyGovtEmpDto.prototype, "action", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: "Document illegible or expired" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], AdminVerifyGovtEmpDto.prototype, "rejectionReason", void 0);
class AdminFeatureGovtEmpDto {
}
exports.AdminFeatureGovtEmpDto = AdminFeatureGovtEmpDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: true }),
    __metadata("design:type", Boolean)
], AdminFeatureGovtEmpDto.prototype, "isFeatured", void 0);
class AdminStatusGovtEmpDto {
}
exports.AdminStatusGovtEmpDto = AdminStatusGovtEmpDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: true }),
    __metadata("design:type", Boolean)
], AdminStatusGovtEmpDto.prototype, "isActive", void 0);
class CreateDepartmentDto {
}
exports.CreateDepartmentDto = CreateDepartmentDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: "Education Department" }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateDepartmentDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: "શિક્ષણ વિભાગ" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateDepartmentDto.prototype, "gujaratiName", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: "DEPT_EDU" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateDepartmentDto.prototype, "code", void 0);
class CreateDesignationDto {
}
exports.CreateDesignationDto = CreateDesignationDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: "dept-uuid-001" }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateDesignationDto.prototype, "departmentId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: "High School Teacher" }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", String)
], CreateDesignationDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: "ઉચ્ચતર માધ્યમિક શિક્ષક" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateDesignationDto.prototype, "gujaratiName", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: "DESIG_TEACHER" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateDesignationDto.prototype, "code", void 0);
//# sourceMappingURL=government-employees.dto.js.map