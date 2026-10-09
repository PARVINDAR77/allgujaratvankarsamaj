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
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF041126),
        title: const Text(
          'Search Profiles (ઉમેદવાર શોધ)',
          style: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Filter Profiles (શોધ ફિલ્ટર)',
            icon: const Icon(Icons.tune, color: Color(0xFFFFD700)),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quick Search Input
            _buildSearchBar(),

            // Search by Filter Banner
            _buildSearchByFilterBanner(),

            // Segmented Tab Selector for Boys / Girls / All
            _buildGenderSegmentedTabs(),

            // Dynamic Summary / Count Badge
            _buildSummaryBadge(profiles.length, profileState.isLoading),

            // Content List or Empty State
            Expanded(
              child: profileState.isLoading && profiles.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF0056D2)),
                          SizedBox(height: 16),
                          Text('પ્રોફાઇલ્સ લોડ થઈ રહી છે...', style: TextStyle(color: Color(0xFF0056D2), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : profiles.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: profiles.length + (profileState.isLoadingNextPage ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == profiles.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final profile = profiles[index];
                            return _buildProfileCard(context, profile);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'નામ, આઈડી, ગામ કે શહેરથી શોધો...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF0056D2), size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : IconButton(
                  tooltip: 'Filter Profiles (શોધ ફિલ્ટર)',
                  icon: const Icon(Icons.tune, color: Color(0xFF0056D2), size: 20),
                  onPressed: () => _showFilterBottomSheet(context),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSearchByFilterBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final lookingFor = _selectedGender == 'MALE' ? 'Groom' : (_selectedGender == 'FEMALE' ? 'Bride' : 'Groom');
            context.push('/advanced-search?lookingFor=$lookingFor');
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF0F7FF), Color(0xFFE0EFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade300, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade900.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0056D2).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.filter_list_rounded, color: Color(0xFF0056D2), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ફિલ્ટર દ્વારા શોધો (Search by Filter)',
                        style: TextStyle(
                          color: Color(0xFF0056D2),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'પરગણા, જિલ્લો, શિક્ષણ, વ્યવસાય સાથે વિગતવાર શોધો',
                        style: TextStyle(color: Colors.black54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF0056D2), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSegmentedTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          // 1. Boys / વર
          Expanded(
            child: _buildTabButton(
              gender: 'MALE',
              label: '👨 વર (Boys)',
              isSelected: _selectedGender == 'MALE',
              activeColor: const Color(0xFF0056D2),
            ),
          ),
          const SizedBox(width: 4),
          // 2. Girls / કન્યા
          Expanded(
            child: _buildTabButton(
              gender: 'FEMALE',
              label: '👰 કન્યા (Girls)',
              isSelected: _selectedGender == 'FEMALE',
              activeColor: const Color(0xFFC2185B),
            ),
          ),
          const SizedBox(width: 4),
          // 3. All / બધા
          Expanded(
            child: _buildTabButton(
              gender: 'ALL',
              label: '👥 બધા (All)',
              isSelected: _selectedGender == 'ALL',
              activeColor: const Color(0xFF041126),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String gender,
    required String label,
    required bool isSelected,
    required Color activeColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _onGenderTabChanged(gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 6,
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
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

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
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                          color: Colors.grey.shade300,
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
                            Icon(Icons.tune, color: Color(0xFF0056D2), size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Filter Profiles (શોધ ફિલ્ટર)',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0056D2),
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
                          child: const Text('રીસેટ (Reset)', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                    const Divider(),
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
                              colors: [Color(0xFF003C9E), Color(0xFF0056D2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0056D2).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.filter_list_rounded, color: Color(0xFFFFD700), size: 22),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
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
                                      style: TextStyle(fontSize: 10.5, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFD700), size: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Gender Section
                    const Text(
                      'કોને શોધી રહ્યા છો? (Looking For)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModalChoiceChip(
                            label: '👨 વર (Boys)',
                            isSelected: tempGender == 'MALE',
                            activeColor: const Color(0xFF0056D2),
                            onTap: () => setSheetState(() => tempGender = 'MALE'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildModalChoiceChip(
                            label: '👰 કન્યા (Girls)',
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
                            activeColor: const Color(0xFF041126),
                            onTap: () => setSheetState(() => tempGender = 'ALL'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Marital Status Section
                    const Text(
                      'વૈવાહિક સ્થિતિ (Marital Status)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChoiceChipItem(
                          label: 'બધા (All)',
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
                          label: 'વિધુર / વિધવા (Widowed)',
                          isSelected: tempMaritalStatus == 'WIDOWED',
                          onTap: () => setSheetState(() => tempMaritalStatus = 'WIDOWED'),
                        ),
                        _buildChoiceChipItem(
                          label: 'છૂટાછેડા (Divorced)',
                          isSelected: tempMaritalStatus == 'DIVORCED',
                          onTap: () => setSheetState(() => tempMaritalStatus = 'DIVORCED'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Age Range Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ઉંમર (Age Range)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                        ),
                        Text(
                          '${tempAgeRange.start.round()} થી ${tempAgeRange.end.round()} વર્ષ',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0056D2), fontSize: 13),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: tempAgeRange,
                      min: 18,
                      max: 60,
                      divisions: 42,
                      activeColor: const Color(0xFF0056D2),
                      inactiveColor: Colors.blue.shade100,
                      labels: RangeLabels(
                        '${tempAgeRange.start.round()}',
                        '${tempAgeRange.end.round()}',
                      ),
                      onChanged: (values) {
                        setSheetState(() => tempAgeRange = values);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Side-by-Side Action Buttons: Old Form + Apply Filters
                    Row(
                      children: [
                        // Detailed Search Filters Button
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              final lookingFor = tempGender == 'MALE' ? 'Groom' : (tempGender == 'FEMALE' ? 'Bride' : 'Groom');
                              context.push('/advanced-search?lookingFor=$lookingFor');
                            },
                            icon: const Icon(Icons.filter_alt_outlined, color: Color(0xFF0056D2), size: 18),
                            label: const Text(
                              'વિસ્તૃત શોધ\n(Advance)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0056D2),
                                height: 1.2,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFEFF6FF),
                              side: const BorderSide(color: Color(0xFF0056D2), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Apply Filters Button
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
                              backgroundColor: const Color(0xFF0056D2),
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
      selectedColor: const Color(0xFF0056D2),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      backgroundColor: Colors.grey.shade100,
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
          color: isSelected ? activeColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBadge(int count, bool isLoading) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;
    String title;

    if (_selectedGender == 'FEMALE') {
      bgColor = const Color(0xFFFFF0F5);
      borderColor = const Color(0xFFF8BBD0);
      textColor = const Color(0xFFC2185B);
      icon = Icons.female;
      title = 'કન્યા ઉમેદવારો (Brides / Girls)';
    } else if (_selectedGender == 'MALE') {
      bgColor = const Color(0xFFEBF4FF);
      borderColor = const Color(0xFFBBDEFB);
      textColor = const Color(0xFF0056D2);
      icon = Icons.male;
      title = 'વર ઉમેદવારો (Grooms / Boys)';
    } else {
      bgColor = Colors.white;
      borderColor = Colors.grey.shade300;
      textColor = const Color(0xFF041126);
      icon = Icons.people;
      title = 'તમામ ઉમેદવારો (All Candidates)';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title • $count પ્રોફાઇલ ઉપલબ્ધ',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ),
          if (isLoading)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final title = _selectedGender == 'FEMALE'
        ? 'કોઈ કન્યા પ્રોફાઈલ મળી નથી\n(No Bride Profiles Found)'
        : _selectedGender == 'MALE'
            ? 'કોઈ વર પ્રોફાઈલ મળી નથી\n(No Groom Profiles Found)'
            : 'કોઈ પ્રોફાઈલ મળી નથી\n(No Profiles Found)';

    final desc = _selectedGender == 'FEMALE'
        ? 'તમારા શોધ માપદંડ મુજબ હાલમાં કોઈ કન્યા ઉમેદવાર ઉપલબ્ધ નથી.'
        : _selectedGender == 'MALE'
            ? 'તમારા શોધ માપદંડ મુજબ હાલમાં કોઈ વર ઉમેદવાર ઉપલબ્ધ નથી.'
            : 'તમારા શોધ માપદંડ મુજબ હાલમાં કોઈ ઉમેદવાર ઉપલબ્ધ નથી. કૃપા કરીને ફિલ્ટર્સ બદલીને ફરી પ્રયાસ કરો.';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_search_rounded, size: 64, color: const Color(0xFF0056D2).withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedGender != 'ALL')
                  OutlinedButton.icon(
                    onPressed: () => _onGenderTabChanged('ALL'),
                    icon: const Icon(Icons.people_alt, size: 16),
                    label: const Text('બધા જુઓ (View All)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0056D2),
                      side: const BorderSide(color: Color(0xFF0056D2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                if (_selectedGender != 'ALL') const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showFilterBottomSheet(context),
                  icon: const Icon(Icons.tune, size: 16),
                  label: const Text('શોધ ફિલ્ટર બદલો (Adjust Filters)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056D2),
                    foregroundColor: Colors.white,
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

  Widget _buildProfileCard(BuildContext context, ProfileModel profile) {
    final isGirl = profile.isFemale;
    final primaryColor = isGirl ? const Color(0xFFC2185B) : const Color(0xFF0056D2);
    final lightColor = isGirl ? const Color(0xFFFCE4EC) : const Color(0xFFE3F2FD);
    final borderColor = isGirl ? const Color(0xFFF48FB1) : const Color(0xFF90CAF9);

    final ageStr = profile.age != null ? "${profile.age} Yrs" : "";
    final maritalStr = (profile.maritalStatus.isNotEmpty &&
            profile.maritalStatus != 'Not specified' &&
            profile.maritalStatus != 'Not Specified')
        ? profile.maritalStatus
        : "";
    final statusStr = [if (ageStr.isNotEmpty) ageStr, if (maritalStr.isNotEmpty) maritalStr].join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Theme color strip on left
              Container(
                width: 5,
                color: primaryColor,
              ),

              // Card content
              Expanded(
                child: InkWell(
                  onTap: () {
                    context.push('/candidate-profile-details', extra: profile);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Candidate Avatar with gender-colored ring
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 2.2),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 34,
                            backgroundColor: lightColor,
                            backgroundImage: profile.fullPhotoUrl != null ? NetworkImage(profile.fullPhotoUrl!) : null,
                            onBackgroundImageError: profile.fullPhotoUrl != null ? (exception, stackTrace) {} : null,
                            child: profile.fullPhotoUrl == null
                                ? Icon(isGirl ? Icons.face_3_rounded : Icons.face_rounded, size: 38, color: primaryColor)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Candidate Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name & Gender Tag
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      profile.fullName,
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: lightColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Text(
                                      isGirl ? '👰 કન્યા (Bride)' : '👨 વર (Groom)',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),

                              // ID Capsule & Age / Status
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (profile.id.isNotEmpty) {
                                        Clipboard.setData(ClipboardData(text: profile.id));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('ID કોપી થયો: ${profile.id}'),
                                            backgroundColor: primaryColor,
                                            duration: const Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isGirl ? const Color(0xFFFCE4EC) : Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isGirl ? const Color(0xFFF48FB1) : Colors.blue.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'ID: ${profile.displayId}',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: isGirl ? const Color(0xFFC2185B) : const Color(0xFF0056D2),
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          Icon(
                                            Icons.copy_rounded,
                                            size: 10,
                                            color: isGirl ? const Color(0xFFC2185B).withValues(alpha: 0.7) : const Color(0xFF0056D2).withValues(alpha: 0.7),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (statusStr.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        statusStr,
                                        style: const TextStyle(fontSize: 11.5, color: Colors.black87, fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Education (if available)
                              if (profile.education.isNotEmpty &&
                                  profile.education != 'Not Specified' &&
                                  profile.education != 'Not specified')
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2.5),
                                  child: Row(
                                    children: [
                                      Icon(Icons.school_rounded, size: 13.5, color: primaryColor.withValues(alpha: 0.8)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          profile.education,
                                          style: const TextStyle(color: Colors.black87, fontSize: 11.5, fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Profession & Income
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2.5),
                                child: Row(
                                  children: [
                                    const Icon(Icons.work_outline_rounded, size: 13.5, color: Colors.black54),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${profile.displayProfession}${profile.annualIncome != null && profile.annualIncome!.isNotEmpty && profile.annualIncome != 'Not specified' && profile.annualIncome != 'Not Specified' ? " • ${profile.annualIncome}" : ""}',
                                        style: const TextStyle(color: Colors.black87, fontSize: 11.5, fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Location
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2.5),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 13.5, color: Colors.black54),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        profile.displayLocation,
                                        style: const TextStyle(color: Colors.black87, fontSize: 11.5, fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Action buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        context.push('/candidate-profile-details', extra: profile);
                                      },
                                      icon: const Icon(Icons.remove_red_eye_outlined, size: 15),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        elevation: 1.5,
                                        shadowColor: primaryColor.withValues(alpha: 0.35),
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      label: const Text(
                                        'View Profile (વિગતવાર જુઓ)',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
            ],
          ),
        ),
      ),
    );
  }
}

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
      decoration: BoxDecoration(
        color: _isLiked ? Colors.pink.shade50 : Colors.grey.shade50,
        shape: BoxShape.circle,
        border: Border.all(
          color: _isLiked ? Colors.pink.shade200 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: IconButton(
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
        iconSize: 20,
        tooltip: _isLiked ? 'પસંદ કરેલ (Liked)' : 'પસંદ કરો (Like)',
        onPressed: () {
          setState(() {
            _isLiked = !_isLiked;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isLiked
                    ? '${widget.profile.fullName} ની પ્રોફાઇલ પસંદ કરી છે!'
                    : '${widget.profile.fullName} લિસ્ટમાંથી દૂર થઈ',
              ),
              backgroundColor: _isLiked ? const Color(0xFFC2185B) : Colors.black87,
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: Icon(
          _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: _isLiked ? const Color(0xFFE91E63) : Colors.grey.shade600,
        ),
      ),
    );
  }
}
