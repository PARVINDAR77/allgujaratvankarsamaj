import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from "@nestjs/common";
import { Request, Response } from "express";

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    const requestId = request.headers["x-request-id"] || "N/A";

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const errorResponse =
      exception instanceof HttpException
        ? exception.getResponse()
        : { message: "Internal server error" };

    const message =
      typeof errorResponse === "string"
        ? errorResponse
        : (errorResponse as any).message || "Internal server error";
        
    const errorString = 
      typeof errorResponse === "string"
        ? undefined
        : (errorResponse as any).error || (status === 500 ? "Internal Server Error" : undefined);

    const isValidationError = Array.isArray((errorResponse as any)?.message);
    const code = isValidationError ? "VALIDATION_ERROR" : (errorString ? errorString.toUpperCase().replace(/\s+/g, '_') : "INTERNAL_ERROR");

    const responseMessage = isValidationError ? "Invalid request" : message;
    const errorsArray = isValidationError ? (errorResponse as any).message : [];

    // Log the exception
    if (status >= HttpStatus.INTERNAL_SERVER_ERROR) {
      this.logger.error(
        `[RequestID: ${requestId}] ${request.method} ${request.url} - ${status}`,
        exception instanceof Error ? exception.stack : String(exception),
      );
    } else {
      this.logger.warn(
        `[RequestID: ${requestId}] ${request.method} ${request.url} - ${status} - ${JSON.stringify(message)}`,
      );
    }

    // Standardized API error response
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
}
