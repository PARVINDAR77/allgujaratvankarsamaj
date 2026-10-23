import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeaturedItemData {
  final String number;
  final String title;
  final String subtitle;
  final String description;
  final String route;
  final IconData icon;

  const FeaturedItemData({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.route,
    required this.icon,
  });
}

class WebFeaturedContent extends StatelessWidget {
  const WebFeaturedContent({super.key});

  static const List<FeaturedItemData> items = [
    FeaturedItemData(
      number: '1',
      title: 'પાવન પ્રેરણાદાતા',
      subtitle: 'Pavan Prernadata',
      description: 'Honoring the visionary mentors, guides, and spiritual pioneers who illuminate our community with wisdom and values.',
      route: '/pavan-prernadata',
      icon: Icons.menu_book_rounded,
    ),
    FeaturedItemData(
      number: '2',
      title: 'Samaj Super Stars',
      subtitle: 'Achievers & Youth Icons',
      description: 'Celebrating high achievers, academic toppers, sports icons, civil servants, and leaders elevating our community pride.',
      route: '/samaj-super-stars-poster',
      icon: Icons.auto_awesome_rounded,
    ),
    FeaturedItemData(
      number: '3',
      title: 'વણકર સમાજ રત્ન',
      subtitle: 'Vankar Samaj Ratna',
      description: 'Honoring prominent leaders, visionaries, philanthropists, and lifetime contributors who have elevated our Samaj with pride.',
      route: '/samaj-ratna',
      icon: Icons.military_tech_rounded,
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
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0.0, _isHovered ? -5.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFFA4143D)
                : const Color(0xFFE5D5BA),
            width: _isHovered ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0xFFA4143D).withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => context.push(it.route),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Velvet Maroon & Gold Medallion Container
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA4143D), Color(0xFF6B0E27)],
                      ),
                      border: Border.all(color: const Color(0xFFFFD54F), width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA4143D).withValues(alpha: 0.45),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        it.icon,
                        color: const Color(0xFFFFDF73),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card Title
                  Text(
                    '${it.number}. ${it.title}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF101B36),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Subtitle
                  Text(
                    it.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFA4143D),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: Text(
                      it.description,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Velvet Maroon Action Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA4143D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD6A34A), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA4143D).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Open Portal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Color(0xFFFFD54F),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
