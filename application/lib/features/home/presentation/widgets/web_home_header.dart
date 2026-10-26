import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../providers/notifications_provider.dart';
import 'community_navigation_menu.dart';
import 'notifications_dialog.dart';
import '../../../profile/presentation/widgets/update_password_dialog.dart';

class WebHomeHeader extends ConsumerWidget implements PreferredSizeWidget {
  final String activeRoute;

  const WebHomeHeader({
    super.key,
    this.activeRoute = '/main-poster',
  });

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final isTablet = width >= 768 && width < 1100;
    final authState = ref.watch(authNotifierProvider);
    final unreadNotificationCount = ref.watch(unreadNotificationCountProvider);

    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD6A34A).withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : (isTablet ? 20 : 12),
          ),
          child: Row(
            children: [
              // 1. Logo & Brand
              _buildBrand(context),

              const Spacer(),

              // 2. Navigation Links (Desktop only)
              if (isDesktop) ...[
                _buildNavLink(context, 'Home', '/main-poster', isActive: activeRoute == '/main-poster'),
                _buildNavLink(context, 'Matrimony', '/home', isActive: activeRoute == '/home'),
                _buildNavLink(context, 'Govt. Employees', '/government-employees', isActive: activeRoute == '/government-employees'),
                _buildNavLink(context, 'Private Job', '/private-employees', isActive: activeRoute == '/private-employees'),
                _buildNavLink(context, 'Samaj Services', '/samaj-services', isActive: activeRoute == '/samaj-services'),
                _buildNavLink(context, 'Directory', '/family-details', isActive: activeRoute == '/family-details'),
                const SizedBox(width: 12),
              ],

              // 3. Notification Bell (if logged in)
              if (authState.isAuthenticated) ...[
                _buildNotificationBell(context, ref, unreadNotificationCount),
                const SizedBox(width: 12),
              ],

              // 4. Auth Actions
              if (isDesktop || isTablet) ...[
                if (!authState.isAuthenticated) ...[
                  _buildLoginButton(context),
                  const SizedBox(width: 10),
                  _buildRegisterButton(context),
                ] else ...[
                  _buildProfileButton(context),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.lock_reset_rounded, color: Color(0xFFA4143D), size: 24),
                    tooltip: 'પાસવર્ડ બદલો (Update Password)',
                    onPressed: () => showUpdatePasswordDialog(context, ref),
                  ),
                  const SizedBox(width: 6),
                  _buildLogoutButton(context, ref),
                ],
              ],

              // 5. Mobile / Tablet Menu Button
              if (!isDesktop) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Color(0xFFA4143D), size: 28),
                  tooltip: 'Menu',
                  onPressed: () => showCommunityNavigationMenu(context, ref),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrand(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/main-poster'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Official Emblem with gold ring
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4AF37),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  color: Colors.white,
                  child: Image.asset(
                    'assets/images/vankar_samaj_official_emblem.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.temple_hindu,
                      color: Color(0xFFA4143D),
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Typography
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'All Gujarat Vankar Samaj',
                    style: TextStyle(
                      color: Color(0xFF101B36),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      height: 1.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'એક સમાજ, એક વિચાર, એક પરિવાર',
                    style: TextStyle(
                      color: Color(0xFFA4143D),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavLink(BuildContext context, String title, String route, {bool isActive = false}) {
    return _HoverNavLink(
      title: title,
      isActive: isActive,
      onTap: () {
        if (route == '/main-poster') {
          context.go('/main-poster');
        } else {
          context.push(route);
        }
      },
    );
  }

  Widget _buildNotificationBell(BuildContext context, WidgetRef ref, int unreadCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFFA4143D), size: 24),
          tooltip: 'Notifications',
          onPressed: () => showNotificationsDialog(context, ref),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => context.push('/login'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFA4143D),
        side: const BorderSide(color: Color(0xFFA4143D), width: 1.3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.login_rounded, size: 16, color: Color(0xFFA4143D)),
          SizedBox(width: 6),
          Text(
            'Login',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFA4143D), Color(0xFF7E102F)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6A34A), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA4143D).withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => context.push('/register'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add_alt_1_rounded, size: 16, color: Color(0xFFFFD700)),
            SizedBox(width: 6),
            Text(
              'Register',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    final isCurrent = activeRoute == '/profile';
    return ElevatedButton.icon(
      onPressed: () => context.go('/profile'),
      icon: const Icon(Icons.person_rounded, size: 16, color: Color(0xFFFFD700)),
      label: const Text(
        'My Profile',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCurrent ? const Color(0xFF7E102F) : const Color(0xFFA4143D),
        foregroundColor: Colors.white,
        side: BorderSide(
          color: isCurrent ? Colors.white : const Color(0xFFD6A34A),
          width: isCurrent ? 1.6 : 1.1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Logout',
      icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF8A80), size: 20),
      onPressed: () async {
        await ref.read(authNotifierProvider.notifier).logout();
        if (context.mounted) {
          context.go('/login');
        }
      },
    );
  }
}

class _HoverNavLink extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _HoverNavLink({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_HoverNavLink> createState() => _HoverNavLinkState();
}

class _HoverNavLinkState extends State<_HoverNavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeOrHover = widget.isActive || _isHovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: activeOrHover ? const Color(0xFFA4143D) : Colors.transparent,
                width: 2.2,
              ),
            ),
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              color: activeOrHover ? const Color(0xFFA4143D) : const Color(0xFF374151),
              fontWeight: activeOrHover ? FontWeight.bold : FontWeight.w500,
              fontSize: 13.5,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
