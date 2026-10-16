import { Test, TestingModule } from "@nestjs/testing";
import { MasterDataService } from "./master-data.service";
import { PrismaService } from "../prisma/prisma.service";

describe("MasterDataService", () => {
  let service: MasterDataService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MasterDataService,
        {
          provide: PrismaService,
          useValue: {
            state: { findMany: jest.fn() },
          },
        },
      ],
    }).compile();

    service = module.get<MasterDataService>(MasterDataService);
  });

  it("should be defined", () => {
    expect(service).toBeDefined();
  });
});
