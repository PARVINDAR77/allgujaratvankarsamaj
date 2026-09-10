import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class VankarHeader extends StatelessWidget {
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const VankarHeader({
    super.key,
    this.subtitle,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020B18),
      child: AspectRatio(
        aspectRatio: 1024 / 395,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Authentic High-Resolution Royal Header Artwork with Peacocks & 99 Medallion
            Image.asset(
              'assets/images/vankar_header_banner.jpg',
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primary,
                  alignment: Alignment.center,
                  child: const Text('Vankar Samaj Matrimony', style: TextStyle(color: AppColors.secondary)),
                );
              },
            ),

            // Top-Left Button (Drawer Menu or Back Button)
            Positioned(
              top: 12,
              left: 12,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: showBackButton
                      ? (onBackPressed ?? () => Navigator.of(context).maybePop())
                      : () => Scaffold.maybeOf(context)?.openDrawer(),
                  borderRadius: BorderRadius.circular(24),
                  child: showBackButton
                      ? Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.secondary, width: 1.5),
                            color: const Color(0xFF030D1E),
                          ),
                          child: const Icon(Icons.arrow_back, color: AppColors.secondary, size: 22),
                        )
                      : const SizedBox(
                          width: 44,
                          height: 44,
                        ),
                ),
              ),
            ),

            // Top-Right Button (Notification Bell with Badge 5)
            Positioned(
              top: 12,
              right: 12,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('5 New Notifications (૫ નવી સૂચનાઓ)'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
