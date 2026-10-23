import { PrismaService } from "../prisma/prisma.service";
export declare class SamajSuperStarsService {
    private prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    findAllAdmin(): Promise<any>;
    findAllPublic(): Promise<any>;
    create(data: any): Promise<any>;
    update(id: string, data: any): Promise<any>;
    remove(id: string): Promise<any>;
}
