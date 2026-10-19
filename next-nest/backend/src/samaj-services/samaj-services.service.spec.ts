import { Test, TestingModule } from "@nestjs/testing";
import { SamajServicesService } from "./samaj-services.service";
import { PrismaService } from "../prisma/prisma.service";

describe("SamajServicesService Business Sync & Education Services Tests", () => {
  let service: SamajServicesService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      samajService: {
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        findMany: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
      },
      samajServicePerson: {
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        findMany: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
        deleteMany: jest.fn(),
      },
      matrimonialProfile: {
        findMany: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SamajServicesService,
        {
          provide: PrismaService,
          useValue: prisma,
        },
      ],
    }).compile();

    service = module.get<SamajServicesService>(SamajServicesService);
  });

  it("MUST auto-sync VAMIKA NURSING ACADEMY into Education Services", async () => {
    prisma.samajServicePerson.findMany.mockResolvedValue([]);
    prisma.samajServicePerson.deleteMany.mockResolvedValue({ count: 0 });

    // 1. Mock finding or creating services
    prisma.samajService.findFirst
      .mockResolvedValueOnce(null) // garmentService cleanup check
      .mockResolvedValueOnce(null) // bikeService cleanup check
      .mockResolvedValueOnce(null) // eduService initially null -> will create
      .mockResolvedValueOnce(null) // tuitionService initially null -> will create
      .mockResolvedValueOnce(null); // itService initially null -> will create

    prisma.samajService.create
      .mockResolvedValueOnce({
        id: "srv-edu-001",
        title: "શિક્ષણ સેવાઓ અને એકેડેમી (Education Services)",
        category: "Education Services",
        slug: "education-services",
        isActive: true,
      })
      .mockResolvedValueOnce({
        id: "srv-tuition-001",
        title: "ટ્યુશન અને કોચિંગ ક્લાસીસ (Tuition / Coaching)",
        category: "Education Services",
        slug: "tuition-coaching-classes",
        isActive: true,
      })
      .mockResolvedValueOnce({
        id: "srv-it-001",
        title: "કમ્પ્યુટર અને આઇટી સેવાઓ (Computer & IT Services)",
        category: "કમ્પ્યુટર અને ટેકનોલોજી (IT & Computer)",
        slug: "computer-it-services",
        isActive: true,
      });

    // 2. Mock business profiles in matrimonialProfile with VAMIKA NURSING ACADEMY
    prisma.matrimonialProfile.findMany.mockResolvedValue([
      {
        id: "prof-vamika-01",
        userId: "user-vamika-01",
        firstName: "VAMIKA NURSING ACADEMY, I",
        lastName: "",
        city: "IDAR",
        nativePlace: "35 Gam Pargana",
        occupation: "Business / Self-Employed",
        businessIndustry: "Education Services",
        businessService: "Education Services",
        organizationName: "VAMIKA NURSING ACADEMY",
        user: { phone: "9265476537", email: "vamika@idar.com" },
      },
    ]);

    prisma.samajServicePerson.findFirst.mockResolvedValue(null);
    prisma.samajServicePerson.create.mockResolvedValue({
      id: "sp-vamika-created",
      serviceId: "srv-edu-001",
      userId: "user-vamika-01",
      name: "VAMIKA NURSING ACADEMY (IDAR)",
      phone: "9265476537",
    });

    await service.syncMissingBusinessProfiles();

    // Verify education service was ensured
    expect(prisma.samajService.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        category: "Education Services",
        slug: "education-services",
      }),
    });

    // Verify Vamika Nursing Academy person was created under Education Services
    expect(prisma.samajServicePerson.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        name: "VAMIKA NURSING ACADEMY (IDAR)",
        phone: "9265476537",
        city: "IDAR",
      }),
    });
  });

  it("getPublicServices MUST trigger syncMissingBusinessProfiles and return services with person counts", async () => {
    jest.spyOn(service, "syncMissingBusinessProfiles").mockResolvedValue();

    prisma.samajService.findMany.mockResolvedValue([
      {
        id: "srv-edu-001",
        title: "શિક્ષણ સેવાઓ અને એકેડેમી (Education Services)",
        category: "Education Services",
        isActive: true,
        _count: { persons: 1 },
      },
    ]);

    const res = await service.getPublicServices(undefined, "Education");
    expect(service.syncMissingBusinessProfiles).toHaveBeenCalled();
    expect(res).toHaveLength(1);
    expect(res[0].title).toContain("Education Services");
    expect(res[0]._count.persons).toBe(1);
  });

  it("getPublicPersonsByServiceId MUST return Vamika Nursing Academy when querying Education Service", async () => {
    jest.spyOn(service, "syncMissingBusinessProfiles").mockResolvedValue();

    prisma.samajServicePerson.findMany.mockResolvedValue([
      {
        id: "sp-vamika-01",
        serviceId: "srv-edu-001",
        name: "VAMIKA NURSING ACADEMY (IDAR)",
        phone: "9265476537",
        city: "IDAR",
        isActive: true,
        service: {
          id: "srv-edu-001",
          title: "Education Services",
          category: "Education Services",
          icon: "🎓",
        },
      },
    ]);

    const res = await service.getPublicPersonsByServiceId("srv-edu-001");
    expect(res).toHaveLength(1);
    expect(res[0].name).toBe("VAMIKA NURSING ACADEMY (IDAR)");
    expect(res[0].phone).toBe("9265476537");
  });
});
