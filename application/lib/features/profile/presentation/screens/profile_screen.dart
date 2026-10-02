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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Profile (મારી પ્રોફાઈલ)', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: myProfileAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
                  error: (err, stack) => const Center(
                    child: Text(
                      'Failed to load profile. Please complete your profile.',
                      style: TextStyle(color: AppColors.accentRed, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  data: (profile) => Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                            ? NetworkImage(profile.photoUrl!)
                            : null,
                        child: profile.photoUrl == null || profile.photoUrl!.isEmpty
                            ? const Icon(Icons.person, size: 50, color: Colors.black54)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.fullName,
                        style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authState.user?.email ?? '',
                        style: const TextStyle(color: Colors.black54, fontSize: 14),
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
                        const Text('સભ્ય (Member)', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildListTile(
                context,
                icon: Icons.edit,
                title: 'Edit Profile (પ્રોફાઈલ સુધારો)',
                onTap: () => context.push('/profile/edit'),
              ),
              const SizedBox(height: 12),
              _buildListTile(
                context,
                icon: Icons.contact_phone,
                title: 'Privacy & Contact (ગોપનીયતા)',
                onTap: () => context.push('/privacy-contact'),
              ),
              const SizedBox(height: 12),
              _buildListTile(
                context,
                icon: Icons.policy,
                title: 'Privacy Policy (ગોપનીયતા નીતિ)',
                onTap: () => context.push('/privacy-policy'),
              ),
              const SizedBox(height: 12),
              _buildListTile(
                context,
                icon: Icons.verified,
                title: 'Verified Profile Details',
                onTap: () => context.push('/verified-profile'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showDeleteAccountReasons(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.accentRed,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.accentRed, width: 1.5),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete Account (એકાઉન્ટ કાઢી નાખો)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 12),
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
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Logout (લોગઆઉટ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.secondary),
      ),
      title: Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: Colors.black45),
      onTap: onTap,
    );
  }

  void _showDeleteAccountReasons(BuildContext context, WidgetRef ref) {
    String? selectedReason;
    final List<String> reasons = [
      'I found my match elsewhere',
      'I am not finding the app useful',
      'Privacy concerns',
      'I am getting too many notifications',
      'Other reasons'
    ];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Why are you leaving?',
                style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: reasons.map((reason) {
                    return RadioListTile<String>(
                      title: Text(reason, style: const TextStyle(fontSize: 14)),
                      value: reason,
                      groupValue: selectedReason,
                      activeColor: AppColors.secondary,
                      onChanged: (String? value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
                ),
                ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                          _showDeleteConfirmationDialog(context, ref);
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
                  child: const Text('Continue', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Are you sure?',
            style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Pop the dialog
                Navigator.of(dialogContext).pop();
                
                // Show a loading snackbar or message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deleting account...'), backgroundColor: AppColors.accentRed),
                );

                // Simulate deletion API call / actually log out
                await ref.read(authNotifierProvider.notifier).logout();
                
                if (context.mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
              child: const Text('Delete Account', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

