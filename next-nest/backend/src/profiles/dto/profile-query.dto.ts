import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, IsString, Min } from 'class-validator';
import { Gender, ProfileStatus, VerificationStatus } from '@prisma/client';

export enum SortOrder {
  ASC = 'asc',
  DESC = 'desc',
}

export enum ProfileSortField {
  CREATED_AT = 'createdAt',
  UPDATED_AT = 'updatedAt',
  FIRST_NAME = 'firstName',
  AGE = 'age', // We might need to compute this or sort by dateOfBirth
}

export class BaseProfileQueryDto {
  @ApiPropertyOptional({ description: 'Page number for pagination', default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Number of items per page', default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit?: number = 10;

  @ApiPropertyOptional({ description: 'Filter by gender', enum: Gender })
  @IsOptional()
  @IsEnum(Gender)
  gender?: Gender;

  @ApiPropertyOptional({ description: 'Minimum age' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  ageMin?: number;

  @ApiPropertyOptional({ description: 'Maximum age' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  ageMax?: number;

  @ApiPropertyOptional({ description: 'Filter by district ID' })
  @IsOptional()
  @IsString()
  districtId?: string;

  @ApiPropertyOptional({ description: 'Filter by taluka ID' })
  @IsOptional()
  @IsString()
  talukaId?: string;

  @ApiPropertyOptional({ description: 'Filter by occupation category (e.g. GOVERNMENT, PRIVATE, BUSINESS)' })
  @IsOptional()
  @IsString()
  occupationCategory?: string;

  @ApiPropertyOptional({ description: 'Filter by verification status', enum: VerificationStatus })
  @IsOptional()
  @IsEnum(VerificationStatus)
  verification?: VerificationStatus;

  @ApiPropertyOptional({ description: 'Filter by profile status', enum: ProfileStatus })
  @IsOptional()
  @IsEnum(ProfileStatus)
  status?: ProfileStatus;

  @ApiPropertyOptional({ description: 'Search keyword for name, occupation, or location' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ description: 'Field to sort by', enum: ProfileSortField, default: ProfileSortField.CREATED_AT })
  @IsOptional()
  @IsEnum(ProfileSortField)
  sortBy?: ProfileSortField = ProfileSortField.CREATED_AT;

  @ApiPropertyOptional({ description: 'Sort order (asc/desc)', enum: SortOrder, default: SortOrder.DESC })
  @IsOptional()
  @IsEnum(SortOrder)
  sortOrder?: SortOrder = SortOrder.DESC;
}
