import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/pargana_footer_bar.dart';
import '../../../../shared/widgets/vankar_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Standard Vankar Header with Peacocks & Medallion
            const VankarHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Section Title: Matrimony Home
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.favorite, color: AppColors.secondary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Matrimony Home',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.favorite, color: AppColors.secondary, size: 18),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'લગ્ન માટે છોકરો / છોકરી શોધો',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Main Matrimony Card with 3-Column Layout
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF041126),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cardBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Left 3 Action Tiles
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    _buildActionTile(
                                      icon: Icons.person,
                                      gujaratiTitle: 'છોકરો શોધો',
                                      englishSubtitle: 'Find Boy',
                                      onTap: () => context.go('/search'),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildActionTile(
                                      icon: Icons.face_3,
                                      gujaratiTitle: 'છોકરી શોધો',
                                      englishSubtitle: 'Find Girl',
                                      onTap: () => context.go('/search'),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildActionTile(
                                      icon: Icons.favorite,
                                      gujaratiTitle: 'મેળ શોધો',
                                      englishSubtitle: 'Find Match',
                                      onTap: () => context.go('/match'),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Center Couple Photo with Arch Frame
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.secondary, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondary.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.asset(
                                          'assets/images/home_couple.jpg',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/images/WhatsApp Image 2026-09-08 at 10.08.42 PM (1).jpeg',
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                        // Subtle golden glow overlay around edges
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: AppColors.goldAccent.withValues(alpha: 0.4),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Right 3 Action Tiles
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    _buildActionTile(
                                      icon: Icons.assignment_ind,
                                      gujaratiTitle: 'પ્રોફાઈલ બનાવો',
                                      englishSubtitle: 'Create Profile',
                                      onTap: () => context.go('/profile/create'),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildActionTile(
                                      icon: Icons.search,
                                      gujaratiTitle: 'શોધો',
                                      englishSubtitle: 'Search',
                                      onTap: () => context.go('/search'),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildActionTile(
                                      icon: Icons.verified_user,
                                      gujaratiTitle: 'વેરિફાઈડ પ્રોફાઈલ',
                                      englishSubtitle: 'Verified Profiles',
                                      onTap: () => context.push('/verified-profile'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Center Golden Pill: "હમણાં જ જોડાઓ / Join Now"
                          InkWell(
                            onTap: () => context.go('/register'),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxWidth: 240),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: AppColors.goldGradient,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.group_add, color: Colors.black87, size: 20),
                                  const SizedBox(width: 8),
                                  Column(
                                    children: const [
                                      Text(
                                        'હમણાં જ જોડાઓ',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Join Now',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Quick Pargana Bar
                    ParganaFooterBar(
                      onParganaTap: (pargana) {
                        context.push('/pargana-overview');
                      },
                    ),

                    const SizedBox(height: 14),

                    // Additional Workable Services & Quick Links
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF041126),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.stars, color: AppColors.secondary, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'સમાજ સેવાઓ અને સુવિધાઓ',
                                style: TextStyle(
                                  color: AppColors.goldLight,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildServiceQuickCard(
                                  context,
                                  icon: Icons.storefront,
                                  title: 'સમાજ સર્વિસીસ',
                                  subtitle: 'Mandap & Cars',
                                  onTap: () => context.push('/samaj-services'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildServiceQuickCard(
                                  context,
                                  icon: Icons.family_restroom,
                                  title: 'પરિવાર વિગત',
                                  subtitle: 'Family Matrix',
                                  onTap: () => context.push('/family-details'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildServiceQuickCard(
                                  context,
                                  icon: Icons.lock,
                                  title: 'Privacy & Call',
                                  subtitle: 'સંપર્ક Privacy',
                                  onTap: () => context.push('/privacy-contact'),
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildServiceQuickCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF061A3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.secondary, size: 22),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white60, fontSize: 8),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String gujaratiTitle,
    required String englishSubtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF031633),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: AppColors.secondary, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              gujaratiTitle,
              style: const TextStyle(
                color: AppColors.goldLight,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              englishSubtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
