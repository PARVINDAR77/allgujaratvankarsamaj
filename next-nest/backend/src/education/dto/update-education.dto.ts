import { IsString, IsOptional, IsBoolean } from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";

export class UpdateEducationDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  headerTitle?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  headerSubtitle?: string;

  // Box 1: PDF Document
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  box1Title?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  box1Subtitle?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  box1PdfUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  box1FileName?: string;

  // Box 2: Written Paragraph / Article
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  box2Title?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  box2Content?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  box2Author?: string;

  // Box 3: YouTube Video 1
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  box3Title?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  box3YoutubeUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  box3Description?: string;

  // Box 4: YouTube Video 2
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  box4Title?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  box4YoutubeUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  box4Description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
