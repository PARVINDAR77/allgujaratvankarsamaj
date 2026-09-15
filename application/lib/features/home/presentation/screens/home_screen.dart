import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF041126),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFFD4AF37)),
            SizedBox(width: 8),
            Text(
              'સૂચનાઓ (Notifications)',
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ૫ નવી સંબંધ પ્રોફાઈલ ઉપલબ્ધ છે.', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 6),
            Text('• તમારા પરગણામાં ૧૨ નવી મેચ મળી.', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 6),
            Text('• પ્રોફાઈલ ચકાસણી સફળ થઈ.', style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  void _showMenuDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF041126),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'All Gujarat Vankar Samaj',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                dense: true,
                leading: const Icon(Icons.home, color: Color(0xFFD4AF37)),
                title: const Text('Home (મુખ્ય પૃષ્ઠ)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/home');
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.search, color: Color(0xFFD4AF37)),
                title: const Text('Search Profiles (શોધો)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/search');
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.favorite, color: Color(0xFFD4AF37)),
                title: const Text('Mutual Interest (મેળ)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/match');
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.groups, color: Color(0xFFD4AF37)),
                title: const Text('View Families (પરિવાર જુઓ)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/family-details');
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.location_city, color: Color(0xFFD4AF37)),
                title: const Text('Pargana Overview (પરગણાં)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/pargana-overview');
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.handshake, color: Color(0xFFD4AF37)),
                title: const Text('Samaj Services (સમાજ સેવાઓ)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/samaj-services');
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.work, color: Color(0xFFD4AF37)),
                title: const Text('Govt. Employees (સરકારી કર્મચારી)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/government-employees');
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.verified_user, color: Color(0xFFD4AF37)),
                title: const Text('Verified Profiles (વેરિફાઈડ પ્રોફાઈલ)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/verified-profile');
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.person_add, color: Color(0xFFD4AF37)),
                title: const Text('Create Profile (પ્રોફાઈલ બનાવો)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/profile/create');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF06152D),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenW = constraints.maxWidth;
            final croppedH = screenW * (1455 / 736); // Display height cropping out the printed bottom nav bar
            final totalImageH = screenW * (1600 / 736); // Full artwork height

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: screenW,
                height: croppedH,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    minWidth: screenW,
                    maxWidth: screenW,
                    minHeight: totalImageH,
                    maxHeight: totalImageH,
                    child: Stack(
                      children: [
                        // 1. Full Master Peacock & Lotus Theme Layout Image
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/main_home_layout.jpg',
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/images/WhatsApp Image 2026-09-08 at 10.08.42 PM (1).jpeg',
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFF06152D),
                              ),
                            ),
                          ),
                        ),

                        // 2. Top-Left Menu Icon (☰)
                        Positioned(
                          left: screenW * 0.03,
                          top: totalImageH * 0.012,
                          width: screenW * 0.14,
                          height: totalImageH * 0.045,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(30),
                              onTap: () => _showMenuDialog(context),
                            ),
                          ),
                        ),

                        // 3. Top-Right Notification Bell Icon (🔔 5)
                        Positioned(
                          right: screenW * 0.03,
                          top: totalImageH * 0.012,
                          width: screenW * 0.14,
                          height: totalImageH * 0.045,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(30),
                              onTap: () => _showNotificationDialog(context),
                            ),
                          ),
                        ),

                        // 4. Left Action Box 1: છોકરો શોધો (Find Boy)
                        Positioned(
                          left: screenW * 0.02,
                          top: totalImageH * 0.365,
                          width: screenW * 0.20,
                          height: totalImageH * 0.105,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.go('/search'),
                            ),
                          ),
                        ),

                        // 5. Left Action Box 2: છોકરી શોધો (Find Girl)
                        Positioned(
                          left: screenW * 0.02,
                          top: totalImageH * 0.48,
                          width: screenW * 0.20,
                          height: totalImageH * 0.105,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.go('/search'),
                            ),
                          ),
                        ),

                        // 6. Left Action Box 3: મેળ શોધો (Find Match)
                        Positioned(
                          left: screenW * 0.02,
                          top: totalImageH * 0.595,
                          width: screenW * 0.20,
                          height: totalImageH * 0.105,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.go('/match'),
                            ),
                          ),
                        ),

                        // 7. Right Action Box 1: પ્રોફાઈલ બનાવો (Create Profile)
                        Positioned(
                          left: screenW * 0.78,
                          top: totalImageH * 0.365,
                          width: screenW * 0.20,
                          height: totalImageH * 0.105,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.go('/profile/create'),
                            ),
                          ),
                        ),

                        // 8. Right Action Box 2: શોધો (Search)
                        Positioned(
                          left: screenW * 0.78,
                          top: totalImageH * 0.48,
                          width: screenW * 0.20,
                          height: totalImageH * 0.105,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.go('/search'),
                            ),
                          ),
                        ),

                        // 9. Right Action Box 3: વેરિફાઈડ પ્રોફાઈલ (Verified Profiles)
                        Positioned(
                          left: screenW * 0.78,
                          top: totalImageH * 0.595,
                          width: screenW * 0.20,
                          height: totalImageH * 0.105,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.push('/verified-profile'),
                            ),
                          ),
                        ),

                        // 10. Center Golden Pill: હમણાં જ જોડાઓ (Join Now)
                        Positioned(
                          left: screenW * 0.28,
                          top: totalImageH * 0.695,
                          width: screenW * 0.44,
                          height: totalImageH * 0.045,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => context.go('/profile/create'),
                            ),
                          ),
                        ),

                        // 11. Bottom Feature Icon 1: Education for Better Tomorrow
                        Positioned(
                          left: screenW * 0.04,
                          top: totalImageH * 0.755,
                          width: screenW * 0.16,
                          height: totalImageH * 0.075,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(30),
                              onTap: () => context.push('/samaj-services'),
                            ),
                          ),
                        ),

                        // 12. Bottom Feature Icon 2: Unity in Diversity
                        Positioned(
                          left: screenW * 0.23,
                          top: totalImageH * 0.755,
                          width: screenW * 0.16,
                          height: totalImageH * 0.075,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(30),
                              onTap: () => context.push('/pargana-overview'),
                            ),
                          ),
                        ),

                        // 13. Bottom Feature Icon 3: Progress Through Support
                        Positioned(
                          left: screenW * 0.42,
                          top: totalImageH * 0.755,
                          width: screenW * 0.16,
                          height: totalImageH * 0.075,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(30),
                              onTap: () => context.push('/verified-profile'),
                            ),
                          ),
                        ),

                        // 14. Bottom Feature Icon 4: Service to Society
                        Positioned(
                          left: screenW * 0.61,
                          top: totalImageH * 0.755,
                          width: screenW * 0.16,
                          height: totalImageH * 0.075,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(30),
                              onTap: () => context.push('/samaj-services'),
                            ),
                          ),
                        ),

                        // 15. Bottom Feature Icon 5: Strong Roots Bright Future
                        Positioned(
                          left: screenW * 0.80,
                          top: totalImageH * 0.755,
                          width: screenW * 0.16,
                          height: totalImageH * 0.075,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(30),
                              onTap: () => context.push('/family-details'),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
