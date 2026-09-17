import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class VerifiedProfileScreen extends StatelessWidget {
  const VerifiedProfileScreen({super.key});

  static const List<String> _unknownImages = [
    'assets/images/WhatsApp Image 2026-09-08 at 10.08.42 PM (1).jpeg',
    'assets/images/WhatsApp Image 2026-09-08 at 10.08.42 PM (2).jpeg',
    'assets/images/WhatsApp Image 2026-09-08 at 10.08.42 PM.jpeg',
    'assets/images/WhatsApp Image 2026-09-08 at 10.08.43 PM (1).jpeg',
    'assets/images/WhatsApp Image 2026-09-08 at 10.08.43 PM.jpeg',
    'assets/images/WhatsApp Image 2026-09-08 at 10.08.44 PM (1).jpeg',
    'assets/images/WhatsApp Image 2026-09-08 at 10.08.44 PM (2).jpeg',
    'assets/images/WhatsApp Image 2026-09-08 at 10.08.44 PM.jpeg',
    'assets/images/WhatsApp Image 2026-09-08 at 10.08.45 PM (2).jpeg',
    'assets/images/WhatsApp Image 2026-09-08 at 10.08.45 PM (3).jpeg',
    'assets/images/WhatsApp Image 2026-09-12 at 1.20.08 PM.jpeg',
    'assets/images/2.png',
    'assets/images/3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Find the Correct Image', style: TextStyle(color: AppColors.secondary)),
        iconTheme: const IconThemeData(color: AppColors.secondary),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _unknownImages.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary),
            ),
            child: Column(
              children: [
                Text(
                  _unknownImages[index].split('/').last,
                  style: const TextStyle(color: AppColors.secondary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Image.asset(
                  _unknownImages[index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, err, stack) => const Text('Image Failed', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
