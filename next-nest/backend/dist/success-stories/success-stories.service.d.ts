import { PrismaService } from "../prisma/prisma.service";
import { CreateSuccessStoryDto } from "./dto/create-success-story.dto";
import { UpdateSuccessStoryDto } from "./dto/update-success-story.dto";
export declare class SuccessStoriesService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    create(createSuccessStoryDto: CreateSuccessStoryDto, adminId: string): Promise<{
        id: string;
        createdAt: Date;
        imageUrl: string | null;
        brideName: string;
        groomName: string;
        weddingDate: string | null;
        story: string;
        isPublished: boolean;
    }>;
    findAllPublic(): Promise<{
        id: string;
        createdAt: Date;
        imageUrl: string | null;
        brideName: string;
        groomName: string;
        weddingDate: string | null;
        story: string;
        isPublished: boolean;
    }[]>;
    findAllAdmin(): Promise<{
        id: string;
        createdAt: Date;
        imageUrl: string | null;
        brideName: string;
        groomName: string;
        weddingDate: string | null;
        story: string;
        isPublished: boolean;
    }[]>;
    findOne(id: string): Promise<{
        id: string;
        createdAt: Date;
        imageUrl: string | null;
        brideName: string;
        groomName: string;
        weddingDate: string | null;
        story: string;
        isPublished: boolean;
    }>;
    update(id: string, updateSuccessStoryDto: UpdateSuccessStoryDto, adminId: string): Promise<{
        id: string;
        createdAt: Date;
        imageUrl: string | null;
        brideName: string;
        groomName: string;
        weddingDate: string | null;
        story: string;
        isPublished: boolean;
    }>;
    remove(id: string, adminId: string): Promise<{
        id: string;
        createdAt: Date;
        imageUrl: string | null;
        brideName: string;
        groomName: string;
        weddingDate: string | null;
        story: string;
        isPublished: boolean;
    }>;
}
