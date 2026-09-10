import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_error.dart';
import '../../data/profile_models.dart';
import '../../providers/profile_provider.dart';
import '../widgets/profile_form.dart';

/// Screen for editing the authenticated user's existing matrimonial profile.
/// Pre-fills all form fields from the current [ProfileState].
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.profile;
    final refData = profileState.referenceData;

    // If we somehow arrive here without a loaded profile, show error
    if (profile == null || refData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: AppError(
          message: 'Profile data is unavailable. Please go back and try again.',
          onRetry: () {
            ref.read(profileNotifierProvider.notifier).loadProfile();
            context.pop();
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ProfileForm(
        key: const PageStorageKey('edit_profile_form'),
        initialProfile: profile,
        referenceData: refData,
        isSaving: profileState.isSaving,
        submitLabel: 'Save Changes',
        onSubmit: (result) => _handleUpdate(context, ref, result),
      ),
    );
  }

  Future<bool> _handleUpdate(
      BuildContext context, WidgetRef ref, ProfileFormResult result) async {
    final request = UpdateProfileRequest(
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
    );

    final success =
        await ref.read(profileNotifierProvider.notifier).updateProfile(request);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop(); // Go back to profile view
    } else if (context.mounted) {
      final msg = ref.read(profileNotifierProvider).errorMessage ??
          'Failed to update profile.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error),
      );
    }
    return success;
  }
}
