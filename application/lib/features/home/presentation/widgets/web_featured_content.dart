import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeaturedItemData {
  final String number;
  final String title;
  final String subtitle;
  final String description;
  final String route;
  final IconData icon;
  final String imageAsset;

  const FeaturedItemData({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.route,
    required this.icon,
    required this.imageAsset,
  });
}

class WebFeaturedContent extends StatelessWidget {
  const WebFeaturedContent({super.key});

  static const List<FeaturedItemData> items = [
    FeaturedItemData(
      number: '1',
      title: 'પાવન પ્રેરણાદાતા',
      subtitle: 'PAVAN PRERNADATA',
      description: 'સમાજ માટે પ્રેરણા આપનાર મહાન વ્યક્તિઓ',
      route: '/pavan-prernadata',
      icon: Icons.menu_book_rounded,
      imageAsset: 'assets/images/portal_card_prernadata.png',
    ),
    FeaturedItemData(
      number: '2',
      title: 'સમાજ સુપર સ્ટાર્સ',
      subtitle: 'SAMAJ SUPER STARS',
      description: 'વિવિધ ક્ષેત્રોમાં ઉત્કૃષ્ટ સેવા અને સિદ્ધિ મેળવનાર',
      route: '/samaj-super-stars-poster',
      icon: Icons.auto_awesome_rounded,
      imageAsset: 'assets/images/portal_card_superstars.png',
    ),
    FeaturedItemData(
      number: '3',
      title: 'સમાજ રત્ન',
      subtitle: 'SAMAJ RATNA',
      description: 'સમાજના હીરા સમાન અમૂલ્ય રત્નો',
      route: '/samaj-ratna',
      icon: Icons.military_tech_rounded,
      imageAsset: 'assets/images/portal_card_ratna.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 950;
    final isTablet = width >= 650 && width < 950;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFAF8F5),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 36 : (isTablet ? 24 : 16),
        vertical: 44,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Section Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA4143D), Color(0xFF7E102F)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD6A34A)),
                ),
                child: const Text(
                  'FEATURED COMMUNITY INITIATIVES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Prominent Community Portals',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF101B36),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: const Text(
                  'Explore our distinguished elders, celebrate youth achievers, and access the verified community family directory.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Responsive Cards
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((item) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: _FeaturedCard(item: item),
                      ),
                    );
                  }).toList(),
                )
              else
                Column(
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: _FeaturedCard(item: item),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatefulWidget {
  final FeaturedItemData item;

  const _FeaturedCard({required this.item});

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final it = widget.item;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _isHovered ? -8.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _isHovered ? const Color(0xFFFFD700) : const Color(0xFFD4AF37),
            width: _isHovered ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0xFFFFD700).withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.15),
              blurRadius: _isHovered ? 24 : 12,
              offset: Offset(0, _isHovered ? 10 : 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.push(it.route),
              child: AspectRatio(
                aspectRatio: 160.0 / 260.0,
                child: Image.asset(
                  it.imageAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
