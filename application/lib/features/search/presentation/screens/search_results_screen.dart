import 'dart:async';
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
          // Background Real Peacock Feather Corner Ornaments
          Positioned(
            left: -6,
            top: -8,
            width: 46,
            height: 58,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -0.35,
                child: Opacity(
                  opacity: 0.75,
                  child: Image.asset(
                    'assets/images/real_peacock_feather.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -6,
            top: -8,
            width: 46,
            height: 58,
            child: IgnorePointer(
              child: Transform.flip(
                flipX: true,
                child: Transform.rotate(
                  angle: 0.35,
                  child: Opacity(
                    opacity: 0.75,
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE8F6F8),
                  Color(0xFFF3FAFB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF80DEEA), width: 1.5),
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
                // Filter square-rounded tile (Electric Blue)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A2FF), Color(0xFF0066CC)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.tune_rounded, color: Colors.white, size: 22),
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
                          color: Color(0xFF0056B3),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 1.5),
                      Text(
                        'પરગણા, જિલ્લો, શિક્ષણ, વ્યવસાય સાથે વિગતવાર શોધો',
                        style: TextStyle(color: Color(0xFF5A6E85), fontSize: 10.8),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF0056B3), size: 16),
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
        color: const Color(0xFFE0F7F6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF80CBC4), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            symbol,
            style: const TextStyle(
              color: Color(0xFF00796B),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title • $count પ્રોફાઇલ ઉપલબ્ધ',
              style: const TextStyle(
                color: Color(0xFF004D40),
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isLoading) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF006D77)),
            ),
          ],
          const SizedBox(width: 6),
          Image.asset(
            'assets/images/real_peacock_feather.png',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  // --- 6. ROYAL ORNATE CANDIDATE PROFILE CARD (EXACT AS SCREENSHOT) ---
  Widget _buildProfileCard(BuildContext context, ProfileModel profile, int index) {
    final isGirl = profile.isFemale;

    // Harmonious jewel button gradients matching Image 2:
    // Card 1 & 3: Glossy Emerald/Teal gradient
    // Card 2: Glossy Royal Purple gradient
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

    final avatarCircleBg = isAlternatePurple ? const Color(0xFFF3E5F5) : const Color(0xFFE0F2F1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2D6A5), width: 1.6),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            // Left decorative peacock wing with golden border
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: PeacockCardWingPainter(isPurple: isAlternatePurple),
                ),
              ),
            ),

            // Authentic Photorealistic Royal Peacock Feather Ornament in lower corner
            Positioned(
              left: -10,
              bottom: -6,
              width: 88,
              height: 100,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: 0.28,
                  child: Image.asset(
                    'assets/images/real_peacock_feather.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Main Card Content
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar with Double Concentric Embossed Gold Ring Medallion
                      InkWell(
                        onTap: () => context.push('/candidate-profile-details', extra: profile),
                        child: Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFEA88), Color(0xFFD4AF37), Color(0xFF8B5A10)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(2.5),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: avatarCircleBg,
                              border: Border.all(color: const Color(0xFFFFDF73), width: 1.0),
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
                      const SizedBox(width: 14),

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
                                      fontSize: 16,
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
                                    color: const Color(0xFFE0F7F0),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFF80CBC4), width: 1.0),
                                  ),
                                  child: Text(
                                    isGirl ? '👧 કન્યા (Bride)' : '👦 વર (Groom)',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00695C),
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
                                  color: const Color(0xFFE1F0FF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF90CAF9), width: 1.0),
                                ),
                                child: Text(
                                  'ID: ${profile.id.isNotEmpty ? profile.id : (profile.displayId.isNotEmpty ? profile.displayId : "d651408e-a133-4989-ae72-3a5efdaba695")}',
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

                            // Profession Row
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

                            // Location Row
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
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Bottom Action Buttons: Metallic View Profile + Golden Heart
                  Row(
                    children: [
                      const SizedBox(width: 82), // Indent past the left peacock arc
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              context.push('/candidate-profile-details', extra: profile);
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.5, horizontal: 12),
                              decoration: BoxDecoration(
                                gradient: buttonGradient,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFFFDF73), width: 1.6),
                                boxShadow: const [
                                  BoxShadow(
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFD700), size: 12),
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
