import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../features/profile/providers/profile_provider.dart';

class MainNavigationScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.secondary, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
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

            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: Colors.white60,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'હોમ'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'શોધો'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'મેળ'),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: 'મેસેજ'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'પ્રોફાઈલ'),
          ],
        ),
      ),
    );
  }
}
