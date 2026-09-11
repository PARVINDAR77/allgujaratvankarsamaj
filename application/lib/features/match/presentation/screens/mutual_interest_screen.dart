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
              'Mutual Interest (પરસ્પર પસંદગી)',
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
              leading: const Icon(Icons.groups, color: Color(0xFFD4AF37)),
              title: const Text('View Families (પરિવાર જુઓ)', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/family-details');
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
            aspectRatio: 1024 / 1536,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                return Stack(
                  children: [
                    // 1. Full Master Mutual Interest Image (Exact 1:1 match of WhatsApp Image 2026-09-08 at 10.08.42 PM (2).jpeg)
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/template_mutual.jpg',
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/WhatsApp Image 2026-09-08 at 10.08.42 PM (2).jpeg',
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
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

                    // 4. Action Button 1: Send Message / સંદેશ મોકલો (Green)
                    Positioned(
                      left: w * 0.04,
                      top: h * 0.755,
                      width: w * 0.29,
                      height: h * 0.055,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            context.go('/messages');
                          },
                        ),
                      ),
                    ),

                    // 5. Action Button 2: Call Now / હવે કોલ કરો (Blue)
                    Positioned(
                      left: w * 0.355,
                      top: h * 0.755,
                      width: w * 0.29,
                      height: h * 0.055,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
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
                      left: w * 0.67,
                      top: h * 0.755,
                      width: w * 0.29,
                      height: h * 0.055,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => context.push('/family-details'),
                        ),
                      ),
                    ),

                    // 7. Pargana Pill 1: 35 પરગણાં
                    Positioned(
                      left: w * 0.135,
                      top: h * 0.825,
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

                    // 8. Pargana Pill 2: 27 પરગણાં
                    Positioned(
                      left: w * 0.32,
                      top: h * 0.825,
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

                    // 9. Pargana Pill 3: 16 પરગણાં
                    Positioned(
                      left: w * 0.505,
                      top: h * 0.825,
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

                    // 10. Pargana Pill 4: 14 પરગણાં
                    Positioned(
                      left: w * 0.69,
                      top: h * 0.825,
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

                    // 11. Bottom Navigation Bar Tabs:
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

                    // Tab 3: પરસ્પર પસંદગી (Match - Heart Center)
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

