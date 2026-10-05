import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../features/advertisements/providers/advertisements_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/views_provider.dart';
import '../widgets/notifications_dialog.dart';

final homeButtonsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final dio = ref.watch(apiClientProvider);
    final response = await dio.get('/home-buttons');
    dynamic raw = response.data;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {}
    }
    if (raw is Map && raw.containsKey('data')) {
      raw = raw['data'];
    }
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  } catch (e) {
    return [];
  }
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Invalidate the providers on resume so they fetch fresh data
      ref.invalidate(advertisementsProvider);
      ref.invalidate(homeButtonsProvider);
    }
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
                leading: const Icon(Icons.workspace_premium, color: Color(0xFFD4AF37)),
                title: const Text('Samaj Ratna (સમાજ રત્ન)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/samaj-ratna');
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.star, color: Color(0xFFD4AF37)),
                title: const Text('Samaj Super Stars (સમાજ સુપર સ્ટાર્સ)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/samaj-super-stars-poster');
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.lightbulb, color: Color(0xFFD4AF37)),
                title: const Text('Pavan Prernadata (પાવન પ્રેરણાદાતા)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/pavan-prernadata');
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.campaign, color: Color(0xFFD4AF37)),
                title: const Text('Advertisements (જાહેરાતો)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/advertisement');
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.notifications, color: Color(0xFFD4AF37)),
                title: const Text('Notifications (સૂચનાઓ)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  showNotificationsDialog(context, ref);
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

  void _handleBottomButtonTap(
    BuildContext context,
    WidgetRef ref,
    int buttonId,
    String defaultTitle,
    String defaultDetails,
    IconData icon,
    Color color,
    String sectionName,
    String fallbackRoute,
  ) {
    ref.read(incrementViewProvider)(sectionName);

    // Look up dynamic route from homeButtonsProvider
    final homeButtonsAsync = ref.read(homeButtonsProvider);
    String targetRoute = fallbackRoute;

    homeButtonsAsync.whenData((buttons) {
      final match = buttons.firstWhere(
        (b) => b['buttonId'] == buttonId || b['buttonId']?.toString() == buttonId.toString(),
        orElse: () => <String, dynamic>{},
      );
      if (match.isNotEmpty && match['route'] != null && match['route'].toString().trim().isNotEmpty) {
        targetRoute = match['route'].toString().trim();
      }
    });

    if (targetRoute.isNotEmpty) {
      context.push(targetRoute);
    } else {
      _showCategoryModal(context, defaultTitle, defaultDetails, icon, color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadNotificationCount = ref.watch(unreadNotificationCountProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenW = constraints.maxWidth;
          final screenH = constraints.maxHeight > 0
              ? constraints.maxHeight
              : MediaQuery.of(context).size.height;
          // Scale factors: poster is 1080x1920, stretch to fill the screen exactly
          final double scaleX = screenW / 1080;
          final double scaleY = screenH / 1920;
          
          final double renderedW = screenW;
          final double renderedH = screenH;
          final double offsetX = 0;
          final double offsetY = 0;

          // Helper to convert poster coords to screen coords independently
          double sx(double x) => x * scaleX;
          double sy(double y) => y * scaleY;
          double sw(double w) => w * scaleX;
          double sh(double h) => h * scaleY;

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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(45),
                            onTap: () => showNotificationsDialog(context, ref),
                          ),
                        ),
                      ),
                      if (unreadNotificationCount > 0)
                        Positioned(
                          right: sw(16),
                          top: sy(4),
                          child: IgnorePointer(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              constraints: BoxConstraints(
                                minWidth: sw(32).clamp(18.0, 26.0),
                                minHeight: sh(32).clamp(18.0, 26.0),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                unreadNotificationCount > 99 ? '99+' : '$unreadNotificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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
                      onTap: () => context.go('/search?lookingFor=Groom'),
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
                      onTap: () => context.go('/search?lookingFor=Bride'),
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
                      onTap: () => context.go('/match'),
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
                      onTap: () => context.go('/search'),
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

                // --- Golden Buttons (Middle section above Join Now) ---
                // 1. Pavan Prernadata
                Positioned(
                  left: sx(20),
                  top: sy(1415),
                  width: sw(330),
                  height: sh(130),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/pavan-prernadata'),
                    ),
                  ),
                ),
                // 2. Samaj Super Stars
                Positioned(
                  left: sx(370),
                  top: sy(1415),
                  width: sw(340),
                  height: sh(130),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/samaj-super-stars-poster'),
                    ),
                  ),
                ),
                // 3. Family Directory
                Positioned(
                  left: sx(730),
                  top: sy(1415),
                  width: sw(330),
                  height: sh(130),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/family-details'),
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
                // 8. Education (Button 1) -> /samaj-ratna
                Positioned(
                  left: sx(0),
                  top: sy(1670),
                  width: sw(216),
                  height: sh(170),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleBottomButtonTap(context, ref, 1, 'Education', 'For Better Tomorrow', Icons.menu_book, const Color(0xFF1565C0), 'HOME_EDUCATION', '/samaj-ratna'),
                    ),
                  ),
                ),
                // 9. Unity (Button 2) -> /advertisement
                Positioned(
                  left: sx(216),
                  top: sy(1670),
                  width: sw(216),
                  height: sh(170),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleBottomButtonTap(context, ref, 2, 'Unity', 'In Diversity', Icons.groups, const Color(0xFFD84315), 'HOME_UNITY', '/advertisement'),
                    ),
                  ),
                ),
                // 10. Progress (Button 3) -> /statistics
                Positioned(
                  left: sx(432),
                  top: sy(1670),
                  width: sw(216),
                  height: sh(170),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleBottomButtonTap(context, ref, 3, 'Progress', 'Through Support', Icons.trending_up, const Color(0xFF2E7D32), 'HOME_PROGRESS', '/statistics'),
                    ),
                  ),
                ),
                // 11. Service (Button 4) -> /birthdays
                Positioned(
                  left: sx(648),
                  top: sy(1670),
                  width: sw(216),
                  height: sh(170),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleBottomButtonTap(context, ref, 4, 'Service', 'To Society', Icons.volunteer_activism, const Color(0xFFC62828), 'HOME_SERVICE', '/birthdays'),
                    ),
                  ),
                ),
                // 12. Strong Roots (Button 5) -> /advertisement
                Positioned(
                  left: sx(864),
                  top: sy(1670),
                  width: sw(216),
                  height: sh(170),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleBottomButtonTap(context, ref, 5, 'Strong Roots', 'Bright Future', Icons.nature, const Color(0xFF1565C0), 'HOME_STRONG_ROOTS', '/advertisement'),
                    ),
                  ),
                ),

                // ── Success Stories quick-access button ────────────────────
                Positioned(
                  left: sx(30),
                  bottom: sh(60),
                  child: GestureDetector(
                    onTap: () => context.push('/success-stories'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite, color: Colors.black, size: 18),
                          SizedBox(width: 6),
                          Text('Success Stories',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
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
