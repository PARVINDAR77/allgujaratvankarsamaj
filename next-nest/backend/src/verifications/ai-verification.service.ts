import { Injectable, Logger } from "@nestjs/common";
let GoogleGenerativeAIClass: any = null;
try {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const genAiModule = require("@google/generative-ai");
  GoogleGenerativeAIClass = genAiModule?.GoogleGenerativeAI || null;
} catch (_err) {
  GoogleGenerativeAIClass = null;
}

export interface AiVerifyDocOptions {
  fileBuffer: Buffer;
  mimetype: string;
  expectedFirstName: string;
  expectedLastName: string;
  expectedDob: string; // YYYY-MM-DD
  documentType: string; // e.g. "Voter ID Card", "Driving License", "Govt Job Card / Service ID", "Passport"
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

@Injectable()
export class AiVerificationService {
  private readonly logger = new Logger(AiVerificationService.name);
  private genAI: any = null;

  constructor() {
    const apiKey = process.env.GEMINI_API_KEY?.trim();
    if (apiKey && apiKey.length > 5 && GoogleGenerativeAIClass) {
      this.genAI = new GoogleGenerativeAIClass(apiKey);
      this.logger.log("Google Gemini AI client initialized for document verification.");
    } else {
      if (!GoogleGenerativeAIClass) {
        this.logger.warn("@google/generative-ai is not installed. Running AI document verification in safe fallback mode.");
      } else {
        this.logger.warn("GEMINI_API_KEY is not set in environment or .env. Running AI document verification in development fallback mode.");
      }
    }
  }

  /**
   * Main entry point to verify document image against expected candidate data.
   */
  async verifyDocument(options: AiVerifyDocOptions): Promise<AiVerificationResult> {
    const {
      fileBuffer,
      mimetype,
      expectedFirstName,
      expectedLastName,
      expectedDob,
      documentType,
      documentNumber,
      side,
    } = options;

    if (!fileBuffer || fileBuffer.length === 0) {
      return {
        isValidDocument: false,
        detectedDocumentType: "UNKNOWN",
        extractedName: null,
        extractedDob: null,
        extractedDocNumber: null,
        nameMatched: false,
        dobMatched: false,
        confidence: 0,
        isApproved: false,
        rejectionReason: "EMPTY_FILE",
        englishMessage: "No document image was provided.",
        gujaratiMessage: "કોઈ દસ્તાવેજનો ફોટો મળ્યો નથી. કૃપા કરીને ફોટો અપલોડ કરો.",
      };
    }

    // If Gemini API is available, use live multimodal vision analysis
    if (this.genAI) {
      try {
        return await this.verifyWithGemini(options);
      } catch (err: any) {
        this.logger.error(`Gemini AI document verification error: ${err.message}`, err.stack);
        // Fall back to rule-based evaluation if API call fails
      }
    }

    // Fallback mode when GEMINI_API_KEY is not configured or network call fails
    return this.fallbackVerification(options);
  }

  /**
   * Calls Google Gemini Vision API to inspect document image
   */
  private async verifyWithGemini(options: AiVerifyDocOptions): Promise<AiVerificationResult> {
    const {
      fileBuffer,
      mimetype,
      expectedFirstName,
      expectedLastName,
      expectedDob,
      documentType,
      documentNumber,
      side,
    } = options;

    // Use gemini-1.5-flash for ultra-fast, accurate multimodal recognition
    const model = this.genAI!.getGenerativeModel({
      model: "gemini-1.5-flash",
      generationConfig: {
        responseMimeType: "application/json",
        temperature: 0.1,
      },
    });

    const isFront = side === "FRONT";

    const prompt = isFront
      ? `You are an expert document verification AI specialized in Indian identification documents: Voter ID / EPIC Card, Driving License, Government Employee Job Card / Service ID, and Passport.

Task:
1. Examine the attached document image thoroughly.
2. Determine if it is a genuine, clear, and valid identification document matching the requested document type: "${documentType}".
   - CRITICAL: If the image is NOT an official government ID card (such as a random photo, selfie, personal portrait, animal, landscape, wallpaper, meme, vehicle, furniture, food, or screenshot of something unrelated), you MUST mark isValidDocument as false, isApproved as false, and rejectionReason as "INVALID_DOCUMENT". Under NO circumstances should any random or non-ID image be approved.
   - If the image is blurry, unreadable, obscured, or corrupted, mark isValidDocument as false.
3. Extract the following details:
   - Full Name (in English and/or Gujarati / Hindi if printed).
   - Date of Birth (DOB) or Year of Birth (YOB).
   - Document ID Number (e.g. 10-char Voter ID/EPIC No, DL No, Employee ID, or Passport No).
4. Compare extracted details with the expected candidate details:
   - Expected First Name: "${expectedFirstName.trim()}"
   - Expected Last Name: "${expectedLastName.trim()}"
   - Expected Date of Birth: "${expectedDob.trim()}" (Format: YYYY-MM-DD)
   - Expected Document Number: "${(documentNumber || "").trim()}"

Comparison Guidelines:
- Name Matching:
  * In Indian documents, a candidate's full name often includes father's name as a middle name (e.g., "Ramesh Arvindbhai Vankar" for candidate "Ramesh Vankar").
  * Common honorifics and suffixes may be attached ("bhai", "kumar", "ben", "devi", "lal", "prasad", "shree").
  * Word order may be "FirstName LastName" or "LastName FirstName" or "LastName FirstName MiddleName".
  * If the candidate's first name and last name both clearly appear in the extracted document name, consider nameMatched = true.
  * Allow minor transliteration differences between Gujarati and English (e.g., "Vankar" vs "Vankaar", "Patel" vs "Pateel").
- Date of Birth Matching:
  * If full DOB is visible (e.g., 15/05/1995 or 1995-05-15), compare day, month, and year against "${expectedDob}".
  * If the document only shows Year of Birth (e.g., "Year of Birth: 1995"), check if the birth year matches the year in "${expectedDob}". If the birth year matches, consider dobMatched = true.
- Approval Condition:
  * isApproved MUST be true ONLY IF isValidDocument is true AND nameMatched is true AND dobMatched is true.
  * If name does not match, set isApproved = false, rejectionReason = "NAME_MISMATCH".
  * If DOB does not match, set isApproved = false, rejectionReason = "DOB_MISMATCH".
  * If document is invalid/unreadable/blurry/random-photo, set isApproved = false, rejectionReason = "INVALID_DOCUMENT".

Return ONLY JSON matching this exact structure:
{
  "isValidDocument": boolean,
  "detectedDocumentType": string,
  "extractedName": string or null,
  "extractedDob": string or null,
  "extractedDocNumber": string or null,
  "nameMatched": boolean,
  "dobMatched": boolean,
  "confidence": number,
  "isApproved": boolean,
  "rejectionReason": string or null,
  "englishMessage": string,
  "gujaratiMessage": string
}`
      : `You are an expert document verification AI specialized in Indian identification documents (Voter ID, Driving License, Govt Employee Job Card, Passport).

Task:
1. Examine the attached document image to determine if it is the genuine BACK side of the requested document type: "${documentType}".
2. Check for typical features of the back of this document:
   - Voter ID Back: electoral registration officer details, assembly constituency, address.
   - Driving License Back: vehicle category endorsements, issuing authority, address.
   - Govt Job Card Back: department instructions, emergency contact, issuing authority seal/signature.
   - Passport Back: parents' names, address, file number, barcode.
   - CRITICAL: If the image is a selfie, random photo, animal, landscape, wallpaper, or non-ID image, mark isValidDocument as false and isApproved as false.
3. Determine if the image is clear and valid.

Return ONLY JSON matching this exact structure:
{
  "isValidDocument": boolean,
  "detectedDocumentType": string,
  "extractedName": null,
  "extractedDob": null,
  "extractedDocNumber": string or null,
  "nameMatched": true,
  "dobMatched": true,
  "confidence": number,
  "isApproved": boolean,
  "rejectionReason": string or null,
  "englishMessage": string,
  "gujaratiMessage": string
}`;
  

    const normalizedMime = ["image/jpeg", "image/png", "image/webp"].includes(mimetype.toLowerCase())
      ? mimetype.toLowerCase()
      : "image/jpeg";

    const imagePart = {
      inlineData: {
        data: fileBuffer.toString("base64"),
        mimeType: normalizedMime,
      },
    };

    const response = await model.generateContent([prompt, imagePart]);
    const responseText = response.response.text();
    this.logger.debug(`Gemini response: ${responseText}`);

    let parsed: any;
    try {
      parsed = JSON.parse(responseText);
    } catch (parseErr) {
      // Clean possible markdown code fences if present
      const cleaned = responseText.replace(/```(?:json)?/g, "").trim();
      parsed = JSON.parse(cleaned);
    }

    // Run programmatic secondary checks on parsed result
    const isDocValid = parsed.isValidDocument === true;
    const extName = parsed.extractedName || null;
    const extDob = parsed.extractedDob || null;
    const extDocNum = parsed.extractedDocNumber || null;

    let nameMatched = parsed.nameMatched === true;
    let dobMatched = parsed.dobMatched === true;

    if (isFront && isDocValid && extName) {
      // Double check name match using our algorithm
      const programmaticNameMatch = this.checkNameMatch(expectedFirstName, expectedLastName, extName);
      nameMatched = nameMatched || programmaticNameMatch;
    }

    if (isFront && isDocValid && extDob) {
      const programmaticDobMatch = this.checkDobMatch(expectedDob, extDob);
      dobMatched = dobMatched || programmaticDobMatch;
    }

    let isApproved = isFront
      ? (isDocValid && nameMatched && dobMatched)
      : (isDocValid && parsed.isApproved !== false);

    let rejectionReason = parsed.rejectionReason || null;
    let englishMsg = parsed.englishMessage || "";
    let gujaratiMsg = parsed.gujaratiMessage || "";

    if (!isDocValid) {
      isApproved = false;
      rejectionReason = "INVALID_DOCUMENT";
      englishMsg = "Uploaded photo is not a clear or valid ID proof document. Please upload a clear photo of your original ID.";
      gujaratiMsg = "અપલોડ કરેલો ફોટો માન્ય અથવા સ્પષ્ટ ઓળખપત્ર નથી. કૃપા કરીને તમારા અસલ ઓળખપત્રનો સ્પષ્ટ ફોટો અપલોડ કરો.";
    } else if (isFront && !nameMatched) {
      isApproved = false;
      rejectionReason = "NAME_MISMATCH";
      englishMsg = `The name on the document (${extName || "Unknown"}) does not match your profile name (${expectedFirstName} ${expectedLastName}). Please upload your own document.`;
      gujaratiMsg = `દસ્તાવેજ પરનું નામ (${extName || "અજ્ઞાત"}) તમારી પ્રોફાઇલના નામ (${expectedFirstName} ${expectedLastName}) સાથે મેળ ખાતું નથી. કૃપા કરીને તમારું પોતાનું સાચું ઓળખપત્ર અપલોડ કરો.`;
    } else if (isFront && !dobMatched) {
      isApproved = false;
      rejectionReason = "DOB_MISMATCH";
      englishMsg = `The Date of Birth on the document (${extDob || "Unknown"}) does not match your profile Date of Birth (${expectedDob}). Please upload the correct document.`;
      gujaratiMsg = `દસ્તાવેજ પરની જન્મ તારીખ (${extDob || "અજ્ઞાત"}) તમારી પ્રોફાઇલમાં આપેલી જન્મ તારીખ (${expectedDob}) સાથે મેળ ખાતી નથી. કૃપા કરીને સાચું ઓળખપત્ર અપલોડ કરો.`;
    } else if (isApproved) {
      englishMsg = isFront
        ? "AI Verification Successful! Name and Date of Birth have been verified from the document."
        : "AI Verification Successful! Document back side verified.";
      gujaratiMsg = isFront
        ? "AI ચકાસણી સફળ! દસ્તાવેજ પરથી નામ અને જન્મ તારીખ ચકાસાઈ ગઈ છે."
        : "AI ચકાસણી સફળ! ઓળખપત્રનો પાછળનો ભાગ સફળતાપૂર્વક ચકાસાયો છે.";
    }

    return {
      isValidDocument: isDocValid,
      detectedDocumentType: parsed.detectedDocumentType || documentType,
      extractedName: extName,
      extractedDob: extDob,
      extractedDocNumber: extDocNum,
      nameMatched,
      dobMatched,
      confidence: typeof parsed.confidence === "number" ? parsed.confidence : 0.95,
      isApproved,
      rejectionReason,
      englishMessage: englishMsg,
      gujaratiMessage: gujaratiMsg,
    };
  }

  /**
   * Programmatic matching for Indian Names
   * Checks if candidate's first and last names appear in the extracted document name.
   */
  public checkNameMatch(candidateFirst: string, candidateLast: string, docName: string): boolean {
    if (!docName || docName.trim().length === 0) return false;

    const cleanCandidateFirst = this.normalizeName(candidateFirst);
    const cleanCandidateLast = this.normalizeName(candidateLast);
    const cleanDoc = this.normalizeName(docName);

    if (cleanDoc.length === 0) return false;

    // Check direct substring inclusion
    const firstMatched = cleanCandidateFirst.length > 0 && (
      cleanDoc.includes(cleanCandidateFirst) ||
      this.hasTokenSimilarity(cleanCandidateFirst, cleanDoc)
    );
    const lastMatched = cleanCandidateLast.length > 0 && (
      cleanDoc.includes(cleanCandidateLast) ||
      this.hasTokenSimilarity(cleanCandidateLast, cleanDoc)
    );

    return firstMatched && lastMatched;
  }

  /**
   * Programmatic matching for Date of Birth
   * Handles YYYY-MM-DD, DD/MM/YYYY, DD-MM-YYYY, or YYYY (Year of Birth)
   */
  public checkDobMatch(candidateDob: string, docDob: string): boolean {
    if (!candidateDob || !docDob) return false;

    const candDigits = candidateDob.replace(/\D/g, "");
    const docDigits = docDob.replace(/\D/g, "");

    // Extract year from candidate (e.g. 1995 from 1995-05-15)
    let candYear = "";
    const candMatch = candidateDob.match(/(\d{4})/);
    if (candMatch) candYear = candMatch[1];

    let docYear = "";
    const docMatch = docDob.match(/(\d{4})/);
    if (docMatch) docYear = docMatch[1];

    // If years don't match, return false
    if (candYear.length === 4 && docYear.length === 4 && candYear !== docYear) {
      return false;
    }

    // If doc only specifies year (e.g. "Year of Birth: 1995")
    if (docDigits.length === 4 && candYear === docDigits) {
      return true;
    }

    // Check full date matching
    const candParts = candidateDob.split(/[-/]/);
    const docParts = docDob.split(/[-/]/);

    if (candParts.length === 3 && docParts.length === 3) {
      // Find candidate year, month, day
      let cy = "", cm = "", cd = "";
      if (candParts[0].length === 4) {
        cy = candParts[0]; cm = candParts[1].padStart(2, "0"); cd = candParts[2].padStart(2, "0");
      } else {
        cd = candParts[0].padStart(2, "0"); cm = candParts[1].padStart(2, "0"); cy = candParts[2];
      }

      let dy = "", dm = "", dd = "";
      if (docParts[0].length === 4) {
        dy = docParts[0]; dm = docParts[1].padStart(2, "0"); dd = docParts[2].padStart(2, "0");
      } else {
        dd = docParts[0].padStart(2, "0"); dm = docParts[1].padStart(2, "0"); dy = docParts[2];
      }

      if (cy === dy && cm === dm && cd === dd) return true;
      // Allow day/month swap if valid (e.g. US vs UK date format)
      if (cy === dy && cm === dd && cd === dm) return true;
    }

    // Default to birth year match if year matches
    return candYear.length === 4 && docYear.length === 4 && candYear === docYear;
  }

  /**
   * Normalizes names by stripping whitespace, punctuation, and common Indian honorifics.
   */
  private normalizeName(name: string): string {
    return name
      .toLowerCase()
      .replace(/[\.,\/#!$%\^&\*;:{}=\-_`~()]/g, " ")
      .replace(/\s+/g, " ")
      .trim();
  }

  /**
   * Checks if any word token in the target text matches the search token with high similarity.
   */
  private hasTokenSimilarity(searchToken: string, targetText: string): boolean {
    const tokens = targetText.split(/\s+/);
    // Strip common honorific suffixes for comparison
    const baseSearch = searchToken.replace(/(?:bhai|kumar|ben|devi|lal|prasad)$/i, "");

    for (const token of tokens) {
      const baseToken = token.replace(/(?:bhai|kumar|ben|devi|lal|prasad)$/i, "");
      if (baseToken === baseSearch || token === searchToken) return true;
      if (baseSearch.length >= 4 && baseToken.startsWith(baseSearch)) return true;
      if (baseToken.length >= 4 && baseSearch.startsWith(baseToken)) return true;
    }
    return false;
  }

  /**
   * Graceful fallback when GEMINI_API_KEY is not configured in local development.
   */
  private fallbackVerification(options: AiVerifyDocOptions): AiVerificationResult {
    const { documentType, side } = options;
    const isFront = side === "FRONT";

    this.logger.warn(
      `Running AI Document Verification in fallback mode for ${documentType} (${side}). Live Gemini vision is unavailable or image cannot be automatically approved.`,
    );

    return {
      isValidDocument: false,
      detectedDocumentType: "UNKNOWN",
      extractedName: null,
      extractedDob: null,
      extractedDocNumber: options.documentNumber || null,
      nameMatched: false,
      dobMatched: false,
      confidence: 0.0,
      isApproved: false,
      rejectionReason: "MANUAL_ADMIN_REVIEW_REQUIRED",
      englishMessage: isFront
        ? "This image could not be verified as a valid ID document (Voter ID, Driving License, or Govt Job Card). A genuine government ID must be uploaded for verification."
        : "The back side of this document could not be verified as a valid government ID. Please upload a clear photo of the ID back side.",
      gujaratiMessage: isFront
        ? "આ ફોટો માન્ય સરકારી ઓળખપત્ર (ચૂંટણી કાર્ડ, ડ્રાઇવિંગ લાયસન્સ અથવા સરકારી જોબ કાર્ડ) તરીકે ઓળખાયો નથી. કૃપા કરીને અસલ ઓળખપત્રનો સ્પષ્ટ ફોટો અપલોડ કરો."
        : "આ ફોટો ઓળખપત્રના પાછળના ભાગ તરીકે ઓળખાયો નથી. કૃપા કરીને ઓળખપત્રના પાછળના ભાગનો સ્પષ્ટ ફોટો અપલોડ કરો.",
    };
  }
}

