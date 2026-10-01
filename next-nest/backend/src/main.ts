import { Logger, ValidationPipe } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { NestFactory } from "@nestjs/core";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import { AppModule } from "./app.module";
import { AllExceptionsFilter } from "./common/filters/http-exception.filter";
import helmet from "helmet";
import * as morgan from "morgan";

import * as express from "express";
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
      forbidNonWhitelisted: true,
    }),
  );

  // Enable CORS for mobile and web clients
  const nodeEnv = configService.get<string>("NODE_ENV", "development");
  const allowedOriginsStr = configService.get<string>("ALLOWED_ORIGINS", "");

  let corsOrigin: any = true;
  if (nodeEnv === "production" && allowedOriginsStr) {
    corsOrigin = allowedOriginsStr.split(",").map((o) => o.trim());
  }

  app.enableCors({
    origin: corsOrigin,
    credentials: true,
  });

  // Serve static files from the 'uploads' directory with robust CORS and security headers
  app.use(
    "/uploads",
    express.static(join(process.cwd(), "uploads"), {
      setHeaders: (res) => {
        res.set("Access-Control-Allow-Origin", "*");
        res.set("Access-Control-Allow-Methods", "GET, OPTIONS");
        res.set("Cross-Origin-Resource-Policy", "cross-origin");
      },
    }),
  );

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
    await app.listen(process.env.SOCKET_PATH);
    logger.log(`Application is running on Unix Socket: ${process.env.SOCKET_PATH}`);
  } else {
    const port = process.env.PORT || configService.get<number>("PORT", 3000);
    await app.listen(port, '127.0.0.1');
    logger.log(`Application is running on: http://127.0.0.1:${port}/api/v1`);
  }
  logger.log(
    `Swagger documentation available at: /api/docs`,
  );
}

bootstrap();
