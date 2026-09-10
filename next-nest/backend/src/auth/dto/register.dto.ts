import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
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
  @Matches(/^\d{10}$/, { message: "Phone must be a 10-digit number" })
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
}
