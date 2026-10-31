import { Controller, Get, NotFoundException, Res } from "@nestjs/common";
import { ApiOperation, ApiResponse, ApiTags } from "@nestjs/swagger";
import { HealthService, HealthStatusResponse } from "./health.service";
import { Response } from "express";

@ApiTags("Health")
@Controller("health")
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get("liveness")
  @ApiOperation({ summary: "Ultra-fast process liveness check (no DB dependency)" })
  @ApiResponse({
    status: 200,
    description: "Process liveness status",
    schema: {
      example: {
        status: "ok",
        service: "backend",
        timestamp: "2026-10-29T11:30:00.000Z",
      },
    },
  })
  getLiveness(): { status: string; service: string; timestamp: string } {
    return this.healthService.checkLiveness();
  }

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


  @Get("cookie-test")
  @ApiOperation({ summary: "Staging-only multi-cookie verification endpoint" })
  async cookieTest(@Res({ passthrough: true }) res: Response) {
    if (process.env.NODE_ENV !== "staging" || process.env.ENABLE_STAGING_TEST_ROUTES !== "true") {
      throw new NotFoundException("Endpoint available only in staging environment with explicit test flag");
    }
    res.cookie("stg_test_a", "val_alpha", {
      httpOnly: true,
      secure: true,
      sameSite: "lax",
      path: "/",
    });
    res.cookie("stg_test_b", "val_beta", {
      httpOnly: true,
      secure: true,
      sameSite: "lax",
      path: "/",
    });
    return { status: "ok", cookieTest: true };
  }
}
