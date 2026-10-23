import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WebDevelopmentSection extends StatelessWidget {
  const WebDevelopmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final isTablet = width >= 720 && width < 1100;

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
        horizontal: isDesktop ? 36 : (isTablet ? 20 : 12),
        vertical: 56,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Royal Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B1538), Color(0xFF5A0B22)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B1538).withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFD54F), size: 15),
                    SizedBox(width: 8),
                    Text(
                      'COMMUNITY VISION & DEVELOPMENT • સમાજ ઉત્કર્ષ',
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
              const SizedBox(height: 16),

              // 2. Main Title with Deep Midnight Navy
              const Text(
                'Together for a Stronger Gujarat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF101B36),
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),

              // Gujarati Tagline
              const Text(
                'એકતા, શિક્ષણ, પ્રગતિ અને સેવા દ્વારા સશક્ત ગુજરાત',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFA4143D),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 10),

              // Inspiring Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: const Text(
                  'Uniting our community across all 33 districts — fostering education, empowering youth, and contributing to the vibrant progress of Gujarat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // 3. Cultural Artwork Mural with Royal Arch Framing & Glass Badges
              _buildMajesticMural(isDesktop),
              const SizedBox(height: 36),

              // 4. Interactive 5 Pillars of Prosperity (Knowledge, Unity, Opportunity, Service, Prosperity)
              _buildProsperityPillarsGrid(isDesktop, isTablet),
              const SizedBox(height: 36),

              // 5. Three Core Mission Action Cards (Developed Gujarat, Empowered Samaj, Welfare & Service)
              _buildMissionActionCards(context, isDesktop, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  // Cultural Artwork Mural
  Widget _buildMajesticMural(bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.65),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
            blurRadius: 28,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Artwork Image
            Image.asset(
              'assets/images/gujarat_development_clean.png',
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/2 image.jpeg',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Subtle Vignette Overlay for Depth
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),

            // Top Left Heritage Badge (Desktop Only)
            if (isDesktop)
              Positioned(
                top: 14,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF030D1E).withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.7),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_rounded, color: Color(0xFFFFD54F), size: 14),
                      SizedBox(width: 6),
                      Text(
                        '🦁 Gir Pride & Cultural Heritage',
                        style: TextStyle(
                          color: Color(0xFFFFF9E5),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Top Right Infrastructure Badge (Desktop Only)
            if (isDesktop)
              Positioned(
                top: 14,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF030D1E).withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.7),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, color: Color(0xFFFFD54F), size: 15),
                      SizedBox(width: 6),
                      Text(
                        '🚄 Clean Energy & High-Speed Rail',
                        style: TextStyle(
                          color: Color(0xFFFFF9E5),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 4. Interactive 5 Pillars of Prosperity
  Widget _buildProsperityPillarsGrid(bool isDesktop, bool isTablet) {
    final pillars = [
      _ProsperityPillarData(
        title: 'Knowledge',
        gujarati: 'જ્ઞાન',
        tagline: 'Education & Coaching',
        highlight: 'Scholarships & Guidance',
        icon: Icons.menu_book_rounded,
        accentColor: const Color(0xFFD4AF37),
      ),
      _ProsperityPillarData(
        title: 'Unity',
        gujarati: 'સંગઠન',
        tagline: 'Pargana Solidarity',
        highlight: '33 Districts Directory',
        icon: Icons.groups_rounded,
        accentColor: const Color(0xFFA4143D),
      ),
      _ProsperityPillarData(
        title: 'Opportunity',
        gujarati: 'તક',
        tagline: 'Careers & Business',
        highlight: 'Govt & Private Jobs',
        icon: Icons.lightbulb_rounded,
        accentColor: const Color(0xFF8B1538),
      ),
      _ProsperityPillarData(
        title: 'Service',
        gujarati: 'સેવા',
        tagline: 'Healthcare & Aid',
        highlight: 'Medical Relief & Blood',
        icon: Icons.volunteer_activism_rounded,
        accentColor: const Color(0xFF7E102F),
      ),
      _ProsperityPillarData(
        title: 'Prosperity',
        gujarati: 'સમૃદ્ધિ',
        tagline: 'Family Progress',
        highlight: 'Matrimony & Honors',
        icon: Icons.auto_graph_rounded,
        accentColor: const Color(0xFFFFD54F),
      ),
    ];

    if (isDesktop) {
      return Row(
        children: pillars.map((p) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _PillarTileCard(pillar: p),
            ),
          );
        }).toList(),
      );
    } else if (isTablet) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: pillars.map((p) {
          return SizedBox(
            width: 210,
            child: _PillarTileCard(pillar: p),
          );
        }).toList(),
      );
    } else {
      return Column(
        children: pillars.map((p) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PillarTileCard(pillar: p),
          );
        }).toList(),
      );
    }
  }

  // 5. Three Core Mission Action Cards
  Widget _buildMissionActionCards(
      BuildContext context, bool isDesktop, bool isTablet) {
    final missions = [
      _MissionCardData(
        tag: 'DEVELOPED GUJARAT',
        title: 'Modern Growth & Infrastructure',
        gujarati: 'પ્રગતિશીલ અને આધુનિક ગુજરાત',
        description:
            'Celebrating Gujarat’s high-speed rail, smart renewable energy, and world-class industrial corridors.',
        highlights: [
          'High-Speed Rail & Metro Networks',
          'Clean Solar & Wind Energy Corridors',
          'Smart Cities & Vibrant Industries',
        ],
        icon: Icons.location_city_rounded,
        accentColor: const Color(0xFFA4143D),
        actionText: 'View State Statistics',
        route: '/statistics',
      ),
      _MissionCardData(
        tag: 'EMPOWERED SAMAJ',
        title: 'Education & Community Strength',
        gujarati: 'સશક્ત અને એકતાવાન વણકર સમાજ',
        description:
            'Fostering academic excellence, youth career mentorship, pargana solidarity, and collective community upliftment.',
        highlights: [
          'Higher Education & Scholarship Guidance',
          '33 Districts Verified Family Directory',
          'Empowering Matrimonial Connections',
        ],
        icon: Icons.diversity_3_rounded,
        accentColor: const Color(0xFF8B1538),
        actionText: 'Explore Education Portal',
        route: '/education',
      ),
      _MissionCardData(
        tag: 'COMMUNITY SERVICE',
        title: 'Compassion & Social Welfare',
        gujarati: 'સમાજ સેવા, આરોગ્ય અને કલ્યાણ',
        description:
            'Providing emergency medical support, student financial aid, blood donor networks, and honoring community achievers.',
        highlights: [
          'Emergency Healthcare & Medical Aid',
          'Student Scholarships & Coaching Support',
          'Honoring Samaj Ratna Role Models',
        ],
        icon: Icons.medical_services_rounded,
        accentColor: const Color(0xFF9E1B3E),
        actionText: 'Access Samaj Services',
        route: '/samaj-services',
      ),
    ];

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: missions.map((m) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _MissionHoverCard(mission: m),
            ),
          );
        }).toList(),
      );
    } else {
      return Column(
        children: missions.map((m) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _MissionHoverCard(mission: m),
          );
        }).toList(),
      );
    }
  }
}

// Data Model for 5 Prosperity Pillars
class _ProsperityPillarData {
  final String title;
  final String gujarati;
  final String tagline;
  final String highlight;
  final IconData icon;
  final Color accentColor;

  _ProsperityPillarData({
    required this.title,
    required this.gujarati,
    required this.tagline,
    required this.highlight,
    required this.icon,
    required this.accentColor,
  });
}

// Interactive Hover Card for Prosperity Pillars
class _PillarTileCard extends StatefulWidget {
  final _ProsperityPillarData pillar;
  const _PillarTileCard({required this.pillar});

  @override
  State<_PillarTileCard> createState() => _PillarTileCardState();
}

class _PillarTileCardState extends State<_PillarTileCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.pillar;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? p.accentColor
                : const Color(0xFFE5D5BA),
            width: _isHovered ? 1.6 : 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? p.accentColor.withValues(alpha: 0.22)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: _isHovered ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular Medallion Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    p.accentColor,
                    p.accentColor.withValues(alpha: 0.8),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFFD6A34A),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: p.accentColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(p.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),

            // English Title
            Text(
              p.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF101B36),
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),

            // Gujarati Tag
            Text(
              p.gujarati,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFA4143D),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // Tagline Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: p.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: p.accentColor.withValues(alpha: 0.35),
                  width: 0.8,
                ),
              ),
              child: Text(
                p.highlight,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: p.accentColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Model for Mission Cards
class _MissionCardData {
  final String tag;
  final String title;
  final String gujarati;
  final String description;
  final List<String> highlights;
  final IconData icon;
  final Color accentColor;
  final String actionText;
  final String route;

  _MissionCardData({
    required this.tag,
    required this.title,
    required this.gujarati,
    required this.description,
    required this.highlights,
    required this.icon,
    required this.accentColor,
    required this.actionText,
    required this.route,
  });
}

// Interactive Hover Card for 3 Missions
class _MissionHoverCard extends StatefulWidget {
  final _MissionCardData mission;
  const _MissionHoverCard({required this.mission});

  @override
  State<_MissionHoverCard> createState() => _MissionHoverCardState();
}

class _MissionHoverCardState extends State<_MissionHoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.mission;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? m.accentColor
                : const Color(0xFFE5D5BA),
            width: _isHovered ? 1.6 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? m.accentColor.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: _isHovered ? 18 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Tag + Medallion
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: m.accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: m.accentColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    m.tag,
                    style: TextStyle(
                      color: m.accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        m.accentColor,
                        m.accentColor.withValues(alpha: 0.85),
                      ],
                    ),
                    border: Border.all(color: const Color(0xFFD6A34A), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: m.accentColor.withValues(alpha: 0.25),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(m.icon, color: Colors.white, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              m.title,
              style: const TextStyle(
                color: Color(0xFF101B36),
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              m.gujarati,
              style: const TextStyle(
                color: Color(0xFFA4143D),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              m.description,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),

            // Checkmarks Checklist
            Column(
              children: m.highlights.map((h) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.5),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: m.accentColor, size: 15),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          h,
                          style: const TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // CTA Button with Gradient
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(m.route),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        m.accentColor,
                        m.accentColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD6A34A).withValues(alpha: 0.8),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: m.accentColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          m.actionText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
