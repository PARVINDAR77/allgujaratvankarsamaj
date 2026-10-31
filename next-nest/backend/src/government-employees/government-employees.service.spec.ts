import { Test, TestingModule } from "@nestjs/testing";
import { GovernmentEmployeesService } from "./government-employees.service";
import { GovernmentEmployeesController } from "./government-employees.controller";
import { PrismaService } from "../prisma/prisma.service";
import { GovtVerificationStatus, ProfileStatus, Role } from "@prisma/client";
import { ConflictException, ForbiddenException } from "@nestjs/common";

describe("GovernmentEmployeesService - Step 3 Safe Synchronization Tests", () => {
  let service: GovernmentEmployeesService;
  let controller: GovernmentEmployeesController;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      $executeRawUnsafe: jest.fn().mockResolvedValue(0),
      $queryRawUnsafe: jest.fn().mockResolvedValue([{ acquired: 1 }]),
      $transaction: jest.fn().mockImplementation(async (cb) => cb(prisma)),
      governmentEmployment: {
        findMany: jest.fn().mockResolvedValue([]),
        findUnique: jest.fn().mockResolvedValue(null),
        count: jest.fn().mockResolvedValue(0),
        create: jest.fn().mockResolvedValue({ id: "gov-new" }),
        update: jest.fn().mockResolvedValue({ id: "gov-updated" }),
        delete: jest.fn(),
        deleteMany: jest.fn(),
      },
      matrimonialProfile: {
        findMany: jest.fn().mockResolvedValue([]),
        findUnique: jest.fn().mockResolvedValue(null),
      },
      govtDepartment: {
        findMany: jest.fn().mockResolvedValue([]),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [GovernmentEmployeesController],
      providers: [
        GovernmentEmployeesService,
        {
          provide: PrismaService,
          useValue: prisma,
        },
      ],
    }).compile();

    service = module.get<GovernmentEmployeesService>(GovernmentEmployeesService);
    controller = module.get<GovernmentEmployeesController>(GovernmentEmployeesController);
  });

  describe("Public Read Path Invariants (Step 2 Verification)", () => {
    it("searchPublicGovtEmployees MUST NOT trigger synchronization or table purges", async () => {
      const syncSpy = jest.spyOn(service, "triggerAdminSync");
      const legacySyncSpy = jest.spyOn(service, "syncMissingGovtEmployees");

      prisma.governmentEmployment.findMany.mockResolvedValue([
        {
          id: "gov-1",
          profileId: "prof-1",
          employmentType: "STATE_GOVT",
          officeLocation: "Gandhinagar",
          verificationStatus: GovtVerificationStatus.VERIFIED,
          isActive: true,
          isFeatured: false,
          profile: {
            id: "prof-1",
            firstName: "Ramesh",
            lastName: "Vankar",
            occupation: "State Govt Teacher",
            status: ProfileStatus.APPROVED,
          },
        },
      ]);
      prisma.governmentEmployment.count.mockResolvedValue(1);

      const result = await service.searchPublicGovtEmployees({ page: 1, limit: 10 });

      expect(syncSpy).not.toHaveBeenCalled();
      expect(legacySyncSpy).not.toHaveBeenCalled();
      expect(prisma.$executeRawUnsafe).not.toHaveBeenCalled();
      expect(prisma.governmentEmployment.deleteMany).not.toHaveBeenCalled();

      expect(result).toBeDefined();
      expect(result.data).toHaveLength(1);
      expect(result.meta.total).toBe(1);
    });

    it("getFeaturedGovtEmployees MUST perform direct read without triggering synchronization", async () => {
      const syncSpy = jest.spyOn(service, "triggerAdminSync");

      prisma.governmentEmployment.findMany.mockResolvedValue([
        {
          id: "gov-feat-1",
          profileId: "prof-feat-1",
          isFeatured: true,
          isActive: true,
          verificationStatus: GovtVerificationStatus.VERIFIED,
          profile: {
            id: "prof-feat-1",
            firstName: "Suresh",
            lastName: "Parmar",
            status: ProfileStatus.APPROVED,
          },
        },
      ]);

      const result = await service.getFeaturedGovtEmployees();

      expect(syncSpy).not.toHaveBeenCalled();
      expect(prisma.$executeRawUnsafe).not.toHaveBeenCalled();
      expect(prisma.governmentEmployment.deleteMany).not.toHaveBeenCalled();
      expect(result).toHaveLength(1);
    });

    it("getAdminGovtEmployees MUST NOT trigger synchronization on ordinary paginated reads", async () => {
      const syncSpy = jest.spyOn(service, "triggerAdminSync");

      prisma.governmentEmployment.findMany.mockResolvedValue([]);
      prisma.governmentEmployment.count.mockResolvedValue(0);

      const result = await service.getAdminGovtEmployees(1, 20, "ALL", false);

      expect(syncSpy).not.toHaveBeenCalled();
      expect(prisma.$executeRawUnsafe).not.toHaveBeenCalled();
      expect(result.data).toEqual([]);
    });

    it("getAdminGovtEmployees MUST invoke triggerAdminSync only when forceSync is explicitly true", async () => {
      const syncSpy = jest.spyOn(service, "triggerAdminSync").mockResolvedValue({
        success: true,
        message: "Sync complete",
        durationMs: 5,
        syncedCount: 0,
        updatedCount: 0,
        deactivatedCount: 0,
        hasMore: false,
      });

      prisma.governmentEmployment.findMany.mockResolvedValue([]);
      prisma.governmentEmployment.count.mockResolvedValue(0);

      await service.getAdminGovtEmployees(1, 20, "ALL", true);

      expect(syncSpy).toHaveBeenCalledTimes(1);
    });
  });

  describe("Administrative Route Authorization Policies", () => {
    it("MUST reject triggerAdminSync from non-admin users with ForbiddenException", async () => {
      const regularUserReq = { user: { id: "user-1", role: Role.USER } };
      expect(() => controller.triggerAdminSync(regularUserReq)).toThrow(ForbiddenException);
    });

    it("MUST reject getAdminSyncStatus from non-admin users with ForbiddenException", async () => {
      const regularUserReq = { user: { id: "user-1", role: Role.USER } };
      expect(() => controller.getAdminSyncStatus(regularUserReq)).toThrow(ForbiddenException);
    });

    it("MUST reject getAdminProfiles from non-admin users with ForbiddenException", async () => {
      const regularUserReq = { user: { id: "user-1", role: Role.USER } };
      expect(() => controller.getAdminProfiles(regularUserReq, 1, 20)).toThrow(ForbiddenException);
    });

    it("MUST allow triggerAdminSync for authorized ADMIN and SUPER_ADMIN roles", async () => {
      const adminReq = { user: { id: "admin-1", role: Role.ADMIN } };
      const syncSpy = jest.spyOn(service, "triggerAdminSync").mockResolvedValue({
        success: true,
        message: "Sync complete",
        durationMs: 5,
        syncedCount: 0,
        updatedCount: 0,
        deactivatedCount: 0,
        hasMore: false,
      });

      const result = await controller.triggerAdminSync(adminReq);
      expect(result).toBeDefined();
      expect(syncSpy).toHaveBeenCalledTimes(1);
    });
  });

  describe("Step 3 Safeguards: Advisory Lock & Connection Scoping", () => {
    it("triggerAdminSync MUST throw ConflictException when MySQL advisory lock is held by another process", async () => {
      // Simulate another process holding the MySQL lock (GET_LOCK returns 0)
      prisma.$queryRawUnsafe.mockResolvedValueOnce([{ acquired: 0 }]);

      await expect(service.triggerAdminSync()).rejects.toThrow(ConflictException);

      // Verify no creation queries occurred
      expect(prisma.governmentEmployment.create).not.toHaveBeenCalled();
    });

    it("triggerAdminSync MUST release the advisory lock in finally block on completion", async () => {
      prisma.$queryRawUnsafe
        .mockResolvedValueOnce([{ acquired: 1 }]) // GET_LOCK
        .mockResolvedValueOnce([{ released: 1 }]); // RELEASE_LOCK

      const result = await service.triggerAdminSync();

      expect(result.success).toBe(true);
      expect(prisma.$queryRawUnsafe).toHaveBeenCalledWith(
        expect.stringContaining("RELEASE_LOCK('govt_employee_sync_lock')"),
      );
      expect(service.getSyncStatus().isRunning).toBe(false);
    });

    it("triggerAdminSync MUST release advisory lock even when sync worker throws an error", async () => {
      prisma.$queryRawUnsafe.mockResolvedValueOnce([{ acquired: 1 }]); // GET_LOCK
      prisma.governmentEmployment.findMany.mockRejectedValueOnce(new Error("Database connection dropped"));

      await expect(service.triggerAdminSync()).rejects.toThrow("Database connection dropped");

      // Verify RELEASE_LOCK was still called in finally block
      expect(prisma.$queryRawUnsafe).toHaveBeenCalledWith(
        expect.stringContaining("RELEASE_LOCK('govt_employee_sync_lock')"),
      );
      expect(service.getSyncStatus().isRunning).toBe(false);
    });
  });

  describe("Step 3 Safeguards: Non-Destructive Soft Deactivation & Preservation", () => {
    it("MUST soft-deactivate only unreviewed records and NEVER call delete or deleteMany", async () => {
      // Return 1 unreviewed record belonging to a private employee
      prisma.governmentEmployment.findMany.mockResolvedValueOnce([
        { id: "gov-private-unreviewed" },
      ]);

      await service.triggerAdminSync();

      // Soft-deactivation via update (isActive = false)
      expect(prisma.governmentEmployment.update).toHaveBeenCalledWith({
        where: { id: "gov-private-unreviewed" },
        data: { isActive: false },
      });

      // INVARIANT: Destructive delete operations must NEVER be called
      expect(prisma.governmentEmployment.delete).not.toHaveBeenCalled();
      expect(prisma.governmentEmployment.deleteMany).not.toHaveBeenCalled();
    });

    it("MUST NEVER deactivate records with manual admin reviews or verification documents", async () => {
      // Prisma findMany where query includes:
      // departmentId: null, designationId: null, verifiedBy: null, verifications: { none: {} }
      // This invariant guarantees manual reviews are filtered out before update
      await service.triggerAdminSync();

      const callArgs = prisma.governmentEmployment.findMany.mock.calls[0][0];
      expect(callArgs.where.departmentId).toBeNull();
      expect(callArgs.where.designationId).toBeNull();
      expect(callArgs.where.verifiedBy).toBeNull();
      expect(callArgs.where.verifications).toEqual({ none: {} });
    });
  });

  describe("Step 3 Safeguards: Deterministic Bounded Batching & Unique Upsert", () => {
    it("MUST process bounded batch of 50 candidates ordered deterministically by id asc and targeting unlinked profiles", async () => {
      await service.triggerAdminSync();

      const candidateCallArgs = prisma.matrimonialProfile.findMany.mock.calls[0][0];
      expect(candidateCallArgs.take).toBe(50);
      expect(candidateCallArgs.orderBy).toEqual({ id: "asc" });
      expect(candidateCallArgs.where.governmentEmployment).toBeNull();
      expect(candidateCallArgs.where.status).toEqual({
        notIn: [ProfileStatus.REJECTED, ProfileStatus.SUSPENDED],
      });
    });

    it("MUST create new record if profile has no existing government employment", async () => {
      prisma.matrimonialProfile.findMany.mockResolvedValueOnce([
        {
          id: "prof-new-govt",
          firstName: "Bipin",
          lastName: "Solanki",
          occupation: "Government High School Teacher",
          organizationName: "Gujarat State Education Board",
          city: "Ahmedabad",
          state: "Gujarat",
          isFeatured: true,
        },
      ]);
      prisma.governmentEmployment.findUnique.mockResolvedValueOnce(null);

      const result = await service.triggerAdminSync();

      expect(result.syncedCount).toBe(1);
      expect(prisma.governmentEmployment.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          profileId: "prof-new-govt",
          employmentType: "STATE_GOVT",
          officeLocation: "Ahmedabad",
          verificationStatus: GovtVerificationStatus.VERIFIED,
          isActive: true,
          isFeatured: true,
        }),
      });
    });

    it("repeated synchronization runs MUST progress without re-creating existing records (batch completeness)", async () => {
      // Run 1: Returns 1 unlinked candidate -> synced
      prisma.matrimonialProfile.findMany.mockResolvedValueOnce([
        {
          id: "prof-batch-1",
          firstName: "Kishor",
          lastName: "Parmar",
          occupation: "Talati Mantri",
          city: "Mehsana",
          isFeatured: false,
        },
      ]);
      prisma.governmentEmployment.findUnique.mockResolvedValueOnce(null);
      const run1 = await service.triggerAdminSync();
      expect(run1.syncedCount).toBe(1);

      // Run 2: Unlinked candidate query returns empty (because prof-batch-1 is now linked)
      prisma.matrimonialProfile.findMany.mockResolvedValueOnce([]);
      const run2 = await service.triggerAdminSync();
      expect(run2.syncedCount).toBe(0);

      // Total creates remains 1
      expect(prisma.governmentEmployment.create).toHaveBeenCalledTimes(1);
    });

    it("MUST PRESERVE manually assigned department, designation, and verificationStatus on reactivation", async () => {
      // Inactive record exists with manual admin fields
      prisma.governmentEmployment.findMany
        .mockResolvedValueOnce([]) // unreviewedActiveGovt
        .mockResolvedValueOnce([   // reactivatableGovt
          {
            id: "gov-manual-inactive",
            profileId: "prof-manual-1",
            departmentId: "dept-police-manual",
            designationId: "desig-psi-manual",
            verificationStatus: GovtVerificationStatus.VERIFIED,
            verifiedBy: "super-admin-uuid",
            isActive: false,
            profile: {
              id: "prof-manual-1",
              occupation: "Police Sub Inspector",
              status: ProfileStatus.APPROVED,
            },
          },
        ]);

      // Since departmentId, designationId, verifiedBy are present, it should NOT match the reactivatable query
      // (which requires departmentId: null, designationId: null, verifiedBy: null)
      await service.triggerAdminSync();

      const reactivateQueryArgs = prisma.governmentEmployment.findMany.mock.calls[1][0];
      expect(reactivateQueryArgs.where.departmentId).toBeNull();
      expect(reactivateQueryArgs.where.designationId).toBeNull();
      expect(reactivateQueryArgs.where.verifiedBy).toBeNull();
      expect(reactivateQueryArgs.where.verificationStatus).toEqual({
        not: GovtVerificationStatus.REJECTED,
      });
      expect(reactivateQueryArgs.where.rejectionReason).toBeNull();
    });

    it("MUST distinguish between fully completed sync and sync with remaining eligible profiles (hasMore)", async () => {
      // Case 1: Less than 50 profiles -> hasMore is false
      prisma.matrimonialProfile.findMany.mockResolvedValueOnce([
        {
          id: "prof-single",
          firstName: "Ramesh",
          lastName: "Vankar",
          occupation: "Talati",
        },
      ]);
      const completeRun = await service.triggerAdminSync();
      expect(completeRun.hasMore).toBe(false);
      expect(completeRun.message).toContain("fully completed");

      // Case 2: Exactly 50 profiles in all 5 batches (250 total) -> hasMore is true
      const fullBatch = Array.from({ length: 50 }, (_, i) => ({
        id: `prof-full-${i}`,
        firstName: `First${i}`,
        lastName: `Last${i}`,
        occupation: "Police Constable",
      }));
      // 5 consecutive batches of 50
      prisma.matrimonialProfile.findMany
        .mockResolvedValueOnce(fullBatch)
        .mockResolvedValueOnce(fullBatch)
        .mockResolvedValueOnce(fullBatch)
        .mockResolvedValueOnce(fullBatch)
        .mockResolvedValueOnce(fullBatch);

      const partialRun = await service.triggerAdminSync();
      expect(partialRun.hasMore).toBe(true);
      expect(partialRun.message).toContain("Additional eligible profiles remain");
    });
  });
});
