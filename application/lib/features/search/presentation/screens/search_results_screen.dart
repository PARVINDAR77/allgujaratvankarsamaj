import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../profile/providers/liked_profiles_provider.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../home/presentation/widgets/web_home_header.dart';
import '../../../home/presentation/widgets/web_home_footer.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  final String? initialGender;
  final String? initialMaritalStatus;

  const SearchResultsScreen({
    super.key,
    this.initialGender,
    this.initialMaritalStatus,
  });

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  late String _selectedGender; // 'MALE', 'FEMALE', or 'ALL'
  String _selectedMaritalStatus = 'ALL';
  RangeValues _ageRange = const RangeValues(18, 55);

  @override
  void initState() {
    super.initState();
    final normalized = ProfileModel.normalizeGenderToApi(widget.initialGender);
    if (normalized == 'MALE' || normalized == 'FEMALE') {
      _selectedGender = normalized;
    } else {
      _selectedGender = 'ALL';
    }

    if (widget.initialMaritalStatus != null && widget.initialMaritalStatus!.isNotEmpty) {
      final normMarital = ProfileModel.normalizeMaritalStatusToApi(widget.initialMaritalStatus);
      if (normMarital.isNotEmpty) {
        _selectedMaritalStatus = normMarital;
      }
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(profileNotifierProvider.notifier).fetchNextPage();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeGender = _selectedGender == 'ALL' ? '' : _selectedGender;
      final currentInProvider = ref.read(profileNotifierProvider.notifier).currentGender ?? '';
      if (currentInProvider != activeGender || ref.read(profileNotifierProvider).profiles.isEmpty) {
        ref.read(profileNotifierProvider.notifier).updateFilters(gender: activeGender);
      }
    });
  }

  @override
  void didUpdateWidget(covariant SearchResultsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialGender != widget.initialGender) {
      final normalized = ProfileModel.normalizeGenderToApi(widget.initialGender);
      final newGender = (normalized == 'MALE' || normalized == 'FEMALE') ? normalized : 'ALL';
      if (_selectedGender != newGender) {
        _onGenderTabChanged(newGender);
      }
    }
  }

  void _onGenderTabChanged(String gender) {
    if (_selectedGender == gender) return;
    setState(() {
      _selectedGender = gender;
    });
    _applyActiveFilters();
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _applyActiveFilters();
    });
  }

  void _applyActiveFilters() {
    final keyword = _searchController.text.trim();
    final apiGender = _selectedGender == 'ALL' ? '' : _selectedGender;
    final status = _selectedMaritalStatus == 'ALL' ? null : _selectedMaritalStatus;
    final minAge = _ageRange.start.round();
    final maxAge = _ageRange.end.round();

    ref.read(profileNotifierProvider.notifier).updateFilters(
      search: keyword.isNotEmpty ? keyword : null,
      gender: apiGender,
      maritalStatus: status,
      status: status,
      minAge: minAge > 18 ? minAge : null,
      maxAge: maxAge < 55 ? maxAge : null,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileNotifierProvider, (previous, next) {
      if (widget.initialGender == null) {
        final currentGenderInProvider = ref.read(profileNotifierProvider.notifier).currentGender;
        if (currentGenderInProvider == null || currentGenderInProvider.isEmpty) {
          if (_selectedGender != 'ALL' || _selectedMaritalStatus != 'ALL' || _searchController.text.isNotEmpty) {
            setState(() {
              _selectedGender = 'ALL';
              _selectedMaritalStatus = 'ALL';
              _ageRange = const RangeValues(18, 55);
              _searchController.clear();
            });
          }
        }
      }
    });

    final profileState = ref.watch(profileNotifierProvider);
    final rawProfiles = profileState.profiles;

    // Strict client-side gender and marital status separation
    final profiles = rawProfiles.where((p) {
      if (_selectedGender == 'MALE' && !p.isMale) return false;
      if (_selectedGender == 'FEMALE' && !p.isFemale) return false;
      if (_selectedMaritalStatus == 'MARRIED') {
        if (!p.isMarried) return false;
      } else {
        // By default, exclude married profiles from general matrimony searches unless specifically selected
        if (_selectedMaritalStatus == 'ALL' && p.isMarried) return false;
        if (_selectedMaritalStatus != 'ALL') {
          final norm = ProfileModel.normalizeMaritalStatusToApi(p.maritalStatus);
          if (norm != _selectedMaritalStatus) return false;
        }
      }
      return true;
    }).toList();

    if (kIsWeb) {
      return _buildWebScaffold(context, profileState, profiles);
    }
    return _buildMobileScaffold(context, profileState, profiles);
  }

  // ==========================================
  // WEB DEDICATED SEARCH & DISCOVERY INTERFACE
  // ==========================================
  Widget _buildWebScaffold(BuildContext context, ProfileState profileState, List<ProfileModel> profiles) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 990;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: const WebHomeHeader(activeRoute: '/search'),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // 1. Breadcrumbs & Search Hero Banner
            _buildWebHeroBanner(context, profiles.length, profileState.isLoading),

            // 2. Main Search Body (Sidebar + Candidates Grid)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1260),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width >= 1200 ? 32 : (width >= 768 ? 20 : 14),
                    vertical: 28,
                  ),
                  child: isDesktop
                      ? _buildWebDesktopLayout(context, profileState, profiles)
                      : _buildWebMobileTabletLayout(context, profileState, profiles),
                ),
              ),
            ),

            // 3. Official Web Footer
            const WebHomeFooter(),
          ],
        ),
      ),
    );
  }

  // --- WEB HERO & SEARCH BANNER ---
  Widget _buildWebHeroBanner(BuildContext context, int count, bool isLoading) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 990;

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
            color: const Color(0xFFD6A34A).withValues(alpha: 0.7),
            width: 1.2,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Corner mandala watermarks
          Positioned(
            top: 0,
            left: 0,
            width: isDesktop ? 180 : 100,
            height: isDesktop ? 180 : 100,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.35,
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
            width: isDesktop ? 180 : 100,
            height: isDesktop ? 180 : 100,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  'assets/images/mandala_watermark_top.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.topRight,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1260),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16,
                  vertical: isDesktop ? 26 : 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumbs
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        InkWell(
                          onTap: () => context.go('/main-poster'),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.home_outlined, size: 14, color: Color(0xFF64748B)),
                              SizedBox(width: 4),
                              Text('હોમ (Home)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const Text('›', style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                        InkWell(
                          onTap: () => context.go('/home'),
                          child: const Text('લગ્ન સાથી (Matrimony)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                        ),
                        const Text('›', style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                        const Text('ઉમેદવાર શોધ (Search Profiles)', style: TextStyle(fontSize: 12, color: Color(0xFFA4143D), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Badge + Heading
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF101B36), Color(0xFF1F325C)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD6A34A), width: 1.0),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user_rounded, color: Color(0xFFFFDF7A), size: 12),
                              SizedBox(width: 6),
                              Text(
                                '૧૦૦% પ્રમાણિત વણકર સમાજ વૈવાહિક પ્રોફાઇલ્સ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFDF7A),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      'Search Profiles (ઉમેદવાર શોધ)',
                      style: TextStyle(
                        fontSize: isDesktop ? 30 : 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF101B36),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFA4143D), Color(0xFFD97706)],
                      ).createShader(bounds),
                      child: const Text(
                        'સંસ્કારી અને શિક્ષિત વણકર સમાજના સુયોગ્ય ઉમેદવારો (Find Verified Matches)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Quick Search Box & Gender Toggle Tabs Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFD6A34A).withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF101B36).withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Input Row
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 46,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF8F5),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFD6A34A).withValues(alpha: 0.4),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search_rounded, color: Color(0xFFA4143D), size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          onChanged: _onSearchChanged,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            color: Color(0xFF101B36),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: 'નામ, આઈડી, ગામ કે શહેરથી શોધો... (Search by Name, ID, Village, City)',
                                            hintStyle: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF94A3B8),
                                              fontWeight: FontWeight.normal,
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                      if (_searchController.text.isNotEmpty)
                                        IconButton(
                                          icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                                          onPressed: () {
                                            _searchController.clear();
                                            _applyActiveFilters();
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Gender Toggle Chips & Count Row
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              // Gender chips
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildWebGenderChip(
                                    label: 'વર (Grooms)',
                                    icon: Icons.man_rounded,
                                    genderValue: 'MALE',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildWebGenderChip(
                                    label: 'કન્યા (Brides)',
                                    icon: Icons.woman_rounded,
                                    genderValue: 'FEMALE',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildWebGenderChip(
                                    label: 'બધા (All)',
                                    icon: Icons.people_alt_rounded,
                                    genderValue: 'ALL',
                                  ),
                                ],
                              ),

                              // Count badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF8F5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFD6A34A).withValues(alpha: 0.5),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF00695C)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$count ઉમેદવારો ઉપલબ્ધ (Profiles Found)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF101B36),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebGenderChip({
    required String label,
    required IconData icon,
    required String genderValue,
  }) {
    final isSelected = _selectedGender == genderValue;
    return InkWell(
      onTap: () => _onGenderTabChanged(genderValue),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFA4143D) : const Color(0xFFFAF8F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFA4143D) : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF101B36),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF101B36),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DESKTOP TWO-COLUMN LAYOUT (SIDEBAR + GRID) ---
  Widget _buildWebDesktopLayout(BuildContext context, ProfileState profileState, List<ProfileModel> profiles) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Sticky Filter Sidebar
        SizedBox(
          width: 290,
          child: _buildWebFilterSidebar(context),
        ),

        const SizedBox(width: 28),

        // Right Column: Active Filters Bar + Candidate Grid
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWebActiveFiltersBar(context, profiles.length),
              const SizedBox(height: 18),
              if (profileState.isLoading && profiles.isEmpty)
                _buildWebLoadingGrid()
              else if (profiles.isEmpty)
                _buildWebEmptyState(context)
              else
                _buildWebCandidateGrid(context, profileState, profiles),
            ],
          ),
        ),
      ],
    );
  }

  // --- TABLET & MOBILE WEB LAYOUT ---
  Widget _buildWebMobileTabletLayout(BuildContext context, ProfileState profileState, List<ProfileModel> profiles) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showFilterBottomSheet(context),
                icon: const Icon(Icons.tune_rounded, size: 16, color: Color(0xFFA4143D)),
                label: const Text('શોધ ફિલ્ટર (Filter Profiles)', style: TextStyle(color: Color(0xFFA4143D), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFD6A34A), width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD6A34A).withValues(alpha: 0.5)),
              ),
              child: Text(
                '${profiles.length} પ્રોફાઇલ',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF101B36)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (profileState.isLoading && profiles.isEmpty)
          _buildWebLoadingGrid()
        else if (profiles.isEmpty)
          _buildWebEmptyState(context)
        else
          _buildWebCandidateGrid(context, profileState, profiles),
      ],
    );
  }

  // --- WEB FILTER SIDEBAR ---
  Widget _buildWebFilterSidebar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD6A34A).withValues(alpha: 0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101B36).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune_rounded, color: Color(0xFFA4143D), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'શોધ ફિલ્ટર (Filters)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101B36),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _resetAllFilters,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'રીસેટ (Reset)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA4143D),
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFFE2E8F0), height: 22),

          // 1. Candidate Type
          const Text(
            'ઉમેદવાર (Looking For)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF101B36)),
          ),
          const SizedBox(height: 10),
          _buildSidebarRadioItem('👨 વર (Grooms)', 'MALE'),
          const SizedBox(height: 6),
          _buildSidebarRadioItem('👰 કન્યા (Brides)', 'FEMALE'),
          const SizedBox(height: 6),
          _buildSidebarRadioItem('👥 તમામ (All Candidates)', 'ALL'),

          const Divider(color: Color(0xFFE2E8F0), height: 24),

          // 2. Age Range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'વય મર્યાદા (Age Range)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF101B36)),
              ),
              Text(
                '${_ageRange.start.round()} - ${_ageRange.end.round()} વર્ષ',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFA4143D)),
              ),
            ],
          ),
          RangeSlider(
            values: _ageRange,
            min: 18,
            max: 55,
            divisions: 37,
            activeColor: const Color(0xFFA4143D),
            inactiveColor: const Color(0xFFE2E8F0),
            onChanged: (values) {
              setState(() => _ageRange = values);
              _debounceTimer?.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 300), _applyActiveFilters);
            },
          ),
          // Quick Age Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildQuickAgeChip('18-25', 18, 25),
              _buildQuickAgeChip('26-30', 26, 30),
              _buildQuickAgeChip('31-35', 31, 35),
              _buildQuickAgeChip('36+', 36, 55),
            ],
          ),

          const Divider(color: Color(0xFFE2E8F0), height: 24),

          // 3. Marital Status
          const Text(
            'વૈવાહિક સ્થિતિ (Marital Status)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF101B36)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildSidebarMaritalChip('બધા (All)', 'ALL'),
              _buildSidebarMaritalChip('અપરિણીત (Never Married)', 'NEVER_MARRIED'),
              _buildSidebarMaritalChip('પરિણીત (Married)', 'MARRIED'),
              _buildSidebarMaritalChip('છૂટાછેડા (Divorced)', 'DIVORCED'),
              _buildSidebarMaritalChip('વિધુર / વિધવા (Widowed)', 'WIDOWED'),
            ],
          ),

          const Divider(color: Color(0xFFE2E8F0), height: 24),

          // 4. Detailed Advanced Search Link
          InkWell(
            onTap: () {
              final lookingFor = _selectedGender == 'MALE' ? 'Groom' : (_selectedGender == 'FEMALE' ? 'Bride' : 'Groom');
              context.push('/advanced-search?lookingFor=$lookingFor');
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF8F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD6A34A).withValues(alpha: 0.6)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.filter_alt_rounded, size: 16, color: Color(0xFFA4143D)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'વિસ્તૃત શોધ (Advanced Search)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101B36),
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFA4143D)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Trust Badge inside sidebar
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_rounded, size: 14, color: Color(0xFF00695C)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '૧૦૦% સુરક્ષિત અને ચકાસાયેલ પારિવારિક માહિતી.',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarRadioItem(String label, String genderVal) {
    final isSelected = _selectedGender == genderVal;
    return InkWell(
      onTap: () => _onGenderTabChanged(genderVal),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF1F2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFA4143D) : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              size: 16,
              color: isSelected ? const Color(0xFFA4143D) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFFA4143D) : const Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAgeChip(String label, double min, double max) {
    final isSelected = _ageRange.start == min && _ageRange.end == max;
    return InkWell(
      onTap: () {
        setState(() => _ageRange = RangeValues(min, max));
        _applyActiveFilters();
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFA4143D) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarMaritalChip(String label, String status) {
    final isSelected = _selectedMaritalStatus == status;
    return InkWell(
      onTap: () {
        setState(() => _selectedMaritalStatus = status);
        _applyActiveFilters();
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFA4143D) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFFA4143D) : const Color(0xFFCBD5E1),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildWebActiveFiltersBar(BuildContext context, int count) {
    final hasSearch = _searchController.text.trim().isNotEmpty;
    final hasGender = _selectedGender != 'ALL';
    final hasMarital = _selectedMaritalStatus != 'ALL';
    final hasAge = _ageRange.start > 18 || _ageRange.end < 55;
    final hasFilters = hasSearch || hasGender || hasMarital || hasAge;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(
            'દર્શાવેલ ઉમેદવારો: $count',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101B36),
            ),
          ),
          const SizedBox(width: 12),
          if (hasFilters) ...[
            const Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (hasGender)
                      _buildActiveFilterTag(
                        _selectedGender == 'MALE' ? 'વર (Groom)' : 'કન્યા (Bride)',
                        () => _onGenderTabChanged('ALL'),
                      ),
                    if (hasMarital)
                      _buildActiveFilterTag(
                        _selectedMaritalStatus,
                        () {
                          setState(() => _selectedMaritalStatus = 'ALL');
                          _applyActiveFilters();
                        },
                      ),
                    if (hasAge)
                      _buildActiveFilterTag(
                        '${_ageRange.start.round()}-${_ageRange.end.round()} વર્ષ',
                        () {
                          setState(() => _ageRange = const RangeValues(18, 55));
                          _applyActiveFilters();
                        },
                      ),
                    if (hasSearch)
                      _buildActiveFilterTag(
                        '"${_searchController.text.trim()}"',
                        () {
                          _searchController.clear();
                          _applyActiveFilters();
                        },
                      ),
                    TextButton(
                      onPressed: _resetAllFilters,
                      child: const Text('બધા દૂર કરો (Clear All)', style: TextStyle(fontSize: 11.5, color: Color(0xFFA4143D), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const Spacer(),
            const Text(
              'તમામ વણકર સમાજ પ્રોફાઇલ્સ',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFilterTag(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFFA4143D), fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 13, color: Color(0xFFA4143D)),
          ),
        ],
      ),
    );
  }

  // --- CANDIDATE CARDS GRID FOR WEB ---
  Widget _buildWebCandidateGrid(BuildContext context, ProfileState profileState, List<ProfileModel> profiles) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 820 ? 2 : 1;
        final rowCount = (profiles.length + crossAxisCount - 1) ~/ crossAxisCount;

        return Column(
          children: [
            for (int r = 0; r < rowCount; r++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int c = 0; c < crossAxisCount; c++) ...[
                    if (c > 0) const SizedBox(width: 18),
                    Expanded(
                      child: (r * crossAxisCount + c < profiles.length)
                          ? _buildWebCandidateCard(
                              context,
                              profiles[r * crossAxisCount + c],
                              r * crossAxisCount + c,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
            ],
            if (profileState.isLoadingNextPage)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: Color(0xFFA4143D)),
                ),
              ),
          ],
        );
      },
    );
  }

  // --- PRECISE, MODERN WEB CANDIDATE CARD ---
  Widget _buildWebCandidateCard(BuildContext context, ProfileModel profile, int index) {
    final isGirl = profile.isFemale;
    final hasPhoto = profile.fullPhotoUrl != null && profile.fullPhotoUrl!.isNotEmpty;
    final cleanId = profile.cleanDisplayId;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD6A34A).withValues(alpha: 0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101B36).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar + Name + ID + Gender Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with Gold Frame & Verified Badge
                  Stack(
                    children: [
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD6A34A),
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD6A34A).withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: hasPhoto
                              ? Image.network(
                                  profile.fullPhotoUrl!,
                                  fit: BoxFit.cover,
                                  width: 66,
                                  height: 66,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildAvatarFallback(isGirl, profile.fullName),
                                )
                              : _buildAvatarFallback(isGirl, profile.fullName),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00695C),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Name + Gender + ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                profile.fullName.isNotEmpty ? profile.fullName : 'Samaj Member',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF101B36),
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: profile.isMarried
                                    ? const Color(0xFFFEF3C7)
                                    : (isGirl ? const Color(0xFFFCE4EC) : const Color(0xFFE0F2F1)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: profile.isMarried
                                      ? const Color(0xFFF59E0B)
                                      : (isGirl ? const Color(0xFFF48FB1) : const Color(0xFF80CBC4)),
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                profile.isMarried
                                    ? '💍 પરિણીત (Married)'
                                    : (isGirl ? '👰 કન્યા (Bride)' : '👨 વર (Groom)'),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: profile.isMarried
                                      ? const Color(0xFF92400E)
                                      : (isGirl ? const Color(0xFFA4143D) : const Color(0xFF00695C)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // ID Capsule with Copy Action
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: cleanId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('ID કોપી થયો: $cleanId'),
                                    backgroundColor: const Color(0xFFA4143D),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1F0FF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF90CAF9), width: 1.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'ID: $cleanId',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1976D2),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.copy_rounded, size: 11, color: Color(0xFF1976D2)),
                                  ],
                                ),
                              ),
                            ),
                            if (profile.age != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFFED7AA), width: 1.0),
                                ),
                                child: Text(
                                  '🎂 ${profile.age} વર્ષ',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC2410C),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // Subtle Divider
              Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xFFE2D6C0), Colors.transparent],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Details Rows
              _buildWebCardInfoRow(
                Icons.work_outline_rounded,
                profile.displayProfession,
              ),
              const SizedBox(height: 6),

              _buildWebCardInfoRow(
                Icons.school_outlined,
                profile.education.isNotEmpty ? profile.education : 'શિક્ષણ વિગતવાર ઉપલબ્ધ',
              ),
              const SizedBox(height: 6),

              _buildWebCardInfoRow(
                Icons.location_on_outlined,
                profile.displayLocation,
              ),

              const SizedBox(height: 14),

              // Action Buttons Row: View Profile CTA + Like Heart
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/candidate-profile-details', extra: profile);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA4143D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: Color(0xFFFFDF7A), width: 1.0),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View Profile (વિગતવાર જુઓ)',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildWebLikeButton(profile),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebCardInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 15, color: const Color(0xFFA4143D)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
              height: 1.25,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildWebLikeButton(ProfileModel profile) {
    return Consumer(
      builder: (context, ref, _) {
        final isLiked = ref.watch(isProfileLikedProvider(profile.id));
        return Tooltip(
          message: isLiked ? 'પસંદ કરેલ (Shortlisted)' : 'પસંદ કરો (Shortlist)',
          child: InkWell(
            onTap: () {
              ref.read(likedProfilesProvider.notifier).toggleLike(profile, context: context);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isLiked ? const Color(0xFFFCE4EC) : const Color(0xFFFAF8F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isLiked ? const Color(0xFFA4143D) : const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isLiked ? const Color(0xFFA4143D) : const Color(0xFF64748B),
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebLoadingGrid() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48.0),
        child: Column(
          children: [
            CircularProgressIndicator(color: Color(0xFFA4143D)),
            SizedBox(height: 16),
            Text(
              'પ્રોફાઇલ્સ લોડ થઈ રહી છે... (Loading Candidates)',
              style: TextStyle(color: Color(0xFF101B36), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6A34A).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101B36).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFECDD3), width: 1.5),
              ),
              child: const Icon(Icons.person_search_rounded, size: 36, color: Color(0xFFA4143D)),
            ),
            const SizedBox(height: 16),
            const Text(
              'કોઈ ઉમેદવાર મળ્યા નથી (No Profiles Found)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF101B36)),
            ),
            const SizedBox(height: 8),
            const Text(
              'તમારી શોધ મુજબ પ્રોફાઇલ ઉપલબ્ધ નથી. કૃપા કરીને ફિલ્ટર્સ બદલો અથવા તમામ ઉમેદવારો જુઓ.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _resetAllFilters,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('તમામ ઉમેદવારો જુઓ (View All Candidates)', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA4143D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetAllFilters() {
    setState(() {
      _selectedGender = 'ALL';
      _selectedMaritalStatus = 'ALL';
      _ageRange = const RangeValues(18, 55);
      _searchController.clear();
    });
    _applyActiveFilters();
  }

  // ==========================================
  // NATIVE MOBILE LAYOUT (100% PRESERVED)
  // ==========================================
  Widget _buildMobileScaffold(BuildContext context, ProfileState profileState, List<ProfileModel> profiles) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF011A28), // Deep midnight peacock teal
              Color(0xFF042636),
              Color(0xFF01121C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Royal Peacock App Bar with Ornate Gold Buttons & Filigree
              _buildRoyalHeader(context),

              // Centered Search Controls for Web and Mobile
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 2. Pill Search Input with Golden Border
                      _buildSearchBar(),

                      // 3. Jewel-Toned "Search by Filter" Interactive Banner
                      _buildSearchByFilterBanner(),

                      // 4. Segmented Tab Selector for Boys / Girls / All
                      _buildGenderSegmentedTabs(),

                      // 5. Dynamic Summary Counter Strip with Peacock Feather Accent
                      _buildSummaryBadge(profiles.length, profileState.isLoading),
                    ],
                  ),
                ),
              ),

              // 6. Content List or Empty State (Responsive Single-Column on Mobile, 2-Column on Tablet/Desktop)
              Expanded(
                child: profileState.isLoading && profiles.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFFFFD700)),
                            SizedBox(height: 16),
                            Text(
                              'પ્રોફાઇલ્સ લોડ થઈ રહી છે...',
                              style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : profiles.isEmpty
                        ? _buildEmptyState(context)
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 720;

                              if (!isWide) {
                                // Mobile view (< 720px): exact single-column list
                                return ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  itemCount: profiles.length + (profileState.isLoadingNextPage ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == profiles.length) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                                        ),
                                      );
                                    }

                                    final profile = profiles[index];
                                    return _buildProfileCard(context, profile, index);
                                  },
                                );
                              }

                              // Tablet / Desktop view (>= 720px): centered 2-column layout with natural card heights
                              final rowCount = (profiles.length + 1) ~/ 2;
                              final totalRows = rowCount + (profileState.isLoadingNextPage ? 1 : 0);

                              return Align(
                                alignment: Alignment.topCenter,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 1080),
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    itemCount: totalRows,
                                    itemBuilder: (context, rowIndex) {
                                      if (rowIndex == rowCount) {
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                                          ),
                                        );
                                      }

                                      final leftIndex = rowIndex * 2;
                                      final rightIndex = leftIndex + 1;

                                      final leftProfile = profiles[leftIndex];
                                      final rightProfile = rightIndex < profiles.length ? profiles[rightIndex] : null;

                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _buildProfileCard(context, leftProfile, leftIndex),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: rightProfile != null
                                                ? _buildProfileCard(context, rightProfile, rightIndex)
                                                : const SizedBox.shrink(),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. ROYAL HEADER WITH ORNATE GOLD BUTTONS & PEACOCK BANNER ---
  Widget _buildRoyalHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF011824),
            Color(0xFF042838),
            Color(0xFF1E062B),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner Royal Peacock Feather behind Back button
          Positioned(
            left: -6,
            top: -12,
            width: 65,
            height: 78,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -0.28,
                child: Image.asset(
                  'assets/images/real_peacock_feather.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Subtle purple aura behind Filter button
          Positioned(
            right: -6,
            top: -10,
            width: 50,
            height: 65,
            child: IgnorePointer(
              child: Transform.flip(
                flipX: true,
                child: Transform.rotate(
                  angle: 0.32,
                  child: Opacity(
                    opacity: 0.55,
                    child: Image.asset(
                      'assets/images/real_peacock_feather.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                // Ornate Golden Back Button (Circular)
                _buildOrnateCircleButton(
                  icon: Icons.arrow_back,
                  tooltip: 'પાછા જાઓ (Back)',
                  bgColor: const Color(0xFF003834),
                  iconColor: const Color(0xFFFFD700),
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
                const SizedBox(width: 8),

                // Title with Rich 3D Gold Glow
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Search Profiles (ઉમેદવાર શોધ)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFFDF00),
                          fontSize: 17.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 2)),
                            Shadow(color: Color(0xAAFFD700), blurRadius: 10),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 140,
                        height: 1.8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFFFFDF73),
                              Color(0xFFD4AF37),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Ornate Golden Filter Button (Circular)
                _buildOrnateCircleButton(
                  icon: Icons.tune_rounded,
                  tooltip: 'Filter Profiles (શોધ ફિલ્ટર)',
                  bgColor: const Color(0xFF380036),
                  iconColor: const Color(0xFFFFD700),
                  onTap: () => _showFilterBottomSheet(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrnateCircleButton({
    required IconData icon,
    required String tooltip,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFEA88),
                Color(0xFFD4AF37),
                Color(0xFF8B5A10),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(2.5), // Shiny embossed gold frame
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: Border.all(color: const Color(0xFFFFDF73), width: 1.0),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 21),
            ),
          ),
        ),
      ),
    );
  }

  // --- 2. PILL SEARCH BAR WITH METALLIC GOLD BORDER ---
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFDF8),
            Color(0xFFF6EEDA),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13.5, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'નામ, આઈડી, ગામ કે શહેરથી શોધો...',
          hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1E293B), size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF64748B)),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : IconButton(
                  tooltip: 'Filter Profiles (શોધ ફિલ્ટર)',
                  icon: const Icon(Icons.tune_rounded, color: Color(0xFF006D77), size: 21),
                  onPressed: () => _showFilterBottomSheet(context),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        ),
      ),
    );
  }

  // --- 3. JEWEL-TONED "SEARCH BY FILTER" BANNER ---
  Widget _buildSearchByFilterBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final lookingFor = _selectedGender == 'MALE' ? 'Groom' : (_selectedGender == 'FEMALE' ? 'Bride' : 'Groom');
            context.push('/advanced-search?lookingFor=$lookingFor');
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00796B),
                  Color(0xFF004D40),
                  Color(0xFF00332B),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
                const BoxShadow(
                  color: Colors.black45,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Filter circular medallion badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFDF73), width: 1.6),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A896), Color(0xFF028090)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 3,
                        offset: Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.filter_list_rounded, color: Colors.white, size: 21),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ફિલ્ટર દ્વારા શોધો (Search by Filter)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          letterSpacing: 0.2,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
                          ],
                        ),
                      ),
                      SizedBox(height: 1.5),
                      Text(
                        'પરગણા, જિલ્લો, શિક્ષણ, વ્યવસાય સાથે વિગતવાર શોધો',
                        style: TextStyle(
                          color: Color(0xFFB2DFDB),
                          fontSize: 10.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFD700), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 4. SEGMENTED TABS (BOYS / GIRLS / ALL) ---
  Widget _buildGenderSegmentedTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 6),
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Boys / વર
          Expanded(
            child: _buildSegmentedTabButton(
              gender: 'MALE',
              label: '👦 વર (Boys)',
              isSelected: _selectedGender == 'MALE',
              activeColors: [const Color(0xFF008272), const Color(0xFF005349)],
              inactiveTextColor: const Color(0xFF00584E),
            ),
          ),
          const SizedBox(width: 4),
          // 2. Girls / કન્યા
          Expanded(
            child: _buildSegmentedTabButton(
              gender: 'FEMALE',
              label: '👧 કન્યા (Girls)',
              isSelected: _selectedGender == 'FEMALE',
              activeColors: [const Color(0xFFC2185B), const Color(0xFF880E4F)],
              inactiveTextColor: const Color(0xFF9D174D),
            ),
          ),
          const SizedBox(width: 4),
          // 3. All / બધા
          Expanded(
            child: _buildSegmentedTabButton(
              gender: 'ALL',
              label: '👥 બધા (All)',
              isSelected: _selectedGender == 'ALL',
              activeColors: [const Color(0xFF0056D2), const Color(0xFF003087)],
              inactiveTextColor: const Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabButton({
    required String gender,
    required String label,
    required bool isSelected,
    required List<Color> activeColors,
    required Color inactiveTextColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () => _onGenderTabChanged(gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: activeColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(26),
          border: isSelected ? Border.all(color: const Color(0xFFFFDF73), width: 1.8) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : inactiveTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }

  // --- 5. SUMMARY COUNTER BADGE ---
  Widget _buildSummaryBadge(int count, bool isLoading) {
    String title;

    if (_selectedGender == 'FEMALE') {
      title = 'કન્યા ઉમેદવારો (Brides / Girls)';
    } else if (_selectedGender == 'MALE') {
      title = 'વર ઉમેદવારો (Grooms / Boys)';
    } else {
      title = 'તમામ ઉમેદવારો (All Candidates)';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 8),
      decoration: BoxDecoration(
        // Outer 3D Metallic Gold Rim
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF5B8), // Bright gold highlight
            Color(0xFFD4AF37), // Metallic gold
            Color(0xFF8B5A10), // Deep bevel shade
            Color(0xFFFFD700), // Pure gold sheen
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.2), // Crisp 3D metallic bevel thickness
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          // Inner Ivory Satin Plaque
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFFDF8),
              Color(0xFFFBF4E2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(21.8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21.8),
          child: Stack(
            children: [
              // 1. Right-side Seamless Peacock Feather Eye
              Positioned(
                right: -2,
                top: -3,
                bottom: -3,
                width: 68,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/summary_peacock_feather.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.centerRight,
                  ),
                ),
              ),

              // 2. Foreground content (Symbol, Title & Count, Loading Spinner)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 50, 0),
                child: Row(
                  children: [
                    // Gender Symbol
                    if (_selectedGender == 'ALL')
                      const Icon(
                        Icons.people_alt_rounded,
                        size: 16,
                        color: Color(0xFF00382E),
                      )
                    else
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CustomPaint(
                          painter: GenderSymbolPainter(
                            gender: _selectedGender,
                            color: const Color(0xFF00382E),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),

                    // Title & Count (FittedBox ensures 0 truncation on any screen size)
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$title • $count પ્રોફાઇલ ઉપલબ્ધ',
                          style: const TextStyle(
                            color: Color(0xFF00382E),
                            fontWeight: FontWeight.w700,
                            fontSize: 12.0,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),

                    if (isLoading) ...[
                      const SizedBox(width: 6),
                      const SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF006D77),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 6. ROYAL ORNATE CANDIDATE PROFILE CARD (EXACT AS TARGET SCREENSHOT) ---
  Widget _buildProfileCard(BuildContext context, ProfileModel profile, int index) {
    final isGirl = profile.isFemale;
    final isAlternatePurple = index % 2 == 1;
    final buttonGradient = (isGirl || isAlternatePurple)
        ? const LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF260447)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFF005A43), Color(0xFF002E22)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    final hasPhoto = profile.fullPhotoUrl != null && profile.fullPhotoUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        // Outer 3D Metallic Beveled Gold Rim
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF5B8), // Bright gold highlight
            Color(0xFFD4AF37), // Classic rich metallic gold
            Color(0xFF8B5A10), // Deep bronze bevel shade
            Color(0xFFFFD700), // Pure gold sheen
            Color(0xFFE5C158), // Warm gold base
          ],
          stops: [0.0, 0.25, 0.55, 0.82, 1.0],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.22),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFDF8),
              Color(0xFFFFFBF2),
              Color(0xFFF9F1DC),
            ],
          ),
          borderRadius: BorderRadius.circular(19.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19.5),
          child: CustomPaint(
            painter: RoyalCardWholeBoxPainter(isPurple: isAlternatePurple),
            child: Stack(
              children: [
                // 1. Full-Height Seamless Royal Baroque Peacock Wing with Centered Medallion Avatar
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 92,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cardHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : 180.0;
                      // Medallion Round Section Center:
                      // X is 58.5px from left edge, Y tracks at 33.5% of the dynamic card height
                      const medallionX = 58.5;
                      final medallionY = cardHeight * 0.335;
                      // Diameter is 64px to fill the golden medallion inner aperture cleanly
                      const avatarDiameter = 64.0;
                      final avatarLeft = medallionX - (avatarDiameter / 2);
                      final avatarTop = medallionY - (avatarDiameter / 2);

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Peacock wing background
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Image.asset(
                                isAlternatePurple
                                    ? 'assets/images/royal_card_wing_purple_full.png'
                                    : 'assets/images/royal_card_wing_teal_full.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),

                          // Mask & Avatar container centered precisely in the golden medallion
                          Positioned(
                            left: avatarLeft,
                            top: avatarTop,
                            width: avatarDiameter,
                            height: avatarDiameter,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => context.push('/candidate-profile-details', extra: profile),
                                customBorder: const CircleBorder(),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isGirl ? const Color(0xFFFCE4EC) : const Color(0xFFE8F4FD),
                                    border: Border.all(
                                      color: const Color(0xFFFFD700),
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.35),
                                        blurRadius: 6,
                                        spreadRadius: 0.5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: hasPhoto
                                        ? Image.network(
                                            profile.fullPhotoUrl!,
                                            fit: BoxFit.cover,
                                            width: avatarDiameter,
                                            height: avatarDiameter,
                                            errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(isGirl, profile.fullName),
                                          )
                                        : _buildAvatarFallback(isGirl, profile.fullName),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // 3. Main Candidate Details (Padded cleanly to the right of the ornate wing)
                Padding(
                  padding: const EdgeInsets.fromLTRB(98, 11, 11, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Name and Gender Pill Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              profile.fullName.isNotEmpty ? profile.fullName : 'User Member',
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F2D37),
                                height: 1.15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: profile.isMarried
                                  ? const Color(0xFFFEF3C7)
                                  : (isGirl ? const Color(0xFFFCE4EC) : const Color(0xFFE0F7F0)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: profile.isMarried
                                    ? const Color(0xFFF59E0B)
                                    : (isGirl ? const Color(0xFFF48FB1) : const Color(0xFF80CBC4)),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              profile.isMarried
                                  ? '💍 પરિણીત (Married)'
                                  : (isGirl ? '👧 કન્યા (Bride)' : '👦 વર (Groom)'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: profile.isMarried
                                    ? const Color(0xFF92400E)
                                    : (isGirl ? const Color(0xFFA4143D) : const Color(0xFF00695C)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Row 2: Sky Blue ID Capsule with Copy Action
                      InkWell(
                        onTap: () {
                          final idToCopy = profile.cleanDisplayId;
                          if (idToCopy.isNotEmpty) {
                            Clipboard.setData(ClipboardData(text: idToCopy));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('ID કોપી થયો: $idToCopy'),
                                backgroundColor: const Color(0xFF006D77),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F0FF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF90CAF9), width: 1.0),
                          ),
                          child: Text(
                            'ID: ${profile.cleanDisplayId}',
                            style: const TextStyle(
                              fontSize: 10.2,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Row 3: Profession Row
                      Row(
                        children: [
                          const Icon(Icons.work_rounded, size: 14, color: Color(0xFF475569)),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              profile.displayProfession.isNotEmpty ? profile.displayProfession : 'Not specified',
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Row 4: Location Row
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF475569)),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              profile.displayLocation.isNotEmpty ? profile.displayLocation : 'Not specified',
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 5: Action buttons (View Profile + Heart)
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  context.push('/candidate-profile-details', extra: profile);
                                },
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                  decoration: BoxDecoration(
                                    gradient: buttonGradient,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                      const BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 3,
                                        offset: Offset(0, 1.5),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'View Profile (વિગતવાર જુઓ)',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFD700), size: 11),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _FavoriteIconButton(profile: profile),
                        ],
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

  // --- CANDIDATE AVATAR FALLBACK ---
  Widget _buildAvatarFallback(bool isGirl, String name) {
    final trimmed = name.trim();
    final String initial = trimmed.isNotEmpty
        ? trimmed.characters.first.toUpperCase()
        : (isGirl ? 'B' : 'G');
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGirl
              ? const [Color(0xFFFCE4EC), Color(0xFFF8BBD0)]
              : const [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: isGirl ? const Color(0xFFAD1457) : const Color(0xFF0D47A1),
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState(BuildContext context) {
    String title = 'કોઈ ઉમેદવાર મળ્યા નથી';
    String desc = 'તમારી શોધ મુજબ પ્રોફાઇલ ઉપલબ્ધ નથી. કૃપા કરીને શોધ ફિલ્ટર બદલો અથવા તમામ ઉમેદવારો જુઓ.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_search_rounded,
                size: 54,
                color: Color(0xFF006D77),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedGender != 'ALL')
                  OutlinedButton.icon(
                    onPressed: () => _onGenderTabChanged('ALL'),
                    icon: const Icon(Icons.people_alt, size: 16, color: Color(0xFFFFD700)),
                    label: const Text('બધા જુઓ (View All)', style: TextStyle(color: Color(0xFFFFD700))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                if (_selectedGender != 'ALL') const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showFilterBottomSheet(context),
                  icon: const Icon(Icons.tune, size: 16, color: Colors.white),
                  label: const Text('શોધ ફિલ્ટર બદલો (Adjust Filters)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D77),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- FILTER MODAL BOTTOM SHEET ---
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        String tempGender = _selectedGender;
        String tempMaritalStatus = _selectedMaritalStatus;
        RangeValues tempAgeRange = _ageRange;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 16,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFDF8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: Color(0xFFD4AF37), width: 2.5),
                  left: BorderSide(color: Color(0xFFD4AF37), width: 1),
                  right: BorderSide(color: Color(0xFFD4AF37), width: 1),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Title Row with Reset button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tune_rounded, color: Color(0xFF006D77), size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Filter Profiles (શોધ ફિલ્ટર)',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F2D37),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              tempGender = 'ALL';
                              tempMaritalStatus = 'ALL';
                              tempAgeRange = const RangeValues(18, 55);
                            });
                          },
                          child: const Text('રીસેટ (Reset)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 6),

                    // Ultra-Prominent Top Card to open Detailed Search Filters
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          final lookingFor = tempGender == 'MALE' ? 'Groom' : (tempGender == 'FEMALE' ? 'Bride' : 'Groom');
                          context.push('/advanced-search?lookingFor=$lookingFor');
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF007A87), Color(0xFF004E5B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5C07B), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.filter_list_rounded, color: Color(0xFFFFD700), size: 22),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'વિસ્તૃત શોધ ફિલ્ટર (Detailed Search Filters)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'પરગણા, ગામ, શિક્ષણ, નોકરી સાથે સંપૂર્ણ ફોર્મ ખોલો',
                                      style: TextStyle(fontSize: 10.5, color: Color(0xFFBBE5ED)),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFD700), size: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1. Gender Filter
                    const Text('લિંગ (Gender)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F2D37))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModalChoiceChip(
                            label: '👦 વર (Boys)',
                            isSelected: tempGender == 'MALE',
                            activeColor: const Color(0xFF007A87),
                            onTap: () => setSheetState(() => tempGender = 'MALE'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildModalChoiceChip(
                            label: '👧 કન્યા (Girls)',
                            isSelected: tempGender == 'FEMALE',
                            activeColor: const Color(0xFFC2185B),
                            onTap: () => setSheetState(() => tempGender = 'FEMALE'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildModalChoiceChip(
                            label: '👥 બધા (All)',
                            isSelected: tempGender == 'ALL',
                            activeColor: const Color(0xFF0056D2),
                            onTap: () => setSheetState(() => tempGender = 'ALL'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 2. Marital Status Filter
                    const Text('વૈવાહિક દરજ્જો (Marital Status)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F2D37))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChoiceChipItem(
                          label: 'તમામ (All)',
                          isSelected: tempMaritalStatus == 'ALL',
                          onTap: () => setSheetState(() => tempMaritalStatus = 'ALL'),
                        ),
                        _buildChoiceChipItem(
                          label: 'અપરિણીત (Never Married)',
                          isSelected: tempMaritalStatus == 'NEVER_MARRIED',
                          onTap: () => setSheetState(() => tempMaritalStatus = 'NEVER_MARRIED'),
                        ),
                        _buildChoiceChipItem(
                          label: 'પરિણીત (Married)',
                          isSelected: tempMaritalStatus == 'MARRIED',
                          onTap: () => setSheetState(() => tempMaritalStatus = 'MARRIED'),
                        ),
                        _buildChoiceChipItem(
                          label: 'છૂટાછેડા (Divorced)',
                          isSelected: tempMaritalStatus == 'DIVORCED',
                          onTap: () => setSheetState(() => tempMaritalStatus = 'DIVORCED'),
                        ),
                        _buildChoiceChipItem(
                          label: 'વિધવા / વિધુર (Widowed)',
                          isSelected: tempMaritalStatus == 'WIDOWED',
                          onTap: () => setSheetState(() => tempMaritalStatus = 'WIDOWED'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3. Age Range Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ઉંમર (Age Range)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F2D37))),
                        Text(
                          '${tempAgeRange.start.round()} થી ${tempAgeRange.end.round()} વર્ષ',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF007A87), fontSize: 13),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: tempAgeRange,
                      min: 18,
                      max: 60,
                      divisions: 42,
                      activeColor: const Color(0xFF007A87),
                      inactiveColor: const Color(0xFFCBD5E1),
                      labels: RangeLabels(
                        '${tempAgeRange.start.round()}',
                        '${tempAgeRange.end.round()}',
                      ),
                      onChanged: (values) {
                        setSheetState(() => tempAgeRange = values);
                      },
                    ),
                    const SizedBox(height: 18),

                    // Action Buttons: Old Form + Apply Filters
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              final lookingFor = tempGender == 'MALE' ? 'Groom' : (tempGender == 'FEMALE' ? 'Bride' : 'Groom');
                              context.push('/advanced-search?lookingFor=$lookingFor');
                            },
                            icon: const Icon(Icons.filter_alt_outlined, color: Color(0xFF007A87), size: 18),
                            label: const Text(
                              'વિસ્તૃત શોધ\n(Advance)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF007A87),
                                height: 1.2,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFE6FAF6),
                              side: const BorderSide(color: Color(0xFF007A87), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              setState(() {
                                _selectedGender = tempGender;
                                _selectedMaritalStatus = tempMaritalStatus;
                                _ageRange = tempAgeRange;
                              });
                              _applyActiveFilters();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007A87),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 2,
                            ),
                            child: const Text(
                              'લાગુ કરો (Apply Filters)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChoiceChipItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF007A87),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF0F2D37),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      backgroundColor: const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      showCheckmark: false,
    );
  }

  Widget _buildModalChoiceChip({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFCBD5E1),
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF0F2D37),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// --- FAVORITE / LIKE BUTTON WITH GOLD EMBOSSED CIRCLE ---
class _FavoriteIconButton extends ConsumerWidget {
  final ProfileModel profile;
  const _FavoriteIconButton({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(isProfileLikedProvider(profile.id));

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFEA88),
            Color(0xFFD4AF37),
            Color(0xFF8B5A10),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.2),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF8),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFDF73), width: 1.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: Tooltip(
            message: isLiked ? 'પસંદ કરેલ (Liked)' : 'પસંદ કરો (Like)',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                ref.read(likedProfilesProvider.notifier).toggleLike(profile, context: context);
              },
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    key: ValueKey<bool>(isLiked),
                    color: isLiked ? const Color(0xFFE91E63) : const Color(0xFF3E2723),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- STYLIZED AVATAR VECTOR FACE (MATCHING BOY SEARCH SCREENSHOT) ---
class StylizedAvatarFace extends StatelessWidget {
  final bool isFemale;
  final bool isPurple;
  const StylizedAvatarFace({super.key, required this.isFemale, this.isPurple = false});

  @override
  Widget build(BuildContext context) {
    final faceBgColor = isPurple ? const Color(0xFF381245) : const Color(0xFF0A2E35);
    return Center(
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: faceBgColor,
          shape: BoxShape.circle,
        ),
        child: CustomPaint(
          painter: _CuteBoyAvatarPainter(),
        ),
      ),
    );
  }
}

class _CuteBoyAvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Boy hair with side-swept fringe
    final hairPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final hairPath = Path();
    hairPath.moveTo(cx - 22, cy - 2);
    hairPath.cubicTo(cx - 20, cy - 20, cx + 20, cy - 20, cx + 22, cy - 2);
    hairPath.quadraticBezierTo(cx + 8, cy - 6, cx, cy - 3);
    hairPath.quadraticBezierTo(cx - 10, cy - 10, cx - 22, cy - 2);
    canvas.drawPath(hairPath, hairPaint);

    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Two friendly white dot eyes
    canvas.drawCircle(Offset(cx - 8, cy + 2), 3.2, eyePaint);
    canvas.drawCircle(Offset(cx + 8, cy + 2), 3.2, eyePaint);

    // Warm white curved smile
    final smilePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final smilePath = Path();
    smilePath.moveTo(cx - 6, cy + 10);
    smilePath.quadraticBezierTo(cx, cy + 15, cx + 6, cy + 10);
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- PEACOCK CARD WING PAINTER (EXACT DECORATIVE ARCH & FEATHER MATCHING TARGET) ---
class PeacockCardWingPainter extends CustomPainter {
  final bool isPurple;
  PeacockCardWingPainter({required this.isPurple});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Curved Wing Boundary Path
    final wingPath = Path();
    wingPath.moveTo(0, 0);
    wingPath.lineTo(55, 0);
    wingPath.cubicTo(85, 0, 98, 40, 88, 80);
    wingPath.cubicTo(78, 110, 88, size.height - 25, 60, size.height);
    wingPath.lineTo(0, size.height);
    wingPath.close();

    // Fill wing with rich gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: isPurple
            ? [const Color(0xFF8E24AA), const Color(0xFF6A1B9A), const Color(0xFF38006B)]
            : [const Color(0xFF00897B), const Color(0xFF00695C), const Color(0xFF003326)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, 100, size.height));
    canvas.drawPath(wingPath, fillPaint);

    // 2. Gleaming golden ribbon along the curved boundary
    final goldBorderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFEA88), Color(0xFFD4AF37), Color(0xFF8B5A10), Color(0xFFFFD700)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, 100, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final ribbonPath = Path();
    ribbonPath.moveTo(55, 0);
    ribbonPath.cubicTo(85, 0, 98, 40, 88, 80);
    ribbonPath.cubicTo(78, 110, 88, size.height - 25, 60, size.height);
    canvas.drawPath(ribbonPath, goldBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- ROYAL WHOLE-BOX PLAQUE PAINTER (3D BEVEL, CORNER FILIGREE & SATIN WATERMARK) ---
class RoyalCardWholeBoxPainter extends CustomPainter {
  final bool isPurple;
  const RoyalCardWholeBoxPainter({this.isPurple = false});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Subtle inner hairline border inset by 3.5px
    final innerHairline = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3.5, 3.5, size.width - 7, size.height - 7),
      const Radius.circular(16),
    );
    canvas.drawRRect(rrect, innerHairline);

    // 2. Top-Right Corner Baroque Gold Filigree Flourish
    _drawTopRightFiligree(canvas, size.width, 0);

    // 3. Bottom-Right Corner Soft Gold Filigree Accent
    _drawBottomRightFiligree(canvas, size.width, size.height);

    // 4. Soft satin ambient light arc across middle
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.4, -0.6),
        radius: 1.2,
        colors: [
          (isPurple ? const Color(0xFFE1BEE7) : const Color(0xFFFFF9C4)).withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);
  }

  void _drawTopRightFiligree(Canvas canvas, double w, double y) {
    final goldPen = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFDF73), Color(0xFFD4AF37), Color(0xFF996515)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(w - 70, y, 70, 50))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    // Corner curl 1 (large outer swoop)
    final p1 = Path();
    p1.moveTo(w - 60, y + 5);
    p1.cubicTo(w - 30, y + 6, w - 8, y + 16, w - 6, y + 42);
    canvas.drawPath(p1, goldPen);

    // Inner petal / spiral curl
    final p2 = Path();
    p2.moveTo(w - 42, y + 8);
    p2.cubicTo(w - 24, y + 10, w - 12, y + 22, w - 10, y + 34);
    canvas.drawPath(p2, goldPen..strokeWidth = 1.0);

    // Mini gold bead dots along the corner
    final dotPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w - 48, y + 7), 1.5, dotPaint);
    canvas.drawCircle(Offset(w - 28, y + 12), 1.6, dotPaint);
    canvas.drawCircle(Offset(w - 12, y + 26), 1.6, dotPaint);
    canvas.drawCircle(Offset(w - 8, y + 46), 1.4, dotPaint);
  }

  void _drawBottomRightFiligree(Canvas canvas, double w, double h) {
    final goldPen = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    final p = Path();
    p.moveTo(w - 45, h - 5);
    p.cubicTo(w - 25, h - 6, w - 6, h - 14, w - 5, h - 30);
    canvas.drawPath(p, goldPen);

    final dotPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w - 32, h - 7), 1.3, dotPaint);
    canvas.drawCircle(Offset(w - 14, h - 16), 1.3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- PEACOCK & GOLD FILIGREE CORNER PAINTER (LEGACY / FALLBACK) ---
class PeacockCardCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    PeacockCardWingPainter(isPurple: false).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- PEACOCK HEADER ORNAMENT PAINTER (LUSH PLUMES BEHIND BUTTONS) ---
class PeacockHeaderOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Left Corner Peacock Plume (behind Back button)
    _drawPeacockPlume(canvas, origin: const Offset(-4, 0), angle: 0.55);

    // 2. Right Corner Peacock Plume (behind Filter button)
    _drawPeacockPlume(canvas, origin: Offset(size.width + 4, 0), angle: -0.55);
  }

  void _drawPeacockPlume(Canvas canvas, {required Offset origin, required double angle}) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);

    final quillPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawLine(Offset.zero, const Offset(0, 50), quillPaint);

    final greenBarb = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final cyanBarb = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    for (int i = 0; i < 9; i++) {
      final y = 10.0 + (i * 4.2);
      canvas.drawLine(Offset(0, y), Offset(-18 - (i * 1.2), y - 7), i % 2 == 0 ? greenBarb : cyanBarb);
      canvas.drawLine(Offset(0, y), Offset(18 + (i * 1.2), y - 7), i % 2 == 0 ? cyanBarb : greenBarb);
    }

    // Eye
    final eyeCenter = const Offset(0, 46);
    canvas.drawOval(Rect.fromCenter(center: eyeCenter, width: 28, height: 20), Paint()..color = const Color(0xFF004D40));
    canvas.drawOval(Rect.fromCenter(center: eyeCenter, width: 20, height: 14), Paint()..color = const Color(0xFF00E5FF));
    canvas.drawOval(Rect.fromCenter(center: eyeCenter, width: 13, height: 9), Paint()..color = const Color(0xFFFFD700));
    canvas.drawOval(Rect.fromCenter(center: eyeCenter, width: 8, height: 6), Paint()..color = const Color(0xFF051026));
    canvas.drawCircle(Offset(eyeCenter.dx - 1, eyeCenter.dy - 1), 1.2, Paint()..color = Colors.white);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- MINI PEACOCK FEATHER PAINTER FOR STRIP ---
class PeacockMiniPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Barbules
    final barbulePaint = Paint()
      ..color = const Color(0xFF00A86B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawLine(Offset(cx - 12, cy + 6), Offset(cx + 10, cy - 6), barbulePaint);
    canvas.drawLine(Offset(cx - 8, cy + 8), Offset(cx + 12, cy - 3), barbulePaint);
    canvas.drawLine(Offset(cx - 5, cy + 9), Offset(cx + 14, cy), barbulePaint);

    // Eye
    final cyanPaint = Paint()..color = const Color(0xFF00E5FF)..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 2, cy), width: 18, height: 12), cyanPaint);

    final goldPaint = Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 2, cy), width: 12, height: 8), goldPaint);

    final pupilPaint = Paint()..color = const Color(0xFF051026)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + 2, cy), 2.8, pupilPaint);

    // Shimmer
    canvas.drawCircle(Offset(cx + 1, cy - 1), 0.8, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- CRISP GENDER SYMBOL PAINTER (EXACT MARS/VENUS VECTORS) ---
class GenderSymbolPainter extends CustomPainter {
  final String gender;
  final Color color;
  const GenderSymbolPainter({required this.gender, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    if (gender == 'MALE') {
      // Mars symbol: circle at lower-left, arrow pointing to upper-right
      const radius = 4.8;
      final circleCenter = Offset(cx - 2.2, cy + 2.2);
      canvas.drawCircle(circleCenter, radius, strokePaint);

      final arrowEnd = Offset(cx + 6.2, cy - 6.2);
      final arrowStart = Offset(
        circleCenter.dx + radius * 0.7071,
        circleCenter.dy - radius * 0.7071,
      );
      canvas.drawLine(arrowStart, arrowEnd, strokePaint);
      // Arrowhead
      canvas.drawLine(arrowEnd, Offset(arrowEnd.dx - 4.5, arrowEnd.dy), strokePaint);
      canvas.drawLine(arrowEnd, Offset(arrowEnd.dx, arrowEnd.dy + 4.5), strokePaint);
    } else if (gender == 'FEMALE') {
      // Venus symbol: circle at upper-center, cross pointing downward
      const radius = 4.8;
      final circleCenter = Offset(cx, cy - 2.5);
      canvas.drawCircle(circleCenter, radius, strokePaint);

      final stemStart = Offset(cx, circleCenter.dy + radius);
      final stemEnd = Offset(cx, cy + 7.0);
      canvas.drawLine(stemStart, stemEnd, strokePaint);
      // Crossbar
      canvas.drawLine(Offset(cx - 3.5, cy + 3.8), Offset(cx + 3.5, cy + 3.8), strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant GenderSymbolPainter oldDelegate) =>
      oldDelegate.gender != gender || oldDelegate.color != color;
}

