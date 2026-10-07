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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) {
        final screenH = MediaQuery.of(ctx).size.height;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 580,
              maxHeight: screenH * 0.90,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF071838),
                    Color(0xFF040E22),
                    Color(0xFF020712),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 35,
                    spreadRadius: 5,
                    offset: const Offset(0, -10),
                  ),
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top drag pill
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 44,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Header: Logo, Title, Subtitle, Close Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0E2752).withOpacity(0.9),
                              const Color(0xFF071836).withOpacity(0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Glowing Circular Logo
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFD4AF37),
                                  width: 1.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withOpacity(0.35),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFF0B1E3D),
                                    child: const Icon(
                                      Icons.account_balance,
                                      color: Color(0xFFD4AF37),
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Brand Titles
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'અખિલ ગુજરાત વણકર સમાજ',
                                    style: TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'All Gujarat Vankar Samaj',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4AF37).withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFD4AF37).withOpacity(0.4),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: const Text(
                                      'એકતા • સેવા • પ્રગતિ',
                                      style: TextStyle(
                                        color: Color(0xFFFFE082),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Close Button
                            InkWell(
                              onTap: () => Navigator.pop(ctx),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Scrollable Menu Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Quick Navigation Grid (2x2)
                            _buildMenuSectionTitle('મુખ્ય સેવાઓ', 'QUICK ACCESS', Icons.flash_on_rounded),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickActionCard(
                                    icon: Icons.home_rounded,
                                    title: 'મુખ્ય પૃષ્ઠ',
                                    subtitle: 'Home Portal',
                                    accentColor: const Color(0xFF3B82F6),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      context.go('/home');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildQuickActionCard(
                                    icon: Icons.auto_awesome_rounded,
                                    title: 'મુખ્ય પોસ્ટર',
                                    subtitle: 'Poster View',
                                    accentColor: const Color(0xFFF59E0B),
                                    badge: 'Featured',
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      context.push('/main-poster');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickActionCard(
                                    icon: Icons.person_search_rounded,
                                    title: 'પ્રોફાઈલ શોધો',
                                    subtitle: 'Search Profiles',
                                    accentColor: const Color(0xFF10B981),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      context.go('/search');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildQuickActionCard(
                                    icon: Icons.favorite_rounded,
                                    title: 'પરસ્પર મેળ',
                                    subtitle: 'Mutual Match',
                                    accentColor: const Color(0xFFEC4899),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      context.go('/match');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // 2. Community & Services Section
                            _buildMenuSectionTitle('સમાજ અને સમુદાય', 'COMMUNITY DIRECTORY', Icons.groups_rounded),
                            const SizedBox(height: 8),
                            _buildModernMenuItem(
                              icon: Icons.handshake_rounded,
                              iconGradient: const [Color(0xFFF59E0B), Color(0xFFB45309)],
                              title: 'સમાજ સેવાઓ (Samaj Services)',
                              subtitle: '128+ વ્યાવસાયિક સેવાઓ અને સુવિધાઓ',
                              badgeText: '128+ Services',
                              badgeColor: const Color(0xFFF59E0B),
                              onTap: () {
                                Navigator.pop(ctx);
                                context.push('/samaj-services');
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildModernMenuItem(
                              icon: Icons.groups_rounded,
                              iconGradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                              title: 'પરિવાર જુઓ (View Families)',
                              subtitle: 'સમાજ પરિવાર અને શાખા ડિરેક્ટરી',
                              onTap: () {
                                Navigator.pop(ctx);
                                context.push('/family-details');
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildModernMenuItem(
                              icon: Icons.account_balance_rounded,
                              iconGradient: const [Color(0xFF06B6D4), Color(0xFF0E7490)],
                              title: 'પરગણાં (Pargana Overview)',
                              subtitle: 'ગુજરાતના તમામ પરગણાં અને વિગતો',
                              onTap: () {
                                Navigator.pop(ctx);
                                context.push('/pargana-overview');
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildModernMenuItem(
                              icon: Icons.badge_rounded,
                              iconGradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                              title: 'સરકારી કર્મચારી (Govt. Employees)',
                              subtitle: 'સરકારી અને પબ્લિક સેક્ટરમાં કાર્યરત સભ્યો',
                              onTap: () {
                                Navigator.pop(ctx);
                                context.push('/government-employees');
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildModernMenuItem(
                              icon: Icons.verified_user_rounded,
                              iconGradient: const [Color(0xFF10B981), Color(0xFF047857)],
                              title: 'વેરિફાઈડ પ્રોફાઈલ (Verified Profiles)',
                              subtitle: 'સત્યાપિત અને અધિકૃત ઉમેદવારો',
                              badgeText: 'Verified',
                              badgeColor: const Color(0xFF10B981),
                              onTap: () {
                                Navigator.pop(ctx);
                                context.push('/verified-profile');
                              },
                            ),
                            const SizedBox(height: 18),

                            // 3. Pride & Recognition Section
                            _buildMenuSectionTitle('સમાજનું ગૌરવ', 'PRIDE & INSPIRATION', Icons.workspace_premium_rounded),
                            const SizedBox(height: 8),
                            _buildModernMenuItem(
                              icon: Icons.workspace_premium_rounded,
                              iconGradient: const [Color(0xFFFBBF24), Color(0xFFD97706)],
                              title: 'સમાજ રત્ન (Samaj Ratna)',
                              subtitle: 'સમાજના ગૌરવવંતા અને સન્માનિત રત્નો',
                              badgeText: 'Pride',
                              badgeColor: const Color(0xFFF59E0B),
                              onTap: () {
                                Navigator.pop(ctx);
                                context.push('/samaj-ratna');
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildModernMenuItem(
                              icon: Icons.star_rounded,
                              iconGradient: const [Color(0xFFFB923C), Color(0xFFC2410C)],
                              title: 'સમાજ સુપર સ્ટાર્સ (Samaj Super Stars)',
                              subtitle: 'વિશેષ સિદ્ધિ મેળવનાર પ્રતિભાઓ',
                              onTap: () {
                                Navigator.pop(ctx);
                                context.push('/samaj-super-stars-poster');
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildModernMenuItem(
                              icon: Icons.lightbulb_rounded,
                              iconGradient: const [Color(0xFFFCD34D), Color(0xFFB45309)],
                              title: 'પાવન પ્રેરણાદાતા (Pavan Prernadata)',
                              subtitle: 'માર્ગદર્શક અને પ્રેરણાદાયી વ્યક્તિત્વ',
                              onTap: () {
                                Navigator.pop(ctx);
                                context.push('/pavan-prernadata');
                              },
                            ),
                            const SizedBox(height: 18),

                            // 4. Updates & Utilities
                            _buildMenuSectionTitle('અપડેટ્સ અને સૂચનાઓ', 'UPDATES & ALERTS', Icons.notifications_active_rounded),
                            const SizedBox(height: 8),
                            _buildModernMenuItem(
                              icon: Icons.campaign_rounded,
                              iconGradient: const [Color(0xFFF43F5E), Color(0xFFBE123C)],
                              title: 'જાહેરાતો (Advertisements)',
                              subtitle: 'સમાજ અને વ્યાપારની તાજી જાહેરાતો',
                              onTap: () {
                                Navigator.pop(ctx);
                                context.push('/advertisement');
                              },
                            ),
                            const SizedBox(height: 8),
                            _buildModernMenuItem(
                              icon: Icons.notifications_active_rounded,
                              iconGradient: const [Color(0xFFEF4444), Color(0xFFB91C1C)],
                              title: 'સૂચનાઓ (Notifications)',
                              subtitle: 'મહત્વપૂર્ણ સમાચારો અને જાહેરાતો',
                              badgeText: 'LIVE',
                              badgeColor: const Color(0xFFEF4444),
                              onTap: () {
                                Navigator.pop(ctx);
                                showNotificationsDialog(context, ref);
                              },
                            ),
                            const SizedBox(height: 20),

                            // Footer Card
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.volunteer_activism_rounded,
                                    color: Color(0xFFD4AF37),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'સંગઠન એ જ શક્તિ • એકતા એ જ પ્રગતિ',
                                      style: TextStyle(
                                        color: Color(0xFFFFD54F),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'v1.0.0',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
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
      },
    );
  }

  Widget _buildMenuSectionTitle(String gujarati, String english, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 6),
          Text(
            gujarati,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white30,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            english,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withOpacity(0.18),
                const Color(0xFF0B1E3D).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required List<Color> iconGradient,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF091936).withOpacity(0.65),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.07),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon Badge with Gradient
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: iconGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: iconGradient.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 21),
              ),
              const SizedBox(width: 12),
              // Titles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Optional Badge or Chevron
              if (badgeText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? const Color(0xFFD4AF37)).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (badgeColor ?? const Color(0xFFD4AF37)).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor ?? const Color(0xFFFFD54F),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.25),
                size: 20,
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
                    'assets/images/home_poster_clean_v4.jpg',
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
