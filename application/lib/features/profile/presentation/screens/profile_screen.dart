import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_error.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../providers/profile_provider.dart';
import '../widgets/profile_completeness_card.dart';
import '../widgets/profile_empty_state.dart';
import '../widgets/profile_field.dart';

/// Main matrimonial profile screen for the authenticated user.
/// States: loading → loaded (show profile) | empty (no profile yet) | error.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile on screen open (defer to post-frame to allow provider to settle)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (profileState.isLoaded)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Edit Profile',
              onPressed: () => context.push('/profile/edit'),
            ),
        ],
      ),
      body: _buildBody(context, theme, profileState),
    );
  }

  Widget _buildBody(
      BuildContext context, ThemeData theme, ProfileState profileState) {
    // Overlay a progress indicator for save/delete while keeping content visible
    if (profileState.isSaving || profileState.isDeleting) {
      return Stack(
        children: [
          _buildLoadedContent(context, theme, profileState),
          Container(
            color: Colors.black.withValues(alpha: 0.18),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (profileState.isLoading || profileState.status == ProfileStatus.initial) {
      return const AppLoading(message: 'Loading your profile…');
    }

    if (profileState.hasError && profileState.profile == null) {
      return AppError(
        message: profileState.errorMessage ?? 'Failed to load profile.',
        onRetry: () =>
            ref.read(profileNotifierProvider.notifier).loadProfile(),
      );
    }

    if (profileState.isEmpty) {
      return ProfileEmptyState(
        onCreateProfile: () => context.push('/profile/create'),
      );
    }

    return _buildLoadedContent(context, theme, profileState);
  }

  Widget _buildLoadedContent(
      BuildContext context, ThemeData theme, ProfileState profileState) {
    final profile = profileState.profile;
    if (profile == null) {
      return ProfileEmptyState(
        onCreateProfile: () => context.push('/profile/create'),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(profileNotifierProvider.notifier).loadProfile(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Profile Header ──────────────────────────────────────────
            _buildProfileHeader(context, theme, profile.fullName, profile.gender, profile.photoUrl),

            const SizedBox(height: 20),

            // ─── Completeness Card ───────────────────────────────────────
            if (profileState.completeness != null)
              ProfileCompletenessCard(completeness: profileState.completeness!),

            const SizedBox(height: 24),

            // ─── Personal Details ────────────────────────────────────────
            _buildSectionCard(
              theme,
              title: 'Personal Details',
              icon: Icons.person_outline_rounded,
              children: [
                ProfileField(
                  label: 'Full Name',
                  value: profile.fullName,
                  icon: Icons.badge_outlined,
                ),
                ProfileField(
                  label: 'Date of Birth',
                  value: profile.displayDateOfBirth,
                  icon: Icons.cake_outlined,
                ),
                ProfileField(
                  label: 'Gender',
                  value: _formatEnum(profile.gender),
                  icon: Icons.wc_outlined,
                ),
                ProfileField(
                  label: 'Marital Status',
                  value: _formatEnum(profile.maritalStatus),
                  icon: Icons.favorite_border_rounded,
                ),
                ProfileField(
                  label: 'Religion',
                  value: profile.religion,
                  icon: Icons.brightness_high_outlined,
                ),
                ProfileField(
                  label: 'Caste',
                  value: profile.caste,
                  icon: Icons.groups_outlined,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ─── Location ────────────────────────────────────────────────
            _buildSectionCard(
              theme,
              title: 'Location',
              icon: Icons.location_on_outlined,
              children: [
                ProfileField(
                  label: 'City',
                  value: profile.city,
                  icon: Icons.location_city_outlined,
                ),
                ProfileField(
                  label: 'State',
                  value: profile.state,
                  icon: Icons.map_outlined,
                ),
                ProfileField(
                  label: 'Country',
                  value: profile.country,
                  icon: Icons.public_outlined,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ─── Career & Education ──────────────────────────────────────
            _buildSectionCard(
              theme,
              title: 'Career & Education',
              icon: Icons.school_outlined,
              children: [
                ProfileField(
                  label: 'Education',
                  value: profile.education,
                  icon: Icons.menu_book_outlined,
                ),
                ProfileField(
                  label: 'Occupation',
                  value: profile.occupation,
                  icon: Icons.work_outline_rounded,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ─── About ───────────────────────────────────────────────────
            if (profile.about != null)
              _buildSectionCard(
                theme,
                title: 'About Me',
                icon: Icons.info_outline_rounded,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      profile.about!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // ─── Samaj & Privacy Services ─────────────────────────────────
            _buildSectionCard(
              theme,
              title: 'Samaj & Privacy Services',
              icon: Icons.shield_outlined,
              children: [
                ListTile(
                  leading: const Icon(Icons.verified, color: AppColors.secondary),
                  title: const Text('Verified Profile (સત્યાપિત પ્રોફાઈલ)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('View 3-tier verification status', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.secondary, size: 14),
                  onTap: () => context.push('/verified-profile'),
                ),
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  leading: const Icon(Icons.lock, color: AppColors.secondary),
                  title: const Text('Privacy & Contact (સંપર્ક Privacy)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Manage who can view phone, email & address', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.secondary, size: 14),
                  onTap: () => context.push('/privacy-contact'),
                ),
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  leading: const Icon(Icons.storefront, color: AppColors.secondary),
                  title: const Text('Samaj Services (સમાજ સર્વિસીસ)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Wedding mandap, photography, cars & business', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.secondary, size: 14),
                  onTap: () => context.push('/samaj-services'),
                ),
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  leading: const Icon(Icons.groups, color: AppColors.secondary),
                  title: const Text('Family Details (પરિવારની સંપૂર્ણ માહિતી)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Family members matrix and address details', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.secondary, size: 14),
                  onTap: () => context.push('/family-details'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ─── Delete profile ──────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              label: const Text(
                'Delete Profile',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error, width: 1.5),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, ThemeData theme, String name, String gender, String? photoUrl) {
    ImageProvider? imageProvider;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('data:image')) {
        final base64Str = photoUrl.split(',').last;
        try {
          imageProvider = MemoryImage(base64Decode(base64Str));
        } catch (_) {}
      } else {
        imageProvider = NetworkImage(photoUrl);
      }
    }

    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorder, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.4),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipOval(
            child: imageProvider != null
                ? Image(
                    image: imageProvider,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Text(
                      _initials(name),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatEnum(gender),
                style: const TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF041026),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.secondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Profile?'),
        content: const Text(
            'This will permanently delete your matrimonial profile. Your account will remain active and you can create a new profile anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success =
          await ref.read(profileNotifierProvider.notifier).deleteProfile();
      if (!success && context.mounted) {
        final msg = ref.read(profileNotifierProvider).errorMessage ??
            'Failed to delete profile.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatEnum(String raw) {
    return raw.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
    }).join(' ');
  }
}
