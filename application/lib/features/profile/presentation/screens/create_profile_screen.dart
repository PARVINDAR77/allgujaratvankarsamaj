import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/profile_models.dart';
import '../../providers/profile_provider.dart';
import '../widgets/profile_form.dart';

/// Screen for creating a new matrimonial profile.
/// Navigates back to /profile on success.
class CreateProfileScreen extends ConsumerWidget {
  const CreateProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaving = ref.watch(profileNotifierProvider.select((s) => s.isSaving));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile (ઉમેદવાર પ્રોફાઈલ બનાવો)'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ProfileForm(
        key: const PageStorageKey('create_profile_form'),
        referenceData: ReferenceDataModel.defaultData(),
        isSaving: isSaving,
        submitLabel: 'Create Profile (પ્રોફાઈલ બનાવો)',
        onSubmit: (result) =>
            _handleCreate(context, ref, result),
      ),
    );
  }

  Future<bool> _handleCreate(
      BuildContext context, WidgetRef ref, ProfileFormResult result) async {
    final request = CreateProfileRequest(
      firstName: result.firstName,
      lastName: result.lastName,
      dateOfBirth: result.dateOfBirth,
      gender: result.gender,
      maritalStatus: result.maritalStatus,
      religion: result.religion,
      caste: result.caste,
      city: result.city,
      state: result.state,
      country: result.country,
      education: result.education,
      occupation: result.occupation,
      about: result.about,
      photoUrl: result.photoUrl,
    );

    final success =
        await ref.read(profileNotifierProvider.notifier).createProfile(request);

    if (success && context.mounted) {
      _showFormFeePaymentDialog(context, ref, result);
    } else if (context.mounted) {
      final msg = ref.read(profileNotifierProvider).errorMessage ??
          'Failed to create profile.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error),
      );
    }
    return success;
  }

  void _showFormFeePaymentDialog(
      BuildContext context, WidgetRef ref, ProfileFormResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF07182E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.payment, color: Color(0xFFD4AF37), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'ફોર્મ ફી સબમિશન (Registration Fee)',
                style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'તમારી પ્રોફાઇલ સફળતાપૂર્વક બની ગઈ છે! સુપર એડમિન દ્વારા સેટ કરેલ નોંધણી ફી ચુકવો:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4AF37)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Super Admin Fee (ફોર્મ ફી):',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  Text('₹ 500.00',
                      style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ફી સબમિટ કર્યા પછી પ્રોફાઇલ સુપર એડમિન સમીક્ષા હેઠળ જશે.',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.go('/profile/under-review');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('Pay Fee & Submit (ફી ભરો અને મોકલો)',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
