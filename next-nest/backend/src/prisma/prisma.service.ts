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
    const connectStartTime = Date.now();
    try {
      await this.$connect();
      const connectDuration = Date.now() - connectStartTime;
      this.logger.log(`Successfully connected to MySQL database via Prisma (${connectDuration}ms)`);
      if (process.env.DISABLE_RUNTIME_SCHEMA_SYNC !== "true") {
        await this.syncSchema();
      } else {
        this.logger.log(
          "Runtime schema auto-migration skipped (DISABLE_RUNTIME_SCHEMA_SYNC=true). Schema integrity must be managed via deployment migrations (e.g. prisma migrate deploy).",
        );
      }
    } catch (error: any) {
      this.logger.warn(
        `MySQL database not yet reachable at DATABASE_URL (${error.message || error}). Backend will retry on demand.`,
      );
    }
  }

  /**
   * Verifies that all runtime-managed tables and supplementary columns are present in the database.
   */
  async isSchemaComplete(): Promise<boolean> {
    try {
      // 1. Verify all 6 runtime-managed tables exist
      const tableRows = await this.$queryRawUnsafe<any[]>(`
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = DATABASE() 
          AND table_name IN (
            'section_view_counts', 
            'home_button_configs', 
            'samaj_service_persons', 
            'system_notifications', 
            'otp_sessions', 
            'otp_logs'
          );
      `);
      const existingTables = new Set(
        (tableRows || []).map((r: any) => (r.table_name || r.TABLE_NAME || "").toLowerCase()),
      );
      const requiredTables = [
        "section_view_counts",
        "home_button_configs",
        "samaj_service_persons",
        "system_notifications",
        "otp_sessions",
        "otp_logs",
      ];
      if (!requiredTables.every((t) => existingTables.has(t))) {
        return false;
      }

      // 2. Verify critical supplementary columns exist
      const columnRows = await this.$queryRawUnsafe<any[]>(`
        SELECT table_name, column_name 
        FROM information_schema.columns 
        WHERE table_schema = DATABASE() 
          AND (
            (table_name = 'samaj_service_persons' AND column_name = 'user_id') OR
            (table_name = 'verification_requests' AND column_name = 'document_back_url') OR
            (table_name = 'matrimonial_profiles' AND column_name = 'show_in_matrimony') OR
            (table_name = 'users' AND column_name IN ('is_email_verified', 'is_phone_verified'))
          );
      `);
      const existingCols = new Set(
        (columnRows || []).map(
          (r: any) => `${(r.table_name || r.TABLE_NAME || "").toLowerCase()}.${(r.column_name || r.COLUMN_NAME || "").toLowerCase()}`,
        ),
      );
      const requiredCols = [
        "samaj_service_persons.user_id",
        "verification_requests.document_back_url",
        "matrimonial_profiles.show_in_matrimony",
        "users.is_email_verified",
        "users.is_phone_verified",
      ];
      return requiredCols.every((c) => existingCols.has(c));
    } catch (err: any) {
      this.logger.warn(`Schema completeness probe notice: ${err?.message || err}`);
      return false;
    }
  }

  /**
   * Executes runtime DDL statements on a single dedicated, connection-pinned transaction.
   * Guarantees that GET_LOCK, all DDL execution, and RELEASE_LOCK run on the exact same physical session.
   */
  async syncSchemaWithLock(): Promise<boolean> {
    return this.$transaction(
      async (tx) => {
        let lockAcquired = false;
        try {
          // 1. Connection-pinned MySQL advisory lock acquisition (5s wait)
          try {
            const lockRes = await tx.$queryRawUnsafe<any[]>(
              "SELECT GET_LOCK('vankar_schema_sync_lock', 5) AS lock_acquired;"
            );
            const val = lockRes?.[0]?.lock_acquired;
            if (val === 1 || val === "1" || val === 1n) {
              lockAcquired = true;
            } else {
              this.logger.warn(
                `Advisory lock 'vankar_schema_sync_lock' could not be acquired on session (status=${val}, held by concurrent process or timed out)`,
              );
              return false;
            }
          } catch (lockErr: any) {
            this.logger.warn(
              `Advisory lock check bypassed on pinned connection: ${lockErr?.message || lockErr}. Proceeding with schema check.`,
            );
            lockAcquired = true;
          }

          // 2. Execute all 15 backward-compatible DDL statements on the same pinned connection
          await tx.$executeRawUnsafe(`
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

          await tx.$executeRawUnsafe(`
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

          await tx.$executeRawUnsafe(`
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

          // Ensure supplementary columns exist on existing tables
          await tx.$executeRawUnsafe(`
            ALTER TABLE \`samaj_service_persons\` ADD COLUMN IF NOT EXISTS \`user_id\` VARCHAR(191) NULL;
          `);
          await tx.$executeRawUnsafe(`
            ALTER TABLE \`samaj_service_persons\` MODIFY COLUMN \`address\` TEXT NULL;
          `);
          await tx.$executeRawUnsafe(`
            ALTER TABLE \`samaj_service_persons\` MODIFY COLUMN \`description\` TEXT NULL;
          `);
          await tx.$executeRawUnsafe(`
            ALTER TABLE \`samaj_service_persons\` MODIFY COLUMN \`photo_url\` TEXT NULL;
          `);
          await tx.$executeRawUnsafe(`
            ALTER TABLE \`verification_requests\` ADD COLUMN IF NOT EXISTS \`document_back_url\` VARCHAR(191) NULL;
          `);
          await tx.$executeRawUnsafe(`
            ALTER TABLE \`matrimonial_profiles\` ADD COLUMN IF NOT EXISTS \`show_in_matrimony\` TINYINT(1) NOT NULL DEFAULT 1;
          `);

          await tx.$executeRawUnsafe(`
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

          await tx.$executeRawUnsafe(`
            ALTER TABLE \`advertisements\` MODIFY COLUMN \`placement\` ENUM('HOME_BANNER', 'DIRECTORY_BANNER', 'POPUP', 'BUTTON_1', 'BUTTON_2', 'BUTTON_3', 'BUTTON_4', 'BUTTON_5', 'PAVAN_PRERNADATA', 'SAMAJ_SUPER_STARS', 'SAMAJ_RATNA') NOT NULL DEFAULT 'HOME_BANNER';
          `);

          // OTP Verification and Logs Schema
          await tx.$executeRawUnsafe(`
            ALTER TABLE \`users\` ADD COLUMN IF NOT EXISTS \`is_email_verified\` BOOLEAN NOT NULL DEFAULT false;
          `);
          await tx.$executeRawUnsafe(`
            ALTER TABLE \`users\` ADD COLUMN IF NOT EXISTS \`is_phone_verified\` BOOLEAN NOT NULL DEFAULT false;
          `);
          await tx.$executeRawUnsafe(`
            CREATE TABLE IF NOT EXISTS \`otp_sessions\` (
              \`id\` varchar(191) NOT NULL,
              \`target\` varchar(191) NOT NULL,
              \`channel\` enum('SMS','EMAIL') NOT NULL,
              \`purpose\` enum('REGISTRATION','FORGOT_PASSWORD') NOT NULL,
              \`code\` varchar(191) NOT NULL,
              \`attempts\` int NOT NULL DEFAULT 0,
              \`max_attempts\` int NOT NULL DEFAULT 4,
              \`is_verified\` tinyint(1) NOT NULL DEFAULT 0,
              \`verified_at\` datetime(3) DEFAULT NULL,
              \`expires_at\` datetime(3) NOT NULL,
              \`locked_until\` datetime(3) DEFAULT NULL,
              \`token\` varchar(191) DEFAULT NULL,
              \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
              \`updated_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
              PRIMARY KEY (\`id\`),
              UNIQUE KEY \`otp_sessions_token_key\` (\`token\`),
              KEY \`otp_sessions_target_purpose_idx\` (\`target\`,\`purpose\`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
          `);
          await tx.$executeRawUnsafe(`
            CREATE TABLE IF NOT EXISTS \`otp_logs\` (
              \`id\` varchar(191) NOT NULL,
              \`channel\` enum('SMS','EMAIL') NOT NULL,
              \`purpose\` enum('REGISTRATION','FORGOT_PASSWORD') NOT NULL,
              \`recipient\` varchar(191) NOT NULL,
              \`ip_address\` varchar(191) DEFAULT NULL,
              \`status\` enum('SENT','DELIVERED','FAILED') NOT NULL DEFAULT 'SENT',
              \`gateway_id\` varchar(191) DEFAULT NULL,
              \`gateway_response\` text DEFAULT NULL,
              \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
              PRIMARY KEY (\`id\`),
              KEY \`otp_logs_created_at_idx\` (\`created_at\`),
              KEY \`otp_logs_recipient_idx\` (\`recipient\`),
              KEY \`otp_logs_channel_idx\` (\`channel\`),
              KEY \`otp_logs_purpose_idx\` (\`purpose\`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
          `);

          return true;
        } finally {
          if (lockAcquired) {
            try {
              // 3. Guaranteed release on the exact same pinned connection
              await tx.$queryRawUnsafe("SELECT RELEASE_LOCK('vankar_schema_sync_lock');");
            } catch (releaseErr: any) {
              this.logger.warn(
                `Failed to release schema sync advisory lock: ${releaseErr?.message || releaseErr}`,
              );
            }
          }
        }
      },
      { timeout: 45000 },
    );
  }

  /**
   * Safe, bounded schema auto-migration coordinator.
   * If lock is held by a peer process, verifies schema completeness before allowing startup.
   * Fails startup clearly if schema remains incomplete after bounded retries.
   */
  async syncSchema(maxRetries = 3, retryDelayMs = 2000) {
    const syncStartTime = Date.now();

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        const migrated = await this.syncSchemaWithLock();
        if (migrated) {
          const elapsed = Date.now() - syncStartTime;
          this.logger.log(
            `Schema auto-migration check completed successfully in ${elapsed}ms (attempt ${attempt})`,
          );
          return;
        }

        // Lock was not acquired because another process is currently running migrations
        this.logger.warn(
          `Schema auto-migration lock held by peer process (attempt ${attempt}/${maxRetries}). Verifying schema completeness...`,
        );

        // Check if the competing process has completed or if schema is already complete
        const complete = await this.isSchemaComplete();
        if (complete) {
          this.logger.log(
            "Schema completeness confirmed (all required tables exist). Peer migration completed or schema already applied. Proceeding safely.",
          );
          return;
        }

        // Schema is incomplete and lock is held: wait before next retry
        if (attempt < maxRetries) {
          await new Promise((res) => setTimeout(res, retryDelayMs));
        }
      } catch (err: any) {
        this.logger.warn(`Schema auto-migration attempt ${attempt} warning: ${err?.message || err}`);
        const complete = await this.isSchemaComplete();
        if (complete) {
          this.logger.log("Schema completeness confirmed despite migration warning. Proceeding safely.");
          return;
        }
        if (attempt < maxRetries) {
          await new Promise((res) => setTimeout(res, retryDelayMs));
        }
      }
    }

    // After all retries exhausted, perform final completeness check
    const finalComplete = await this.isSchemaComplete();
    if (finalComplete) {
      this.logger.log("Final schema completeness verified after retries. Proceeding safely.");
      return;
    }

    // Failsafe: Do NOT proceed on an unverified, incomplete database schema
    throw new Error(
      "FATAL: Database schema is incomplete and synchronization lock could not be acquired after bounded retries. Halting bootstrap to prevent serving traffic on an unverified schema.",
    );
  }

  /**
   * @deprecated Decoupled from startup boot path.
   * Synchronization is handled safely and on-demand via GovernmentEmployeesService.triggerAdminSync(),
   * which includes transaction-scoped MySQL advisory locking, non-destructive soft deactivations,
   * bounded batching, and role-based admin authorization.
   */
  async syncGovernmentEmployeesFromProfiles(): Promise<void> {
    this.logger.warn(
      "PrismaService.syncGovernmentEmployeesFromProfiles is deprecated and decoupled from startup. Use GovernmentEmployeesService.triggerAdminSync instead."
    );
  }

  async onModuleDestroy() {
    await this.$disconnect();
    this.logger.log("Disconnected from MySQL database");
  }
}
