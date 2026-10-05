import { ApiPropertyOptional } from "@nestjs/swagger";
import { Transform, Type } from "class-transformer";
import { IsEnum, IsInt, IsOptional, IsString, Min } from "class-validator";
import { Gender, MaritalStatus, ProfileStatus, VerificationStatus } from "@prisma/client";
import { normalizeGender, normalizeMaritalStatus } from "./normalize-profile.helper";
import { ProfileSortField, SortOrder } from "./profile-query.dto";

export class SearchQueryDto {
  @ApiPropertyOptional({ default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit?: number = 10;

  @ApiPropertyOptional({ enum: Gender })
  @IsOptional()
  @Transform(({ value }) => normalizeGender(value))
  @IsEnum(Gender)
  gender?: Gender;

  @ApiPropertyOptional({ description: "Groom / Bride indicator" })
  @IsOptional()
  @IsString()
  lookingFor?: string;

  @ApiPropertyOptional({ enum: MaritalStatus })
  @IsOptional()
  @Transform(({ value }) => normalizeMaritalStatus(value))
  @IsEnum(MaritalStatus)
  maritalStatus?: MaritalStatus;

  @ApiPropertyOptional({ description: "Min age" })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  ageMin?: number;

  @ApiPropertyOptional({ description: "Max age" })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  ageMax?: number;

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

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  heightFrom?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  heightTo?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  districtId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  talukaId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  parganaId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  pargana?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  education?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  occupation?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  occupationCategory?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  religion?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  annualIncome?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  diet?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  familyType?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  motherTongue?: string;

  @ApiPropertyOptional({ enum: VerificationStatus })
  @IsOptional()
  @IsEnum(VerificationStatus)
  verification?: VerificationStatus;

  @ApiPropertyOptional({ enum: ProfileStatus })
  @IsOptional()
  @IsEnum(ProfileStatus)
  status?: ProfileStatus;

  @ApiPropertyOptional({ description: "Search keyword" })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ description: "Keyword search alias" })
  @IsOptional()
  @IsString()
  keyword?: string;

  @ApiPropertyOptional({ enum: ProfileSortField })
  @IsOptional()
  @IsEnum(ProfileSortField)
  sortBy?: ProfileSortField;

  @ApiPropertyOptional({ enum: SortOrder })
  @IsOptional()
  @IsEnum(SortOrder)
  sortOrder?: SortOrder;
}
