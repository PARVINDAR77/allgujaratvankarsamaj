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
exports.BaseProfileQueryDto = exports.ProfileSortField = exports.SortOrder = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_transformer_1 = require("class-transformer");
const class_validator_1 = require("class-validator");
const profile_enums_1 = require("../../common/enums/profile.enums");
const normalize_profile_helper_1 = require("./normalize-profile.helper");
var SortOrder;
(function (SortOrder) {
    SortOrder["ASC"] = "asc";
    SortOrder["DESC"] = "desc";
})(SortOrder || (exports.SortOrder = SortOrder = {}));
var ProfileSortField;
(function (ProfileSortField) {
    ProfileSortField["CREATED_AT"] = "createdAt";
    ProfileSortField["UPDATED_AT"] = "updatedAt";
    ProfileSortField["FIRST_NAME"] = "firstName";
    ProfileSortField["AGE"] = "age";
})(ProfileSortField || (exports.ProfileSortField = ProfileSortField = {}));
class BaseProfileQueryDto {
    constructor() {
        this.page = 1;
        this.limit = 10;
        this.sortBy = ProfileSortField.CREATED_AT;
        this.sortOrder = SortOrder.DESC;
    }
}
exports.BaseProfileQueryDto = BaseProfileQueryDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Page number for pagination",
        default: 1,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Type)(() => Number),
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(1),
    __metadata("design:type", Number)
], BaseProfileQueryDto.prototype, "page", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Number of items per page", default: 10 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Type)(() => Number),
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(1),
    __metadata("design:type", Number)
], BaseProfileQueryDto.prototype, "limit", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Filter by gender", enum: profile_enums_1.Gender }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (0, normalize_profile_helper_1.normalizeGender)(value)),
    (0, class_validator_1.IsEnum)(profile_enums_1.Gender),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "gender", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Filter by lookingFor (e.g. Groom / Bride)" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "lookingFor", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Filter by marital status", enum: profile_enums_1.MaritalStatus }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (0, normalize_profile_helper_1.normalizeMaritalStatus)(value)),
    (0, class_validator_1.IsEnum)(profile_enums_1.MaritalStatus),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "maritalStatus", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Minimum age" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Type)(() => Number),
    (0, class_validator_1.IsInt)(),
    __metadata("design:type", Number)
], BaseProfileQueryDto.prototype, "ageMin", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Maximum age" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Type)(() => Number),
    (0, class_validator_1.IsInt)(),
    __metadata("design:type", Number)
], BaseProfileQueryDto.prototype, "ageMax", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Filter by district ID" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "districtId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Filter by taluka ID" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "talukaId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Filter by occupation category (e.g. GOVERNMENT, PRIVATE, BUSINESS)",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "occupationCategory", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Filter by verification status",
        enum: profile_enums_1.VerificationStatus,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(profile_enums_1.VerificationStatus),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "verification", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Filter by profile status",
        enum: profile_enums_1.ProfileStatus,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(profile_enums_1.ProfileStatus),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "status", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Search keyword for name, occupation, or location",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "search", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Keyword search alias" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "keyword", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Pargana ID filter" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "parganaId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Pargana name filter" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "pargana", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "City filter" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Education filter" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "education", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Occupation filter" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "occupation", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Age from (alias for ageMin)" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Type)(() => Number),
    (0, class_validator_1.IsInt)(),
    __metadata("design:type", Number)
], BaseProfileQueryDto.prototype, "ageFrom", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: "Age to (alias for ageMax)" }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Type)(() => Number),
    (0, class_validator_1.IsInt)(),
    __metadata("design:type", Number)
], BaseProfileQueryDto.prototype, "ageTo", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Field to sort by",
        enum: ProfileSortField,
        default: ProfileSortField.CREATED_AT,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(ProfileSortField),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "sortBy", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Sort order (asc/desc)",
        enum: SortOrder,
        default: SortOrder.DESC,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(SortOrder),
    __metadata("design:type", String)
], BaseProfileQueryDto.prototype, "sortOrder", void 0);
//# sourceMappingURL=profile-query.dto.js.map