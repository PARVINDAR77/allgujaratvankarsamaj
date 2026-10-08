import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsString } from "class-validator";

export class CreateShortlistDto {
  @ApiProperty({
    description: "The profile ID of the person the user wants to shortlist",
  })
  @IsNotEmpty()
  @IsString()
  targetProfileId: string;
}
