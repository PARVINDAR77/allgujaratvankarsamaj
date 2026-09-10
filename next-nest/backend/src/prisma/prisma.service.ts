import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from "@nestjs/common";
import { PrismaClient } from "@prisma/client";

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);

  async onModuleInit() {
    try {
      await this.$connect();
      this.logger.log(
        "Successfully connected to PostgreSQL database via Prisma",
      );
    } catch (error: any) {
      this.logger.warn(
        `PostgreSQL database not yet reachable at DATABASE_URL (${error.message || error}). Backend will retry on demand.`,
      );
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
    this.logger.log("Disconnected from PostgreSQL database");
  }
}
