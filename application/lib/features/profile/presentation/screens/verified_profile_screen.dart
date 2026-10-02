import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
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
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: image.name),
      });

      final response = await dio.post('/storage/upload', data: formData);
      if (response.data != null && response.data['url'] != null) {
        final relUrl = response.data['url'] as String;
        final fullUrl = relUrl.startsWith('http')
            ? relUrl
            : 'https://allgujaratvankarsamaj.com$relUrl';
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
                  const SizedBox(height: 28),

                  if (isVerified) ...[
                    // ── Verified state ───────────────────────────────────
                    _buildVerifiedDetails(),
                  ] else ...[
                    // ── Not verified: show submit form ───────────────────
                    _buildSubmitForm(submitState),
                  ],
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verification Benefits',
              style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          SizedBox(height: 16),
          _BenefitRow(
              icon: Icons.star, text: 'Gold verified badge on your profile'),
          _BenefitRow(
              icon: Icons.visibility, text: 'Higher visibility in search'),
          _BenefitRow(
              icon: Icons.shield, text: 'Trusted member status'),
          _BenefitRow(
              icon: Icons.people, text: 'Access to verified members only section'),
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
          const SizedBox(height: 20),

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
