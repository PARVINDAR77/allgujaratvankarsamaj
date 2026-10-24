import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WebHomeHero extends StatefulWidget {
  const WebHomeHero({super.key});

  @override
  State<WebHomeHero> createState() => _WebHomeHeroState();
}

class _WebHomeHeroState extends State<WebHomeHero> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1050;
    final isTablet = width >= 650 && width < 1050;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFAF8F5),
            Color(0xFFF6F2E9),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD6A34A).withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Background corner mandala watermarks
          Positioned(
            top: 0,
            left: 0,
            width: isDesktop ? 220 : 130,
            height: isDesktop ? 220 : 130,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  'assets/images/mandala_watermark_top.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.topLeft,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            width: isDesktop ? 220 : 130,
            height: isDesktop ? 220 : 130,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  'assets/images/mandala_watermark_top.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.topRight,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          // Main Hero 2-Column Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1260),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 36 : (isTablet ? 24 : 16),
                  vertical: isDesktop ? 48 : 32,
                ),
                child: isDesktop
                    ? _buildDesktopHero(context)
                    : _buildMobileTabletHero(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Desktop Three-Pillar Layout (Buddha • Community Identity • Dr. Babasaheb Ambedkar)
  Widget _buildDesktopHero(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Left Pillar: Sacred Lord Buddha Artwork Card (Pavan Prernadata)
        Expanded(
          flex: 8,
          child: Center(
            child: _buildBuddhaArtworkCard(maxWidth: 270),
          ),
        ),
        const SizedBox(width: 32),

        // 2. Center Pillar: Regal Typography, Gujarati Identity, Supporting Text & CTAs
        Expanded(
          flex: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF101B36), Color(0xFF1F325C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD6A34A), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF101B36).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFDF7A), size: 14),
                    SizedBox(width: 8),
                    Text(
                      'એક સમાજ, એક વિચાર, એક પરિવાર • UNITY • IDENTITY • PROGRESS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFDF7A),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Main Heading
              const Text(
                'All Gujarat Vankar Samaj',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF101B36),
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 8),

              // Supporting Heading
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFA4143D), Color(0xFFD97706)],
                ).createShader(bounds),
                child: const Text(
                  'One Community. One Identity. A Brighter Future.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Supporting Text
              const Text(
                'Connect families, discover matrimonial opportunities, celebrate community achievements, and work together for the progress of Vankar Samaj.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF475569),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 28),

              // Primary Actions
              Wrap(
                spacing: 14,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.favorite_rounded, size: 18),
                    label: const Text(
                      'Explore Matrimony (મેટ્રિમોની પોર્ટલ)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA4143D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFFFFDF7A), width: 1.2),
                      elevation: 4,
                      shadowColor: const Color(0xFFA4143D).withValues(alpha: 0.4),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/samaj-services'),
                    icon: const Icon(Icons.volunteer_activism_rounded, size: 18),
                    label: const Text(
                      'Samaj Services (સમાજ સેવાઓ)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF101B36),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFFD6A34A), width: 1.5),
                      elevation: 2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Trust Badges
              Row(
                children: [
                  _buildTrustBadge(Icons.verified_user_rounded, '100% Verified Profiles'),
                  const SizedBox(width: 20),
                  _buildTrustBadge(Icons.lock_rounded, 'Family Privacy Guaranteed'),
                  const SizedBox(width: 20),
                  _buildTrustBadge(Icons.public_rounded, 'Statewide Samaj Network'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 32),

        // 3. Right Pillar: Sacred Dr. Babasaheb Ambedkar Artwork Centerpiece
        Expanded(
          flex: 8,
          child: Center(
            child: _buildArtworkCard(maxWidth: 270),
          ),
        ),
      ],
    );
  }

  // 2. Mobile & Tablet Stacked Layout
  Widget _buildMobileTabletHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sacred Lord Buddha Artwork Card for Mobile & Tablet
        _buildBuddhaArtworkCard(maxWidth: 240),
        const SizedBox(height: 24),

        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF101B36), Color(0xFF1F325C)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD6A34A), width: 1.2),
          ),
          child: const Text(
            'એક સમાજ, એક વિચાર, એક પરિવાર',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFDF7A),
            ),
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'All Gujarat Vankar Samaj',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF101B36),
            height: 1.2,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'One Community. One Identity. A Brighter Future.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFFA4143D),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Connect families, discover matrimonial opportunities, celebrate community achievements, and work together for the progress of Vankar Samaj.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF475569),
            height: 1.45,
          ),
        ),

        const SizedBox(height: 22),

        // Primary Actions
        Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.favorite_rounded, size: 16),
              label: const Text(
                'Explore Matrimony (મેટ્રિમોની)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA4143D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: Color(0xFFFFDF7A), width: 1.0),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => context.push('/samaj-services'),
              icon: const Icon(Icons.volunteer_activism_rounded, size: 16),
              label: const Text(
                'Samaj Services (સેવાઓ)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF101B36),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: Color(0xFFD6A34A), width: 1.2),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Dr. Babasaheb Ambedkar Artwork Centerpiece
        _buildArtworkCard(maxWidth: 240),
      ],
    );
  }

  // Dr. Babasaheb Ambedkar Artwork Card
  Widget _buildArtworkCard({required double maxWidth}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Soft warm golden backlight aura behind poster to blend seamlessly into hero canvas
              Container(
                width: maxWidth * 0.95,
                height: maxWidth * (1024.0 / 854.0) * 0.95,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                  gradient: RadialGradient(
                    colors: [
                      Color(0x55FFDF7A),
                      Color(0x22D6A34A),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.65, 1.0],
                  ),
                ),
              ),

              // Royal Golden Beveled Heritage Frame
              Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFDF7A),
                      Color(0xFFD6A34A),
                      Color(0xFF9E6D1C),
                      Color(0xFFD6A34A),
                      Color(0xFFFFDF7A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD6A34A).withValues(alpha: 0.35),
                      blurRadius: 26,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(0xFF101B36).withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1B38),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: const Color(0xFF101B36),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17.5),
                    child: AspectRatio(
                      aspectRatio: 854.0 / 1024.0,
                      child: Image.asset(
                        'assets/images/babasaheb_ambedkar_poster.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/heritage_login_poster.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Symmetrical Reverence Badge (Mirrors Buddha's badge on the left)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD6A34A).withValues(alpha: 0.6),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF101B36).withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, color: Color(0xFFA4143D), size: 12),
                SizedBox(width: 6),
                Text(
                  'ભારતરત્ન • બોધિસત્વ ડૉ. બાબાસાહેબ આંબેડકર',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFA4143D),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuddhaArtworkCard({required double maxWidth}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Soft warm golden backlight aura behind poster to blend seamlessly into hero canvas
              Container(
                width: maxWidth * 0.95,
                height: maxWidth * (1024.0 / 854.0) * 0.95,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                  gradient: RadialGradient(
                    colors: [
                      Color(0x55FFDF7A),
                      Color(0x22D6A34A),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.65, 1.0],
                  ),
                ),
              ),

              // Royal Golden Beveled Heritage Frame (symmetrical to Dr. Ambedkar's card)
              Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFDF7A),
                      Color(0xFFD6A34A),
                      Color(0xFF9E6D1C),
                      Color(0xFFD6A34A),
                      Color(0xFFFFDF7A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD6A34A).withValues(alpha: 0.35),
                      blurRadius: 26,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(0xFF101B36).withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1B38),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: const Color(0xFF101B36),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17.5),
                    child: AspectRatio(
                      aspectRatio: 854.0 / 1024.0,
                      child: Image.asset(
                        'assets/images/buddha_meditation_sacred.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/buddha_login_poster.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Symmetrical Reverence Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD6A34A).withValues(alpha: 0.6),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF101B36).withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, color: Color(0xFFA4143D), size: 12),
                SizedBox(width: 6),
                Text(
                  'પાવન પ્રેરણાદાતા • ભગવાન ગૌતમ બુદ્ધ',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFA4143D),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFFA4143D)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
