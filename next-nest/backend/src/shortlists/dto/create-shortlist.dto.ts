import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsUUID } from 'class-validator';

export class CreateShortlistDto {
  @ApiProperty({ description: 'The profile ID of the person the user wants to shortlist' })
  @IsNotEmpty()
  @IsUUID()
  targetProfileId: string;
}
