import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { IsNotEmpty, IsOptional, IsString } from "class-validator";

export class CreateNotificationDto {
  @ApiProperty({ description: "Title of notification" })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({ description: "Body message" })
  @IsString()
  @IsNotEmpty()
  message: string;

  @ApiPropertyOptional({ description: "Target audience: ALL, 35, 27, 16, 14, VERIFIED" })
  @IsString()
  @IsOptional()
  target?: string;

  @ApiPropertyOptional({ description: "Optional app route to navigate to on tap" })
  @IsString()
  @IsOptional()
  route?: string;
}
