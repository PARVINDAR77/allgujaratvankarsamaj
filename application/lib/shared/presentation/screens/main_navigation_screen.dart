import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

class MainNavigationScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
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
