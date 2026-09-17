import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainPosterScreen extends ConsumerWidget {
  const MainPosterScreen({super.key});

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

  void _showCategoryModal(BuildContext context, String title, String details, IconData icon, Color color) {
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              details,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
              ),
              child: const Text('બંધ કરો (Close)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.paddingOf(context);
    final availableHeight = size.height - padding.top - padding.bottom;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: isMobile ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
            child: Container(
              width: isMobile ? size.width : 500,
              height: isMobile ? availableHeight : (500 * (1000 / 685)),
              margin: isMobile ? EdgeInsets.zero : const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF020B18),
                borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(16),
                border: isMobile ? null : Border.all(color: const Color(0xFFD4AF37), width: 2),
                boxShadow: isMobile
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                          blurRadius: 14,
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: isMobile ? BorderRadius.zero : BorderRadius.circular(14),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;

                      return Stack(
                        children: [
                          // 1. Post-Login Home Graphic: 1 (1).jpeg (Buddha Layout)
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/buddha_home_poster.jpeg',
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                'assets/images/1 (1).jpeg',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),

                          // 3. Top-Right Notification Bell Icon (🔔)
                          Positioned(
                            right: w * 0.02,
                            top: h * 0.015,
                            width: w * 0.14,
                            height: h * 0.045,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () => _showNotificationDialog(context),
                              ),
                            ),
                          ),

                          // 4. Circle 1: Government Employees (Red)
                          Positioned(
                            left: w * 0.02,
                            top: h * 0.49,
                            width: w * 0.22,
                            height: h * 0.16,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () => context.push('/government-employees'),
                              ),
                            ),
                          ),

                          // 5. Circle 2: Matrimony (Maroon) - GOES TO HOME
                          Positioned(
                            left: w * 0.26,
                            top: h * 0.49,
                            width: w * 0.22,
                            height: h * 0.16,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () => context.go('/home'),
                              ),
                            ),
                          ),

                          // 6. Circle 3: Private Job (Blue)
                          Positioned(
                            left: w * 0.50,
                            top: h * 0.49,
                            width: w * 0.22,
                            height: h * 0.16,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () => context.push('/private-employees'),
                              ),
                            ),
                          ),

                          // 7. Circle 4: VANKAR SAMAJ Services (Green)
                          Positioned(
                            left: w * 0.74,
                            top: h * 0.49,
                            width: w * 0.22,
                            height: h * 0.16,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () => context.push('/samaj-services'),
                              ),
                            ),
                          ),

                          // 8. Gold Button 1: પાવન પ્રેરણાદાતા (Bottom Left)
                          Positioned(
                            left: w * 0.08,
                            top: h * 0.77,
                            width: w * 0.42,
                            height: h * 0.15,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () => context.push('/pavan-prernadata'),
                              ),
                            ),
                          ),

                          // 9. Gold Button 2: Samaj Super Stars (Bottom Right)
                          Positioned(
                            left: w * 0.50,
                            top: h * 0.77,
                            width: w * 0.42,
                            height: h * 0.15,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () => context.push('/samaj-super-stars'),
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
          ),
        ),
      );
  }
}
