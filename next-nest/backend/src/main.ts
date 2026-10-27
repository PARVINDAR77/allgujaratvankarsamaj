import { Logger, ValidationPipe } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { NestFactory } from "@nestjs/core";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import { AppModule } from "./app.module";
import { AllExceptionsFilter } from "./common/filters/http-exception.filter";
import { validateAndNormalizeAllowedOrigins } from "./common/validators/cors.validator";
import { isAllowedStaticMediaPath } from "./common/validators/static-media.validator";
import { servePublicStaticMedia } from "./common/middleware/static-media.middleware";
import helmet from "helmet";
import * as morgan from "morgan";

import * as express from "express";
import * as path from "path";
import * as fs from "fs";
import * as fsPromises from "fs/promises";
import { join } from "path";
import * as cookieParser from "cookie-parser";



async function bootstrap() {
  const logger = new Logger("Bootstrap");
  const app = await NestFactory.create(AppModule);

  // Read config early for bootstrap dependencies
  const configService = app.get(ConfigService);

  app.use(cookieParser());

  // Security middlewares (configured for Web CORS compatibility)
  app.use(
    helmet({
      crossOriginResourcePolicy: false,
      crossOriginEmbedderPolicy: false,
    }),
  );

  // Setup Morgan logger
  morgan.token("request-id", (req: any) => {
    return req.headers["x-request-id"] || "-";
  });

  app.use(
    morgan(
      ':remote-addr - :remote-user [:date[clf]] ":method :url HTTP/:http-version" :status :res[content-length] ":referrer" ":user-agent" - RequestID: :request-id',
      {
        stream: {
          write: (message: string) => logger.log(message.trim()),
        },
      },
    ),
  );

  // Global Exception filter
  app.useGlobalFilters(new AllExceptionsFilter());

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: false,
    }),
  );

  const nodeEnv = configService.get<string>("NODE_ENV", "development");
  const allowedOriginsStr = configService.get<string>(
    "ALLOWED_ORIGINS",
    "https://allgujaratvankarsamaj.com,https://www.allgujaratvankarsamaj.com",
  );

  let corsOrigin: any = true;
  if (nodeEnv === "production" || nodeEnv === "staging") {
    try {
      const validatedOrigins = validateAndNormalizeAllowedOrigins(
        allowedOriginsStr,
        nodeEnv,
      );
      corsOrigin = validatedOrigins;
      logger.log(
        `CORS origin allowlist strictly enforced for ${nodeEnv} (${validatedOrigins.length} origins): ${validatedOrigins.join(", ")}`,
      );
    } catch (err: any) {
      logger.error(
        `FATAL: CORS origin configuration error in ${nodeEnv}: ${err.message}. Halting bootstrap.`,
      );
      process.exit(1);
    }
  }

  app.enableCors({
    origin: corsOrigin,
    credentials: true,
  });

  // Public static media middleware: serves public profile photos and media safely
  app.use("/uploads", servePublicStaticMedia);
  app.use("/api/v1/uploads", servePublicStaticMedia);


  // Global API Prefix /api/v1
  app.setGlobalPrefix("api/v1");

  // Swagger OpenAPI Documentation at /api/docs
  const config = new DocumentBuilder()
    .setTitle("All Gujarat Vankar Samaj Matrimony API")
    .setDescription(
      "REST API documentation for the All Gujarat Vankar Samaj Matrimony platform",
    )
    .setVersion("1.0")
    .addTag("Health", "Health check and connectivity verification")
    .addTag(
      "Authentication",
      "User registration, login, and profile verification",
    )
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup("api/docs", app, document);

  // Listen on Unix Socket if specified (for Hostinger), otherwise fallback to port
  if (process.env.SOCKET_PATH) {
    const socketPath = process.env.SOCKET_PATH;
    const fs = await import("fs");
    if (fs.existsSync(socketPath)) {
      try {
        fs.unlinkSync(socketPath);
        logger.log(`Cleaned up stale socket at ${socketPath}`);
      } catch (e) {
        logger.warn(`Failed to unlink existing socket: ${e}`);
      }
    }
    await app.listen(socketPath);
    try {
      fs.chmodSync(socketPath, 0o777);
    } catch (e) {
      logger.warn(`Failed to chmod socket: ${e}`);
    }
    logger.log(`Application is running on Unix Socket: ${socketPath}`);

    const gracefulShutdown = () => {
      try {
        if (fs.existsSync(socketPath)) {
          fs.unlinkSync(socketPath);
        }
      } catch (_) {}
      process.exit(0);
    };
    process.on("SIGTERM", gracefulShutdown);
    process.on("SIGINT", gracefulShutdown);
  } else {
    const port = process.env.PORT || configService.get<number>("PORT", 3000);
    await app.listen(port, '127.0.0.1');
    logger.log(`Application is running on: http://127.0.0.1:${port}/api/v1`);
  }

  process.on("unhandledRejection", (reason: any) => {
    logger.error("Unhandled Rejection in background process:", reason?.stack || reason);
  });

  process.on("uncaughtException", (error: any) => {
    logger.error("Uncaught Exception in process:", error?.stack || error);
  });

  logger.log(
    `Swagger documentation available at: /api/docs`,
  );
}

bootstrap();
