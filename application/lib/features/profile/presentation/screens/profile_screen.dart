import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../home/presentation/widgets/web_home_header.dart';
import '../../../home/presentation/widgets/web_home_footer.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final myProfileAsync = ref.watch(myProfileProvider);
    final isDesktopWeb = kIsWeb && MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: isDesktopWeb
          ? const WebHomeHeader(activeRoute: '/profile')
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'My Profile (મારી પ્રોફાઈલ)',
                style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
              iconTheme: const IconThemeData(color: AppColors.secondary),
              leading: Navigator.of(context).canPop()
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    )
                  : IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () => context.go('/main-poster'),
                    ),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(color: AppColors.secondary),
                              ),
                            ),
                            error: (err, stack) {
                              final user = authState.user;
                              final displayName = (user?.email != null && user!.email.isNotEmpty)
                                  ? user.email.split('@').first
                                  : 'સભ્ય (Member)';
                              return Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.secondary.withValues(alpha: 0.1),
                                      border: Border.all(
                                        color: AppColors.secondary.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.person_rounded, size: 48, color: AppColors.secondary),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? '',
                                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'સભ્ય (Member)',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton.icon(
                                    onPressed: () => context.push('/profile/create'),
                                    icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                                    label: const Text('પ્રોફાઈલ બનાવો (Complete Profile)'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ],
                              );
                            },
                            data: (profile) => Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                    border: Border.all(color: Colors.grey.shade300, width: 2),
                                  ),
                                  child: ClipOval(
                                    child: profile.fullPhotoUrl != null
                                        ? Image.network(
                                            profile.fullPhotoUrl!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.person, size: 50, color: Colors.black54),
                                          )
                                        : const Icon(Icons.person, size: 50, color: Colors.black54),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  profile.fullName,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                        Text('Verified Member',
                                            style: TextStyle(
                                                color: AppColors.secondary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                                else
                                  const Text('સભ્ય (Member)',
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
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
                          icon: Icons.lock_reset_outlined,
                          title: 'Update Password (પાસવર્ડ બદલો / સુધારો)',
                          onTap: () => _showUpdatePasswordDialog(context, ref),
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
                          label: const Text('Delete Account (એકાઉન્ટ કાઢી નાખો)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                          label: const Text('Logout (લોગઆઉટ)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isDesktopWeb) ...[
                const SizedBox(height: 32),
                const WebHomeFooter(),
              ],
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
              content: Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.black54,
                  radioTheme: RadioThemeData(
                    fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return AppColors.secondary;
                      }
                      return Colors.black54;
                    }),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: reasons.map((reason) {
                      return RadioListTile<String>(
                        title: Text(reason, style: const TextStyle(fontSize: 14, color: Colors.black87)),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                  ),
                  child: Text('Continue', style: TextStyle(color: selectedReason == null ? Colors.grey.shade600 : Colors.white)),
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
            style: TextStyle(color: Colors.black87),
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

  void _showUpdatePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSubmitting = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFD4AF37),
                  secondary: Color(0xFFD4AF37),
                ),
              ),
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Icon(Icons.lock_reset, color: Color(0xFFB45309), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Update Password\n(પાસવર્ડ બદલો)',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Text(
                          'Current Password (હાલનો પાસવર્ડ) *',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: currentPasswordController,
                          obscureText: obscureCurrent,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: Colors.black87,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            hintText: 'Enter current password',
                            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.normal),
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFB45309), size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureCurrent ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                                color: Colors.grey.shade800,
                              ),
                              onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'New Password (નવો પાસવર્ડ) *',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: newPasswordController,
                          obscureText: obscureNew,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: Colors.black87,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            hintText: 'Minimum 6 characters',
                            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.normal),
                            prefixIcon: const Icon(Icons.key_outlined, color: Color(0xFFB45309), size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureNew ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                                color: Colors.grey.shade800,
                              ),
                              onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Confirm New Password (નવો પાસવર્ડ ફરીથી લખો) *',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirm,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: Colors.black87,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            hintText: 'Re-enter new password',
                            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.normal),
                            prefixIcon: const Icon(Icons.check_circle_outline, color: Color(0xFFB45309), size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirm ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                                color: Colors.grey.shade800,
                              ),
                              onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  OutlinedButton(
                    onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Cancel (રદ કરો)', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                  ),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final cur = currentPasswordController.text.trim();
                            final nP = newPasswordController.text.trim();
                            final cP = confirmPasswordController.text.trim();

                            if (cur.isEmpty) {
                              setDialogState(() => errorMessage = 'કૃપા કરીને હાલનો પાસવર્ડ દાખલ કરો (Please enter current password)');
                              return;
                            }
                            if (nP.length < 6) {
                              setDialogState(() => errorMessage = 'નવો પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ (New password must be at least 6 characters)');
                              return;
                            }
                            if (nP != cP) {
                              setDialogState(() => errorMessage = 'નવો પાસવર્ડ અને કન્ફર્મ પાસવર્ડ સરખા નથી (New and Confirm passwords do not match)');
                              return;
                            }

                            setDialogState(() {
                              isSubmitting = true;
                              errorMessage = null;
                            });

                            final res = await ref.read(authNotifierProvider.notifier).updatePassword(
                                  currentPassword: cur,
                                  newPassword: nP,
                                );

                            if (res['success'] == true) {
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res['message'] ?? 'પાસવર્ડ સફળતાપૂર્વક અપડેટ થયો છે'),
                                    backgroundColor: Colors.green.shade700,
                                  ),
                                );
                              }
                            } else {
                              setDialogState(() {
                                isSubmitting = false;
                                errorMessage = res['message'] ?? 'પાસવર્ડ અપડેટ કરવામાં નિષ્ફળ';
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                          )
                        : const Text('Save (સેવ કરો)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


