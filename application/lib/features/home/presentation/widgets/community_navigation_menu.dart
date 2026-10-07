import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../profile/providers/profile_provider.dart';
import '../providers/notifications_provider.dart';
import 'notifications_dialog.dart';

void showCommunityNavigationMenu(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.75),
    builder: (ctx) => const CommunityNavigationMenu(),
  );
}

class CommunityNavigationMenu extends ConsumerWidget {
  const CommunityNavigationMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.90;
    final authState = ref.watch(authNotifierProvider);
    final myProfileAsync = ref.watch(myProfileProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 580,
          maxHeight: maxHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0C1935),
                Color(0xFF071124),
                Color(0xFF040A17),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.12),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, -6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.85),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Top Drag Handle
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // 2. Royal App Brand Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Golden Crest Logo
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37), Color(0xFF8C6D15)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFF041126),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.temple_hindu,
                                color: Color(0xFFD4AF37),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title & Motto
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFFFFF2C2), Color(0xFFFFD700), Color(0xFFD4AF37)],
                              ).createShader(bounds),
                              child: const Text(
                                'All Gujarat Vankar Samaj',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4AF37).withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Text(
                                    'ઓલ ગુજરાત વણકર સમાજ',
                                    style: TextStyle(
                                      color: Color(0xFFFFDF7A),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'સંગઠન • સેવા • સમૃદ્ધિ',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.65),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Frosted Dismiss Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white70,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Color(0x22D4AF37), height: 16, thickness: 1),

                // 3. Scrollable Categorized List
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Profile Identity Card
                        _buildUserCard(context, ref, authState, myProfileAsync),
                        const SizedBox(height: 12),

                        // Section 1: Core Navigation (મુખ્ય સેવાઓ)
                        _buildSectionHeader('મુખ્ય સેવાઓ', 'Core Navigation', Icons.navigation_rounded),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.home_rounded,
                          gujaratiTitle: 'મુખ્ય પૃષ્ઠ',
                          englishSubtitle: 'Home Screen',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/home');
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.auto_awesome,
                          gujaratiTitle: 'મુખ્ય પોસ્ટર પૃષ્ઠ',
                          englishSubtitle: 'Main Poster Page',
                          isHighlighted: true,
                          badge: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 10, color: Colors.black),
                                SizedBox(width: 3),
                                Text(
                                  'વિશેષ / SPECIAL',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/main-poster');
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.search_rounded,
                          gujaratiTitle: 'પ્રોફાઇલ શોધો',
                          englishSubtitle: 'Search Profiles',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/search');
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.favorite_rounded,
                          gujaratiTitle: 'મેળ / પસંદગી',
                          englishSubtitle: 'Mutual Interest',
                          customIconColor: const Color(0xFFFF5E7E),
                          customBgTint: const Color(0xFFFF5E7E).withOpacity(0.16),
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/match');
                          },
                        ),

                        // Section 2: Community & Directory (સમાજ નેટવર્ક)
                        _buildSectionHeader('સમાજ નેટવર્ક', 'Community & Directory', Icons.hub_rounded),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.groups_rounded,
                          gujaratiTitle: 'પરિવાર ડિરેક્ટરી',
                          englishSubtitle: 'View Families',
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/family-details');
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.location_city_rounded,
                          gujaratiTitle: 'પરગણાં દર્શન',
                          englishSubtitle: 'Pargana Overview',
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/pargana-overview');
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.handshake_rounded,
                          gujaratiTitle: 'સમાજ સેવાઓ & વ્યવસાય',
                          englishSubtitle: 'Samaj Services',
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/samaj-services');
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.work_rounded,
                          gujaratiTitle: 'સરકારી કર્મચારી મંડળ',
                          englishSubtitle: 'Govt. Employees',
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/government-employees');
                          },
                        ),

                        // Section 3: Honors & Recognition (સમાજ ગૌરવ)
                        _buildSectionHeader('સમાજ ગૌરવ', 'Honors & Recognition', Icons.military_tech_rounded),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.verified_user_rounded,
                          gujaratiTitle: 'વેરિફાઈડ પ્રોફાઈલ',
                          englishSubtitle: 'Verified Profiles',
                          customIconColor: const Color(0xFF10B981),
                          customBgTint: const Color(0xFF10B981).withOpacity(0.16),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/verified-profile');
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.workspace_premium_rounded,
                          gujaratiTitle: 'સમાજ રત્ન સન્માન',
                          englishSubtitle: 'Samaj Ratna Awards',
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/samaj-ratna');
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.star_rounded,
                          gujaratiTitle: 'સમાજ સુપર સ્ટાર્સ',
                          englishSubtitle: 'Samaj Super Stars',
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/samaj-super-stars-poster');
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.lightbulb_rounded,
                          gujaratiTitle: 'પાવન પ્રેરણાદાતા',
                          englishSubtitle: 'Pavan Prernadata',
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/pavan-prernadata');
                          },
                        ),

                        // Section 4: Utilities & Support (ઉપયોગિતા અને સહાય)
                        _buildSectionHeader('સુવિધાઓ અને માહિતી', 'Utilities & Info', Icons.info_outline_rounded),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.campaign_rounded,
                          gujaratiTitle: 'જાહેરાતો & પ્રોમોશન્સ',
                          englishSubtitle: 'Advertisements',
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/advertisement');
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.notifications_active_rounded,
                          gujaratiTitle: 'સૂચનાઓ & ઘોષણાઓ',
                          englishSubtitle: 'Live Notifications',
                          badge: unreadCount > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF3366), Color(0xFFFF5E7E)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF3366).withOpacity(0.5),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '$unreadCount NEW',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            showNotificationsDialog(context, ref);
                          },
                        ),

                        const SizedBox(height: 18),

                        // 4. Executive Logout / Action Bar
                        if (authState.isAuthenticated)
                          _buildLogoutTile(context, ref),

                        // 5. Community Footer Branding
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 1,
                                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'All Gujarat Vankar Samaj • Digital App',
                                      style: TextStyle(
                                        color: const Color(0xFFD4AF37).withOpacity(0.75),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 24,
                                      height: 1,
                                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'આપણા સમાજનું ગૌરવ • ડિજિટલ સંગઠન • v1.0.0',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.38),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- User Profile Mini Banner ---
  Widget _buildUserCard(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    AsyncValue myProfileAsync,
  ) {
    if (!authState.isAuthenticated) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF162544), Color(0xFF0F1B33)],
          ),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, color: Color(0xFFD4AF37), size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'સમાજ સભ્ય લૉગિન',
                    style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'તમારું એકાઉન્ટ લૉગિન કરો અથવા નોંધણી કરો',
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                context.go('/login');
              },
              child: const Text('લૉગિન', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      );
    }

    return myProfileAsync.when(
      data: (profile) {
        final fullName = '${profile.firstName} ${profile.lastName}'.trim();
        final displayName = fullName.isNotEmpty ? fullName : (authState.user?.email ?? 'સમાજ સભ્ય');
        final isVerified = profile.isVerified == true || authState.user?.isVerified == true;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF142445), Color(0xFF0D182E)],
                ),
                border: Border.all(
                  color: isVerified
                      ? const Color(0xFF10B981).withOpacity(0.4)
                      : const Color(0xFFD4AF37).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isVerified ? const Color(0xFF10B981) : const Color(0xFFD4AF37),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF091426),
                      backgroundImage: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                          ? NetworkImage(profile.photoUrl!)
                          : null,
                      child: profile.photoUrl == null || profile.photoUrl!.isEmpty
                          ? Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'V',
                              style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 5),
                              const Icon(Icons.verified, color: Color(0xFF10B981), size: 16),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: isVerified
                                    ? const Color(0xFF10B981).withOpacity(0.18)
                                    : const Color(0xFFD4AF37).withOpacity(0.18),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isVerified ? 'વેરિફાઈડ સભ્ય' : 'સક્રિય સભ્ય',
                                style: TextStyle(
                                  color: isVerified ? const Color(0xFF34D399) : const Color(0xFFFFDF7A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (profile.pargana.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  profile.pargana,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 10.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Edit profile arrow
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: const Color(0xFFD4AF37).withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  // --- Section Category Header ---
  Widget _buildSectionHeader(String gujaratiTitle, String englishSubtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4.5),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.14),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.25),
                width: 0.8,
              ),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 13),
          ),
          const SizedBox(width: 8),
          Text(
            gujaratiTitle,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '• $englishSubtitle',
            style: TextStyle(
              color: Colors.white.withOpacity(0.42),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            height: 1,
            width: 45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4AF37).withOpacity(0.45),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Menu Item Card Component ---
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String gujaratiTitle,
    required String englishSubtitle,
    required VoidCallback onTap,
    bool isHighlighted = false,
    Widget? badge,
    Color? customIconColor,
    Color? customBgTint,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: isHighlighted
                  ? const LinearGradient(
                      colors: [Color(0xFF282006), Color(0xFF161203)],
                    )
                  : LinearGradient(
                      colors: [
                        const Color(0xFF101F3B).withOpacity(0.7),
                        const Color(0xFF091427).withOpacity(0.8),
                      ],
                    ),
              border: Border.all(
                color: isHighlighted
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFFD4AF37).withOpacity(0.12),
                width: isHighlighted ? 1.2 : 0.8,
              ),
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Squircle Icon Container
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: isHighlighted
                        ? const LinearGradient(
                            colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37)],
                          )
                        : null,
                    color: isHighlighted
                        ? null
                        : (customBgTint ?? const Color(0xFFD4AF37).withOpacity(0.14)),
                    border: Border.all(
                      color: isHighlighted
                          ? const Color(0xFFFFDF7A)
                          : (customIconColor ?? const Color(0xFFD4AF37)).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: isHighlighted
                          ? Colors.black
                          : (customIconColor ?? const Color(0xFFFFD700)),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 13),

                // Bilingual Label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        gujaratiTitle,
                        style: TextStyle(
                          color: isHighlighted ? const Color(0xFFFFDF7A) : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 1.5),
                      Text(
                        englishSubtitle,
                        style: TextStyle(
                          color: isHighlighted
                              ? Colors.white70
                              : const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Optional Badge
                if (badge != null) ...[
                  badge,
                  const SizedBox(width: 8),
                ],

                // Subtle Trailing Chevron
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: isHighlighted
                      ? const Color(0xFFFFDF7A)
                      : Colors.white.withOpacity(0.28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Executive Logout Tile ---
  Widget _buildLogoutTile(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (dCtx) => AlertDialog(
                backgroundColor: const Color(0xFF0A1832),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.logout, color: Color(0xFFD4AF37)),
                    SizedBox(width: 8),
                    Text('લૉગઆઉટની ખાતરી', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 17)),
                  ],
                ),
                content: const Text(
                  'શું તમે ખરેખર લૉગઆઉટ કરવા માંગો છો?\nAre you sure you want to log out?',
                  style: TextStyle(color: Colors.white, fontSize: 13.5),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dCtx, false),
                    child: const Text('રદ કરો (Cancel)', style: TextStyle(color: Colors.white70)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(dCtx, true),
                    child: const Text('હા, લૉગઆઉટ કરો', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );

            if (confirm == true && context.mounted) {
              Navigator.pop(context); // Close bottom sheet
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF2E0D14).withOpacity(0.55),
              border: Border.all(
                color: const Color(0xFFFF3366).withOpacity(0.28),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFFF3366).withOpacity(0.18),
                    border: Border.all(
                      color: const Color(0xFFFF3366).withOpacity(0.35),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.logout_rounded, color: Color(0xFFFF5E7E), size: 19),
                  ),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'લૉગઆઉટ (Logout)',
                        style: TextStyle(
                          color: Color(0xFFFF8FA3),
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.5),
                      Text(
                        'એકાઉન્ટમાંથી સુરક્ષિત બહાર નીકળો',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: const Color(0xFFFF8FA3).withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
