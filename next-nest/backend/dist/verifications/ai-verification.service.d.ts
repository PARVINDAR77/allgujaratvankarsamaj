export interface AiVerifyDocOptions {
    fileBuffer: Buffer;
    mimetype: string;
    expectedFirstName: string;
    expectedLastName: string;
    expectedDob: string;
    documentType: string;
    documentNumber?: string;
    side: "FRONT" | "BACK";
}
export interface AiVerificationResult {
    isValidDocument: boolean;
    detectedDocumentType: string;
    extractedName: string | null;
    extractedDob: string | null;
    extractedDocNumber: string | null;
    nameMatched: boolean;
    dobMatched: boolean;
    confidence: number;
    isApproved: boolean;
    rejectionReason: string | null;
    englishMessage: string;
    gujaratiMessage: string;
}
export declare class AiVerificationService {
    private readonly logger;
    private genAI;
    constructor();
    verifyDocument(options: AiVerifyDocOptions): Promise<AiVerificationResult>;
    private verifyWithGemini;
    checkNameMatch(candidateFirst: string, candidateLast: string, docName: string): boolean;
    checkDobMatch(candidateDob: string, docDob: string): boolean;
    private normalizeName;
    private hasTokenSimilarity;
    private fallbackVerification;
}
