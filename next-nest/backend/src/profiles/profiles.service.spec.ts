import { Test, TestingModule } from "@nestjs/testing";
import { ProfilesService } from "./profiles.service";
import { PrismaService } from "../prisma/prisma.service";
import { Gender, MaritalStatus, MatrimonialProfile } from "@prisma/client";

describe("ProfilesService Completeness Calculation", () => {
  let service: ProfilesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProfilesService,
        {
          provide: PrismaService,
          useValue: {
            matrimonialProfile: {
              findUnique: jest.fn(),
            },
          },
        },
      ],
    }).compile();

    service = module.get<ProfilesService>(ProfilesService);
  });

  it("should return 0 completed fields and 0% for a null profile", () => {
    const result = service.calculateCompleteness(null);
    expect(result).toEqual({
      completedFields: 0,
      totalFields: 13,
      percentage: 0,
      isComplete: false,
    });
  });

  it("should calculate exact completion stats for a partial profile (5 / 13 = 38%)", () => {
    const partialProfile: Partial<MatrimonialProfile> = {
      firstName: "Ramesh",
      lastName: "Parmar",
      dateOfBirth: new Date("1995-08-15"),
      gender: Gender.MALE,
      maritalStatus: MaritalStatus.NEVER_MARRIED,
      religion: null,
      caste: null,
      city: null,
      state: null,
      country: null,
      education: null,
      occupation: null,
      about: null,
    };

    const result = service.calculateCompleteness(
      partialProfile as MatrimonialProfile,
    );
    expect(result.completedFields).toBe(5);
    expect(result.totalFields).toBe(13);
    expect(result.percentage).toBe(38);
    expect(result.isComplete).toBe(false);
  });

  it("should calculate 100% and isComplete true for a fully populated profile", () => {
    const fullProfile: Partial<MatrimonialProfile> = {
      firstName: "Ramesh",
      lastName: "Parmar",
      dateOfBirth: new Date("1995-08-15"),
      gender: Gender.MALE,
      maritalStatus: MaritalStatus.NEVER_MARRIED,
      religion: "Hindu",
      caste: "Vankar",
      city: "Ahmedabad",
      state: "Gujarat",
      country: "India",
      education: "B.Tech IT",
      occupation: "Software Developer",
      about: "Family oriented",
    };

    const result = service.calculateCompleteness(
      fullProfile as MatrimonialProfile,
    );
    expect(result.completedFields).toBe(13);
    expect(result.totalFields).toBe(13);
    expect(result.percentage).toBe(100);
    expect(result.isComplete).toBe(true);
  });
});
