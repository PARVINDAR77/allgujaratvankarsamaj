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
        title: const Text('Create Profile'),
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
        submitLabel: 'Create Profile',
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

    if (success) {
      ref.read(userGenderNotifierProvider.notifier).setUserGender(result.gender);
    }

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/profile');
    } else if (context.mounted) {
      final msg = ref.read(profileNotifierProvider).errorMessage ??
          'Failed to create profile.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error),
      );
    }
    return success;
  }
}
