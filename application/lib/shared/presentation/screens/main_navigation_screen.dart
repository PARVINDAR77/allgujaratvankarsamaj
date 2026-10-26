import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../features/match/providers/match_provider.dart';
import '../../../features/profile/providers/profile_provider.dart';

class MainNavigationScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchState = ref.watch(matchProvider);
    final receivedRequestsCount = matchState.receivedInterests.length;
    final isDesktopWeb = kIsWeb && MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: isDesktopWeb
          ? null
          : Container(
        color: AppColors.background,
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.secondary, width: 1)),
                ),
                child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex.clamp(0, 3),
          onTap: (index) {
            if (index == 4) {
              context.go('/profile');
              return;
            }

            if (index == 1) {
              // Reset all search and gender locks in profile provider for universal discovery
              ref.read(profileNotifierProvider.notifier).updateFilters(
                search: null,
                gender: '',
                status: null,
                maritalStatus: null,
                minAge: null,
                maxAge: null,
                districtId: null,
                occupationCategory: null,
              );
              // Always return to the root /search screen
              navigationShell.goBranch(
                1,
                initialLocation: true,
              );
              return;
            }

            if (index == 2) {
              // Refresh match requests when opening મેળ tab
              ref.read(matchProvider.notifier).loadAll(silent: true);
            }

            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: Colors.white60,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'હોમ'),
            const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'શોધો'),
            BottomNavigationBarItem(
              icon: Badge.count(
                count: receivedRequestsCount,
                isLabelVisible: receivedRequestsCount > 0,
                backgroundColor: const Color(0xFFEF4444),
                textColor: Colors.white,
                child: const Icon(Icons.favorite),
              ),
              activeIcon: Badge.count(
                count: receivedRequestsCount,
                isLabelVisible: receivedRequestsCount > 0,
                backgroundColor: const Color(0xFFEF4444),
                textColor: Colors.white,
                child: const Icon(Icons.favorite),
              ),
              label: 'મેળ',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.message), label: 'મેસેજ'),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'પ્રોફાઈલ'),
          ],
        ),
      ),
            ),
          ),
        ),
      ),
    );
  }
}
