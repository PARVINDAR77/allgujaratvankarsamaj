import { MasterDataService } from "./master-data.service";
export declare class MasterDataController {
    private readonly masterDataService;
    constructor(masterDataService: MasterDataService);
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
