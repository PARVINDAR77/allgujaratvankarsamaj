"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const core_1 = require("@nestjs/core");
const swagger_1 = require("@nestjs/swagger");
const app_module_1 = require("./app.module");
const http_exception_filter_1 = require("./common/filters/http-exception.filter");
const helmet_1 = require("helmet");
const morgan = require("morgan");
const express = require("express");
const path_1 = require("path");
const cookieParser = require("cookie-parser");
async function bootstrap() {
    const logger = new common_1.Logger("Bootstrap");
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    const configService = app.get(config_1.ConfigService);
    app.use(cookieParser());
    app.use((0, helmet_1.default)({
        crossOriginResourcePolicy: false,
        crossOriginEmbedderPolicy: false,
    }));
    morgan.token("request-id", (req) => {
        return req.headers["x-request-id"] || "-";
    });
    app.use(morgan(':remote-addr - :remote-user [:date[clf]] ":method :url HTTP/:http-version" :status :res[content-length] ":referrer" ":user-agent" - RequestID: :request-id', {
        stream: {
            write: (message) => logger.log(message.trim()),
        },
    }));
    app.useGlobalFilters(new http_exception_filter_1.AllExceptionsFilter());
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        transform: true,
        forbidNonWhitelisted: true,
    }));
    const nodeEnv = configService.get("NODE_ENV", "development");
    const allowedOriginsStr = configService.get("ALLOWED_ORIGINS", "");
    let corsOrigin = true;
    if (nodeEnv === "production" && allowedOriginsStr) {
        corsOrigin = allowedOriginsStr.split(",").map((o) => o.trim());
    }
    app.enableCors({
        origin: corsOrigin,
        credentials: true,
    });
    const uploadStaticMiddleware = express.static((0, path_1.join)(process.cwd(), "uploads"), {
        setHeaders: (res) => {
            res.set("Access-Control-Allow-Origin", "*");
            res.set("Access-Control-Allow-Methods", "GET, OPTIONS");
            res.set("Cross-Origin-Resource-Policy", "cross-origin");
        },
    });
    app.use("/uploads", uploadStaticMiddleware);
    app.use("/api/v1/uploads", uploadStaticMiddleware);
    app.setGlobalPrefix("api/v1");
    const config = new swagger_1.DocumentBuilder()
        .setTitle("All Gujarat Vankar Samaj Matrimony API")
        .setDescription("REST API documentation for the All Gujarat Vankar Samaj Matrimony platform")
        .setVersion("1.0")
        .addTag("Health", "Health check and connectivity verification")
        .addTag("Authentication", "User registration, login, and profile verification")
        .addBearerAuth()
        .build();
    const document = swagger_1.SwaggerModule.createDocument(app, config);
    swagger_1.SwaggerModule.setup("api/docs", app, document);
    if (process.env.SOCKET_PATH) {
        const socketPath = process.env.SOCKET_PATH;
        const fs = await Promise.resolve().then(() => require("fs"));
        if (fs.existsSync(socketPath)) {
            try {
                fs.unlinkSync(socketPath);
                logger.log(`Cleaned up stale socket at ${socketPath}`);
            }
            catch (e) {
                logger.warn(`Failed to unlink existing socket: ${e}`);
            }
        }
        await app.listen(socketPath);
        try {
            fs.chmodSync(socketPath, 0o777);
        }
        catch (e) {
            logger.warn(`Failed to chmod socket: ${e}`);
        }
        logger.log(`Application is running on Unix Socket: ${socketPath}`);
        const gracefulShutdown = () => {
            try {
                if (fs.existsSync(socketPath)) {
                    fs.unlinkSync(socketPath);
                }
            }
            catch (_) { }
            process.exit(0);
        };
        process.on("SIGTERM", gracefulShutdown);
        process.on("SIGINT", gracefulShutdown);
    }
    else {
        const port = process.env.PORT || configService.get("PORT", 3000);
        await app.listen(port, '127.0.0.1');
        logger.log(`Application is running on: http://127.0.0.1:${port}/api/v1`);
    }
    logger.log(`Swagger documentation available at: /api/docs`);
}
bootstrap();
//# sourceMappingURL=main.js.map