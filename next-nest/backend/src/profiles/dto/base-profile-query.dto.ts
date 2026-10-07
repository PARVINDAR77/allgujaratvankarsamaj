import { ApiPropertyOptional } from "@nestjs/swagger";
import { Transform, Type } from "class-transformer";
import {
  IsEnum,
  IsIn,
  IsOptional,
  IsString,
  Max,
  Min,
  IsInt,
} from "class-validator";
import { Gender, MaritalStatus, VerificationStatus } from "../../common/enums/profile.enums";
import { PaginationQueryDto } from "../../common/pagination/dto/pagination-query.dto";
import { normalizeGender, normalizeMaritalStatus } from "./normalize-profile.helper";

const ALLOWED_SORT_FIELDS = [
  "createdAt",
  "updatedAt",
  "dateOfBirth",
  "firstName",
] as const;
type SortField = (typeof ALLOWED_SORT_FIELDS)[number];

export class BaseProfileQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: "Search keyword for name, occupation, or location",
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ enum: Gender })
  @IsOptional()
  @Transform(({ value }) => normalizeGender(value))
  @IsEnum(Gender)
  gender?: Gender;

  @ApiPropertyOptional({ description: "Looking for (e.g. Groom / Bride)" })
  @IsOptional()
  @IsString()
  lookingFor?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(18)
  ageMin?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Max(100)
  ageMax?: number;

  @ApiPropertyOptional({ enum: MaritalStatus })
  @IsOptional()
  @IsEnum(MaritalStatus)
  maritalStatus?: MaritalStatus;

  @ApiPropertyOptional({ enum: VerificationStatus })
  @IsOptional()
  @IsEnum(VerificationStatus)
  verificationStatus?: VerificationStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  stateId?: string;

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
  villageId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  occupation?: string;

  // Additional category filtering (for extending this base query)
  @ApiPropertyOptional({
    description: 'Optional category filter, e.g. "GOVERNMENT_EMPLOYEE"',
  })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiPropertyOptional({ description: "Sort field", enum: ALLOWED_SORT_FIELDS })
  @IsOptional()
  @IsIn(ALLOWED_SORT_FIELDS)
  sortBy?: SortField;

  @ApiPropertyOptional({ description: "Sort order", enum: ["asc", "desc"] })
  @IsOptional()
  @IsIn(["asc", "desc"])
  sortOrder?: "asc" | "desc";
}
