import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/providers/profile_provider.dart';

class WebMatrimonyActions extends ConsumerStatefulWidget {
  const WebMatrimonyActions({super.key});

  @override
  ConsumerState<WebMatrimonyActions> createState() => _WebMatrimonyActionsState();
}

class _WebMatrimonyActionsState extends ConsumerState<WebMatrimonyActions> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1150;
    final isTablet = width >= 650 && width < 1150;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFAF8F5),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFAF8F5),
            Color(0xFFF7F3EA),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 36 : (isTablet ? 20 : 14),
        vertical: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Royal Section Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF101B36), Color(0xFF1D2D52)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD6A34A), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF101B36).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_rounded, color: Color(0xFFFFDF7A), size: 15),
                    SizedBox(width: 8),
                    Text(
                      'MATRIMONY HOME • લગ્ન માટે છોકરો / છોકરી શોધો',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFDF7A),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. Headings
              const Text(
                'પસંદગી મુજબ જીવનસાથીની શોધ કરો',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101B36),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'All Gujarat Vankar Samaj Matrimonial Discovery — 100% Verified Profiles & Family Privacy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 36),

              // 3. The 4 Matrimonial Action Cards (Find Boy, Find Girl, Find Match, Create Profile)
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = isDesktop
                      ? (constraints.maxWidth - (3 * 20)) / 4
                      : isTablet
                          ? (constraints.maxWidth - 20) / 2
                          : constraints.maxWidth;

                  final cards = [
                    _MatrimonyCardData(
                      index: 0,
                      badgeText: 'GROOM SEARCH',
                      title: 'છોકરો શોધો',
                      englishTitle: 'Find Boy',
                      subtitle: 'સુયોગ્ય વર પસંદગી',
                      description: 'ગુજરાતભરના શિક્ષિત અને વ્યવસાયિક વણકર યુવકોની પ્રમાણિત પ્રોફાઈલ.',
                      icon: Icons.male_rounded,
                      headerGradient: const [Color(0xFF0F2B52), Color(0xFF19457D)],
                      accentColor: const Color(0xFF2563EB),
                      ctaText: 'છોકરો શોધો • Find Boy',
                      onTap: () {
                        ref.read(profileNotifierProvider.notifier).updateFilters(gender: 'MALE');
                        context.push('/search-results?gender=MALE');
                      },
                    ),
                    _MatrimonyCardData(
                      index: 1,
                      badgeText: 'BRIDE SEARCH',
                      title: 'છોકરી શોધો',
                      englishTitle: 'Find Girl',
                      subtitle: 'સુયોગ્ય કન્યા પસંદગી',
                      description: 'સંસ્કારી અને ઉચ્ચ શિક્ષિત વણકર સમાજની દીકરીઓની મેટ્રિમોનિયલ પ્રોફાઈલ.',
                      icon: Icons.female_rounded,
                      headerGradient: const [Color(0xFF8B1538), Color(0xFFB51D48)],
                      accentColor: const Color(0xFFA4143D),
                      ctaText: 'છોકરી શોધો • Find Girl',
                      onTap: () {
                        ref.read(profileNotifierProvider.notifier).updateFilters(gender: 'FEMALE');
                        context.push('/search-results?gender=FEMALE');
                      },
                    ),
                    _MatrimonyCardData(
                      index: 2,
                      badgeText: 'MATCHMAKING',
                      title: 'મેચ શોધો',
                      englishTitle: 'Find Match',
                      subtitle: 'પરસ્પર પસંદગી મેળ',
                      description: 'શિક્ષણ, ઉંમર અને પરગણાના આધારે સચોટ અને અનુકૂળ વૈવાહિક મેળ.',
                      icon: Icons.favorite_rounded,
                      headerGradient: const [Color(0xFF065F46), Color(0xFF059669)],
                      accentColor: const Color(0xFF10B981),
                      ctaText: 'મેચ શોધો • Find Match',
                      onTap: () => context.go('/match'),
                    ),
                    _MatrimonyCardData(
                      index: 3,
                      badgeText: 'FREE REGISTRATION',
                      title: 'પ્રોફાઈલ બનાવો',
                      englishTitle: 'Create Profile',
                      subtitle: 'સમાજ સાથે જોડાઓ',
                      description: 'તમારી અથવા પરિવારના સભ્યની સંપૂર્ણ માહિતી સાથે પ્રોફાઈલ નોંધાવો.',
                      icon: Icons.assignment_ind_rounded,
                      headerGradient: const [Color(0xFF92400E), Color(0xFFD97706)],
                      accentColor: const Color(0xFFD6A34A),
                      ctaText: 'પ્રોફાઈલ બનાવો • Register',
                      onTap: () => context.push('/profile/create'),
                    ),
                  ];

                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: cards
                          .map((data) => Container(
                                width: cardWidth,
                                margin: EdgeInsets.only(
                                  right: data.index < 3 ? 20 : 0,
                                ),
                                child: _buildCard(data),
                              ))
                          .toList(),
                    );
                  }

                  if (isTablet) {
                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: cards
                          .map((data) => SizedBox(
                                width: cardWidth,
                                child: _buildCard(data),
                              ))
                          .toList(),
                    );
                  }

                  return Column(
                    children: cards
                        .map((data) => Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: _buildCard(data),
                            ))
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 32),

              // 4. Secondary Action Strip: Search, Liked, Verified & Join Now
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5D5BA), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF101B36).withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _buildToolButton(
                      icon: Icons.search_rounded,
                      label: 'શોધો (Search Directory)',
                      color: const Color(0xFF101B36),
                      onTap: () => context.push('/search'),
                    ),
                    _buildToolButton(
                      icon: Icons.favorite_border_rounded,
                      label: 'પસંદ કરેલ પ્રોફાઈલ (Liked)',
                      color: const Color(0xFFA4143D),
                      onTap: () => context.push('/liked-profiles'),
                    ),
                    _buildToolButton(
                      icon: Icons.verified_user_rounded,
                      label: 'વેરિફાઈડ પ્રોફાઈલ (Verified)',
                      color: const Color(0xFF0F766E),
                      onTap: () => context.push('/verified-profile'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/profile/create'),
                      icon: const Icon(Icons.group_add_rounded, size: 16),
                      label: const Text(
                        'હમણાં જ જોડાઓ (Join Now)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA4143D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(_MatrimonyCardData data) {
    final isHovered = _hoveredIndex == data.index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredIndex = data.index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: data.onTap,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, isHovered ? -6 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHovered ? const Color(0xFFD6A34A) : const Color(0xFFE5D5BA),
            width: isHovered ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? const Color(0xFFD6A34A).withValues(alpha: 0.35)
                  : const Color(0xFF101B36).withValues(alpha: 0.06),
              blurRadius: isHovered ? 18 : 8,
              offset: Offset(0, isHovered ? 8 : 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Top Accent Bar with gradient & icon
              Container(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: data.headerGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(color: const Color(0xFFFFDF7A), width: 1.5),
                      ),
                      child: Icon(data.icon, color: const Color(0xFFFFDF7A), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              data.badgeText,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFDF7A),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            data.title,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

              // Card Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: data.accentColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: data.onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: data.headerGradient.first,
                          foregroundColor: Colors.white,
                          elevation: isHovered ? 3 : 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                            side: const BorderSide(color: Color(0xFFD6A34A), width: 1.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: Text(
                          data.ctaText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatrimonyCardData {
  final int index;
  final String badgeText;
  final String title;
  final String englishTitle;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> headerGradient;
  final Color accentColor;
  final String ctaText;
  final VoidCallback onTap;

  const _MatrimonyCardData({
    required this.index,
    required this.badgeText,
    required this.title,
    required this.englishTitle,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.headerGradient,
    required this.accentColor,
    required this.ctaText,
    required this.onTap,
  });
}
