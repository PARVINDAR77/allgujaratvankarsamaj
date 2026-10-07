import { AdPlacement } from "@prisma/client";
export declare class CreateAdvertisementDto {
    title: string;
    imageUrl: string;
    targetUrl?: string;
    placement?: AdPlacement;
    isActive?: boolean;
    startAt?: string;
    endAt?: string;
    sortOrder?: number;
}
