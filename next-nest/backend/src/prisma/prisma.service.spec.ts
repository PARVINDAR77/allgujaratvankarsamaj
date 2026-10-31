import { Test, TestingModule } from "@nestjs/testing";
import { PrismaService } from "./prisma.service";

describe("PrismaService (Startup & Schema Auto-Migration Optimization)", () => {
  let service: PrismaService;
  let originalEnv: NodeJS.ProcessEnv;

  beforeEach(async () => {
    originalEnv = { ...process.env };
    delete process.env.DISABLE_RUNTIME_SCHEMA_SYNC;

    const module: TestingModule = await Test.createTestingModule({
      providers: [PrismaService],
    }).compile();

    service = module.get<PrismaService>(PrismaService);

    // Mock Prisma Client base methods
    jest.spyOn(service as any, "$connect").mockResolvedValue(undefined as any);
    jest.spyOn(service as any, "$disconnect").mockResolvedValue(undefined as any);
    jest.spyOn(service as any, "$executeRawUnsafe").mockResolvedValue(0 as any);
    jest.spyOn(service as any, "$queryRawUnsafe").mockResolvedValue([{ lock_acquired: 1 }] as any);
    jest.spyOn(service as any, "$transaction").mockImplementation(async (cb: any) => cb(service));
  });

  afterEach(() => {
    process.env = originalEnv;
    jest.restoreAllMocks();
  });

  describe("onModuleInit lifecycle", () => {
    it("MUST connect to database and trigger syncSchema by default", async () => {
      const syncSchemaSpy = jest.spyOn(service, "syncSchema").mockResolvedValue(undefined);

      await service.onModuleInit();

      expect(service.$connect).toHaveBeenCalledTimes(1);
      expect(syncSchemaSpy).toHaveBeenCalledTimes(1);
    });

    it("MUST skip syncSchema when DISABLE_RUNTIME_SCHEMA_SYNC=true", async () => {
      process.env.DISABLE_RUNTIME_SCHEMA_SYNC = "true";
      const syncSchemaSpy = jest.spyOn(service, "syncSchema").mockResolvedValue(undefined);

      await service.onModuleInit();

      expect(service.$connect).toHaveBeenCalledTimes(1);
      expect(syncSchemaSpy).not.toHaveBeenCalled();
    });

    it("MUST handle database connection failure gracefully without halting bootstrap", async () => {
      jest.spyOn(service, "$connect").mockRejectedValue(new Error("Connection refused: 3306"));
      const syncSchemaSpy = jest.spyOn(service, "syncSchema");

      await expect(service.onModuleInit()).resolves.not.toThrow();
      expect(syncSchemaSpy).not.toHaveBeenCalled();
    });
  });

  describe("isSchemaComplete metadata probe", () => {
    it("MUST return true when all 6 required runtime tables and 5 supplementary columns exist", async () => {
      jest.spyOn(service as any, "$queryRawUnsafe").mockImplementation((async (sql: string) => {
        if (sql.includes("information_schema.tables")) {
          return [
            { table_name: "section_view_counts" },
            { table_name: "home_button_configs" },
            { table_name: "samaj_service_persons" },
            { table_name: "system_notifications" },
            { table_name: "otp_sessions" },
            { table_name: "otp_logs" },
          ];
        }
        if (sql.includes("information_schema.columns")) {
          return [
            { table_name: "samaj_service_persons", column_name: "user_id" },
            { table_name: "verification_requests", column_name: "document_back_url" },
            { table_name: "matrimonial_profiles", column_name: "show_in_matrimony" },
            { table_name: "users", column_name: "is_email_verified" },
            { table_name: "users", column_name: "is_phone_verified" },
          ];
        }
        return [];
      }) as any);

      const result = await service.isSchemaComplete();
      expect(result).toBe(true);
    });

    it("MUST return false when any required runtime table is missing", async () => {
      jest.spyOn(service as any, "$queryRawUnsafe").mockResolvedValue([
        { table_name: "section_view_counts" },
        { table_name: "home_button_configs" },
      ] as any);

      const result = await service.isSchemaComplete();
      expect(result).toBe(false);
    });

    it("MUST return false when all tables exist but a supplementary column is missing", async () => {
      jest.spyOn(service as any, "$queryRawUnsafe").mockImplementation((async (sql: string) => {
        if (sql.includes("information_schema.tables")) {
          return [
            { table_name: "section_view_counts" },
            { table_name: "home_button_configs" },
            { table_name: "samaj_service_persons" },
            { table_name: "system_notifications" },
            { table_name: "otp_sessions" },
            { table_name: "otp_logs" },
          ];
        }
        if (sql.includes("information_schema.columns")) {
          // Missing show_in_matrimony
          return [
            { table_name: "samaj_service_persons", column_name: "user_id" },
            { table_name: "verification_requests", column_name: "document_back_url" },
            { table_name: "users", column_name: "is_email_verified" },
            { table_name: "users", column_name: "is_phone_verified" },
          ];
        }
        return [];
      }) as any);

      const result = await service.isSchemaComplete();
      expect(result).toBe(false);
    });

    it("MUST return false gracefully if information_schema query throws", async () => {
      jest.spyOn(service as any, "$queryRawUnsafe").mockRejectedValue(new Error("Query failed"));

      const result = await service.isSchemaComplete();
      expect(result).toBe(false);
    });
  });

  describe("syncSchemaWithLock connection-pinned DDL execution", () => {
    it("MUST pin execution to dedicated transaction, acquire advisory lock, execute 15 DDLs, and release lock", async () => {
      const queryRawSpy = jest.spyOn(service as any, "$queryRawUnsafe").mockImplementation((async (sql: string) => {
        if (sql.includes("GET_LOCK")) {
          return [{ lock_acquired: 1 }];
        }
        if (sql.includes("RELEASE_LOCK")) {
          return [{ release_lock: 1 }];
        }
        return [];
      }) as any);

      const executeRawSpy = jest.spyOn(service, "$executeRawUnsafe").mockResolvedValue(0 as any);

      const success = await service.syncSchemaWithLock();

      expect(success).toBe(true);
      expect(service.$transaction).toHaveBeenCalledTimes(1);

      // Verify lock acquisition on the pinned connection
      expect(queryRawSpy).toHaveBeenCalledWith(
        expect.stringContaining("GET_LOCK('vankar_schema_sync_lock', 5)"),
      );

      // Verify exactly 15 DDL statements executed on the pinned connection
      expect(executeRawSpy).toHaveBeenCalledTimes(15);
      expect(executeRawSpy).toHaveBeenCalledWith(
        expect.stringContaining("CREATE TABLE IF NOT EXISTS `section_view_counts`"),
      );
      expect(executeRawSpy).toHaveBeenCalledWith(
        expect.stringContaining("CREATE TABLE IF NOT EXISTS `home_button_configs`"),
      );
      expect(executeRawSpy).toHaveBeenCalledWith(
        expect.stringContaining("CREATE TABLE IF NOT EXISTS `samaj_service_persons`"),
      );
      expect(executeRawSpy).toHaveBeenCalledWith(
        expect.stringContaining("ALTER TABLE `samaj_service_persons` ADD COLUMN IF NOT EXISTS `user_id`"),
      );
      expect(executeRawSpy).toHaveBeenCalledWith(
        expect.stringContaining("ALTER TABLE `verification_requests` ADD COLUMN IF NOT EXISTS `document_back_url`"),
      );
      expect(executeRawSpy).toHaveBeenCalledWith(
        expect.stringContaining("ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `show_in_matrimony`"),
      );
      expect(executeRawSpy).toHaveBeenCalledWith(
        expect.stringContaining("CREATE TABLE IF NOT EXISTS `system_notifications`"),
      );
      expect(executeRawSpy).toHaveBeenCalledWith(
        expect.stringContaining("ALTER TABLE `advertisements` MODIFY COLUMN `placement`"),
      );
      expect(executeRawSpy).toHaveBeenCalledWith(
        expect.stringContaining("CREATE TABLE IF NOT EXISTS `otp_sessions`"),
      );
      expect(executeRawSpy).toHaveBeenCalledWith(
        expect.stringContaining("CREATE TABLE IF NOT EXISTS `otp_logs`"),
      );

      // Verify lock release on the pinned connection
      expect(queryRawSpy).toHaveBeenCalledWith(
        expect.stringContaining("RELEASE_LOCK('vankar_schema_sync_lock')"),
      );
    });

    it("MUST return false and NOT execute DDL if advisory lock is held by another process (lock_acquired=0)", async () => {
      jest.spyOn(service as any, "$queryRawUnsafe").mockResolvedValue([{ lock_acquired: 0 }] as any);
      const executeRawSpy = jest.spyOn(service, "$executeRawUnsafe");

      const success = await service.syncSchemaWithLock();

      expect(success).toBe(false);
      expect(executeRawSpy).not.toHaveBeenCalled();
    });

    it("MUST release advisory lock in finally block even if a DDL statement fails", async () => {
      const queryRawSpy = jest.spyOn(service as any, "$queryRawUnsafe").mockImplementation((async (sql: string) => {
        if (sql.includes("GET_LOCK")) {
          return [{ lock_acquired: 1 }];
        }
        if (sql.includes("RELEASE_LOCK")) {
          return [{ release_lock: 1 }];
        }
        return [];
      }) as any);

      jest.spyOn(service, "$executeRawUnsafe").mockRejectedValue(new Error("Disk full on MySQL host"));

      await expect(service.syncSchemaWithLock()).rejects.toThrow("Disk full on MySQL host");

      // RELEASE_LOCK MUST still be executed on the pinned session
      expect(queryRawSpy).toHaveBeenCalledWith(
        expect.stringContaining("RELEASE_LOCK('vankar_schema_sync_lock')"),
      );
    });
  });

  describe("syncSchema bounded fallback & safety policy", () => {
    it("MUST safely proceed when lock is held by peer IF schema completeness probe passes", async () => {
      jest.spyOn(service, "syncSchemaWithLock").mockResolvedValue(false);
      jest.spyOn(service, "isSchemaComplete").mockResolvedValue(true);

      await expect(service.syncSchema(2, 10)).resolves.not.toThrow();
    });

    it("MUST fail startup with fatal Error if lock is held and schema remains incomplete after all retries", async () => {
      jest.spyOn(service, "syncSchemaWithLock").mockResolvedValue(false);
      jest.spyOn(service, "isSchemaComplete").mockResolvedValue(false);

      await expect(service.syncSchema(2, 10)).rejects.toThrow(
        /FATAL: Database schema is incomplete and synchronization lock could not be acquired/,
      );
    });

    it("MUST NOT invoke legacy syncGovernmentEmployeesFromProfiles or matrimonial profile queries", async () => {
      const syncGovtSpy = jest.spyOn(service, "syncGovernmentEmployeesFromProfiles");
      jest.spyOn(service, "syncSchemaWithLock").mockResolvedValue(true);

      await service.syncSchema();

      expect(syncGovtSpy).not.toHaveBeenCalled();
    });
  });

  describe("syncGovernmentEmployeesFromProfiles deprecation stub", () => {
    it("MUST be inactive, log a deprecation warning, and not perform raw database mutations", async () => {
      const executeRawSpy = jest.spyOn(service, "$executeRawUnsafe");
      const queryRawSpy = jest.spyOn(service, "$queryRawUnsafe");

      await service.syncGovernmentEmployeesFromProfiles();

      expect(executeRawSpy).not.toHaveBeenCalled();
      expect(queryRawSpy).not.toHaveBeenCalled();
    });
  });

  describe("onModuleDestroy lifecycle", () => {
    it("MUST disconnect from database", async () => {
      await service.onModuleDestroy();
      expect(service.$disconnect).toHaveBeenCalledTimes(1);
    });
  });
});
