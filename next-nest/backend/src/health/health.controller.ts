import { Controller, Get } from "@nestjs/common";
import { ApiOperation, ApiResponse, ApiTags } from "@nestjs/swagger";
import { HealthService, HealthStatusResponse } from "./health.service";

@ApiTags("Health")
@Controller("health")
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get()
  @ApiOperation({ summary: "Backend and Database Health Check" })
  @ApiResponse({
    status: 200,
    description: "System health status and database connectivity indicator",
    schema: {
      example: {
        status: "ok",
        service: "backend",
        timestamp: "2026-09-09T11:30:00.000Z",
        database: "connected",
      },
    },
  })
  async getHealth(): Promise<HealthStatusResponse> {
    return this.healthService.checkHealth();
  }
}
