import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AiDocVerificationResult {
  final bool isApproved;
  final String? extractedName;
  final String? extractedDob;
  final String? extractedDocNumber;
  final String? uploadedUrl;
  final String? rejectionReason;
  final String message;

  const AiDocVerificationResult({
    required this.isApproved,
    this.extractedName,
    this.extractedDob,
    this.extractedDocNumber,
    this.uploadedUrl,
    this.rejectionReason,
    required this.message,
  });
}

class AiDocumentVerifier {
  /// Optional direct Gemini API key for instant on-device vision calls
  /// if backend proxy endpoint is unavailable or not yet redeployed.
  static String geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  /// Prompts candidate to fill Name and DOB first if missing (Disabled)
  static void showMissingDetailsDialog(BuildContext context) {
    // AI Missing Details dialog permanently disabled.
  }

  /// Sends document to AI verification endpoint (AI scanning permanently disabled, returns auto-approved)
  static Future<AiDocVerificationResult> verifyDocument({
    required BuildContext context,
    required Dio dio,
    required Uint8List bytes,
    required String firstName,
    required String lastName,
    required String dob,
    required String documentType,
    String? documentNumber,
    String side = 'FRONT',
  }) async {
    // AI Verification completely neutralized: instant approval with no blocking dialogs
    return const AiDocVerificationResult(
      isApproved: true,
      rejectionReason: null,
      message: 'ઓળખપત્ર સફળતાપૂર્વક અપલોડ થયું છે.',
    );
  }

  /// Direct Google Gemini Vision REST fallback
  static Future<AiDocVerificationResult> _verifyWithGeminiDirect({
    required Uint8List bytes,
    required String firstName,
    required String lastName,
    required String dob,
    required String documentType,
    String? documentNumber,
    String side = 'FRONT',
    required String apiKey,
  }) async {
    try {
      final dioDirect = Dio();
      final isFront = side.toUpperCase() == 'FRONT';
      final base64Image = base64Encode(bytes);

      final prompt = isFront
          ? 'You are an expert document verification AI specialized in Indian identification documents: Voter ID (EPIC Card), Driving License, Ayushman Bharat (PMJAY) Card, Job Card (MGNREGA / Employment ID), Government Employee Service ID, and Passport.\n'
            'Examine the attached image. Determine if it is a genuine, clear, and valid ID document matching "$documentType".\n'
            'CRITICAL: If the image is NOT an official government ID card (e.g. if it is a random photo, selfie, animal, landscape, wallpaper, meme, vehicle, furniture, food, or screenshot), you MUST set isValidDocument = false and isApproved = false.\n'
            'Extract:\n'
            '1. Full Name\n'
            '2. Date of Birth (DOB) or Year of Birth\n'
            '3. ID Number\n'
            'Compare against candidate profile:\n'
            '- Expected Name: "${firstName.trim()} ${lastName.trim()}"\n'
            '- Expected DOB: "${dob.trim()}"\n'
            'Rules:\n'
            '- Indian names often include father\'s middle name or suffixes like "bhai", "kumar", "ben", "devi". If first name and last name appear on the card, consider nameMatched = true.\n'
            '- If full date matches, or if only birth year is on card and birth year matches, consider dobMatched = true.\n'
            '- isApproved MUST be true ONLY if valid ID, nameMatched is true, and dobMatched is true.\n'
            'Return ONLY valid JSON:\n'
            '{\n'
            '  "isValidDocument": boolean,\n'
            '  "detectedDocumentType": string,\n'
            '  "extractedName": string or null,\n'
            '  "extractedDob": string or null,\n'
            '  "extractedDocNumber": string or null,\n'
            '  "nameMatched": boolean,\n'
            '  "dobMatched": boolean,\n'
            '  "isApproved": boolean,\n'
            '  "rejectionReason": string or null,\n'
            '  "gujaratiMessage": string,\n'
            '  "englishMessage": string\n'
            '}'
          : 'Examine this document image to verify if it is the genuine BACK side of "$documentType".\n'
            'Return ONLY JSON:\n'
            '{\n'
            '  "isValidDocument": boolean,\n'
            '  "detectedDocumentType": string,\n'
            '  "extractedName": null,\n'
            '  "extractedDob": null,\n'
            '  "nameMatched": true,\n'
            '  "dobMatched": true,\n'
            '  "isApproved": boolean,\n'
            '  "rejectionReason": null,\n'
            '  "gujaratiMessage": "પાછળનો ભાગ ચકાસાયેલ છે",\n'
            '  "englishMessage": "Back side verified"\n'
            '}';

      final res = await dioDirect.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inlineData': {
                    'mimeType': 'image/jpeg',
                    'data': base64Image,
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'temperature': 0.1,
          }
        },
      );

      final text = res.data['candidates'][0]['content']['parts'][0]['text'] as String;
      final parsed = jsonDecode(text) as Map<String, dynamic>;

      return AiDocVerificationResult(
        isApproved: parsed['isApproved'] == true,
        extractedName: parsed['extractedName'] as String?,
        extractedDob: parsed['extractedDob'] as String?,
        extractedDocNumber: parsed['extractedDocNumber'] as String?,
        rejectionReason: parsed['rejectionReason'] as String?,
        message: (parsed['gujaratiMessage'] ?? parsed['englishMessage'] ?? 'ચકાસણી પૂર્ણ') as String,
      );
    } catch (e) {
      return AiDocVerificationResult(
        isApproved: false,
        rejectionReason: 'GEMINI_DIRECT_ERROR',
        message: 'Google Gemini સીધી ચકાસણીમાં ખામી: $e',
      );
    }
  }

  /// Displays detailed explanation why the document was rejected and prevents attachment
  static void showRejectionDialog({
    required BuildContext context,
    required AiDocVerificationResult result,
    required String expectedName,
    required String expectedDob,
    required String documentType,
  }) {
    // AI Document Rejection Dialog permanently disabled.
  }
}
