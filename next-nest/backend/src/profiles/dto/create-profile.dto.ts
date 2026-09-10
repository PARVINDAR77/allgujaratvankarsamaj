import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Gender, MaritalStatus } from "@prisma/client";
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
  @IsMinAge(18, {
    message:
      "User must be at least 18 years old and date of birth cannot be in the future",
  })
  @IsNotEmpty({ message: "Date of birth is required" })
  dateOfBirth: string;

  @ApiProperty({
    description: "Gender of the profile owner",
    enum: Gender,
    example: Gender.MALE,
  })
  @IsEnum(Gender, { message: "Gender must be MALE, FEMALE, or OTHER" })
  @IsNotEmpty({ message: "Gender is required" })
  gender: Gender;

  @ApiProperty({
    description: "Marital status",
    enum: MaritalStatus,
    example: MaritalStatus.NEVER_MARRIED,
  })
  @IsEnum(MaritalStatus, {
    message:
      "Marital status must be NEVER_MARRIED, DIVORCED, WIDOWED, or SEPARATED",
  })
  @IsNotEmpty({ message: "Marital status is required" })
  maritalStatus: MaritalStatus;

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
}
