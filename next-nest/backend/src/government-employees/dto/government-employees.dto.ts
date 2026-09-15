import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsInt, IsNotEmpty, IsOptional, IsString, Max, Min } from 'class-validator';
import { GovtEmploymentType } from '@prisma/client';

export class CreateGovtEmploymentDto {
  @ApiProperty({ enum: GovtEmploymentType, example: GovtEmploymentType.STATE_GOVT })
  @IsEnum(GovtEmploymentType)
  employmentType: GovtEmploymentType;

  @ApiPropertyOptional({ example: 'dept-uuid-001' })
  @IsOptional()
  @IsString()
  departmentId?: string;

  @ApiPropertyOptional({ example: 'desig-uuid-001' })
  @IsOptional()
  @IsString()
  designationId?: string;

  @ApiPropertyOptional({ example: 'Collectorate, Gandhinagar' })
  @IsOptional()
  @IsString()
  officeLocation?: string;

  @ApiPropertyOptional({ example: 2018 })
  @IsOptional()
  @IsInt()
  @Min(1970)
  @Max(2030)
  joiningYear?: number;
}

export class UpdateGovtEmploymentDto {
  @ApiPropertyOptional({ enum: GovtEmploymentType })
  @IsOptional()
  @IsEnum(GovtEmploymentType)
  employmentType?: GovtEmploymentType;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  departmentId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  designationId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  officeLocation?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  joiningYear?: number;
}

export class SubmitVerificationDto {
  @ApiProperty({ example: 'GOVT_ID_CARD' })
  @IsString()
  @IsNotEmpty()
  documentType: string;

  @ApiProperty({ example: 'https://storage.vankarsamaj.com/proofs/emp-123.jpg' })
  @IsString()
  @IsNotEmpty()
  documentUrl: string;
}

export class GovtEmployeeSearchQueryDto {
  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  page?: number;

  @ApiPropertyOptional({ example: 20 })
  @IsOptional()
  limit?: number;

  @ApiPropertyOptional({ example: 'MALE' })
  @IsOptional()
  @IsString()
  gender?: string;

  @ApiPropertyOptional({ example: 22 })
  @IsOptional()
  ageMin?: number;

  @ApiPropertyOptional({ example: 45 })
  @IsOptional()
  ageMax?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  departmentId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  designationId?: string;

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
  search?: string;

  @ApiPropertyOptional({ example: 'createdAt' })
  @IsOptional()
  @IsString()
  sortBy?: string;

  @ApiPropertyOptional({ example: 'desc' })
  @IsOptional()
  @IsString()
  sortOrder?: 'asc' | 'desc';
}

export class AdminVerifyGovtEmpDto {
  @ApiProperty({ example: 'APPROVE' })
  @IsString()
  @IsNotEmpty()
  action: 'APPROVE' | 'REJECT';

  @ApiPropertyOptional({ example: 'Document illegible or expired' })
  @IsOptional()
  @IsString()
  rejectionReason?: string;
}

export class AdminFeatureGovtEmpDto {
  @ApiProperty({ example: true })
  isFeatured: boolean;
}

export class AdminStatusGovtEmpDto {
  @ApiProperty({ example: true })
  isActive: boolean;
}

export class CreateDepartmentDto {
  @ApiProperty({ example: 'Education Department' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional({ example: 'શિક્ષણ વિભાગ' })
  @IsOptional()
  @IsString()
  gujaratiName?: string;

  @ApiPropertyOptional({ example: 'DEPT_EDU' })
  @IsOptional()
  @IsString()
  code?: string;
}

export class CreateDesignationDto {
  @ApiProperty({ example: 'dept-uuid-001' })
  @IsString()
  @IsNotEmpty()
  departmentId: string;

  @ApiProperty({ example: 'High School Teacher' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional({ example: 'ઉચ્ચતર માધ્યમિક શિક્ષક' })
  @IsOptional()
  @IsString()
  gujaratiName?: string;

  @ApiPropertyOptional({ example: 'DESIG_TEACHER' })
  @IsOptional()
  @IsString()
  code?: string;
}
