import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../../shared/models/profile_model.dart';

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
    final profileState = ref.watch(profileNotifierProvider);
    final rawProfiles = profileState.profiles;

    // Strict client-side gender and marital status separation
    final profiles = rawProfiles.where((p) {
      if (_selectedGender == 'MALE' && !p.isMale) return false;
      if (_selectedGender == 'FEMALE' && !p.isFemale) return false;
      if (_selectedMaritalStatus != 'ALL') {
        final norm = ProfileModel.normalizeMaritalStatusToApi(p.maritalStatus);
        if (norm != _selectedMaritalStatus) return false;
      }
      return true;
    }).toList();

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

              // 2. Pill Search Input with Golden Border
              _buildSearchBar(),

              // 3. Jewel-Toned "Search by Filter" Interactive Banner
              _buildSearchByFilterBanner(),

              // 4. Segmented Tab Selector for Boys / Girls / All
              _buildGenderSegmentedTabs(),

              // 5. Dynamic Summary Counter Strip with Peacock Feather Accent
              _buildSummaryBadge(profiles.length, profileState.isLoading),

              // 6. Content List or Empty State
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
                        : ListView.builder(
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
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. ROYAL HEADER WITH ORNATE GOLD BUTTONS & FILIGREE ---
  Widget _buildRoyalHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF011C2B),
            Color(0xFF082D3B),
            Color(0xFF220A35),
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
          // Background Peacock & Golden Filigree Ornaments
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: PeacockHeaderOrnamentPainter(),
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

                // Title with Rich Gold Glow
                Expanded(
                  child: Text(
                    'Search Profiles (ઉમેદવાર શોધ)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFDF00),
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 2)),
                        Shadow(color: Color(0x88FFD700), blurRadius: 10),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9.5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF007580),
                  Color(0xFF004B54),
                  Color(0xFF00282E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5C07B), width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Filter circular icon badge
                Container(
                  padding: const EdgeInsets.all(7.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A896), Color(0xFF028090)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: const Color(0xFFFFDF73), width: 1.4),
                  ),
                  child: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 19),
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
                        ),
                      ),
                      SizedBox(height: 1.5),
                      Text(
                        'પરગણા, જિલ્લો, શિક્ષણ, વ્યવસાય સાથે વિગતવાર શોધો',
                        style: TextStyle(color: Color(0xFFC7ECF2), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFD700), size: 15),
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

  // --- 5. SUMMARY COUNTER BADGE WITH REAL PEACOCK FEATHER ACCENT ---
  Widget _buildSummaryBadge(int count, bool isLoading) {
    String title;
    String symbol;

    if (_selectedGender == 'FEMALE') {
      title = 'કન્યા ઉમેદવારો (Brides / Girls)';
      symbol = '♀';
    } else if (_selectedGender == 'MALE') {
      title = 'વર ઉમેદવારો (Grooms / Boys)';
      symbol = '♂';
    } else {
      title = 'તમામ ઉમેદવારો (All Candidates)';
      symbol = '👥';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFDF8),
            Color(0xFFF9F2E2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            symbol,
            style: const TextStyle(
              color: Color(0xFF0F2D37),
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title • $count પ્રોફાઇલ ઉપલબ્ધ',
              style: const TextStyle(
                color: Color(0xFF0F2D37),
                fontWeight: FontWeight.bold,
                fontSize: 12.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Miniature Peacock Feather Accent
          SizedBox(
            width: 32,
            height: 22,
            child: CustomPaint(painter: PeacockMiniPainter()),
          ),
          if (isLoading) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF006D77)),
            ),
          ],
        ],
      ),
    );
  }

  // --- 6. ROYAL ORNATE CANDIDATE PROFILE CARD (EXACT AS SCREENSHOT) ---
  Widget _buildProfileCard(BuildContext context, ProfileModel profile, int index) {
    final isGirl = profile.isFemale;

    // Harmonious jewel button gradients:
    // Alternate between deep teal/emerald glossy gradient and royal purple glossy gradient
    final isAlternatePurple = index % 2 == 1;
    final buttonGradient = (isGirl || isAlternatePurple)
        ? const LinearGradient(
            colors: [Color(0xFF3D0A42), Color(0xFF200324)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF003D3D), Color(0xFF001F22)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final avatarCircleBg = isAlternatePurple ? const Color(0xFFEEDBFF) : const Color(0xFFDDF3EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFDF8),
            Color(0xFFFAF3E5),
            Color(0xFFFFFDF8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2.4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x22D4AF37),
            blurRadius: 10,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Top-left starry nebula accent (purple for card 2, emerald for card 1 & 3)
            Positioned(
              top: -24,
              left: -24,
              child: Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (isAlternatePurple ? const Color(0xFF8B1FA6) : const Color(0xFF008375)).withValues(alpha: 0.32),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom-left peacock feather and golden filigree corner decoration
            Positioned(
              left: 0,
              bottom: 0,
              child: IgnorePointer(
                child: SizedBox(
                  width: 115,
                  height: 115,
                  child: CustomPaint(
                    painter: PeacockCardCornerPainter(),
                  ),
                ),
              ),
            ),

            // Main Card Content
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar with Double Concentric Embossed Gold Ring Medallion
                      InkWell(
                        onTap: () => context.push('/candidate-profile-details', extra: profile),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFEA88), Color(0xFFD4AF37), Color(0xFF8B5A10)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(2.8),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: avatarCircleBg,
                              border: Border.all(color: const Color(0xFFFFDF73), width: 1.2),
                            ),
                            child: ClipOval(
                              child: (profile.fullPhotoUrl != null && profile.fullPhotoUrl!.isNotEmpty)
                                  ? Image.network(
                                      profile.fullPhotoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => StylizedAvatarFace(isFemale: isGirl, isPurple: isAlternatePurple),
                                    )
                                  : StylizedAvatarFace(isFemale: isGirl, isPurple: isAlternatePurple),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Candidate Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name & Gender Pill Badge
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    profile.fullName.isNotEmpty ? profile.fullName : 'User Member',
                                    style: const TextStyle(
                                      fontSize: 16.5,
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
                                    color: const Color(0xFFE8FAF4),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                                  ),
                                  child: Text(
                                    isGirl ? '👧 કન્યા (Bride)' : '👦 વર (Groom)',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F2D37),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),

                            // Sky Blue ID Capsule with Copy Action
                            InkWell(
                              onTap: () {
                                final idToCopy = profile.id.isNotEmpty ? profile.id : profile.displayId;
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
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF7DD3FC), width: 1.2),
                                ),
                                child: Text(
                                  'ID: ${profile.id.isNotEmpty ? profile.id : (profile.displayId.isNotEmpty ? profile.displayId : "d651408e-a133-4989-ae72-3a5efdaba695")}',
                                  style: const TextStyle(
                                    fontSize: 10.2,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0284C7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),

                            // Profession Row
                            Row(
                              children: [
                                const Icon(Icons.work_rounded, size: 14, color: Color(0xFF334155)),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    profile.displayProfession.isNotEmpty ? profile.displayProfession : 'Not specified',
                                    style: const TextStyle(
                                      color: Color(0xFF334155),
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

                            // Location Row
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF334155)),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    profile.displayLocation.isNotEmpty ? profile.displayLocation : 'Not specified',
                                    style: const TextStyle(
                                      color: Color(0xFF334155),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Bottom Action Buttons: Metallic View Profile + Golden Heart
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
                              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                              decoration: BoxDecoration(
                                gradient: buttonGradient,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFFFDF73), width: 2.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
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
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFD700), size: 13),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _FavoriteIconButton(profile: profile),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
class _FavoriteIconButton extends StatefulWidget {
  final ProfileModel profile;
  const _FavoriteIconButton({required this.profile});

  @override
  State<_FavoriteIconButton> createState() => _FavoriteIconButtonState();
}

class _FavoriteIconButtonState extends State<_FavoriteIconButton> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD4AF37), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Tooltip(
          message: _isLiked ? 'પસંદ કરેલ (Liked)' : 'પસંદ કરો (Like)',
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              setState(() {
                _isLiked = !_isLiked;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isLiked
                        ? '${widget.profile.fullName.isNotEmpty ? widget.profile.fullName : "ઉમેદવાર"} ની પ્રોફાઇલ પસંદ કરી છે!'
                        : '${widget.profile.fullName.isNotEmpty ? widget.profile.fullName : "ઉમેદવાર"} લિસ્ટમાંથી દૂર થઈ',
                  ),
                  backgroundColor: _isLiked ? const Color(0xFFC2185B) : Colors.black87,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Center(
              child: Icon(
                _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isLiked ? const Color(0xFFE91E63) : const Color(0xFF4A3525),
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- STYLIZED AVATAR VECTOR FACE (EXACTLY AS IN SCREENSHOT) ---
class StylizedAvatarFace extends StatelessWidget {
  final bool isFemale;
  final bool isPurple;
  const StylizedAvatarFace({super.key, required this.isFemale, this.isPurple = false});

  @override
  Widget build(BuildContext context) {
    final faceBgColor = isPurple ? const Color(0xFF381245) : const Color(0xFF0A2E35);
    return Center(
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: faceBgColor,
          shape: BoxShape.circle,
        ),
        child: CustomPaint(
          painter: _CuteFacePainter(),
        ),
      ),
    );
  }
}

class _CuteFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Two friendly white dot eyes
    canvas.drawCircle(Offset(cx - 9, cy - 2), 3.4, eyePaint);
    canvas.drawCircle(Offset(cx + 9, cy - 2), 3.4, eyePaint);

    // Warm white curved smile
    final smilePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final smilePath = Path();
    smilePath.moveTo(cx - 7, cy + 7);
    smilePath.quadraticBezierTo(cx, cy + 13, cx + 7, cy + 7);
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- PEACOCK & GOLD FILIGREE CORNER PAINTER ---
class PeacockCardCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Ornate golden filigree curves sweeping along bottom and left
    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final goldFill = Paint()
      ..color = const Color(0xFFFFDF73)
      ..style = PaintingStyle.fill;

    // Golden vine curling up left side
    final vineLeft = Path();
    vineLeft.moveTo(0, size.height - 12);
    vineLeft.cubicTo(18, size.height - 25, 24, size.height - 55, 12, size.height - 85);
    vineLeft.quadraticBezierTo(6, size.height - 98, 18, size.height - 105);
    canvas.drawPath(vineLeft, goldPaint);

    // Golden vine curling right along bottom
    final vineBottom = Path();
    vineBottom.moveTo(10, size.height);
    vineBottom.cubicTo(45, size.height - 16, 75, size.height - 8, 98, size.height - 12);
    canvas.drawPath(vineBottom, goldPaint);

    // Golden leaves / scroll beads
    canvas.drawCircle(Offset(12, size.height - 85), 3.5, goldFill);
    canvas.drawCircle(Offset(18, size.height - 105), 2.8, goldFill);
    canvas.drawCircle(Offset(75, size.height - 8), 3.2, goldFill);
    canvas.drawCircle(Offset(98, size.height - 12), 2.5, goldFill);

    // 2. Peacock Feather barbules (emerald green and turquoise)
    final barbulePaint1 = Paint()
      ..color = const Color(0xFF00A86B).withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final barbulePaint2 = Paint()
      ..color = const Color(0xFF00B4D8).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (int i = 0; i < 9; i++) {
      final rad = 0.15 + (i * 0.16);
      final x2 = 68 * math.cos(rad);
      final y2 = size.height - (68 * math.sin(rad));
      canvas.drawLine(Offset(8, size.height - 8), Offset(x2, y2), i % 2 == 0 ? barbulePaint1 : barbulePaint2);
    }

    // 3. Peacock Feather Eye (prominent centerpiece)
    final eyeCenterX = 32.0;
    final eyeCenterY = size.height - 32.0;

    // Outer rich emerald / cobalt plume
    final outerPlumePaint = Paint()
      ..color = const Color(0xFF007A65)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(eyeCenterX, eyeCenterY), width: 38, height: 30),
      outerPlumePaint,
    );

    // Turquoise ring
    final cyanPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(eyeCenterX, eyeCenterY), width: 28, height: 22),
      cyanPaint,
    );

    // Golden metallic bronze ring
    final bronzePaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(eyeCenterX, eyeCenterY), width: 19, height: 15),
      bronzePaint,
    );

    // Deep midnight indigo center eye
    final eyeCenterPaint = Paint()
      ..color = const Color(0xFF051026)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(eyeCenterX, eyeCenterY), width: 12, height: 10),
      eyeCenterPaint,
    );

    // Shimmer white highlight dot
    final shimmerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(eyeCenterX - 2, eyeCenterY - 2), 1.8, shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- PEACOCK HEADER ORNAMENT PAINTER ---
class PeacockHeaderOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final cyanPaint = Paint()..color = const Color(0xFF00E5FF)..style = PaintingStyle.fill;
    final goldFill = Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.fill;
    final darkEye = Paint()..color = const Color(0xFF051026)..style = PaintingStyle.fill;

    // Top-left peacock feather eye
    canvas.drawOval(Rect.fromCenter(center: const Offset(54, 12), width: 18, height: 12), cyanPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(54, 12), width: 12, height: 8), goldFill);
    canvas.drawCircle(const Offset(54, 12), 3, darkEye);

    // Top-right peacock feather eye
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width - 54, 12), width: 18, height: 12), cyanPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width - 54, 12), width: 12, height: 8), goldFill);
    canvas.drawCircle(Offset(size.width - 54, 12), 3, darkEye);

    // Decorative golden scroll curves under title
    final scrollPath = Path();
    final cx = size.width / 2;
    final cy = size.height - 4;
    scrollPath.moveTo(cx - 85, cy);
    scrollPath.quadraticBezierTo(cx - 40, cy + 3.5, cx, cy);
    scrollPath.quadraticBezierTo(cx + 40, cy + 3.5, cx + 85, cy);
    canvas.drawPath(scrollPath, goldPaint);
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
