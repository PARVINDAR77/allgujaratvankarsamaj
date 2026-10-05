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
      this.logger.log("Successfully connected to MySQL database via Prisma");
      await this.syncSchema();
    } catch (error: any) {
      this.logger.warn(
        `MySQL database not yet reachable at DATABASE_URL (${error.message || error}). Backend will retry on demand.`,
      );
    }
  }

  async syncSchema() {
    try {
      await this.$executeRawUnsafe(`
        CREATE TABLE IF NOT EXISTS \`section_view_counts\` (
          \`id\` varchar(191) NOT NULL,
          \`section_name\` varchar(191) NOT NULL,
          \`view_count\` int NOT NULL DEFAULT 0,
          \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
          \`updated_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
          PRIMARY KEY (\`id\`),
          UNIQUE KEY \`section_view_counts_section_name_key\` (\`section_name\`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      `);

      await this.$executeRawUnsafe(`
        CREATE TABLE IF NOT EXISTS \`home_button_configs\` (
          \`id\` varchar(191) NOT NULL,
          \`button_id\` int NOT NULL,
          \`title\` varchar(191) DEFAULT NULL,
          \`subtitle\` varchar(191) DEFAULT NULL,
          \`icon\` varchar(191) DEFAULT NULL,
          \`route\` varchar(191) NOT NULL,
          \`is_active\` tinyint(1) NOT NULL DEFAULT 1,
          \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
          \`updated_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
          PRIMARY KEY (\`id\`),
          UNIQUE KEY \`home_button_configs_button_id_key\` (\`button_id\`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      `);

      await this.$executeRawUnsafe(`
        CREATE TABLE IF NOT EXISTS \`samaj_service_persons\` (
          \`id\` varchar(191) NOT NULL,
          \`service_id\` varchar(191) NOT NULL,
          \`user_id\` varchar(191) DEFAULT NULL,
          \`name\` varchar(191) NOT NULL,
          \`gujarati_name\` varchar(191) DEFAULT NULL,
          \`photo_url\` text DEFAULT NULL,
          \`phone\` varchar(191) NOT NULL,
          \`address\` text DEFAULT NULL,
          \`city\` varchar(191) DEFAULT NULL,
          \`description\` text DEFAULT NULL,
          \`experience\` varchar(191) DEFAULT NULL,
          \`district_id\` varchar(191) DEFAULT NULL,
          \`taluka_id\` varchar(191) DEFAULT NULL,
          \`village_id\` varchar(191) DEFAULT NULL,
          \`is_active\` tinyint(1) NOT NULL DEFAULT 1,
          \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
          \`updated_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
          PRIMARY KEY (\`id\`),
          KEY \`samaj_service_persons_service_id_idx\` (\`service_id\`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      `);

      await this.$executeRawUnsafe(`
        CREATE TABLE IF NOT EXISTS \`system_notifications\` (
          \`id\` varchar(191) NOT NULL,
          \`title\` varchar(191) NOT NULL,
          \`message\` text NOT NULL,
          \`target\` varchar(191) NOT NULL DEFAULT 'ALL',
          \`route\` varchar(191) DEFAULT NULL,
          \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
          PRIMARY KEY (\`id\`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      `);

      await this.$executeRawUnsafe(`
        ALTER TABLE \`advertisements\` MODIFY COLUMN \`placement\` ENUM('HOME_BANNER', 'DIRECTORY_BANNER', 'POPUP', 'BUTTON_1', 'BUTTON_2', 'BUTTON_3', 'BUTTON_4', 'BUTTON_5', 'PAVAN_PRERNADATA', 'SAMAJ_SUPER_STARS', 'SAMAJ_RATNA') NOT NULL DEFAULT 'HOME_BANNER';
      `);

      this.logger.log("Schema auto-migration check completed successfully");
    } catch (migrationErr: any) {
      this.logger.warn(`Schema auto-migration notice: ${migrationErr.message}`);
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
    this.logger.log("Disconnected from MySQL database");
  }
}
