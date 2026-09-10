import { plainToInstance } from "class-transformer";
import {
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  validateSync,
} from "class-validator";

class EnvironmentVariables {
  @IsOptional()
  @IsNumber()
  PORT: number = 3000;

  @IsNotEmpty({ message: "DATABASE_URL environment variable is required" })
  @IsString()
  DATABASE_URL: string;

  @IsNotEmpty({ message: "JWT_SECRET environment variable is required" })
  @IsString()
  JWT_SECRET: string;

  @IsOptional()
  @IsString()
  JWT_EXPIRES_IN: string = "1d";

  @IsOptional()
  @IsString()
  JWT_REFRESH_SECRET?: string;
}

export function validate(config: Record<string, unknown>) {
  const validatedConfig = plainToInstance(EnvironmentVariables, config, {
    enableImplicitConversion: true,
  });

  const errors = validateSync(validatedConfig, {
    skipMissingProperties: false,
  });

  if (errors.length > 0) {
    const formattedErrors = errors
      .map((err) => Object.values(err.constraints || {}).join(", "))
      .join("; ");
    throw new Error(`Environment validation failed: ${formattedErrors}`);
  }

  return validatedConfig;
}
