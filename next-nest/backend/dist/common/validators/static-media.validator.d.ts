export interface StaticMediaValidationResult {
    allowed: boolean;
    reason?: string;
    sanitizedPath?: string;
}
export declare const MAX_STATIC_MEDIA_PATH_LENGTH = 512;
export declare function isAllowedStaticMediaPath(rawPath: string): StaticMediaValidationResult;
