import { PrismaService } from "../prisma/prisma.service";
export declare class MasterDataService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    getAllMasterData(): Promise<{
        gujaratDistricts: Record<string, string[]>;
        educationDegrees: string[];
        abroadCountries: string[];
        privateSectors: string[];
        businessSectors: string[];
        incomeRanges: string[];
        religionOptions: string[];
    }>;
}
