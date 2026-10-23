import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServiceItemData {
  final String title;
  final String gujaratiTitle;
  final String tag;
  final String subtitle;
  final String route;
  final String medallionAsset;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final List<String> featureChips;
  final String ctaText;
  final bool isMatrimony;

  const ServiceItemData({
    required this.title,
    required this.gujaratiTitle,
    required this.tag,
    required this.subtitle,
    required this.route,
    required this.medallionAsset,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.featureChips,
    required this.ctaText,
    this.isMatrimony = false,
  });
}

class WebServiceCards extends StatelessWidget {
  const WebServiceCards({super.key});

  static const List<ServiceItemData> services = [
    ServiceItemData(
      title: 'Government Employees',
      gujaratiTitle: 'સરકારી કર્મચારીઓ',
      tag: 'CIVIL & DEFENCE',
      subtitle: 'Directory of public sector professionals, teachers, defense, and state administration officers.',
      route: '/government-employees',
      medallionAsset: 'assets/images/medallion_govt_employees.png',
      icon: Icons.account_balance_rounded,
      primaryColor: Color(0xFFA4143D),
      secondaryColor: Color(0xFF6B0E27),
      featureChips: ['IAS | IPS | IFS', 'Teachers', 'Police & Defence', 'Class 1, 2, 3', 'Healthcare'],
      ctaText: 'Browse Directory',
    ),
    ServiceItemData(
      title: 'Matrimony Portal',
      gujaratiTitle: 'લગ્ન સંબંધી સેવાઓ',
      tag: 'VERIFIED MATCHES',
      subtitle: 'Find your life partner within our Samaj with 100% verified profiles and privacy protection.',
      route: '/home',
      medallionAsset: 'assets/images/medallion_matrimony.png',
      icon: Icons.favorite_rounded,
      primaryColor: Color(0xFFA4143D),
      secondaryColor: Color(0xFF7E102F),
      featureChips: ['Groom Profiles', 'Bride Profiles', 'Pargana Filter', 'Horoscope', 'Family Verified'],
      ctaText: 'Find Life Partner',
      isMatrimony: true,
    ),
    ServiceItemData(
      title: 'Private Job & Business',
      gujaratiTitle: 'ખાનગી નોકરી & વેપાર',
      tag: 'CAREER & COMMERCE',
      subtitle: 'Career network connecting corporate professionals, IT specialists, and business owners.',
      route: '/private-employees',
      medallionAsset: 'assets/images/medallion_private_job.png',
      icon: Icons.business_center_rounded,
      primaryColor: Color(0xFF8B1538),
      secondaryColor: Color(0xFF5A0B22),
      featureChips: ['IT & Software', 'Corporate Jobs', 'Business Owners', 'Self-Employed', 'Startups'],
      ctaText: 'Explore Careers',
    ),
    ServiceItemData(
      title: 'Vankar Samaj Services',
      gujaratiTitle: 'સમાજ સહાય & સેવા',
      tag: 'WELFARE & SUPPORT',
      subtitle: 'Emergency medical aid, student scholarships, career guidance, and community welfare.',
      route: '/samaj-services',
      medallionAsset: 'assets/images/medallion_samaj_services.png',
      icon: Icons.volunteer_activism_rounded,
      primaryColor: Color(0xFFA4143D),
      secondaryColor: Color(0xFF6B0E27),
      featureChips: ['Medical Help', 'Student Aid', 'Community Network', 'Legal Guidance', 'Social Welfare'],
      ctaText: 'Get Support',
    ),
    ServiceItemData(
      title: 'Vankar Samaj Ratna',
      gujaratiTitle: 'સમાજ રત્ન સન્માન',
      tag: 'HALL OF FAME',
      subtitle: 'Honoring prominent community achievers, award winners, role models, and distinguished leaders.',
      route: '/samaj-ratna',
      medallionAsset: 'assets/images/medallion_samaj_ratna.png',
      icon: Icons.stars_rounded,
      primaryColor: Color(0xFF8B1538),
      secondaryColor: Color(0xFF5A0B22),
      featureChips: ['Distinguished Elders', 'State Awardees', 'Youth Icons', 'Role Models', 'Excellence'],
      ctaText: 'Meet Role Models',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
        horizontal: width >= 1200 ? 32 : (width >= 768 ? 20 : 14),
        vertical: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Section Header
              _buildSectionHeader(),
              const SizedBox(height: 36),

              // Responsive Cards Layout
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;

                  if (availableWidth >= 1150) {
                    // 5 cards across on desktop with equal height
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: services.map((service) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: _ProductiveServiceCard(service: service),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  } else if (availableWidth >= 700) {
                    // 2 or 3 cards per row on tablet
                    return Wrap(
                      spacing: 16,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: services.map((service) {
                        return SizedBox(
                          width: (availableWidth - 36) / 2 > 330
                              ? (availableWidth - 36) / 2
                              : (availableWidth - 20) / 2,
                          child: _ProductiveServiceCard(service: service),
                        );
                      }).toList(),
                    );
                  } else {
                    // Stacked cards on mobile
                    return Column(
                      children: services.map((service) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: _ProductiveServiceCard(service: service),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      children: [
        // Category Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFA4143D), Color(0xFF7E102F)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD6A34A), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA4143D).withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 16),
              SizedBox(width: 8),
              Text(
                'FIVE ESSENTIAL COMMUNITY PORTALS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Main Title
        const Text(
          'Samaj Service Categories',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF101B36),
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 10),

        // Subtitle
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: const Text(
            'Active community directories and welfare platforms designed for matrimonial matching, employment verification, youth excellence, and emergency assistance.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductiveServiceCard extends StatefulWidget {
  final ServiceItemData service;

  const _ProductiveServiceCard({required this.service});

  @override
  State<_ProductiveServiceCard> createState() => _ProductiveServiceCardState();
}

class _ProductiveServiceCardState extends State<_ProductiveServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0.0, _isHovered ? -7.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFFA4143D)
                : const Color(0xFFE5D5BA),
            width: _isHovered ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? s.primaryColor.withValues(alpha: 0.22)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 8 : 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              if (s.isMatrimony) {
                context.go(s.route);
              } else {
                context.push(s.route);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Section: Tag Badge + Circular Medallion + Title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Tag Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: s.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: s.primaryColor.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          s.tag,
                          style: TextStyle(
                            color: s.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Grand Medallion Avatar with Golden Filigree Trim & Ambient Glow
                      Container(
                        width: 82,
                        height: 82,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFDF7A),
                              const Color(0xFFD4AF37),
                              s.primaryColor,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: s.primaryColor.withValues(alpha: 0.35),
                              blurRadius: _isHovered ? 16 : 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: const Color(0xFFFAF8F5),
                          child: ClipOval(
                            child: Image.asset(
                              s.medallionAsset,
                              fit: BoxFit.cover,
                              width: 76,
                              height: 76,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                s.icon,
                                color: s.primaryColor,
                                size: 38,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Card Title (English)
                      Text(
                        s.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF101B36),
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Gujarati Title
                      Text(
                        s.gujaratiTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFA4143D),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle / Description
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 46),
                        child: Text(
                          s.subtitle,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Middle Section: Productive Feature Chips
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: s.featureChips.map((chip) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F4EE),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isHovered
                                  ? const Color(0xFFD6A34A)
                                  : const Color(0xFFE5D8C5),
                              width: 0.9,
                            ),
                          ),
                          child: Text(
                            chip,
                            style: TextStyle(
                              color: _isHovered
                                  ? const Color(0xFF101B36)
                                  : const Color(0xFF374151),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Bottom Section: Interactive Gradient Action Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [s.primaryColor, s.secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isHovered ? const Color(0xFFFFD700) : const Color(0xFFD6A34A),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: s.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s.ctaText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Color(0xFFFFD700),
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
      ),
    );
  }
}
