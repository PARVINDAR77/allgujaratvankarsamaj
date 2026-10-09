import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../verifications/providers/verifications_provider.dart';

class VerifiedProfileScreen extends ConsumerStatefulWidget {
  const VerifiedProfileScreen({super.key});

  @override
  ConsumerState<VerifiedProfileScreen> createState() =>
      _VerifiedProfileScreenState();
}

class _VerifiedProfileScreenState
    extends ConsumerState<VerifiedProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _documentType = 'Aadhar Card';
  final _docUrlController = TextEditingController();
  bool _isUploadingFile = false;

  static const _documentTypes = [
    'Aadhar Card',
    'PAN Card',
    'Driving License',
    'Passport',
    'Voter ID',
    'Government ID',
  ];

  @override
  void dispose() {
    _docUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadDocument() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image == null) return;

      setState(() => _isUploadingFile = true);

      final dio = ref.read(apiClientProvider);
      final bytes = await image.readAsBytes();
      String? rawUrl;

      // Strategy 1: Base64 JSON upload
      try {
        final base64String = base64Encode(bytes);
        final response = await dio.post(
          '/storage/upload',
          data: {
            'base64': base64String,
            'filename': image.name,
            'mimetype': image.mimeType ?? 'image/jpeg',
          },
        );
        if (response.data != null && response.data['url'] != null) {
          rawUrl = response.data['url'] as String;
        }
      } catch (b64Err) {
        debugPrint('Base64 doc upload error: $b64Err');
      }

      // Strategy 2: Multipart fallback
      if (rawUrl == null) {
        try {
          final formData = FormData.fromMap({
            'file': MultipartFile.fromBytes(bytes, filename: image.name),
          });
          final response = await dio.post('/storage/upload', data: formData);
          if (response.data != null && response.data['url'] != null) {
            rawUrl = response.data['url'] as String;
          }
        } catch (multiErr) {
          debugPrint('Multipart doc upload error: $multiErr');
        }
      }

      if (rawUrl != null) {
        final fullUrl = rawUrl.startsWith('http')
            ? rawUrl
            : 'https://allgujaratvankarsamaj.com$rawUrl';
        setState(() {
          _docUrlController.text = fullUrl;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('દસ્તાવેજ અપલોડ થયો! હવે સબમિટ કરો. (Document uploaded!)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('અપલોડ નિષ્ફળ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingFile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myProfileAsync = ref.watch(myProfileProvider);
    final submitState = ref.watch(verificationSubmitProvider);

    // After successful submit, refresh profile and redirect to under review screen
    ref.listen(verificationSubmitProvider, (_, next) {
      if (next.isSuccess) {
        ref.invalidate(myProfileProvider);
        ref.read(verificationSubmitProvider.notifier).reset();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('દસ્તાવેજ સફળતાપૂર્વક સબમિટ થયો! હવે એડમિન ચકાસણી કરશે.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/profile-under-review');
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Verification Status',
            style: TextStyle(color: AppColors.secondary, fontSize: 18, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.secondary),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.secondary),
            tooltip: 'લૉગઆઉટ (Sign Out)',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: myProfileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.accentRed, size: 48),
                  const SizedBox(height: 12),
                  Text('Failed to load profile: $err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(myProfileProvider),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.black),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (profile) {
            // Determine state from backend isVerified field
            // Future: also read verificationStatus field if backend exposes it
            final isVerified = profile.isVerified ?? false;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status card ──────────────────────────────────────────
                  _buildStatusCard(isVerified),
                  const SizedBox(height: 24),

                  if (isVerified) ...[
                    // ── Verified state ───────────────────────────────────
                    _buildVerifiedDetails(),
                  ] else ...[
                    // ── Not verified: show submit form ───────────────────
                    _buildSubmitForm(submitState),
                  ],

                  const SizedBox(height: 28),

                  // ── Official Verification Guide & Poster ─────────────
                  _buildOfficialVerificationGuide(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isVerified) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? AppColors.secondary : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: isVerified
            ? [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  blurRadius: 16,
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isVerified
                  ? AppColors.secondary.withValues(alpha: 0.15)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVerified ? Icons.verified : Icons.pending_outlined,
              color: isVerified ? AppColors.secondary : Colors.black54,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVerified ? '✓ Verified Profile' : 'Not Yet Verified',
                  style: TextStyle(
                    color: isVerified ? AppColors.secondary : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isVerified
                      ? 'Your profile has been verified by the samaj admin.'
                      : 'Submit your document to get a verified badge on your profile.',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Verification Benefits',
              style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 16),
          const _BenefitRow(
              icon: Icons.star, text: 'Gold verified badge on your profile'),
          const _BenefitRow(
              icon: Icons.visibility, text: 'Higher visibility in search'),
          const _BenefitRow(
              icon: Icons.shield, text: 'Trusted member status'),
          const _BenefitRow(
              icon: Icons.people, text: 'Access to verified members only section'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'તમારા દસ્તાવેજો સફળતાપૂર્વક માન્ય (Verified) થઈ ગયા છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ થઈ શકે છે.\n(Documents verified & locked. Each document can be used one time only.)',
                    style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficialVerificationGuide(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon & Bilingual Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user, color: AppColors.secondary, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'દસ્તાવેજ ચકાસણી માર્ગદર્શિકા',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Official Verification Checklist & Guide',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Poster Graphic with Tap to Zoom
          GestureDetector(
            onTap: () => _showFullscreenPoster(context),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 460),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/5 (6).jpeg',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.8),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in, color: AppColors.secondary, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'મોટું જોવા માટે ટેપ કરો (Tap to Zoom)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Self-verification Warning Notice Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.campaign, color: Color(0xFFD97706), size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'If you are interested, you should verify the other documents and other details yourself.',
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'જો તમને રસ હોય, તો સામેવાળા પાર્ટનરના દસ્તાવેજો (ડોક્યુમેન્ટ્સ) અને અન્ય વિગતોની ચકાસણી તમે જાતે કરો.',
                        style: TextStyle(
                          color: Color(0xFFB45309),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Category 1: Income & Occupation
          _buildCategoryCard(
            number: '1',
            titleEn: 'Income & Occupation',
            titleGu: 'આવક અને વ્યવસાય',
            color: const Color(0xFF059669),
            items: const [
              'Income Tax Returns (ITR) (ઇન્કમ ટેક્સ રિટર્ન / આવકવેરા રિટર્ન)',
              'Salary Slips (પગારની સ્લિપ)',
              'Bank Statements (બેંક સ્ટેટમેન્ટ / બેંક પાસબુકની નકલ)',
              'Business Proof (વ્યવસાયના પુરાવા / બિઝનેસ પ્રૂફ)',
            ],
          ),
          const SizedBox(height: 12),

          // Category 2: Caste & Religion
          _buildCategoryCard(
            number: '2',
            titleEn: 'Caste & Religion',
            titleGu: 'જાતિ અને ધર્મ',
            color: const Color(0xFFE11D48),
            items: const [
              'School Leaving Certificate (L.C.) (શાળા છોડ્યાનું પ્રમાણપત્ર - લિવિંગ સર્ટિફિકેટ)',
              'Caste Certificate (જાતિનો દાખલો - કાસ્ટ સર્ટિફિકેટ)',
            ],
          ),
          const SizedBox(height: 12),

          // Category 3: Properties & Assets
          _buildCategoryCard(
            number: '3',
            titleEn: 'Properties & Assets',
            titleGu: 'મિલકત અને સંપત્તિ',
            color: const Color(0xFFD97706),
            items: const [
              'Property Deeds (Dastavel) (મિલકતના દસ્તાવેજ)',
              'Property Tax Bills (પ્રોપર્ટી ટેક્સ બિલ / મિલકત વેરાની પહોંચ)',
              'Land Records (7/12 & 8-A Extracts) (જમીનના ઉતારા ૭/૧૨ અને ૮-અ)',
            ],
          ),
          const SizedBox(height: 12),

          // Category 4: Identity, Age & Background
          _buildCategoryCard(
            number: '4',
            titleEn: 'Identity, Age & Background',
            titleGu: 'ઓળખ, ઉંમર અને બેકગ્રાઉન્ડ',
            color: const Color(0xFF7C3AED),
            items: const [
              'Government IDs (સરકારી ઓળખ કાર્ડ - આધાર કાર્ડ, પાન કાર્ડ વગેરે)',
              'Birth Certificate (જન્મનો દાખલો)',
              'Divorce Decree (If applicable) (છૂટાછેડાનો હુકમ / ડિવોર્સ ડિક્રી - જો અગાઉ લગ્ન થયા હોય તો)',
              'Medical Reports (તબીબી તપાસના રિપોર્ટ)',
            ],
          ),
          const SizedBox(height: 20),

          // Responsibility Disclaimer Notice
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0), width: 1.2),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.handshake_outlined, color: Color(0xFF16A34A), size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'The responsibility of verifying all documents before marriage will be yours.',
                        style: TextStyle(
                          color: Color(0xFF166534),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'લગ્ન પહેલાં બધા ડોક્યુમેન્ટ્સ (દસ્તાવેજો) તપાસવાની જવાબદારી તમારી રહેશે.',
                        style: TextStyle(
                          color: Color(0xFF15803D),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullscreenPoster(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Image.asset(
                    'assets/images/5 (6).jpeg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String number,
    required String titleEn,
    required String titleGu,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$titleEn / $titleGu',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline, color: color, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitForm(VerificationSubmitState submitState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Submit for Verification',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Upload a valid government document to get your profile verified.',
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 14),

          // Single-use document notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309), size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'મહત્વપૂર્ણ નિયમ: ઉમેદવાર પોતાના દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકે છે. અન્ય પ્રોફાઇલમાં કે ફરીથી આ દસ્તાવેજ માન્ય રહેશે નહીં.\n(Important: Documents can only be used one time. Re-submission or reuse is not allowed.)',
                    style: TextStyle(color: Color(0xFF92400E), fontSize: 12, height: 1.3, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Document type dropdown
          const Text('Document Type',
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _documentType,
                dropdownColor: Colors.white,
                isExpanded: true,
                style: const TextStyle(color: Colors.black87, fontSize: 15),
                iconEnabledColor: AppColors.secondary,
                onChanged: (v) => setState(() => _documentType = v ?? _documentType),
                items: _documentTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Option 1: Direct File / Photo Upload
          const Text('ઓળખ કાર્ડનો ફોટો અપલોડ કરો (Upload ID Photo)',
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _isUploadingFile ? null : _pickAndUploadDocument,
            icon: _isUploadingFile
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Icon(Icons.add_a_photo_rounded, color: Colors.black),
            label: Text(
              _isUploadingFile
                  ? 'અપલોડ થઈ રહ્યું છે... (Uploading...)'
                  : 'ગેલેરીમાંથી ફોટો પસંદ કરો (Choose from Gallery)',
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('અથવા લિંક દાખલ કરો (OR Enter Link)',
                    style: TextStyle(color: Colors.black45, fontSize: 12)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 18),

          // Document URL field
          const Text('Document URL / Link',
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _docUrlController,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'https://drive.google.com/...',
              hintStyle: const TextStyle(color: Colors.black38),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.secondary),
              ),
              prefixIcon:
                  const Icon(Icons.link, color: AppColors.secondary, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter the document URL';
              if (!Uri.tryParse(v.trim())!.isAbsolute) {
                return 'Please enter a valid URL starting with https://';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Upload your document to Google Drive, Dropbox, or any public link and paste the URL above.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 28),

          // Error message
          if (submitState.isError) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.accentRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      submitState.errorMessage ?? 'Submission failed.',
                      style: const TextStyle(
                          color: AppColors.accentRed, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: submitState.isSubmitting
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        ref
                            .read(verificationSubmitProvider.notifier)
                            .submit(
                              documentType: _documentType,
                              documentUrl: _docUrlController.text.trim(),
                            );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: submitState.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Submit for Verification',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.black87, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
