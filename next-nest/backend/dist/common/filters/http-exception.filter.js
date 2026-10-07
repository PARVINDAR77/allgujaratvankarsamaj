"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var AllExceptionsFilter_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AllExceptionsFilter = void 0;
const common_1 = require("@nestjs/common");
let AllExceptionsFilter = AllExceptionsFilter_1 = class AllExceptionsFilter {
    constructor() {
        this.logger = new common_1.Logger(AllExceptionsFilter_1.name);
    }
    catch(exception, host) {
        const ctx = host.switchToHttp();
        const response = ctx.getResponse();
        const request = ctx.getRequest();
        const requestId = request.headers["x-request-id"] || "N/A";
        const status = exception instanceof common_1.HttpException
            ? exception.getStatus()
            : common_1.HttpStatus.INTERNAL_SERVER_ERROR;
        const errorResponse = exception instanceof common_1.HttpException
            ? exception.getResponse()
            : { message: "Internal server error" };
        const message = typeof errorResponse === "string"
            ? errorResponse
            : errorResponse.message || "Internal server error";
        const errorString = typeof errorResponse === "string"
            ? undefined
            : errorResponse.error ||
                (status === 500 ? "Internal Server Error" : undefined);
        const isValidationError = Array.isArray(errorResponse?.message);
        const code = isValidationError
            ? "VALIDATION_ERROR"
            : errorString
                ? errorString.toUpperCase().replace(/\s+/g, "_")
                : "INTERNAL_ERROR";
        const responseMessage = isValidationError ? "Invalid request" : message;
        const errorsArray = isValidationError ? errorResponse.message : [];
        if (status >= common_1.HttpStatus.INTERNAL_SERVER_ERROR) {
            this.logger.error(`[RequestID: ${requestId}] ${request.method} ${request.url} - ${status}`, exception instanceof Error ? exception.stack : String(exception));
        }
        else {
            this.logger.warn(`[RequestID: ${requestId}] ${request.method} ${request.url} - ${status} - ${JSON.stringify(message)}`);
        }
        response.status(status).json({
            success: false,
            statusCode: status,
            code,
            message: responseMessage,
            errors: errorsArray,
            requestId,
            path: request.url,
            timestamp: new Date().toISOString(),
        });
    }
};
exports.AllExceptionsFilter = AllExceptionsFilter;
exports.AllExceptionsFilter = AllExceptionsFilter = AllExceptionsFilter_1 = __decorate([
    (0, common_1.Catch)()
], AllExceptionsFilter);
//# sourceMappingURL=http-exception.filter.js.map