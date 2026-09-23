import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { VerificationStatus } from '@prisma/client';

export class UpdateVerificationStatusDto {
  @ApiProperty({ description: 'The new status', enum: VerificationStatus })
  @IsNotEmpty()
  @IsEnum(VerificationStatus)
  status: VerificationStatus;

  @ApiPropertyOptional({ description: 'Reason for rejection if status is REJECTED' })
  @IsOptional()
  @IsString()
  rejectionReason?: string;
}
