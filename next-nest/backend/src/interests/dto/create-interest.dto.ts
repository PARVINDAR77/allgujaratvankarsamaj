import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString } from "class-validator";

export class CreateInterestDto {
  @ApiProperty({
    description: "The profile ID of the person the user is interested in",
  })
  @IsNotEmpty()
  @IsString()
  targetProfileId: string;
}
