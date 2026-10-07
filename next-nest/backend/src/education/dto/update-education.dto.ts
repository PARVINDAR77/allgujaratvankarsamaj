import { IsOptional } from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";

export class UpdateEducationDto {
  @ApiPropertyOptional()
  @IsOptional()
  id?: any;

  @ApiPropertyOptional()
  @IsOptional()
  createdAt?: any;

  @ApiPropertyOptional()
  @IsOptional()
  updatedAt?: any;

  @ApiPropertyOptional()
  @IsOptional()
  headerTitle?: string;

  @ApiPropertyOptional()
  @IsOptional()
  headerSubtitle?: string;

  // Box 1: PDF Document
  @ApiPropertyOptional()
  @IsOptional()
  box1Title?: string;

  @ApiPropertyOptional()
  @IsOptional()
  box1Subtitle?: string;

  @ApiPropertyOptional()
  @IsOptional()
  box1PdfUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  box1FileName?: string;

  // Box 2: Written Paragraph / Article
  @ApiPropertyOptional()
  @IsOptional()
  box2Title?: string;

  @ApiPropertyOptional()
  @IsOptional()
  box2Content?: string;

  @ApiPropertyOptional()
  @IsOptional()
  box2Author?: string;

  // Box 3: YouTube Video 1
  @ApiPropertyOptional()
  @IsOptional()
  box3Title?: string;

  @ApiPropertyOptional()
  @IsOptional()
  box3YoutubeUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  box3Description?: string;

  // Box 4: YouTube Video 2
  @ApiPropertyOptional()
  @IsOptional()
  box4Title?: string;

  @ApiPropertyOptional()
  @IsOptional()
  box4YoutubeUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  box4Description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  isActive?: boolean;
}
