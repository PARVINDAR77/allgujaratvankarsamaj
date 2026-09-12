import { IsBoolean, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateServicePersonDto {
  @IsString()
  @IsNotEmpty()
  serviceId: string;

  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  gujaratiName?: string;

  @IsString()
  @IsOptional()
  photoUrl?: string;

  @IsString()
  @IsNotEmpty()
  phone: string;

  @IsString()
  @IsOptional()
  address?: string;

  @IsString()
  @IsOptional()
  city?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @IsOptional()
  experience?: string;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}
