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

  void _showMenuDialog(BuildContext context, WidgetRef ref) {
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
                leading: const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37)),
                title: const Text('Main Poster Page (મુખ્ય પોસ્ટર પૃષ્ઠ)', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/main-poster');
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
                  context.go('/pargana-overview');
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
            ],
          ),
        ),
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
    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenW = constraints.maxWidth;
          final screenH = constraints.maxHeight > 0
              ? constraints.maxHeight
              : MediaQuery.of(context).size.height;
          // Scale factors: poster is 1080x1920, scale to fill the screen
          final double scaleX = screenW / 1080;
          final double scaleY = screenH / 1920;
          // Use the larger scale to cover entire screen (cover behavior)
          final double scale = scaleX > scaleY ? scaleX : scaleY;
          final double renderedW = 1080 * scale;
          final double renderedH = 1920 * scale;
          final double offsetX = (renderedW - screenW) / 2;
          final double offsetY = (renderedH - screenH) / 2;

          // Helper to convert poster coords to screen coords
          double sx(double x) => x * scale - offsetX;
          double sy(double y) => y * scale - offsetY;
          double sw(double w) => w * scale;
          double sh(double h) => h * scale;

          return SizedBox(
            width: screenW,
            height: screenH,
            child: ClipRect(
              child: Stack(
              children: [
                // Post-Login Matrimony Graphic — covers full screen
                Positioned(
                  left: -offsetX,
                  top: -offsetY,
                  width: renderedW,
                  height: renderedH,
                  child: Image.asset(
                    'assets/images/home_poster_v3.jpg',
                    fit: BoxFit.fill,
                    width: renderedW,
                    height: renderedH,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/1 (1).jpeg',
                      fit: BoxFit.fill,
                      width: renderedW,
                      height: renderedH,
                    ),
                  ),
                ),

                // Top-Left Menu Button (Hamburger)
                Positioned(
                  left: sx(20),
                  top: sy(30),
                  width: sw(150),
                  height: sh(90),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(45),
                      onTap: () => _showMenuDialog(context, ref),
                    ),
                  ),
                ),

                // Top-Right Notification Bell Icon (🔔)
                Positioned(
                  left: sx(910),
                  top: sy(30),
                  width: sw(150),
                  height: sh(90),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(45),
                      onTap: () => _showNotificationDialog(context),
                    ),
                  ),
                ),

                // --- Left Side Buttons ---
                // 1. Find Boy (Blue)
                Positioned(
                  left: sx(0),
                  top: sy(730),
                  width: sw(280),
                  height: sh(250),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/search'),
                    ),
                  ),
                ),
                // 2. Find Girl (Pink)
                Positioned(
                  left: sx(0),
                  top: sy(1000),
                  width: sw(280),
                  height: sh(250),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/search?lookingFor=Bride'),
                    ),
                  ),
                ),
                // 3. Find Match (Green)
                Positioned(
                  left: sx(0),
                  top: sy(1270),
                  width: sw(280),
                  height: sh(250),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/match'),
                    ),
                  ),
                ),

                // --- Right Side Buttons ---
                // 4. Create Profile (Orange)
                Positioned(
                  left: sx(800),
                  top: sy(730),
                  width: sw(280),
                  height: sh(250),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/profile/create'),
                    ),
                  ),
                ),
                // 5. Search (Purple)
                Positioned(
                  left: sx(800),
                  top: sy(1000),
                  width: sw(280),
                  height: sh(250),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/search'),
                    ),
                  ),
                ),
                // 6. Verified Profiles (Teal)
                Positioned(
                  left: sx(800),
                  top: sy(1270),
                  width: sw(280),
                  height: sh(250),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/verified-profile'),
                    ),
                  ),
                ),

                // --- Center Bottom ---
                // 7. Join Now
                Positioned(
                  left: sx(300),
                  top: sy(1555),
                  width: sw(480),
                  height: sh(100),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => context.push('/profile/create'),
                    ),
                  ),
                ),

                // --- Bottom Icons ---
                // 8. Education
                Positioned(
                  left: sx(0),
                  top: sy(1670),
                  width: sw(216),
                  height: sh(170),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showCategoryModal(context, 'Education', 'For Better Tomorrow', Icons.menu_book, const Color(0xFF1565C0)),
                    ),
                  ),
                ),
                // 9. Unity
                Positioned(
                  left: sx(216),
                  top: sy(1670),
                  width: sw(216),
                  height: sh(170),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showCategoryModal(context, 'Unity', 'In Diversity', Icons.groups, const Color(0xFFD84315)),
                    ),
                  ),
                ),
                // 10. Progress
                Positioned(
                  left: sx(432),
                  top: sy(1670),
                  width: sw(216),
                  height: sh(170),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showCategoryModal(context, 'Progress', 'Through Support', Icons.trending_up, const Color(0xFF2E7D32)),
                    ),
                  ),
                ),
                // 11. Service
                Positioned(
                  left: sx(648),
                  top: sy(1670),
                  width: sw(216),
                  height: sh(170),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showCategoryModal(context, 'Service', 'To Society', Icons.volunteer_activism, const Color(0xFFC62828)),
                    ),
                  ),
                ),
                // 12. Strong Roots
                Positioned(
                  left: sx(864),
                  top: sy(1670),
                  width: sw(216),
                  height: sh(170),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showCategoryModal(context, 'Strong Roots', 'Bright Future', Icons.nature, const Color(0xFF1565C0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        },
      ),
    );
  }
}
