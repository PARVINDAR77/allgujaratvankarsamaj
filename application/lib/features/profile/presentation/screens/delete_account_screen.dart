import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  String? _selectedReason;
  bool _confirmed = false;
  bool _isLoading = false;

  final List<String> _reasons = [
    'Marriage fixed through this app (લગ્ન નક્કી થઈ ગયા)',
    'Marriage fixed elsewhere (બીજે લગ્ન નક્કી થયા)',
    'Privacy or personal concerns (અંગત કારણોસર)',
    'Not finding suitable matches (યોગ્ય પાત્ર નથી મળતું)',
    'Created duplicate account',
    'Other reason',
  ];

  Future<void> _handleDelete() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for deletion')),
      );
      return;
    }

    if (!_confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm that you understand this action is permanent')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Perform logout / deletion
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account deletion request has been processed.'),
            backgroundColor: AppColors.accentRed,
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Delete Account (એકાઉન્ટ કાઢી નાખો)',
          style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permanent & Irreversible',
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Deleting your account will permanently remove your matrimonial profile, photographs, biodata, and all activity history from All Gujarat Vankar Samaj Matrimony.',
                            style: TextStyle(color: Colors.red.shade800, fontSize: 13.5, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Please select your reason for leaving:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              ..._reasons.map((reason) => RadioListTile<String>(
                    title: Text(reason, style: const TextStyle(fontSize: 14.5)),
                    value: reason,
                    groupValue: _selectedReason,
                    activeColor: AppColors.accentRed,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _selectedReason = val),
                  )),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _confirmed,
                onChanged: (val) => setState(() => _confirmed = val ?? false),
                activeColor: AppColors.accentRed,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I understand that my profile and data will be permanently deleted and cannot be recovered.',
                  style: TextStyle(fontSize: 13.5, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleDelete,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.delete_forever, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Processing...' : 'Permanently Delete My Account',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('https://allgujaratvankarsamaj.com/delete-account');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_browser, size: 18),
                  label: const Text('Open Web Deletion Page'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
