import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../features/advertisements/providers/advertisements_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/views_provider.dart';
import '../widgets/notifications_dialog.dart';
import '../widgets/community_navigation_menu.dart';
import '../../../profile/providers/profile_provider.dart';

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
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).refresh();
    });
    // Poll for live broadcast notifications every 45 seconds
    _notificationTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (mounted) {
        ref.read(notificationsProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Invalidate the providers on resume so they fetch fresh data
      ref.invalidate(advertisementsProvider);
      ref.invalidate(homeButtonsProvider);
      ref.read(notificationsProvider.notifier).refresh();
    }
  }


  void _showMenuDialog(BuildContext context, WidgetRef ref) {
    showCommunityNavigationMenu(context, ref);
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

          // Responsive full-viewport configuration:
          // On mobile, fill the screen edge-to-edge in width and height (above bottom bar)
          // so all 5 community buttons, labels, and bottom banner are 100% visible with zero scrolling.
          // On desktop/tablet, constrain to mobile phone aspect ratio centered on screen.
          final isMobile = screenW < 600;
          final double posterH = isMobile ? screenH : screenH.clamp(500.0, 920.0);
          final double posterW = isMobile ? screenW : (posterH * (1080.0 / 1920.0)).clamp(360.0, 520.0);

          final double scaleX = posterW / 1080.0;
          final double scaleY = posterH / 1920.0;

          // Helper to convert poster coords to screen coords
          double sx(double x) => x * scaleX;
          double sy(double y) => y * scaleY;
          double sw(double w) => w * scaleX;
          double sh(double h) => h * scaleY;

          return SizedBox(
            width: screenW,
            height: screenH,
            child: Center(
              child: SizedBox(
                width: posterW,
                height: posterH,
                child: Stack(
                  children: [
                    // Post-Login Matrimony Graphic - 100% natural proportions
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/home_poster_clean_v4.jpg',
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/1 (1).jpeg',
                          fit: BoxFit.fill,
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

                // Top-Right Live Notification Bell (🔔)
                Positioned(
                  left: sx(910),
                  top: sy(20),
                  width: sw(150),
                  height: sh(110),
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        final bellSize = (sw(120) < sh(100) ? sw(120) : sh(100)).clamp(46.0, 56.0);
                        return SizedBox(
                          width: bellSize,
                          height: bellSize,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Golden Circle Bell Button
                              Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(bellSize / 2),
                                  splashColor: const Color(0xFFFFD700).withValues(alpha: 0.35),
                                  highlightColor: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                  onTap: () => showNotificationsDialog(context, ref),
                                  child: Container(
                                    width: bellSize,
                                    height: bellSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const RadialGradient(
                                        center: Alignment(0.0, -0.2),
                                        radius: 0.85,
                                        colors: [
                                          Color(0xFF0F2B52),
                                          Color(0xFF030D1C),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFD4AF37),
                                        width: 2.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                        const BoxShadow(
                                          color: Colors.black54,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        unreadNotificationCount > 0
                                            ? Icons.notifications_active
                                            : Icons.notifications,
                                        color: const Color(0xFFFFD700),
                                        size: bellSize * 0.54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Real-Time Dynamic Unread Badge (Appears ONLY when unread > 0)
                              if (unreadNotificationCount > 0)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: IgnorePointer(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                        minHeight: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE53935),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black54,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        unreadNotificationCount > 99
                                            ? '99+'
                                            : '$unreadNotificationCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
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
                      onTap: () {
                        ref.read(profileNotifierProvider.notifier).updateFilters(gender: 'MALE');
                        context.push('/search-results?gender=MALE');
                      },
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
                      onTap: () {
                        ref.read(profileNotifierProvider.notifier).updateFilters(gender: 'FEMALE');
                        context.push('/search-results?gender=FEMALE');
                      },
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
                // 5. Center Button (Purple - Liked Profiles / પસંદ કરેલ પ્રોફાઈલ)
                Positioned(
                  left: sx(800),
                  top: sy(1000),
                  width: sw(280),
                  height: sh(250),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/liked-profiles'),
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
                // 8. Education (Button 1) -> /education
                Positioned(
                  left: sx(0),
                  top: sy(1670),
                  width: sw(216),
                  height: sh(170),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleBottomButtonTap(context, ref, 1, 'Education', 'For Better Tomorrow', Icons.menu_book, const Color(0xFF1565C0), 'HOME_EDUCATION', '/education'),
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

                    ],
                  ),
                ),
              ),
            );
        },
      ),
    );
  }
}
