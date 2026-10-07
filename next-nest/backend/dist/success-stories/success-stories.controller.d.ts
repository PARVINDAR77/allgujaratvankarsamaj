import { SuccessStoriesService } from "./success-stories.service";
import { CreateSuccessStoryDto } from "./dto/create-success-story.dto";
import { UpdateSuccessStoryDto } from "./dto/update-success-story.dto";
export declare class SuccessStoriesController {
    private readonly successStoriesService;
    constructor(successStoriesService: SuccessStoriesService);
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
    create(req: any, createSuccessStoryDto: CreateSuccessStoryDto): Promise<{
        id: string;
        createdAt: Date;
        imageUrl: string | null;
        brideName: string;
        groomName: string;
        weddingDate: string | null;
        story: string;
        isPublished: boolean;
    }>;
    update(req: any, id: string, updateSuccessStoryDto: UpdateSuccessStoryDto): Promise<{
        id: string;
        createdAt: Date;
        imageUrl: string | null;
        brideName: string;
        groomName: string;
        weddingDate: string | null;
        story: string;
        isPublished: boolean;
    }>;
    remove(req: any, id: string): Promise<{
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
