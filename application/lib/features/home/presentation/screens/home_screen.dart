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
      backgroundColor: const Color(0xFF041126),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'All Gujarat Vankar Samaj',
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFFD4AF37)),
              title: const Text('Home (મુખ્ય પૃષ્ઠ)', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Color(0xFFD4AF37)),
              title: const Text('Search Profiles (શોધો)', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/search');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Color(0xFFD4AF37)),
              title: const Text('Mutual Interest (મેળ)', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/match');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city, color: Color(0xFFD4AF37)),
              title: const Text('Pargana Overview (પરગણાં)', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/pargana-overview');
              },
            ),
            ListTile(
              leading: const Icon(Icons.handshake, color: Color(0xFFD4AF37)),
              title: const Text('Samaj Services (સમાજ સેવાઓ)', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/samaj-services');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF01060E),
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 685 / 1000,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                return Stack(
                  children: [
                    // 1. Full Master Layout Image (Exact 1:1 match of Matrimony Home poster)
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/template_home.jpg',
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/WhatsApp Image 2026-09-08 at 10.08.42 PM (1).jpeg',
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/main_home_layout.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // 2. Top-Left Menu Icon (☰)
                    Positioned(
                      left: w * 0.02,
                      top: h * 0.01,
                      width: w * 0.14,
                      height: h * 0.06,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => _showMenuDialog(context),
                        ),
                      ),
                    ),

                    // 3. Top-Right Notification Bell Icon (🔔 5)
                    Positioned(
                      right: w * 0.02,
                      top: h * 0.01,
                      width: w * 0.14,
                      height: h * 0.06,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => _showNotificationDialog(context),
                        ),
                      ),
                    ),

                    // 4. Left Action Box 1: છોકરો શોધો (Find Boy)
                    Positioned(
                      left: w * 0.025,
                      top: h * 0.35,
                      width: w * 0.19,
                      height: h * 0.135,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.go('/search'),
                        ),
                      ),
                    ),

                    // 5. Left Action Box 2: છોકરી શોધો (Find Girl)
                    Positioned(
                      left: w * 0.025,
                      top: h * 0.495,
                      width: w * 0.19,
                      height: h * 0.135,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.go('/search'),
                        ),
                      ),
                    ),

                    // 6. Left Action Box 3: મેળ શોધો (Find Match)
                    Positioned(
                      left: w * 0.025,
                      top: h * 0.64,
                      width: w * 0.19,
                      height: h * 0.135,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.go('/match'),
                        ),
                      ),
                    ),

                    // 7. Right Action Box 1: પ્રોફાઈલ બનાવો (Create Profile)
                    Positioned(
                      left: w * 0.785,
                      top: h * 0.35,
                      width: w * 0.19,
                      height: h * 0.135,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.go('/profile/create'),
                        ),
                      ),
                    ),

                    // 8. Right Action Box 2: શોધો (Search)
                    Positioned(
                      left: w * 0.785,
                      top: h * 0.495,
                      width: w * 0.19,
                      height: h * 0.135,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.go('/search'),
                        ),
                      ),
                    ),

                    // 9. Right Action Box 3: વેરિફાઈડ પ્રોફાઈલ (Verified Profiles)
                    Positioned(
                      left: w * 0.785,
                      top: h * 0.64,
                      width: w * 0.19,
                      height: h * 0.135,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.push('/verified-profile'),
                        ),
                      ),
                    ),

                    // 10. Center Golden Pill: હમણાં જ જોડાઓ (Join Now)
                    Positioned(
                      left: w * 0.30,
                      top: h * 0.74,
                      width: w * 0.40,
                      height: h * 0.055,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => context.go('/profile/create'),
                        ),
                      ),
                    ),

                    // 11. Pargana Pill 1: 35 પરગણાં
                    Positioned(
                      left: w * 0.135,
                      top: h * 0.815,
                      width: w * 0.175,
                      height: h * 0.075,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/pargana-overview'),
                        ),
                      ),
                    ),

                    // 12. Pargana Pill 2: 27 પરગણાં
                    Positioned(
                      left: w * 0.32,
                      top: h * 0.815,
                      width: w * 0.175,
                      height: h * 0.075,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/pargana-overview'),
                        ),
                      ),
                    ),

                    // 13. Pargana Pill 3: 16 પરગણાં
                    Positioned(
                      left: w * 0.505,
                      top: h * 0.815,
                      width: w * 0.175,
                      height: h * 0.075,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/pargana-overview'),
                        ),
                      ),
                    ),

                    // 14. Pargana Pill 4: 14 પરગણાં
                    Positioned(
                      left: w * 0.69,
                      top: h * 0.815,
                      width: w * 0.175,
                      height: h * 0.075,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/pargana-overview'),
                        ),
                      ),
                    ),

                    // 15. Bottom Navigation Bar Tabs:
                    // Tab 1: હોમ (Home)
                    Positioned(
                      left: 0,
                      top: h * 0.91,
                      width: w * 0.20,
                      height: h * 0.09,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.go('/home'),
                        ),
                      ),
                    ),

                    // Tab 2: શોધો (Search)
                    Positioned(
                      left: w * 0.20,
                      top: h * 0.91,
                      width: w * 0.20,
                      height: h * 0.09,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.go('/search'),
                        ),
                      ),
                    ),

                    // Tab 3: મેળ (Match) - Golden Heart Center
                    Positioned(
                      left: w * 0.40,
                      top: h * 0.89,
                      width: w * 0.20,
                      height: h * 0.11,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.go('/match'),
                        ),
                      ),
                    ),

                    // Tab 4: મેસેજ (Message)
                    Positioned(
                      left: w * 0.60,
                      top: h * 0.91,
                      width: w * 0.20,
                      height: h * 0.09,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.go('/messages'),
                        ),
                      ),
                    ),

                    // Tab 5: પ્રોફાઈલ (Profile)
                    Positioned(
                      left: w * 0.80,
                      top: h * 0.91,
                      width: w * 0.20,
                      height: h * 0.09,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.go('/profile'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
