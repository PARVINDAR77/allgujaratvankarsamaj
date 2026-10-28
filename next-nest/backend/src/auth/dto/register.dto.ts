import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Transform } from "class-transformer";
import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  MinLength,
} from "class-validator";

export enum GenderDto {
  Male = "Male",
  Female = "Female",
  Other = "Other",
}

export class RegisterDto {
  @ApiPropertyOptional({
    description: "User full name",
    example: "Ramesh Patel",
  })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({
    description: "10-digit mobile phone number",
    example: "9104082237",
  })
  @IsOptional()
  @IsString()
  @Matches(/^[6-9]\d{9}$/, { message: "Phone must be a valid 10-digit mobile number starting with 6-9" })
  phone?: string;

  @ApiPropertyOptional({
    description: "User email address",
    example: "user@example.com",
  })
  @IsOptional()
  @IsEmail({}, { message: "Invalid email address format" })
  email?: string;

  @ApiPropertyOptional({
    description: "Gender",
    enum: GenderDto,
    example: "Male",
  })
  @IsOptional()
  @Transform(({ value }) => {
    if (!value || typeof value !== "string") return value;
    const lower = value.trim().toLowerCase();
    if (lower === "male" || lower === "m" || lower === "પુરુષ" || lower === "વર") return GenderDto.Male;
    if (lower === "female" || lower === "f" || lower === "સ્ત્રી" || lower === "કન્યા") return GenderDto.Female;
    if (lower === "other") return GenderDto.Other;
    return value;
  })
  @IsEnum(GenderDto, { message: "Gender must be Male, Female, or Other" })
  gender?: GenderDto;

  @ApiProperty({
    description: "User password (minimum 8 characters)",
    example: "StrongPassword123!",
    minLength: 8,
  })
  @IsString()
  @IsNotEmpty({ message: "Password is required" })
  @MinLength(8, { message: "Password must be at least 8 characters long" })
  password: string;

  @ApiPropertyOptional({
    description: "Verified registration token received from dual OTP verification",
  })
  @IsOptional()
  @IsString()
  registrationToken?: string;
}

