import { ApiPropertyOptional } from "@nestjs/swagger";
import { Transform, Type } from "class-transformer";
import { IsEnum, IsInt, IsOptional, IsString, Min } from "class-validator";
import { Gender, MaritalStatus, ProfileStatus, VerificationStatus } from "@prisma/client";
import { normalizeGender, normalizeMaritalStatus } from "./normalize-profile.helper";

export enum SortOrder {
  ASC = "asc",
  DESC = "desc",
}

export enum ProfileSortField {
  CREATED_AT = "createdAt",
  UPDATED_AT = "updatedAt",
  FIRST_NAME = "firstName",
  AGE = "age", // We might need to compute this or sort by dateOfBirth
}

export class BaseProfileQueryDto {
  @ApiPropertyOptional({
    description: "Page number for pagination",
    default: 1,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ description: "Number of items per page", default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit?: number = 10;

  @ApiPropertyOptional({ description: "Filter by gender", enum: Gender })
  @IsOptional()
  @Transform(({ value }) => normalizeGender(value))
  @IsEnum(Gender)
  gender?: Gender;

  @ApiPropertyOptional({ description: "Filter by lookingFor (e.g. Groom / Bride)" })
  @IsOptional()
  @IsString()
  lookingFor?: string;

  @ApiPropertyOptional({ description: "Filter by marital status", enum: MaritalStatus })
  @IsOptional()
  @Transform(({ value }) => normalizeMaritalStatus(value))
  @IsEnum(MaritalStatus)
  maritalStatus?: MaritalStatus;

  @ApiPropertyOptional({ description: "Minimum age" })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  ageMin?: number;

  @ApiPropertyOptional({ description: "Maximum age" })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  ageMax?: number;

  @ApiPropertyOptional({ description: "Filter by district ID" })
  @IsOptional()
  @IsString()
  districtId?: string;

  @ApiPropertyOptional({ description: "Filter by taluka ID" })
  @IsOptional()
  @IsString()
  talukaId?: string;

  @ApiPropertyOptional({
    description:
      "Filter by occupation category (e.g. GOVERNMENT, PRIVATE, BUSINESS)",
  })
  @IsOptional()
  @IsString()
  occupationCategory?: string;

  @ApiPropertyOptional({
    description: "Filter by verification status",
    enum: VerificationStatus,
  })
  @IsOptional()
  @IsEnum(VerificationStatus)
  verification?: VerificationStatus;

  @ApiPropertyOptional({
    description: "Filter by profile status",
    enum: ProfileStatus,
  })
  @IsOptional()
  @IsEnum(ProfileStatus)
  status?: ProfileStatus;

  @ApiPropertyOptional({
    description: "Search keyword for name, occupation, or location",
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ description: "Keyword search alias" })
  @IsOptional()
  @IsString()
  keyword?: string;

  @ApiPropertyOptional({ description: "Pargana ID filter" })
  @IsOptional()
  @IsString()
  parganaId?: string;

  @ApiPropertyOptional({ description: "Pargana name filter" })
  @IsOptional()
  @IsString()
  pargana?: string;

  @ApiPropertyOptional({ description: "City filter" })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional({ description: "Education filter" })
  @IsOptional()
  @IsString()
  education?: string;

  @ApiPropertyOptional({ description: "Occupation filter" })
  @IsOptional()
  @IsString()
  occupation?: string;

  @ApiPropertyOptional({ description: "Age from (alias for ageMin)" })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  ageFrom?: number;

  @ApiPropertyOptional({ description: "Age to (alias for ageMax)" })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  ageTo?: number;

  @ApiPropertyOptional({
    description: "Field to sort by",
    enum: ProfileSortField,
    default: ProfileSortField.CREATED_AT,
  })
  @IsOptional()
  @IsEnum(ProfileSortField)
  sortBy?: ProfileSortField = ProfileSortField.CREATED_AT;

  @ApiPropertyOptional({
    description: "Sort order (asc/desc)",
    enum: SortOrder,
    default: SortOrder.DESC,
  })
  @IsOptional()
  @IsEnum(SortOrder)
  sortOrder?: SortOrder = SortOrder.DESC;
}
