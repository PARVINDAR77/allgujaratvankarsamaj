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
              Color(0xFF021B2B), // Deep peacock blue/teal
              Color(0xFF032635),
              Color(0xFF021622),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Royal Peacock App Bar with Ornate Gold Buttons
              _buildRoyalHeader(context),

              // 2. Pill Search Input with Golden Border
              _buildSearchBar(),

              // 3. Jewel-Toned "Search by Filter" Interactive Banner
              _buildSearchByFilterBanner(),

              // 4. Segmented Tab Selector for Boys / Girls / All
              _buildGenderSegmentedTabs(),

              // 5. Dynamic Summary Counter Strip with Peacock Accent
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

  // --- 1. ROYAL HEADER WITH ORNATE GOLD BUTTONS ---
  Widget _buildRoyalHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF021B2B),
            Color(0xFF082D3B),
            Color(0xFF1E0A2F),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ornate Golden Back Button
          _buildOrnateCircleButton(
            icon: Icons.arrow_back,
            tooltip: 'પાછા જાઓ (Back)',
            bgColor: const Color(0xFF004945),
            iconColor: const Color(0xFFFFD700),
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          const SizedBox(width: 10),

          // Title with Rich Gold Glow
          Expanded(
            child: Text(
              'Search Profiles (ઉમેદવાર શોધ)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 17.5,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1.5)),
                  Shadow(color: Color(0x66FFD700), blurRadius: 8),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),

          // Ornate Golden Filter Button
          _buildOrnateCircleButton(
            icon: Icons.tune_rounded,
            tooltip: 'Filter Profiles (શોધ ફિલ્ટર)',
            bgColor: const Color(0xFF3B0744),
            iconColor: const Color(0xFFFFD700),
            onTap: () => _showFilterBottomSheet(context),
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFDF73),
                Color(0xFFD4AF37),
                Color(0xFF996515),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(2.2), // Gold outer frame width
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: Border.all(color: const Color(0xFFFFE680), width: 0.8),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 20),
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
            Color(0xFFFBF4E4),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
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
                  icon: const Icon(Icons.tune_rounded, color: Color(0xFF006D77), size: 20),
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
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF007A87),
                  Color(0xFF004E5B),
                  Color(0xFF002E38),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE5C07B), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Filter icon inside circular teal gradient badge
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A896), Color(0xFF028090)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: const Color(0xFFFFE680), width: 1.2),
                  ),
                  child: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 18),
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
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 1.5),
                      Text(
                        'પરગણા, જિલ્લો, શિક્ષણ, વ્યવસાય સાથે વિગતવાર શોધો',
                        style: TextStyle(color: Color(0xFFBBE5ED), fontSize: 11),
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
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
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
              activeColors: [const Color(0xFF008375), const Color(0xFF00584E)],
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

  // --- 5. SUMMARY COUNTER BADGE WITH PEACOCK ACCENT ---
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFDF8),
            Color(0xFFF9F2E2),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
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
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title • $count પ્રોફાઇલ ઉપલબ્ધ',
              style: const TextStyle(
                color: Color(0xFF0F2D37),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Miniature Peacock Feather Accent
          SizedBox(
            width: 26,
            height: 20,
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

  // --- 6. ROYAL ORNATE CANDIDATE PROFILE CARD ---
  Widget _buildProfileCard(BuildContext context, ProfileModel profile, int index) {
    final isGirl = profile.isFemale;

    // Harmonious jewel button gradients matching the screenshot style:
    // Alternate between deep teal/emerald gradient and deep royal purple gradient
    final isAlternatePurple = index % 2 == 1;
    final buttonGradient = (isGirl || isAlternatePurple)
        ? const LinearGradient(
            colors: [Color(0xFF4A0E4E), Color(0xFF27052A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF004953), Color(0xFF002B33)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final avatarCircleBg = isAlternatePurple ? const Color(0xFFF3E8FF) : const Color(0xFFD8F3DC);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFDF8),
            Color(0xFFF9F3E5),
            Color(0xFFFFFDF8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2.2),
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
            // Top-left starry nebula accent
            Positioned(
              top: -20,
              left: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (isAlternatePurple ? const Color(0xFF7E22CE) : const Color(0xFF007A87)).withValues(alpha: 0.28),
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
                  width: 90,
                  height: 90,
                  child: CustomPaint(
                    painter: PeacockCardCornerPainter(),
                  ),
                ),
              ),
            ),

            // Main Card Content
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar with Double Concentric Embossed Gold Ring Medallion
                      InkWell(
                        onTap: () => context.push('/candidate-profile-details', extra: profile),
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFDF73), Color(0xFFD4AF37), Color(0xFF996515)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(2.6),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: avatarCircleBg,
                              border: Border.all(color: const Color(0xFFFFF3CD), width: 1),
                            ),
                            child: ClipOval(
                              child: (profile.fullPhotoUrl != null && profile.fullPhotoUrl!.isNotEmpty)
                                  ? Image.network(
                                      profile.fullPhotoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => StylizedAvatarFace(isFemale: isGirl),
                                    )
                                  : StylizedAvatarFace(isFemale: isGirl),
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
                                    color: const Color(0xFFE6FAF6),
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
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F4FE),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF90CAF9), width: 1),
                                ),
                                child: Text(
                                  'ID: ${profile.id.isNotEmpty ? profile.id : (profile.displayId.isNotEmpty ? profile.displayId : "d651408e-a133-4989")}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1565C0),
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
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.5, horizontal: 12),
                              decoration: BoxDecoration(
                                gradient: buttonGradient,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: const Color(0xFFE5C07B), width: 1.8),
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
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
              color: _isLiked ? const Color(0xFFE91E63) : const Color(0xFF5D4037),
              size: 20,
            ),
          ),
        ),
        ),
      ),
    );
  }
}

// --- STYLIZED AVATAR VECTOR FACE (MATCHING SCREENSHOT) ---
class StylizedAvatarFace extends StatelessWidget {
  final bool isFemale;
  const StylizedAvatarFace({super.key, required this.isFemale});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(70, 70),
      painter: _StylizedFacePainter(isFemale: isFemale),
    );
  }
}

class _StylizedFacePainter extends CustomPainter {
  final bool isFemale;
  _StylizedFacePainter({required this.isFemale});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final primaryInk = Paint()
      ..color = const Color(0xFF0F2D37)
      ..style = PaintingStyle.fill;

    final skinPaint = Paint()
      ..color = const Color(0xFFFDE8D0)
      ..style = PaintingStyle.fill;

    // Face base circle
    canvas.drawCircle(Offset(cx, cy + 2), 22, skinPaint);

    // Hair cap / hairstyle
    final hairPath = Path();
    if (!isFemale) {
      // Boy hair (smooth round crop with sideburns)
      hairPath.addArc(Rect.fromCircle(center: Offset(cx, cy - 1), radius: 23), math.pi, math.pi);
      hairPath.lineTo(cx + 23, cy + 5);
      hairPath.quadraticBezierTo(cx + 14, cy - 2, cx, cy - 2);
      hairPath.quadraticBezierTo(cx - 14, cy - 2, cx - 23, cy + 5);
      hairPath.close();
      canvas.drawPath(hairPath, primaryInk);
    } else {
      // Girl hair (parted hair with shoulder drape)
      hairPath.addArc(Rect.fromCircle(center: Offset(cx, cy - 1), radius: 23), math.pi, math.pi);
      hairPath.lineTo(cx + 24, cy + 18);
      hairPath.quadraticBezierTo(cx + 18, cy + 5, cx + 12, cy - 2);
      hairPath.quadraticBezierTo(cx, cy + 4, cx - 12, cy - 2);
      hairPath.quadraticBezierTo(cx - 18, cy + 5, cx - 24, cy + 18);
      hairPath.close();
      canvas.drawPath(hairPath, primaryInk);

      // Cute bindi
      final bindiPaint = Paint()
        ..color = const Color(0xFFC2185B)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy - 1), 1.8, bindiPaint);
    }

    // Eyes
    canvas.drawCircle(Offset(cx - 7, cy + 5), 2.5, primaryInk);
    canvas.drawCircle(Offset(cx + 7, cy + 5), 2.5, primaryInk);

    // Warm Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF0F2D37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final smilePath = Path();
    smilePath.moveTo(cx - 5, cy + 12);
    smilePath.quadraticBezierTo(cx, cy + 17, cx + 5, cy + 12);
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant _StylizedFacePainter oldDelegate) => oldDelegate.isFemale != isFemale;
}

// --- PEACOCK & GOLD FILIGREE CORNER PAINTER ---
class PeacockCardCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Golden filigree swirls curling up from bottom-left corner
    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final goldFill = Paint()
      ..color = const Color(0xFFFFE680).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Vine 1
    final vinePath1 = Path();
    vinePath1.moveTo(0, size.height - 10);
    vinePath1.cubicTo(16, size.height - 18, 22, size.height - 40, 10, size.height - 65);
    vinePath1.quadraticBezierTo(6, size.height - 78, 16, size.height - 82);
    canvas.drawPath(vinePath1, goldPaint);

    // Small gold leaf
    canvas.drawCircle(Offset(10, size.height - 65), 3, goldFill);
    canvas.drawCircle(Offset(16, size.height - 82), 2.5, goldFill);

    // Vine 2 (curling along bottom)
    final vinePath2 = Path();
    vinePath2.moveTo(8, size.height);
    vinePath2.quadraticBezierTo(35, size.height - 12, 55, size.height - 4);
    vinePath2.quadraticBezierTo(68, size.height, 75, size.height - 8);
    canvas.drawPath(vinePath2, goldPaint);
    canvas.drawCircle(Offset(55, size.height - 4), 2.5, goldFill);

    // 2. Peacock Feather barbules radiating from corner
    final barbulePaint = Paint()
      ..color = const Color(0xFF007A5E).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (int i = 0; i < 7; i++) {
      final rad = 0.18 + (i * 0.18);
      final x2 = 52 * math.cos(rad);
      final y2 = size.height - (52 * math.sin(rad));
      canvas.drawLine(Offset(6, size.height - 6), Offset(x2, y2), barbulePaint);
    }

    // 3. Peacock Feather Eye (centerpiece)
    final eyeCenterX = 24.0;
    final eyeCenterY = size.height - 24.0;

    // Outer royal blue / teal glow
    final outerPlumePaint = Paint()
      ..color = const Color(0xFF008375)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(eyeCenterX, eyeCenterY), width: 28, height: 22),
      outerPlumePaint,
    );

    // Iridescent cyan ring
    final cyanPaint = Paint()
      ..color = const Color(0xFF00B4D8)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(eyeCenterX, eyeCenterY), width: 20, height: 16),
      cyanPaint,
    );

    // Golden bronze ring
    final bronzePaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(eyeCenterX, eyeCenterY), width: 14, height: 11),
      bronzePaint,
    );

    // Center deep indigo/navy eye
    final eyeCenterPaint = Paint()
      ..color = const Color(0xFF0C1B33)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(eyeCenterX, eyeCenterY), width: 9, height: 7.5),
      eyeCenterPaint,
    );

    // Shimmer highlight dot
    final shimmerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(eyeCenterX - 1.5, eyeCenterY - 1.5), 1.2, shimmerPaint);
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
      ..color = const Color(0xFF007A5E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx - 10, cy + 6), Offset(cx + 8, cy - 6), barbulePaint);
    canvas.drawLine(Offset(cx - 6, cy + 8), Offset(cx + 10, cy - 2), barbulePaint);

    // Eye
    final eyePaint = Paint()
      ..color = const Color(0xFF00B4D8)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 14, height: 10), eyePaint);

    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 9, height: 6.5), goldPaint);

    final pupilPaint = Paint()
      ..color = const Color(0xFF0C1B33)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 2.2, pupilPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
