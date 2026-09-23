import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final myProfileAsync = ref.watch(myProfileProvider);
    final submitState = ref.watch(verificationSubmitProvider);

    // After successful submit, refresh profile and reset submit state
    ref.listen(verificationSubmitProvider, (_, next) {
      if (next.isSuccess) {
        ref.invalidate(myProfileProvider);
        ref.read(verificationSubmitProvider.notifier).reset();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification request submitted! Under review.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF041126),
        title: const Text('Verification Status',
            style: TextStyle(color: Color(0xFFFFD700), fontSize: 16)),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        centerTitle: true,
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
        color: const Color(0xFF041126),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? AppColors.secondary : Colors.white24,
          width: 1.5,
        ),
        boxShadow: isVerified
            ? [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  blurRadius: 16,
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isVerified
                  ? AppColors.secondary.withValues(alpha: 0.15)
                  : Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVerified ? Icons.verified : Icons.pending_outlined,
              color: isVerified ? AppColors.secondary : Colors.white54,
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
                    color: isVerified ? AppColors.secondary : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isVerified
                      ? 'Your profile has been verified by the samaj admin.'
                      : 'Submit your document to get a verified badge on your profile.',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
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
        color: const Color(0xFF041126),
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
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Upload a valid government document to get your profile verified.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Document type dropdown
          const Text('Document Type',
              style:
                  TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF041126),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _documentType,
                dropdownColor: const Color(0xFF041126),
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                iconEnabledColor: AppColors.secondary,
                onChanged: (v) => setState(() => _documentType = v ?? _documentType),
                items: _documentTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Document URL field
          const Text('Document URL / Link',
              style:
                  TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _docUrlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'https://drive.google.com/...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF041126),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
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
            style: TextStyle(color: Colors.white38, fontSize: 11),
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
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
