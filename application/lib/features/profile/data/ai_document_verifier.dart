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

  /// Prompts candidate to fill Name and DOB first if missing
  static void showMissingDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF041126),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFFD4AF37), size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'વિગતો જરૂરી છે (Details Required)',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'AI દ્વારા ઓળખપત્ર આપમેળે ચકાસવા માટે કૃપા કરીને પહેલા તમારું "પ્રથમ નામ", "અટક" અને "જન્મ તારીખ" ભરો.\n\n(Please enter your First Name, Last Name, and Date of Birth first so AI can cross-verify your document.)',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('સમજાયું (OK)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Sends document to AI verification endpoint with a scanning dialog overlay
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
    final isFront = side.toUpperCase() == 'FRONT';

    // Show scanning progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: const Color(0xFF041126),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'AI ઓળખપત્ર ચકાસણી...',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '(AI Document Verification in Progress)',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 14),
                Text(
                  isFront
                      ? 'દસ્તાવેજ પરથી નામ ($firstName $lastName) અને જન્મ તારીખ ($dob) ચકાસાઈ રહી છે...'
                      : 'ઓળખપત્રના પાછળના ભાગની ચકાસણી થઈ રહી છે...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: 'doc_${side.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'dob': dob.trim(),
        'documentType': documentType.trim(),
        'documentNumber': (documentNumber ?? '').trim(),
        'side': side.toUpperCase(),
      });

      final response = await dio.post(
        '/verifications/ai-verify',
        data: formData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Close scanning dialog safely
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      final data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data is Map) {
          final verified = data['verified'] == true || data['success'] == true;
          final resObj = data['result'] is Map ? data['result'] as Map : null;
          final extractedName = (resObj?['extractedName'] ?? data['extractedName']) as String?;
          final extractedDob = (resObj?['extractedDob'] ?? data['extractedDob']) as String?;
          final extractedDocNum = (resObj?['extractedDocNumber'] ?? data['extractedDocNumber']) as String?;
          final uploadedUrl = data['url'] as String?;
          final reason = (data['reason'] ?? resObj?['rejectionReason']) as String?;
          final message = (data['message'] ?? resObj?['gujaratiMessage'] ?? resObj?['englishMessage'] ?? 'ચકાસણી પૂર્ણ') as String;

          return AiDocVerificationResult(
            isApproved: verified,
            extractedName: extractedName,
            extractedDob: extractedDob,
            extractedDocNumber: extractedDocNum,
            uploadedUrl: uploadedUrl,
            rejectionReason: reason,
            message: message,
          );
        }
      }

      // If backend returned 404 or non-200 (e.g. backend not deployed on hostinger yet),
      // attempt direct Gemini Vision REST call if key is available
      if (geminiApiKey.trim().isNotEmpty) {
        return await _verifyWithGeminiDirect(
          bytes: bytes,
          firstName: firstName,
          lastName: lastName,
          dob: dob,
          documentType: documentType,
          documentNumber: documentNumber,
          side: side,
          apiKey: geminiApiKey.trim(),
        );
      }

      // Default safe rejection when AI endpoint is not reachable
      return const AiDocVerificationResult(
        isApproved: false,
        rejectionReason: 'ENDPOINT_UNAVAILABLE',
        message: 'સર્વર પર AI ચકાસણી સર્વિસ ઉપલબ્ધ નથી અથવા ઍન્ડપોઇન્ટ મળ્યો નથી (AI service unavailable). કૃપા કરીને સાચો દસ્તાવેજ અપલોડ કરો.',
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      return AiDocVerificationResult(
        isApproved: false,
        rejectionReason: 'NETWORK_ERROR',
        message: 'દસ્તાવેજ ચકાસણી દરમિયાન નેટવર્ક ખામી સર્જાઈ: $e',
      );
    }
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
          ? 'You are an expert document verification AI specialized in Indian identification documents (Aadhaar Card, PAN Card, Voter ID, Driving License, Passport).\n'
            'Examine the attached image. Determine if it is a genuine, clear, and valid ID document matching "$documentType".\n'
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF041126),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.gpp_bad_rounded, color: Colors.redAccent, size: 26),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'ઓળખપત્ર અસ્વીકાર્ય (Verification Failed)',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.message,
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'વિગતોની સરખામણી (Comparison):',
                      style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• દસ્તાવેજ પર નામ: ${result.extractedName ?? "અજ્ઞાત / ઓળખાયું નથી"}',
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                    ),
                    Text(
                      '• પ્રોફાઇલ નામ: $expectedName',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• દસ્તાવેજ પર જન્મ તારીખ: ${result.extractedDob ?? "અજ્ઞાત / ઓળખાઈ નથી"}',
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                    ),
                    Text(
                      '• પ્રોફાઇલ જન્મ તારીખ: $expectedDob',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'સુરક્ષા અને અધિકૃતતા માટે આ દસ્તાવેજ જોડવામાં આવ્યો નથી. કૃપા કરીને તમારું પોતાનું સાચું ઓળખપત્ર અપલોડ કરો.',
                        style: TextStyle(color: Colors.redAccent, fontSize: 11, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ફરી પ્રયાસ કરો (Try Again)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
