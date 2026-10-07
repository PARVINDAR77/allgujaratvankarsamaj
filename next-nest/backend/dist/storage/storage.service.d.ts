export declare class StorageService {
    private readonly logger;
    private readonly uploadDir;
    uploadFile(fileBuffer: Buffer, mimetype: string, originalName: string): Promise<string>;
    deleteFile(fileUrl: string): Promise<void>;
}
