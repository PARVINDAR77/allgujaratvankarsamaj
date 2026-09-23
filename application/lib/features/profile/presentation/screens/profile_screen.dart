import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final myProfileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('My Profile (મારી પ્રોફાઈલ)', style: TextStyle(color: AppColors.secondary)),
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondary, width: 1.5),
                ),
                child: myProfileAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
                  error: (err, stack) => Center(
                    child: Text(
                      'Failed to load profile. Please complete your profile.',
                      style: const TextStyle(color: AppColors.accentRed, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  data: (profile) => Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.secondary,
                        backgroundImage: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                            ? NetworkImage(profile.photoUrl!)
                            : null,
                        child: profile.photoUrl == null || profile.photoUrl!.isEmpty
                            ? const Icon(Icons.person, size: 50, color: Colors.black)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.fullName,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authState.user?.email ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      if (profile.isVerified == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.secondary),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: AppColors.secondary, size: 14),
                              SizedBox(width: 4),
                              Text('Verified Member', style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      else
                        const Text('સભ્ય (Member)', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                tileColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.edit, color: AppColors.secondary),
                title: const Text('Edit Profile (પ્રોફાઈલ સુધારો)', style: TextStyle(color: Colors.white)),
                onTap: () => context.push('/profile/edit'),
              ),
              const SizedBox(height: 10),
              ListTile(
                tileColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.contact_phone, color: AppColors.secondary),
                title: const Text('Privacy & Contact (ગોપનીયતા)', style: TextStyle(color: Colors.white)),
                onTap: () => context.push('/privacy-contact'),
              ),
              const SizedBox(height: 10),
              ListTile(
                tileColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.verified, color: AppColors.secondary),
                title: const Text('Verified Profile Details', style: TextStyle(color: Colors.white)),
                onTap: () => context.push('/verified-profile'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Logout (લોગઆઉટ)', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
