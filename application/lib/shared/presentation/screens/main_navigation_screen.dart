import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';

class MainNavigationScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScreen({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: (currentIndex == 0 || currentIndex == 2)
          ? null
          : Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF020917),
          border: const Border(
            top: BorderSide(color: AppColors.secondary, width: 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 1. Home
            _buildNavItem(
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'હોમ',
              isSelected: currentIndex == 0,
              onTap: () => _goBranch(0),
            ),

            // 2. Search
            _buildNavItem(
              index: 1,
              icon: Icons.search_outlined,
              activeIcon: Icons.search,
              label: 'શોધો',
              isSelected: currentIndex == 1,
              onTap: () => _goBranch(1),
            ),

            // 3. Central Elevated Golden Match Button ("મેળ")
            InkWell(
              onTap: () => _goBranch(2),
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.goldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                        border: Border.all(
                          color: currentIndex == 2 ? Colors.white : AppColors.goldLight,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'પરસ્પર પસંદગી',
                      style: TextStyle(
                        color: currentIndex == 2 ? AppColors.secondary : Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Messages (with notification badge '5')
            _buildNavItem(
              index: 3,
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: 'મેસેજ',
              isSelected: currentIndex == 3,
              badgeText: '5',
              onTap: () => _goBranch(3),
            ),

            // 5. Profile
            _buildNavItem(
              index: 4,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'પ્રોફાઇલ',
              isSelected: currentIndex == 4,
              onTap: () => _goBranch(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.secondary : Colors.white60,
                  size: 24,
                ),
                if (badgeText != null)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F2F),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.secondary : Colors.white60,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
