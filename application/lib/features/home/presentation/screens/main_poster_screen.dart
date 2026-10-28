import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/advertisements/providers/advertisements_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/view_badge.dart';
import '../providers/views_provider.dart';
import '../widgets/notifications_dialog.dart';
import '../widgets/community_navigation_menu.dart';
import 'community_web_home_screen.dart';
class MainPosterScreen extends ConsumerStatefulWidget {
  const MainPosterScreen({super.key});

  @override
  ConsumerState<MainPosterScreen> createState() => _MainPosterScreenState();
}

class _MainPosterScreenState extends ConsumerState<MainPosterScreen> with WidgetsBindingObserver {

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
      // Invalidate the provider on resume so it fetches fresh data
      ref.invalidate(advertisementsProvider);
      ref.invalidate(viewsProvider);
    }
  }




  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const CommunityWebHomeScreen();
    }

    final unreadNotificationCount = ref.watch(unreadNotificationCountProvider);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    if (isMobile) {
      return Scaffold(
        backgroundColor: const Color(0xFF020B18),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SizedBox.expand(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildPosterStack(
                  context,
                  ref,
                  constraints.maxWidth,
                  constraints.maxHeight,
                  unreadNotificationCount,
                );
              },
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: 500,
              height: 500 * (1600 / 735),
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF020B18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return _buildPosterStack(
                      context,
                      ref,
                      constraints.maxWidth,
                      constraints.maxHeight,
                      unreadNotificationCount,
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

  Widget _buildPosterStack(
    BuildContext context,
    WidgetRef ref,
    double w,
    double h,
    int unreadNotificationCount,
  ) {
    return Stack(
      children: [
        // 1. Post-Login Home Graphic: 2 image.jpeg (New layout)
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/2 image.jpeg',
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                'assets/images/1 (1).jpeg',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),

                          // 2. Top-Left Menu Button (Hamburger)
                          Positioned(
                            left: w * 0.02,
                            top: h * 0.015,
                            width: w * 0.14,
                            height: h * 0.045,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () => showCommunityNavigationMenu(context, ref),
                              ),
                            ),
                          ),

                          // 3. Top-Right Notification Bell Icon (🔔)
                          Positioned(
                            right: w * 0.02,
                            top: h * 0.015,
                            width: w * 0.14,
                            height: h * 0.045,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30),
                                      onTap: () => showNotificationsDialog(context, ref),
                                    ),
                                  ),
                                ),
                                if (unreadNotificationCount > 0)
                                  Positioned(
                                    right: 4,
                                    top: 2,
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
                          ),

                          // 4. Circle 1: Government Employees (Red)
                          Positioned(
                            left: w * 0.02,
                            top: h * 0.48,
                            width: w * 0.18,
                            height: h * 0.12,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () => context.push('/government-employees'),
                              ),
                            ),
                          ),

                          // 5. Circle 2: Matrimony (Pink)
                          Positioned(
                            left: w * 0.21,
                            top: h * 0.48,
                            width: w * 0.18,
                            height: h * 0.12,
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
                            left: w * 0.41,
                            top: h * 0.48,
                            width: w * 0.18,
                            height: h * 0.12,
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
                            left: w * 0.61,
                            top: h * 0.48,
                            width: w * 0.18,
                            height: h * 0.12,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () => context.push('/samaj-services'),
                              ),
                            ),
                          ),

                          // 8. Circle 5: VANKAR SAMAJ Ratna (Purple)
                          Positioned(
                            left: w * 0.80,
                            top: h * 0.48,
                            width: w * 0.18,
                            height: h * 0.12,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () => context.push('/samaj-ratna'),
                              ),
                            ),
                          ),

                          // 9. Gold Button 1: પાવન પ્રેરણાદાતા
                          Positioned(
                            left: w * 0.03,
                            top: h * 0.75,
                            width: w * 0.30,
                            height: h * 0.08,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => context.push('/pavan-prernadata'),
                              ),
                            ),
                          ),

                          // 10. Gold Button 2: Samaj Super Stars
                          Positioned(
                            left: w * 0.35,
                            top: h * 0.75,
                            width: w * 0.30,
                            height: h * 0.08,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => context.push('/samaj-super-stars-poster'),
                              ),
                            ),
                          ),

                          // 11. Gold Button 3: Family Directory
                          Positioned(
                            left: w * 0.67,
                            top: h * 0.75,
                            width: w * 0.30,
                            height: h * 0.08,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => context.push('/family-details'),
                              ),
                            ),
                          ),

                          // 12. Bottom Icon 1: Education for Better Tomorrow
                          Positioned(
                            left: w * 0.00,
                            top: h * 0.86,
                            width: w * 0.20,
                            height: h * 0.12,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      onTap: () {
                                        ref.read(incrementViewProvider)('HOME_EDUCATION');
                                        context.push('/education');
                                      },
                                    ),
                                  ),
                                ),
                                const Align(
                                  alignment: Alignment.bottomCenter,
                                  child: IgnorePointer(child: ViewBadge(sectionName: 'HOME_EDUCATION')),
                                ),
                              ],
                            ),
                          ),

                          // 13. Bottom Icon 2: Unity in Diversity (Advertisement Space 1)
                          Positioned(
                            left: w * 0.20,
                            top: h * 0.86,
                            width: w * 0.20,
                            height: h * 0.12,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      onTap: () {
                                        ref.read(incrementViewProvider)('HOME_UNITY');
                                        context.push('/advertisement?section=HOME_UNITY');
                                      },
                                    ),
                                  ),
                                ),
                                const Align(
                                  alignment: Alignment.bottomCenter,
                                  child: IgnorePointer(child: ViewBadge(sectionName: 'HOME_UNITY')),
                                ),
                              ],
                            ),
                          ),

                          // 14. Bottom Icon 3: Progress Through Support (Live Statistics)
                          Positioned(
                            left: w * 0.40,
                            top: h * 0.86,
                            width: w * 0.20,
                            height: h * 0.12,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      onTap: () {
                                        ref.read(incrementViewProvider)('HOME_PROGRESS');
                                        context.push('/statistics');
                                      },
                                    ),
                                  ),
                                ),
                                const Align(
                                  alignment: Alignment.bottomCenter,
                                  child: IgnorePointer(child: ViewBadge(sectionName: 'HOME_PROGRESS')),
                                ),
                              ],
                            ),
                          ),

                          // 15. Bottom Icon 4: Service to Society (Today's Birthdays)
                          Positioned(
                            left: w * 0.60,
                            top: h * 0.86,
                            width: w * 0.20,
                            height: h * 0.12,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      onTap: () {
                                        ref.read(incrementViewProvider)('HOME_SERVICE');
                                        context.push('/birthdays');
                                      },
                                    ),
                                  ),
                                ),
                                const Align(
                                  alignment: Alignment.bottomCenter,
                                  child: IgnorePointer(child: ViewBadge(sectionName: 'HOME_SERVICE')),
                                ),
                              ],
                            ),
                          ),

                          // 16. Bottom Icon 5: Strong Roots Bright Future (Advertisement Space 2)
                          Positioned(
                            left: w * 0.80,
                            top: h * 0.86,
                            width: w * 0.20,
                            height: h * 0.12,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      onTap: () {
                                        ref.read(incrementViewProvider)('HOME_STRONG_ROOTS');
                                        context.push('/advertisement?section=HOME_STRONG_ROOTS');
                                      },
                                    ),
                                  ),
                                ),
                                const Align(
                                  alignment: Alignment.bottomCenter,
                                  child: IgnorePointer(child: ViewBadge(sectionName: 'HOME_STRONG_ROOTS')),
                                ),
                              ],
                            ),
                          ),
                        ],
    );
  }
}
