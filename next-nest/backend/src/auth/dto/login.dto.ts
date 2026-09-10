import { ApiPropertyOptional } from "@nestjs/swagger";
import { IsEmail, IsOptional, IsString, Matches, MinLength, IsNotEmpty } from "class-validator";

export class LoginDto {
  @ApiPropertyOptional({
    description: "User email address",
    example: "user@example.com",
  })
  @IsOptional()
  @IsEmail({}, { message: "Invalid email address format" })
  email?: string;

  @ApiPropertyOptional({
    description: "10-digit mobile phone number",
    example: "9104082237",
  })
  @IsOptional()
  @IsString()
  phone?: string;

  @IsString()
  @IsNotEmpty({ message: "Password is required" })
  @MinLength(6, { message: "Password must be at least 6 characters" })
  password: string;
}
