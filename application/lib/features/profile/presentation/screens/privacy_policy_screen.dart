import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Privacy Policy (ગોપનીયતા નીતિ)',
          style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy & Terms of Service',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              SizedBox(height: 16),
              _PolicySection(
                title: '1. Information Collection',
                content: 'We collect personal information such as your name, email address, phone number, and profile details when you register and use the matrimonial services. This information is required to provide accurate matchmaking services.',
              ),
              _PolicySection(
                title: '2. Use of Data',
                content: 'Your data is strictly used for matrimonial purposes within the community. We do not sell your personal information to third parties. Your profile visibility is controlled by the privacy settings you choose.',
              ),
              _PolicySection(
                title: '3. Data Security',
                content: 'We implement reasonable security measures to protect your personal information from unauthorized access, alteration, or disclosure. However, no internet-based service is completely secure.',
              ),
              _PolicySection(
                title: '4. User Responsibilities',
                content: 'You are responsible for maintaining the confidentiality of your login credentials. You must ensure that the information you provide on your profile is accurate, truthful, and not misleading.',
              ),
              _PolicySection(
                title: '5. Account Deletion',
                content: 'You have the right to request the deletion of your account and personal data at any time by contacting the administration or using the account deletion feature if available.',
              ),
              _PolicySection(
                title: '6. Changes to This Policy',
                content: 'We may update this privacy policy from time to time. Any changes will be posted on this page with a revised effective date.',
              ),
              SizedBox(height: 24),
              Text(
                'By using this application, you agree to the terms outlined in this Privacy Policy.',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
