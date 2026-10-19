import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString, MinLength } from "class-validator";

export class ForgotPasswordDto {
  @ApiProperty({
    description: "Registered email address or 10-digit mobile number",
    example: "user@example.com",
  })
  @IsNotEmpty({ message: "ઈમેઈલ અથવા મોબાઇલ નંબર જરૂરી છે (Email or mobile number is required)" })
  @IsString()
  identifier: string;
}

export class VerifyResetCodeDto {
  @ApiProperty({
    description: "Registered email address or 10-digit mobile number",
    example: "user@example.com",
  })
  @IsNotEmpty({ message: "ઈમેઈલ અથવા મોબાઇલ નંબર જરૂરી છે (Email or mobile number is required)" })
  @IsString()
  identifier: string;

  @ApiProperty({
    description: "6-digit verification code",
    example: "123456",
  })
  @IsNotEmpty({ message: "ચકાસણી કોડ જરૂરી છે (Verification code is required)" })
  @IsString()
  code: string;
}

export class ResetPasswordDto {
  @ApiProperty({
    description: "Registered email address or 10-digit mobile number",
    example: "user@example.com",
  })
  @IsNotEmpty({ message: "ઈમેઈલ અથવા મોબાઇલ નંબર જરૂરી છે (Email or mobile number is required)" })
  @IsString()
  identifier: string;

  @ApiProperty({
    description: "6-digit verification code",
    example: "123456",
  })
  @IsNotEmpty({ message: "ચકાસણી કોડ જરૂરી છે (Verification code is required)" })
  @IsString()
  code: string;

  @ApiProperty({
    description: "New password (minimum 6 characters)",
    example: "NewPassword123!",
  })
  @IsNotEmpty({ message: "નવો પાસવર્ડ જરૂરી છે (New password is required)" })
  @IsString()
  @MinLength(6, { message: "પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ (Password must be at least 6 characters)" })
  newPassword: string;
}

export class UpdatePasswordDto {
  @ApiProperty({
    description: "Current account password",
    example: "OldPassword123!",
  })
  @IsNotEmpty({ message: "હાલનો પાસવર્ડ જરૂરી છે (Current password is required)" })
  @IsString()
  currentPassword: string;

  @ApiProperty({
    description: "New password (minimum 6 characters)",
    example: "NewPassword123!",
  })
  @IsNotEmpty({ message: "નવો પાસવર્ડ જરૂરી છે (New password is required)" })
  @IsString()
  @MinLength(6, { message: "નવો પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ (Password must be at least 6 characters)" })
  newPassword: string;
}

