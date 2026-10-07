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
exports.CreateProfileDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const profile_enums_1 = require("../../common/enums/profile.enums");
const class_transformer_1 = require("class-transformer");
const class_validator_1 = require("class-validator");
const normalize_profile_helper_1 = require("./normalize-profile.helper");
class CreateProfileDto {
}
exports.CreateProfileDto = CreateProfileDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "First name of the profile owner",
        example: "Ramesh",
        maxLength: 100,
    }),
    (0, class_transformer_1.Transform)(({ value }) => (typeof value === "string" ? value.trim() : value)),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)({ message: "First name is required" }),
    (0, class_validator_1.Matches)(/^(?!\s*$).+/, {
        message: "First name must not be blank or whitespace-only",
    }),
    (0, class_validator_1.MaxLength)(100, { message: "First name cannot exceed 100 characters" }),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "firstName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "Last name of the profile owner",
        example: "Parmar",
        maxLength: 100,
    }),
    (0, class_transformer_1.Transform)(({ value }) => (typeof value === "string" ? value.trim() : value)),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)({ message: "Last name is required" }),
    (0, class_validator_1.Matches)(/^(?!\s*$).+/, {
        message: "Last name must not be blank or whitespace-only",
    }),
    (0, class_validator_1.MaxLength)(100, { message: "Last name cannot exceed 100 characters" }),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "lastName", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "Date of birth (ISO 8601 format: YYYY-MM-DD)",
        example: "1995-08-15",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "dateOfBirth", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "Gender of the profile owner",
        enum: profile_enums_1.Gender,
        example: profile_enums_1.Gender.MALE,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (0, normalize_profile_helper_1.normalizeGender)(value) || value),
    (0, class_validator_1.IsEnum)(profile_enums_1.Gender),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "gender", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: "Marital status",
        enum: profile_enums_1.MaritalStatus,
        example: profile_enums_1.MaritalStatus.NEVER_MARRIED,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (0, normalize_profile_helper_1.normalizeMaritalStatus)(value) || value),
    (0, class_validator_1.IsEnum)(profile_enums_1.MaritalStatus),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "maritalStatus", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Religion",
        example: "Hindu",
        maxLength: 100,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (typeof value === "string" ? value.trim() : value)),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^(?!\s*$).+/, { message: "Religion must not be whitespace-only" }),
    (0, class_validator_1.MaxLength)(100, { message: "Religion cannot exceed 100 characters" }),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "religion", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Caste / Sub-caste",
        example: "Vankar",
        maxLength: 100,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (typeof value === "string" ? value.trim() : value)),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^(?!\s*$).+/, { message: "Caste must not be whitespace-only" }),
    (0, class_validator_1.MaxLength)(100, { message: "Caste cannot exceed 100 characters" }),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "caste", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "City of residence",
        example: "Ahmedabad",
        maxLength: 100,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (typeof value === "string" ? value.trim() : value)),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^(?!\s*$).+/, { message: "City must not be whitespace-only" }),
    (0, class_validator_1.MaxLength)(100, { message: "City cannot exceed 100 characters" }),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "city", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "State of residence",
        example: "Gujarat",
        maxLength: 100,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (typeof value === "string" ? value.trim() : value)),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^(?!\s*$).+/, { message: "State must not be whitespace-only" }),
    (0, class_validator_1.MaxLength)(100, { message: "State cannot exceed 100 characters" }),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "state", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Country of residence",
        example: "India",
        maxLength: 100,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (typeof value === "string" ? value.trim() : value)),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^(?!\s*$).+/, { message: "Country must not be whitespace-only" }),
    (0, class_validator_1.MaxLength)(100, { message: "Country cannot exceed 100 characters" }),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "country", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Educational background",
        example: "B.Tech in Computer Engineering",
        maxLength: 200,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (typeof value === "string" ? value.trim() : value)),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^(?!\s*$).+/, { message: "Education must not be whitespace-only" }),
    (0, class_validator_1.MaxLength)(200, { message: "Education cannot exceed 200 characters" }),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "education", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Occupation / Job title",
        example: "Software Engineer",
        maxLength: 200,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (typeof value === "string" ? value.trim() : value)),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^(?!\s*$).+/, { message: "Occupation must not be whitespace-only" }),
    (0, class_validator_1.MaxLength)(200, { message: "Occupation cannot exceed 200 characters" }),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "occupation", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Personal biography or about profile notes",
        example: "Family-oriented professional living in Ahmedabad.",
        maxLength: 2000,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (typeof value === "string" ? value.trim() : value)),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^(?!\s*$).+/, { message: "About must not be whitespace-only" }),
    (0, class_validator_1.MaxLength)(2000, { message: "About cannot exceed 2000 characters" }),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "about", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Native place / Pargana",
        example: "22 Pargana",
        maxLength: 100,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (typeof value === "string" ? value.trim() : value)),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "nativePlace", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Organization / Department Name",
        example: "State Government",
        maxLength: 200,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (typeof value === "string" ? value.trim() : value)),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "organizationName", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Designation",
        example: "Manager",
        maxLength: 200,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => (typeof value === "string" ? value.trim() : value)),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "designation", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Profile photo URL or base64 data URI",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "photoUrl", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Whether the candidate is physically disabled",
        example: true,
    }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Boolean)
], CreateProfileDto.prototype, "isPhysicallyDisabled", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "PwBD Category (if physically disabled)",
        example: "VI - Visual Impairment",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "pwbdCategory", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Whether the candidate is living or studying abroad",
        example: true,
    }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Boolean)
], CreateProfileDto.prototype, "isAbroad", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Abroad country name",
        example: "Canada — કેનેડા",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "abroadCountry", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Business Industry (Category) from Samaj Services",
        example: "Healthcare",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "businessIndustry", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Specific Business Service from Samaj Services",
        example: "Doctor",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "businessService", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Candidate profile custom or generated ID (e.g. VNK12345)",
        example: "VNK12345",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Blood group",
        example: "B+",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "bloodGroup", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Whether the candidate is Vankar",
        example: true,
    }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Boolean)
], CreateProfileDto.prototype, "isVankar", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Annual / Yearly income range",
        example: "5 to 10 Lakhs",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "annualIncome", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Father's full name",
        example: "Rameshbhai Parmar",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "fatherName", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Father's occupation",
        example: "Government Officer",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "fatherOccupation", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Father's contact number",
        example: "9876543210",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "fatherContact", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Mother's full name",
        example: "Shilpaben Parmar",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "motherName", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Mother's occupation",
        example: "Homemaker",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "motherOccupation", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Guardian's contact number",
        example: "9876543210",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "guardianContact", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Brothers and sisters details",
        example: "1 Brother (Married), 1 Sister",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "siblings", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Mama's village / Mosal",
        example: "Mehsana",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "mamasVillage", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Flat / House / Area address",
        example: "B-204, Shivalik Residency, Chandkheda",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "addressLine", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Pincode / Zip Code",
        example: "382424",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "pincode", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "WhatsApp or alternate phone number",
        example: "9876543210",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "altPhone", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Contact email address",
        example: "candidate@gmail.com",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "contactEmail", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: "Mother tongue",
        example: "Gujarati (ગુજરાતી)",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateProfileDto.prototype, "motherTongue", void 0);
//# sourceMappingURL=create-profile.dto.js.map