export declare class StorageService {
    private readonly logger;
    private readonly uploadDir;
    private readonly privateUploadDir;
    uploadPublicMedia(fileBuffer: Buffer, mimetype: string, originalName: string): Promise<string>;
    uploadVerificationDocument(fileBuffer: Buffer, mimetype: string, originalName: string): Promise<string>;
    uploadFile(fileBuffer: Buffer, mimetype: string, originalName: string, isPrivate?: boolean): Promise<string>;
    deleteFile(fileUrl: string): Promise<void>;
}
