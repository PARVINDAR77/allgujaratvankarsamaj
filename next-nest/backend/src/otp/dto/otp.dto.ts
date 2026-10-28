import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  Length,
} from "class-validator";
import { OtpChannel, OtpPurpose } from "@prisma/client";

export class SendRegistrationOtpDto {
  @ApiProperty({
    description: "User full name for SMS greeting",
    example: "Ramesh Patel",
  })
  @IsNotEmpty({ message: "નામ દાખલ કરો (Name is required)" })
  @IsString()
  name: string;

  @ApiProperty({
    description: "10-digit mobile number",
    example: "9876543210",
  })
  @IsNotEmpty({ message: "મોબાઇલ નંબર દાખલ કરો (Mobile number is required)" })
  @IsString()
  @Matches(/^[6-9]\d{9}$/, {
    message: "કૃપા કરીને માન્ય 10 અંકનો મોબાઈલ નંબર દાખલ કરો (Valid 10-digit Indian mobile number required)",
  })
  phone: string;

  @ApiProperty({
    description: "User email address",
    example: "user@example.com",
  })
  @IsNotEmpty({ message: "ઈમેઈલ સરનામું દાખલ કરો (Email is required)" })
  @IsEmail({}, { message: "માન્ય ઈમેઈલ સરનામું દાખલ કરો (Valid email format required)" })
  email: string;
}

export class VerifyRegistrationOtpDto {
  @ApiProperty({
    description: "10-digit mobile number",
    example: "9876543210",
  })
  @IsNotEmpty()
  @IsString()
  phone: string;

  @ApiProperty({
    description: "User email address",
    example: "user@example.com",
  })
  @IsNotEmpty()
  @IsEmail()
  email: string;

  @ApiProperty({
    description: "6-digit OTP code received on Mobile via SMS",
    example: "123456",
  })
  @IsNotEmpty({ message: "મોબાઇલ OTP દાખલ કરો (Mobile OTP is required)" })
  @IsString()
  @Length(6, 6, { message: "મોબાઇલ OTP 6 અંકનો હોવો જોઈએ (Mobile OTP must be 6 digits)" })
  phoneOtp: string;

  @ApiProperty({
    description: "6-digit OTP code received on Email",
    example: "654321",
  })
  @IsNotEmpty({ message: "ઈમેઈલ OTP દાખલ કરો (Email OTP is required)" })
  @IsString()
  @Length(6, 6, { message: "ઈમેઈલ OTP 6 અંકનો હોવો જોઈએ (Email OTP must be 6 digits)" })
  emailOtp: string;
}

export class SendForgotPasswordOtpDto {
  @ApiProperty({
    description: "Registered mobile number or email address",
    example: "9876543210",
  })
  @IsNotEmpty({ message: "મોબાઇલ નંબર અથવા ઈમેઈલ દાખલ કરો (Mobile or email is required)" })
  @IsString()
  identifier: string;

  @ApiPropertyOptional({
    description: "Preferred delivery channel: SMS or EMAIL",
    enum: OtpChannel,
    default: OtpChannel.SMS,
  })
  @IsOptional()
  @IsEnum(OtpChannel)
  channel?: OtpChannel;
}

export class VerifyResetOtpDto {
  @ApiProperty({
    description: "Registered mobile number or email address",
    example: "9876543210",
  })
  @IsNotEmpty()
  @IsString()
  identifier: string;

  @ApiProperty({
    description: "6-digit OTP code",
    example: "123456",
  })
  @IsNotEmpty({ message: "OTP કોડ દાખલ કરો (OTP code is required)" })
  @IsString()
  @Length(6, 6, { message: "OTP કોડ 6 અંકનો હોવો જોઈએ (OTP must be 6 digits)" })
  code: string;
}

export class AdminOtpQueryDto {
  @ApiPropertyOptional({ default: 1 })
  @IsOptional()
  page?: number;

  @ApiPropertyOptional({ default: 20 })
  @IsOptional()
  limit?: number;

  @ApiPropertyOptional({ enum: OtpChannel })
  @IsOptional()
  @IsEnum(OtpChannel)
  channel?: OtpChannel;

  @ApiPropertyOptional({ enum: OtpPurpose })
  @IsOptional()
  @IsEnum(OtpPurpose)
  purpose?: OtpPurpose;

  @ApiPropertyOptional({ description: "Filter by date (YYYY-MM-DD)" })
  @IsOptional()
  @IsString()
  date?: string;

  @ApiPropertyOptional({ description: "Search recipient phone or email" })
  @IsOptional()
  @IsString()
  search?: string;
}

export class SendProfileContactOtpDto {
  @ApiPropertyOptional({ description: "Recipient name" })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ description: "10-digit mobile number" })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ description: "Email address" })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiPropertyOptional({ description: "Target channel: SMS, EMAIL, or BOTH", enum: ["SMS", "EMAIL", "BOTH"] })
  @IsOptional()
  @IsString()
  channel?: "SMS" | "EMAIL" | "BOTH";
}

export class VerifyProfileContactOtpDto {
  @ApiPropertyOptional({ description: "10-digit mobile number" })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ description: "Email address" })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiPropertyOptional({ description: "6-digit OTP code for Mobile" })
  @IsOptional()
  @IsString()
  phoneOtp?: string;

  @ApiPropertyOptional({ description: "6-digit OTP code for Email" })
  @IsOptional()
  @IsString()
  emailOtp?: string;
}
