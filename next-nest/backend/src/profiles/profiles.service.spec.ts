import { Test, TestingModule } from "@nestjs/testing";
import { Gender, MaritalStatus, ProfileStatus, Role } from "@prisma/client";
import { ProfilesService } from "./profiles.service";
import { PrismaService } from "../prisma/prisma.service";

describe("ProfilesService Privacy Boundary Tests", () => {
  let service: ProfilesService;
  let prisma: any;

  const mockTargetProfile = {
    id: "target-profile-001",
    userId: "target-user-001",
    firstName: "Pooja",
    lastName: "Vankar",
    gender: Gender.FEMALE,
    maritalStatus: MaritalStatus.NEVER_MARRIED,
    dateOfBirth: new Date("1999-01-01"),
    status: ProfileStatus.APPROVED,
    isVerified: true,
    city: "Ahmedabad",
    state: "Gujarat",
    contactPhone: "9876543210",
    contactEmail: "pooja.private@vankarsamaj.org",
    altPhone: "9876543211",
    fatherContact: "9876543212",
    guardianContact: "9876543213",
    addressLine: "12, Shanti Nagar, Ranip",
    pincode: "382480",
    privacySettings: JSON.stringify({
      mobile: "માત્ર મને",
      email: "માત્ર મને",
      address: "પરિવારજનો",
      guardian: "બધા માટે",
    }),
    user: {
      phone: "9876543210",
      email: "pooja.account@vankarsamaj.org",
    },
  };

  beforeEach(async () => {
    prisma = {
      $executeRawUnsafe: jest.fn().mockResolvedValue(0),
      matrimonialProfile: {
        findUnique: jest.fn(),
        findFirst: jest.fn(),
        findMany: jest.fn(),
        count: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      matchInterest: {
        findFirst: jest.fn(),
      },
      samajService: {
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      samajServicePerson: {
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        deleteMany: jest.fn(),
      },
      user: {
        findUnique: jest.fn(),
      },
      district: {
        findFirst: jest.fn(),
      },
      taluka: {
        findFirst: jest.fn(),
      },
      verificationRequest: {
        findFirst: jest.fn(),
        update: jest.fn(),
      },
      governmentEmployment: {
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        deleteMany: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProfilesService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    service = module.get<ProfilesService>(ProfilesService);
  });

  describe("Public List & Search Sanitization", () => {
    it("MUST sanitize public listing items and NEVER expose phone numbers or addresses", async () => {
      prisma.matrimonialProfile.count.mockResolvedValue(1);
      prisma.matrimonialProfile.findMany.mockResolvedValue([mockTargetProfile]);

      const result = await service.getProfiles({ page: 1, limit: 10 });

      expect(result.items).toHaveLength(1);
      const item = result.items[0];

      // Public demographic fields preserved
      expect(item.firstName).toBe("Pooja");
      expect(item.lastName).toBe("Vankar");
      expect(item.city).toBe("Ahmedabad");

      // Protected contact fields strictly masked
      expect(item.contactPhone).toBeNull();
      expect(item.contactEmail).toBeNull();
      expect(item.altPhone).toBeNull();
      expect(item.fatherContact).toBeNull();
      expect(item.guardianContact).toBeNull();
      expect(item.addressLine).toBeNull();
      expect(item.pincode).toBeNull();
      expect(item.user).toBeUndefined();
    });

    it("MUST sanitize searchProfiles output and omit user object and contact numbers", async () => {
      prisma.matrimonialProfile.count.mockResolvedValue(1);
      prisma.matrimonialProfile.findMany.mockResolvedValue([mockTargetProfile]);

      const result = await service.searchProfiles({ search: "Pooja" });

      expect(result.profiles).toHaveLength(1);
      const profile = result.profiles[0];

      expect(profile.fatherContact).toBeNull();
      expect(profile.guardianContact).toBeNull();
      expect(profile.addressLine).toBeNull();
      expect(profile.altPhone).toBeNull();
      expect(profile.contactEmail).toBeNull();
      expect(profile.user).toBeUndefined();
    });

    it("MUST redact personal phone numbers and home address from getFamilyDirectory", async () => {
      prisma.matrimonialProfile.findMany.mockResolvedValue([mockTargetProfile]);

      const result = await service.getFamilyDirectory("Vankar");

      expect(result).toHaveLength(1);
      const dirEntry = result[0];

      expect(dirEntry.fatherContact).toBe("");
      expect(dirEntry.guardianContact).toBe("");
      expect(dirEntry.address).toBe("Ahmedabad"); // Locality only, no street address
      expect(dirEntry.pincode).toBe("");
    });
  });

  describe("Profile Detail (getProfileById) Privacy Boundary", () => {
    it("MUST mask contact details for unauthenticated (anonymous) callers", async () => {
      prisma.matrimonialProfile.findUnique.mockResolvedValue({ ...mockTargetProfile });

      const result = await service.getProfileById("target-profile-001", undefined);

      expect(result.contactPhone).toBeNull();
      expect(result.contactEmail).toBeNull();
      expect(result.altPhone).toBeNull();
      expect(result.fatherContact).toBeNull();
      expect(result.guardianContact).toBeNull();
      expect(result.addressLine).toBeNull();
      expect(result.pincode).toBeNull();
      expect(result.user).toBeUndefined();
    });

    it("MUST fail closed when privacySettings is missing or null", async () => {
      const profileNoPrivacy = {
        ...mockTargetProfile,
        privacySettings: null,
      };
      prisma.matrimonialProfile.findUnique
        .mockResolvedValueOnce({ ...profileNoPrivacy })
        .mockResolvedValueOnce({ id: "viewer-profile-002" });
      prisma.matchInterest.findFirst.mockResolvedValue(null);

      const memberViewer = { id: "other-user-002", role: Role.USER };
      const result = await service.getProfileById("target-profile-001", memberViewer);

      expect(result.contactPhone).toBeNull();
      expect(result.contactEmail).toBeNull();
      expect(result.altPhone).toBeNull();
      expect(result.fatherContact).toBeNull();
      expect(result.guardianContact).toBeNull();
      expect(result.addressLine).toBeNull();
      expect(result.pincode).toBeNull();
      expect(result.user).toBeUndefined();
    });

    it("MUST fail closed when privacySettings is malformed or invalid JSON", async () => {
      const profileCorruptPrivacy = {
        ...mockTargetProfile,
        privacySettings: "{ corrupt_json: 123 ",
      };
      prisma.matrimonialProfile.findUnique
        .mockResolvedValueOnce({ ...profileCorruptPrivacy })
        .mockResolvedValueOnce({ id: "viewer-profile-002" });
      prisma.matchInterest.findFirst.mockResolvedValue(null);

      const memberViewer = { id: "other-user-002", role: Role.USER };
      const result = await service.getProfileById("target-profile-001", memberViewer);

      expect(result.contactPhone).toBeNull();
      expect(result.contactEmail).toBeNull();
      expect(result.fatherContact).toBeNull();
      expect(result.addressLine).toBeNull();
    });

    it("MUST expose full contact details to the Profile Owner", async () => {
      prisma.matrimonialProfile.findUnique.mockResolvedValue({ ...mockTargetProfile });

      const ownerViewer = { id: "target-user-001", role: Role.USER };
      const result = await service.getProfileById("target-profile-001", ownerViewer);

      expect(result.contactPhone).toBe("9876543210");
      expect(result.contactEmail).toBe("pooja.private@vankarsamaj.org");
      expect(result.fatherContact).toBe("9876543212");
      expect(result.addressLine).toBe("12, Shanti Nagar, Ranip");
    });

    it("MUST expose contact details to authorized Administrator roles", async () => {
      prisma.matrimonialProfile.findUnique.mockResolvedValue({ ...mockTargetProfile });

      for (const role of [Role.SUPER_ADMIN, Role.ADMIN, Role.VERIFICATION_ADMIN]) {
        const adminViewer = { id: "admin-user", role };
        const result = await service.getProfileById("target-profile-001", adminViewer);

        expect(result.contactPhone).toBe("9876543210");
        expect(result.fatherContact).toBe("9876543212");
      }
    });

    it("MUST deny contact details to CONTENT_ADMIN role", async () => {
      prisma.matrimonialProfile.findUnique
        .mockResolvedValueOnce({ ...mockTargetProfile })
        .mockResolvedValueOnce({ id: "content-admin-profile" });
      prisma.matchInterest.findFirst.mockResolvedValue(null);

      const contentAdminViewer = { id: "content-admin-01", role: Role.CONTENT_ADMIN };
      const result = await service.getProfileById("target-profile-001", contentAdminViewer);

      // CONTENT_ADMIN cannot view private personal contact details
      expect(result.contactPhone).toBeNull();
      expect(result.contactEmail).toBeNull();
      expect(result.fatherContact).toBeNull();
      expect(result.addressLine).toBeNull();
    });

    it("MUST mask contact details for authenticated member when interest is PENDING or DECLINED", async () => {
      prisma.matrimonialProfile.findUnique
        .mockResolvedValueOnce({ ...mockTargetProfile })
        .mockResolvedValueOnce({ id: "viewer-profile-002" });

      prisma.matchInterest.findFirst.mockResolvedValue(null);

      const memberViewer = { id: "other-user-002", role: Role.USER };
      const result = await service.getProfileById("target-profile-001", memberViewer);

      expect(result.contactPhone).toBeNull();
      expect(result.contactEmail).toBeNull();
      expect(result.fatherContact).toBeNull();
      expect(result.addressLine).toBeNull();

      // Guardian was set to "બધા માટે" (ALL) and viewer is authenticated
      expect(result.guardianContact).toBe("9876543213");
    });

    it("MUST disclose contact details when mutual MatchInterest is ACCEPTED", async () => {
      prisma.matrimonialProfile.findUnique
        .mockResolvedValueOnce({ ...mockTargetProfile })
        .mockResolvedValueOnce({ id: "viewer-profile-002" });

      prisma.matchInterest.findFirst.mockResolvedValue({
        id: "interest-123",
        status: "ACCEPTED",
      });

      const memberViewer = { id: "other-user-002", role: Role.USER };
      const result = await service.getProfileById("target-profile-001", memberViewer);

      expect(result.contactPhone).toBe("9876543210");
      expect(result.contactEmail).toBe("pooja.private@vankarsamaj.org");
      expect(result.fatherContact).toBe("9876543212");
      expect(result.addressLine).toBe("12, Shanti Nagar, Ranip");
    });
  });

  describe("Samaj Services Business Auto-Sync", () => {
    it("MUST auto-create a new SamajService and SamajServicePerson when a new business profile is registered", async () => {
      const businessProfile = {
        ...mockTargetProfile,
        id: "profile-biz-101",
        userId: "user-biz-101",
        occupation: "Business (વેપાર / સ્વરોજગાર)",
        businessIndustry: "Solar Energy & Renewable",
        businessService: "Solar Panel Installation",
        organizationName: "Surya Shakti Solutions",
        designation: "Managing Director",
      };

      // Service search finds nothing initially (it's new)
      prisma.samajService.findFirst.mockResolvedValue(null);
      prisma.samajService.findUnique.mockResolvedValue(null);
      prisma.samajService.create.mockResolvedValue({
        id: "srv-new-999",
        title: "Solar Panel Installation",
        slug: "solar-panel-installation",
        category: "Solar Energy & Renewable",
        icon: "💼",
      });
      prisma.samajServicePerson.findFirst.mockResolvedValue(null);
      prisma.samajServicePerson.create.mockResolvedValue({
        id: "person-new-999",
        serviceId: "srv-new-999",
        userId: "user-biz-101",
      });

      await (service as any).syncSamajServicePerson("user-biz-101", businessProfile);

      // Verify that the new SamajService was auto-created
      expect(prisma.samajService.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          title: "Solar Panel Installation",
          category: "Solar Energy & Renewable",
          isActive: true,
        }),
      });

      // Verify that the person was added under the newly created service
      expect(prisma.samajServicePerson.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          serviceId: "srv-new-999",
          userId: "user-biz-101",
          name: expect.stringContaining("Pooja Vankar"),
          phone: "9876543210",
          isActive: true,
        }),
      });
    });

    it("MUST attach to existing SamajService if matching service already exists", async () => {
      const businessProfile = {
        ...mockTargetProfile,
        id: "profile-biz-102",
        userId: "user-biz-102",
        occupation: "Business",
        businessService: "Doctor / Medical Clinic",
        businessIndustry: "Healthcare",
        organizationName: "Life Care Hospital",
        designation: "Chief Medical Officer",
      };

      // Service search finds existing service
      prisma.samajService.findFirst.mockResolvedValue({
        id: "srv-existing-123",
        title: "Doctor / Medical Clinic",
        slug: "doctor-medical-clinic",
        category: "Healthcare",
      });
      prisma.samajServicePerson.findFirst.mockResolvedValue(null);
      prisma.samajServicePerson.create.mockResolvedValue({
        id: "person-biz-102",
        serviceId: "srv-existing-123",
      });

      await (service as any).syncSamajServicePerson("user-biz-102", businessProfile);

      // Should NOT create a duplicate SamajService
      expect(prisma.samajService.create).not.toHaveBeenCalled();

      // Should attach person to existing service
      expect(prisma.samajServicePerson.create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          serviceId: "srv-existing-123",
          userId: "user-biz-102",
          name: expect.stringContaining("Pooja Vankar"),
        }),
      });
    });
  });

  describe("syncGovernmentEmployment", () => {
    it("should delete governmentEmployment record when profile is private or IT company", async () => {
      const privateProfile = {
        id: "prof-private-1",
        occupation: "Private Sector (ખાનગી નોકરી / સેકટર)",
        organizationName: "it company",
        designation: "Software Engineer",
      };

      await (service as any).syncGovernmentEmployment(privateProfile);

      expect(prisma.governmentEmployment.deleteMany).toHaveBeenCalledWith({
        where: { profileId: "prof-private-1" },
      });
      expect(prisma.governmentEmployment.create).not.toHaveBeenCalled();
    });

    it("should delete governmentEmployment record when profile is business", async () => {
      const bizProfile = {
        id: "prof-biz-1",
        occupation: "Business / Self-Employed (વ્યવસાય / સ્વરોજગાર)",
        organizationName: "Shree Trading Co",
      };

      await (service as any).syncGovernmentEmployment(bizProfile);

      expect(prisma.governmentEmployment.deleteMany).toHaveBeenCalledWith({
        where: { profileId: "prof-biz-1" },
      });
    });

    it("should create governmentEmployment record when profile is truly government", async () => {
      const govtProfile = {
        id: "prof-govt-1",
        occupation: "State Government (રાજ્ય સરકાર)",
        organizationName: "Gujarat Police",
        city: "Ahmedabad",
      };

      prisma.governmentEmployment.findUnique = jest.fn().mockResolvedValue(null);

      await (service as any).syncGovernmentEmployment(govtProfile);

      expect(prisma.governmentEmployment.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            profileId: "prof-govt-1",
          }),
        }),
      );
    });
  });
});


