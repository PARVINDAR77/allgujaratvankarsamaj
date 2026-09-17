import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class PrivacyContactScreen extends StatelessWidget {
  const PrivacyContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Privacy & Contact (સંપર્ક)', style: TextStyle(color: AppColors.secondary)),
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.2), blurRadius: 16),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/WhatsApp Image 2026-09-08 at 10.08.44 PM.jpeg',
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 400,
                        color: const Color(0xFF041126),
                        child: const Center(
                          child: Icon(Icons.contact_support, color: Color(0xFFD4AF37), size: 60),
                        ),
                      ),
                    ),
                    Container(
                      color: const Color(0xFF041126),
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('All Gujarat Vankar Samaj Contact Support', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildContactRow(Icons.email, 'Email', 'support@vankarsamaj.com'),
                          const SizedBox(height: 12),
                          _buildContactRow(Icons.phone, 'Phone', '+91 98765 43210'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
