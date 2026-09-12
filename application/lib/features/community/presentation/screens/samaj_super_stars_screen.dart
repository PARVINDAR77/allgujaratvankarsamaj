import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/vankar_header.dart';

class SamajSuperStarsScreen extends StatelessWidget {
  const SamajSuperStarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041026),
      body: SafeArea(
        child: Column(
          children: [
            // Top Standard Vankar Header
            VankarHeader(
              showBackButton: true,
              onBackPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              subtitle: '“All Gujarat Vankar Samaj Super Stars”',
            ),

            // Full-screen Scrollable Poster Artwork
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Super Stars Poster Image
                    Image.asset(
                      'assets/images/super_stars.jpeg',
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 400,
                        alignment: Alignment.center,
                        color: AppColors.primary,
                        child: const Text(
                          'Samaj Super Stars Poster',
                          style: TextStyle(color: AppColors.secondary, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Back Button Bar
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
                      child: InkWell(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back_rounded, color: Colors.black87, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'પાછા જાઓ (Back)',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
