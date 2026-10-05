import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import {
  IsBoolean,
  IsDateString,
  IsNotEmpty,
  IsOptional,
  IsString,
} from "class-validator";

export class CreateSuccessStoryDto {
  @ApiProperty({ description: "Bride Name" })
  @IsNotEmpty()
  @IsString()
  brideName: string;

  @ApiProperty({ description: "Groom Name" })
  @IsNotEmpty()
  @IsString()
  groomName: string;

  @ApiPropertyOptional({ description: "Wedding Date (YYYY-MM-DD)" })
  @IsOptional()
  @IsDateString()
  weddingDate?: string;

  @ApiProperty({ description: "Story text" })
  @IsNotEmpty()
  @IsString()
  story: string;

  @ApiPropertyOptional({ description: "Image URL" })
  @IsOptional()
  @IsString()
  imageUrl?: string;

  @ApiPropertyOptional({ description: "Is Published" })
  @IsOptional()
  @IsBoolean()
  isPublished?: boolean;
}
