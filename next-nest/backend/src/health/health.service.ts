import { Injectable, Logger } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

export interface HealthStatusResponse {
  status: string;
  service: string;
  timestamp: string;
  database: string;
}

@Injectable()
export class HealthService {
  private readonly logger = new Logger(HealthService.name);

  constructor(private readonly prisma: PrismaService) {}

  async checkHealth(): Promise<HealthStatusResponse> {
    let dbStatus = "disconnected";
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      dbStatus = "connected";
    } catch (error) {
      this.logger.error("Database health check query failed", error);
      dbStatus = "disconnected";
    }

    return {
      status: dbStatus === "connected" ? "ok" : "degraded",
      service: "backend",
      timestamp: new Date().toISOString(),
      database: dbStatus,
    };
  }
}
