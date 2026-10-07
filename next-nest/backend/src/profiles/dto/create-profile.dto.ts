import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Gender, MaritalStatus } from "../../common/enums/profile.enums";
import { Transform } from "class-transformer";
import {
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
} from "class-validator";
import { IsMinAge } from "../../common/validators/is-min-age.validator";
import { normalizeGender, normalizeMaritalStatus } from "./normalize-profile.helper";

export class CreateProfileDto {
  @ApiProperty({
    description: "First name of the profile owner",
    example: "Ramesh",
    maxLength: 100,
  })
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString()
  @IsNotEmpty({ message: "First name is required" })
  @Matches(/^(?!\s*$).+/, {
    message: "First name must not be blank or whitespace-only",
  })
  @MaxLength(100, { message: "First name cannot exceed 100 characters" })
  firstName: string;

  @ApiProperty({
    description: "Last name of the profile owner",
    example: "Parmar",
    maxLength: 100,
  })
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString()
  @IsNotEmpty({ message: "Last name is required" })
  @Matches(/^(?!\s*$).+/, {
    message: "Last name must not be blank or whitespace-only",
  })
  @MaxLength(100, { message: "Last name cannot exceed 100 characters" })
  lastName: string;

  @ApiProperty({
    description: "Date of birth (ISO 8601 format: YYYY-MM-DD)",
    example: "1995-08-15",
  })
  @IsOptional()
  @IsString()
  dateOfBirth?: string;

  @ApiProperty({
    description: "Gender of the profile owner",
    enum: Gender,
    example: Gender.MALE,
  })
  @IsOptional()
  @Transform(({ value }) => normalizeGender(value) || value)
  @IsEnum(Gender)
  gender?: Gender;

  @ApiProperty({
    description: "Marital status",
    enum: MaritalStatus,
    example: MaritalStatus.NEVER_MARRIED,
  })
  @IsOptional()
  @Transform(({ value }) => normalizeMaritalStatus(value) || value)
  @IsEnum(MaritalStatus)
  maritalStatus?: MaritalStatus;

  @ApiPropertyOptional({
    description: "Religion",
    example: "Hindu",
    maxLength: 100,
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString()
  @Matches(/^(?!\s*$).+/, { message: "Religion must not be whitespace-only" })
  @MaxLength(100, { message: "Religion cannot exceed 100 characters" })
  religion?: string;

  @ApiPropertyOptional({
    description: "Caste / Sub-caste",
    example: "Vankar",
    maxLength: 100,
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString()
  @Matches(/^(?!\s*$).+/, { message: "Caste must not be whitespace-only" })
  @MaxLength(100, { message: "Caste cannot exceed 100 characters" })
  caste?: string;

  @ApiPropertyOptional({
    description: "City of residence",
    example: "Ahmedabad",
    maxLength: 100,
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString()
  @Matches(/^(?!\s*$).+/, { message: "City must not be whitespace-only" })
  @MaxLength(100, { message: "City cannot exceed 100 characters" })
  city?: string;

  @ApiPropertyOptional({
    description: "State of residence",
    example: "Gujarat",
    maxLength: 100,
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString()
  @Matches(/^(?!\s*$).+/, { message: "State must not be whitespace-only" })
  @MaxLength(100, { message: "State cannot exceed 100 characters" })
  state?: string;

  @ApiPropertyOptional({
    description: "Country of residence",
    example: "India",
    maxLength: 100,
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString()
  @Matches(/^(?!\s*$).+/, { message: "Country must not be whitespace-only" })
  @MaxLength(100, { message: "Country cannot exceed 100 characters" })
  country?: string;

  @ApiPropertyOptional({
    description: "Educational background",
    example: "B.Tech in Computer Engineering",
    maxLength: 200,
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString()
  @Matches(/^(?!\s*$).+/, { message: "Education must not be whitespace-only" })
  @MaxLength(200, { message: "Education cannot exceed 200 characters" })
  education?: string;

  @ApiPropertyOptional({
    description: "Occupation / Job title",
    example: "Software Engineer",
    maxLength: 200,
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString()
  @Matches(/^(?!\s*$).+/, { message: "Occupation must not be whitespace-only" })
  @MaxLength(200, { message: "Occupation cannot exceed 200 characters" })
  occupation?: string;

  @ApiPropertyOptional({
    description: "Personal biography or about profile notes",
    example: "Family-oriented professional living in Ahmedabad.",
    maxLength: 2000,
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString()
  @Matches(/^(?!\s*$).+/, { message: "About must not be whitespace-only" })
  @MaxLength(2000, { message: "About cannot exceed 2000 characters" })
  about?: string;

  @ApiPropertyOptional({
    description: "Native place / Pargana",
    example: "22 Pargana",
    maxLength: 100,
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString()
  nativePlace?: string;

  @ApiPropertyOptional({
    description: "Organization / Department Name",
    example: "State Government",
    maxLength: 200,
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString()
  organizationName?: string;

  @ApiPropertyOptional({
    description: "Designation",
    example: "Manager",
    maxLength: 200,
  })
  @IsOptional()
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString()
  designation?: string;

  @ApiPropertyOptional({
    description: "Profile photo URL or base64 data URI",
  })
  @IsOptional()
  @IsString()
  photoUrl?: string;

  @ApiPropertyOptional({
    description: "Whether the candidate is physically disabled",
    example: true,
  })
  @IsOptional()
  isPhysicallyDisabled?: boolean;

  @ApiPropertyOptional({
    description: "PwBD Category (if physically disabled)",
    example: "VI - Visual Impairment",
  })
  @IsOptional()
  @IsString()
  pwbdCategory?: string;

  @ApiPropertyOptional({
    description: "Whether the candidate is living or studying abroad",
    example: true,
  })
  @IsOptional()
  isAbroad?: boolean;

  @ApiPropertyOptional({
    description: "Abroad country name",
    example: "Canada — કેનેડા",
  })
  @IsOptional()
  @IsString()
  abroadCountry?: string;

  @ApiPropertyOptional({
    description: "Business Industry (Category) from Samaj Services",
    example: "Healthcare",
  })
  @IsOptional()
  @IsString()
  businessIndustry?: string;

  @ApiPropertyOptional({
    description: "Specific Business Service from Samaj Services",
    example: "Doctor",
  })
  @IsOptional()
  @IsString()
  businessService?: string;

  @ApiPropertyOptional({
    description: "Candidate profile custom or generated ID (e.g. VNK12345)",
    example: "VNK12345",
  })
  @IsOptional()
  @IsString()
  id?: string;

  @ApiPropertyOptional({
    description: "Blood group",
    example: "B+",
  })
  @IsOptional()
  @IsString()
  bloodGroup?: string;

  @ApiPropertyOptional({
    description: "Whether the candidate is Vankar",
    example: true,
  })
  @IsOptional()
  isVankar?: boolean;

  @ApiPropertyOptional({
    description: "Annual / Yearly income range",
    example: "5 to 10 Lakhs",
  })
  @IsOptional()
  @IsString()
  annualIncome?: string;

  @ApiPropertyOptional({
    description: "Father's full name",
    example: "Rameshbhai Parmar",
  })
  @IsOptional()
  @IsString()
  fatherName?: string;

  @ApiPropertyOptional({
    description: "Father's occupation",
    example: "Government Officer",
  })
  @IsOptional()
  @IsString()
  fatherOccupation?: string;

  @ApiPropertyOptional({
    description: "Father's contact number",
    example: "9876543210",
  })
  @IsOptional()
  @IsString()
  fatherContact?: string;

  @ApiPropertyOptional({
    description: "Mother's full name",
    example: "Shilpaben Parmar",
  })
  @IsOptional()
  @IsString()
  motherName?: string;

  @ApiPropertyOptional({
    description: "Mother's occupation",
    example: "Homemaker",
  })
  @IsOptional()
  @IsString()
  motherOccupation?: string;

  @ApiPropertyOptional({
    description: "Guardian's contact number",
    example: "9876543210",
  })
  @IsOptional()
  @IsString()
  guardianContact?: string;

  @ApiPropertyOptional({
    description: "Brothers and sisters details",
    example: "1 Brother (Married), 1 Sister",
  })
  @IsOptional()
  @IsString()
  siblings?: string;

  @ApiPropertyOptional({
    description: "Mama's village / Mosal",
    example: "Mehsana",
  })
  @IsOptional()
  @IsString()
  mamasVillage?: string;

  @ApiPropertyOptional({
    description: "Flat / House / Area address",
    example: "B-204, Shivalik Residency, Chandkheda",
  })
  @IsOptional()
  @IsString()
  addressLine?: string;

  @ApiPropertyOptional({
    description: "Pincode / Zip Code",
    example: "382424",
  })
  @IsOptional()
  @IsString()
  pincode?: string;

  @ApiPropertyOptional({
    description: "WhatsApp or alternate phone number",
    example: "9876543210",
  })
  @IsOptional()
  @IsString()
  altPhone?: string;

  @ApiPropertyOptional({
    description: "Contact email address",
    example: "candidate@gmail.com",
  })
  @IsOptional()
  @IsString()
  contactEmail?: string;

  @ApiPropertyOptional({
    description: "Mother tongue",
    example: "Gujarati (ગુજરાતી)",
  })
  @IsOptional()
  @IsString()
  motherTongue?: string;
}
