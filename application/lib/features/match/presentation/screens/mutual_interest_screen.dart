import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MutualInterestScreen extends ConsumerWidget {
  const MutualInterestScreen({super.key});

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
            Text('• હેમંતકુમાર અને હીરાલબેન વચ્ચે પરસ્પર પસંદગી થઈ છે.', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 6),
            Text('• બંને પરિવારો સંપર્કમાં છે.', style: TextStyle(color: Colors.white70)),
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
                title: const Text('Mutual Interest (મેળ / પસંદગી)', style: TextStyle(color: Colors.white)),
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
      backgroundColor: const Color(0xFF01060E),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenW = constraints.maxWidth;
            final screenH = constraints.maxHeight;

            final posterW = screenW;
            final posterH = screenH > 0
                ? (screenH > screenW * (1536 / 1024) ? screenH : screenW * (1536 / 1024))
                : 600.0;
            final imageH = posterH / 0.905;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: posterW,
                height: posterH,
                child: Stack(
                  children: [
                    // 1. Full Master Mutual Interest Image - OverflowBox & ClipRect physically crops printed bottom icons
                    Positioned.fill(
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minWidth: posterW,
                          maxWidth: posterW,
                          minHeight: imageH,
                          maxHeight: imageH,
                          child: Image.asset(
                            'assets/images/template_mutual.jpg',
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/images/WhatsApp Image 2026-09-08 at 10.08.42 PM (2).jpeg',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 2. Top-Left Menu Icon (☰)
                    Positioned(
                      left: posterW * 0.02,
                      top: imageH * 0.01,
                      width: posterW * 0.14,
                      height: imageH * 0.06,
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
                      right: posterW * 0.02,
                      top: imageH * 0.01,
                      width: posterW * 0.14,
                      height: imageH * 0.06,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => _showNotificationDialog(context),
                        ),
                      ),
                    ),

                    // 4. Action Button 1: Send Message / સંદેશ મોકલો (Green)
                    Positioned(
                      left: posterW * 0.04,
                      top: imageH * 0.755,
                      width: posterW * 0.29,
                      height: imageH * 0.055,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            context.go('/messages');
                          },
                        ),
                      ),
                    ),

                    // 5. Action Button 2: Call Now / હવે કોલ કરો (Blue)
                    Positioned(
                      left: posterW * 0.355,
                      top: imageH * 0.755,
                      width: posterW * 0.29,
                      height: imageH * 0.055,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFF041026),
                                content: Text(
                                  'Calling Hemantkumar Kapadiya (+91 98765 43210)...',
                                  style: TextStyle(color: Color(0xFFD4AF37)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // 6. Action Button 3: View Families / પરિવાર જુઓ (Purple)
                    Positioned(
                      left: posterW * 0.67,
                      top: imageH * 0.755,
                      width: posterW * 0.29,
                      height: imageH * 0.055,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => context.push('/family-details'),
                        ),
                      ),
                    ),

                    // 7. Pargana Pill 1: 35 પરગણાં
                    Positioned(
                      left: posterW * 0.135,
                      top: imageH * 0.825,
                      width: posterW * 0.175,
                      height: imageH * 0.075,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/pargana-overview'),
                        ),
                      ),
                    ),

                    // 8. Pargana Pill 2: 27 પરગણાં
                    Positioned(
                      left: posterW * 0.32,
                      top: imageH * 0.825,
                      width: posterW * 0.175,
                      height: imageH * 0.075,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/pargana-overview'),
                        ),
                      ),
                    ),

                    // 9. Pargana Pill 3: 16 પરગણાં
                    Positioned(
                      left: posterW * 0.505,
                      top: imageH * 0.825,
                      width: posterW * 0.175,
                      height: imageH * 0.075,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/pargana-overview'),
                        ),
                      ),
                    ),

                    // 10. Pargana Pill 4: 14 પરગણાં
                    Positioned(
                      left: posterW * 0.69,
                      top: imageH * 0.825,
                      width: posterW * 0.175,
                      height: imageH * 0.075,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.push('/pargana-overview'),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

