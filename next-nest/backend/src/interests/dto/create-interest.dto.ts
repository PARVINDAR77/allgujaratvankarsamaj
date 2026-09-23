import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsUUID } from 'class-validator';

export class CreateInterestDto {
  @ApiProperty({ description: 'The profile ID of the person the user is interested in' })
  @IsNotEmpty()
  @IsUUID()
  targetProfileId: string;
}
