import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WebMatrimonyHero extends StatefulWidget {
  const WebMatrimonyHero({super.key});

  @override
  State<WebMatrimonyHero> createState() => _WebMatrimonyHeroState();
}

class _WebMatrimonyHeroState extends State<WebMatrimonyHero> {
  String _selectedGender = 'Groom'; // 'Groom' or 'Bride'
  String _selectedDistrict = 'All Gujarat (તમામ ગુજરાત)';

  final List<String> _districts = [
    'All Gujarat (તમામ ગુજરાત)',
    'Ahmedabad (અમદાવાદ)',
    'Surat (સુરત)',
    'Vadodara (વડોદરા)',
    'Mehsana (મહેસાણા)',
    'Patan (પાટણ)',
    'Gandhinagar (ગાંધીનગર)',
    'Rajkot (રાજકોટ)',
    'Banaskantha (બનાસકાંઠા)',
    'Sabarkantha (સાબરકાંઠા)',
    'Kheda / Anand (ખેડા / આણંદ)',
  ];

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
            Color(0xFFF7F2E7),
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
                opacity: 0.5,
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
                opacity: 0.5,
                child: Image.asset(
                  'assets/images/mandala_watermark_top.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.topRight,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          // Main Hero Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1260),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 36 : (isTablet ? 24 : 16),
                  vertical: isDesktop ? 44 : 28,
                ),
                child: isDesktop
                    ? _buildDesktopLayout(context)
                    : _buildMobileTabletLayout(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Desktop Two-Column Layout (Quick Search on Left, Sacred Buddha Meditation on Right)
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Matrimonial Heading, Search Bar, CTAs
        Expanded(
          flex: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Slogan Badge
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
                    Icon(Icons.favorite_rounded, color: Color(0xFFFFDF7A), size: 14),
                    SizedBox(width: 8),
                    Text(
                      'એક સમાજ, એક વિચાર, એક પરિવાર • 100% VERIFIED MATRIMONY',
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
                'All Gujarat Vankar Samaj Matrimony',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF101B36),
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 8),

              // Gujarati Subtitle
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFA4143D), Color(0xFFD97706)],
                ).createShader(bounds),
                child: const Text(
                  'લગ્ન માટે સુયોગ્ય જીવનસાથીની પસંદગી (Find Your Life Partner)',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Description
              const Text(
                'સંસ્કારી અને શિક્ષિત વણકર સમાજના પરિવારો માટેનું રાજ્યવ્યાપી સુરક્ષિત, પારિવારિક અને ૧૦૦% પ્રમાણિત વૈવાહિક પ્લેટફોર્મ.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF475569),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // Polished Quick Match Search Card
              _buildQuickSearchCard(context),

              const SizedBox(height: 24),

              // Trust Badges
              Row(
                children: [
                  _buildTrustBadge(Icons.verified_user_rounded, '100% Verified Profiles'),
                  const SizedBox(width: 20),
                  _buildTrustBadge(Icons.lock_rounded, 'Family Privacy Guaranteed'),
                  const SizedBox(width: 20),
                  _buildTrustBadge(Icons.people_alt_rounded, 'Statewide Samaj Network'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 40),

        // Right Column: Sacred Buddha Meditation Centerpiece
        Expanded(
          flex: 10,
          child: Center(
            child: _buildBuddhaArtworkCard(maxWidth: 480),
          ),
        ),
      ],
    );
  }

  // 2. Mobile & Tablet Stacked Layout
  Widget _buildMobileTabletLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sacred Buddha Centerpiece at the Top
        _buildBuddhaArtworkCard(maxWidth: 340),
        const SizedBox(height: 22),

        // Slogan Badge
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
            'લગ્ન માટે છોકરો / છોકરી શોધો • 100% VERIFIED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFDF7A),
            ),
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'All Gujarat Vankar Samaj Matrimony',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF101B36),
            height: 1.2,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'પસંદગી મુજબ જીવનસાથીની શોધ કરો',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFFA4143D),
          ),
        ),

        const SizedBox(height: 18),

        // Quick Search Box
        _buildQuickSearchCard(context),
      ],
    );
  }

  // 3. Clean, Structured Quick Match Search Filter Box
  Widget _buildQuickSearchCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD6A34A).withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101B36).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Candidate Preference Toggle Row (Responsive for all screen sizes)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              const Text(
                'હું શોધી રહ્યો/રહી છું (Looking for):',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101B36),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => setState(() => _selectedGender = 'Groom'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _selectedGender == 'Groom'
                            ? const Color(0xFFA4143D)
                            : const Color(0xFFFAF8F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedGender == 'Groom'
                              ? const Color(0xFFA4143D)
                              : const Color(0xFFCBD5E1),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.man_rounded,
                            size: 16,
                            color: _selectedGender == 'Groom'
                                ? Colors.white
                                : const Color(0xFF101B36),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'વર શોધો (Groom)',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: _selectedGender == 'Groom'
                                  ? Colors.white
                                  : const Color(0xFF101B36),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => setState(() => _selectedGender = 'Bride'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _selectedGender == 'Bride'
                            ? const Color(0xFFA4143D)
                            : const Color(0xFFFAF8F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedGender == 'Bride'
                              ? const Color(0xFFA4143D)
                              : const Color(0xFFCBD5E1),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.woman_rounded,
                            size: 16,
                            color: _selectedGender == 'Bride'
                                ? Colors.white
                                : const Color(0xFF101B36),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'કન્યા શોધો (Bride)',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: _selectedGender == 'Bride'
                                  ? Colors.white
                                  : const Color(0xFF101B36),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 2: Location Dropdown + Search Button
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 480;

              if (isSmall) {
                return Column(
                  children: [
                    _buildDistrictDropdown(),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: _buildSearchButton(context),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildDistrictDropdown(),
                  ),
                  const SizedBox(width: 12),
                  _buildSearchButton(context),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // Row 3: Action Shortcuts
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.push('/profile/create'),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                label: const Text(
                  '+ નવો પ્રોફાઈલ બનાવો (Create Profile)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF101B36),
                  backgroundColor: const Color(0xFFFAF8F5),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: const BorderSide(color: Color(0xFFD6A34A), width: 1.2),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/match'),
                icon: const Icon(Icons.favorite_rounded, size: 15, color: Color(0xFFA4143D)),
                label: const Text(
                  'પરસ્પર મેચ જુઓ (Browse Matches)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF101B36),
                  backgroundColor: const Color(0xFFFAF8F5),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: const BorderSide(color: Color(0xFFD6A34A), width: 1.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD6A34A).withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Theme(
        data: ThemeData.light().copyWith(
          canvasColor: Colors.white,
          cardColor: Colors.white,
          dialogBackgroundColor: Colors.white,
          colorScheme: const ColorScheme.light(
            surface: Colors.white,
            onSurface: Color(0xFF101B36),
            primary: Color(0xFFA4143D),
          ),
          hoverColor: const Color(0xFFFAF5EE),
          focusColor: const Color(0xFFFAF5EE),
          splashColor: const Color(0xFFF3ECE0),
          highlightColor: const Color(0xFFFAF5EE),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedDistrict,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 10,
            menuMaxHeight: 320,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFA4143D), size: 24),
            selectedItemBuilder: (BuildContext context) {
              return _districts.map<Widget>((String d) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Color(0xFFA4143D), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF101B36),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
            items: _districts.map((d) {
              final isSelected = d == _selectedDistrict;
              return DropdownMenuItem<String>(
                value: d,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.location_on_outlined,
                        size: 16,
                        color: isSelected ? const Color(0xFFA4143D) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? const Color(0xFFA4143D) : const Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedDistrict = val);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        final genderParam = _selectedGender == 'Groom' ? 'Groom' : 'Bride';
        final districtParam = _selectedDistrict.contains('All Gujarat')
            ? ''
            : Uri.encodeComponent(_selectedDistrict.split(' ')[0]);
        final query = districtParam.isNotEmpty
            ? '/search?lookingFor=$genderParam&district=$districtParam'
            : '/search?lookingFor=$genderParam';
        context.push(query);
      },
      icon: const Icon(Icons.search_rounded, size: 18),
      label: const Text(
        'પ્રોફાઈલ શોધો (Search)',
        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA4143D),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Color(0xFFFFDF7A), width: 1.0),
        elevation: 3,
      ),
    );
  }

  // 4. Sacred Buddha Meditation Centerpiece
  Widget _buildBuddhaArtworkCard({required double maxWidth}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Soft warm golden backlight / aura behind Buddha painting
              Container(
                width: maxWidth * 0.96,
                height: maxWidth * (1062.0 / 1536.0) * 0.96,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                  gradient: RadialGradient(
                    colors: [
                      Color(0x60FFDF7A),
                      Color(0x28D6A34A),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.65, 1.0],
                  ),
                ),
              ),

              // Royal Golden Beveled Heritage Frame
              Container(
                padding: const EdgeInsets.all(3.5),
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
                      aspectRatio: 1536.0 / 1062.0,
                      child: Image.asset(
                        'assets/images/buddha_meditation_sacred.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/2 image.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Symmetrical Reverence Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4.5),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD6A34A).withValues(alpha: 0.7),
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
                Icon(Icons.auto_awesome_rounded, color: Color(0xFFA4143D), size: 13),
                SizedBox(width: 6),
                Text(
                  'પાવન પ્રેરણાદાતા • ભગવાન બુદ્ધ (સર્વ મંગલમ્)',
                  style: TextStyle(
                    fontSize: 11,
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
