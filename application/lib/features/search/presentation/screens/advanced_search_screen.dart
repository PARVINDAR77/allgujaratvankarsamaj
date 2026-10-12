import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../profile/providers/master_data_provider.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../../shared/constants/pargana_constants.dart';
import 'search_results_screen.dart';

class AdvancedSearchScreen extends ConsumerStatefulWidget {
  final String initialLookingFor;

  const AdvancedSearchScreen({
    super.key,
    this.initialLookingFor = 'Groom',
  });

  @override
  ConsumerState<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  late String _lookingFor;
  String _maritalStatus = 'Never Married';
  String _ageRange = '22 to 30 Years';
  String _height = 'Any';
  String _pargana = 'Any';
  String _livingIn = 'Any';
  String _education = 'Any';
  String _studyingAbroad = 'Any';
  String _occupation = 'Any';
  String _religion = 'Any';
  String _income = 'Any';
  String _motherTongue = 'Any';
  String _pwbdCategory = 'Any';

  final TextEditingController _idSearchController = TextEditingController();

  @override
  void dispose() {
    _idSearchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _lookingFor = widget.initialLookingFor;
  }

  @override
  void didUpdateWidget(covariant AdvancedSearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLookingFor != widget.initialLookingFor) {
      setState(() {
        _lookingFor = widget.initialLookingFor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final masterData = ref.watch(masterDataProvider);
    final isGroom = _lookingFor == 'Groom';

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
              // 1. Royal Peacock Header
              _buildRoyalHeader(context),

              // 2. Form Card
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Container(
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
                      borderRadius: BorderRadius.circular(22),
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
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Bottom-left peacock feather corner ornament
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

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            child: Column(
                              children: [
                                // Title with search icon
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF007580), Color(0xFF004B54)],
                                        ),
                                        border: Border.all(color: const Color(0xFFFFDF73), width: 1.5),
                                      ),
                                      child: const Icon(Icons.search_rounded, color: Color(0xFFFFD700), size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Advance Search',
                                          style: TextStyle(
                                            color: Color(0xFF0F2D37),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          'વિસ્તૃત શોધ ફિલ્ટર',
                                          style: TextStyle(
                                            color: Color(0xFF006D77),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 2.5,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFEA88), Color(0xFFD4AF37), Color(0xFF8B5A10)],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Search by ID/Name Pill
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Color(0xFFFFFDF8), Color(0xFFF6EEDA)],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: const Color(0xFFD4AF37), width: 2.0),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 1.5),
                                      ),
                                    ],
                                  ),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(width: 14),
                                        const Icon(Icons.badge_rounded, color: Color(0xFF006D77), size: 22),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextField(
                                            controller: _idSearchController,
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            decoration: const InputDecoration(
                                              hintText: 'Search Name or ID (નામ અથવા આઈડી)',
                                              hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                                            ),
                                          ),
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              final id = _idSearchController.text.trim();
                                              if (id.isEmpty) return;

                                              final profileState = ref.read(profileNotifierProvider);
                                              final foundProfile = profileState.profiles
                                                  .where((p) => p.id == id || p.fullName.toLowerCase().contains(id.toLowerCase()))
                                                  .firstOrNull;

                                              if (foundProfile != null) {
                                                context.push('/candidate-profile-details', extra: foundProfile);
                                              } else {
                                                context.push('/candidate-profile-details?id=$id');
                                              }
                                            },
                                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(28)),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              alignment: Alignment.center,
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Color(0xFF007580), Color(0xFF004B54)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
                                              ),
                                              child: const Text(
                                                'Find',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Dynamic Boy/Girl Banner with Peacock Theme
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isGroom
                                          ? [const Color(0xFF008272), const Color(0xFF005349)]
                                          : [const Color(0xFFC2185B), const Color(0xFF880E4F)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: const Color(0xFFFFDF73), width: 1.8),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isGroom ? '👦 ♂' : '👧 ♀',
                                        style: const TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isGroom
                                            ? 'ફક્ત વર ઉમેદવારો માટે શોધ (Showing Boys / Grooms Only)'
                                            : 'ફક્ત કન્યા ઉમેદવારો માટે શોધ (Showing Girls / Brides Only)',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Form Grid Dropdowns
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDropdown(
                                        'હું શોધી રહ્યો છું (Looking For)',
                                        _lookingFor,
                                        ['Groom', 'Bride'],
                                        Icons.person_rounded,
                                        const Color(0xFF006D77),
                                        (v) => setState(() => _lookingFor = v!),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDropdown(
                                        'વૈવાહિક સ્થિતિ (Marital Status)',
                                        _maritalStatus,
                                        ['Never Married', 'Married', 'Widowed', 'Divorced'],
                                        Icons.favorite_rounded,
                                        const Color(0xFFC2185B),
                                        (v) => setState(() => _maritalStatus = v!),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDropdown(
                                        'ઉંમર (Age)',
                                        _ageRange,
                                        ['18 to 22 Years', '22 to 30 Years', '30 to 40 Years'],
                                        Icons.calendar_today_rounded,
                                        const Color(0xFFD4AF37),
                                        (v) => setState(() => _ageRange = v!),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDropdown(
                                        'લંબાઈ (Height)',
                                        _height,
                                        ['Any', "Below 5'", "5' to 6'"],
                                        Icons.height_rounded,
                                        const Color(0xFF008272),
                                        (v) => setState(() => _height = v!),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDropdown(
                                        'પરગણા (Pargana)',
                                        _pargana,
                                        kSearchParganaOptions,
                                        Icons.people_rounded,
                                        const Color(0xFF006D77),
                                        (v) => setState(() => _pargana = v!),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDropdown(
                                        'રહેઠાણ (Living In)',
                                        _livingIn,
                                        ['Any', 'Ahmedabad'],
                                        Icons.location_on_rounded,
                                        const Color(0xFFC2185B),
                                        (v) => setState(() => _livingIn = v!),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDropdown(
                                        'શિક્ષણ (Education)',
                                        _education,
                                        ['Any', 'Graduate'],
                                        Icons.school_rounded,
                                        const Color(0xFF006D77),
                                        (v) => setState(() => _education = v!),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDropdown(
                                        'વિદેશમાં અભ્યાસ? (Studying Abroad)',
                                        _studyingAbroad,
                                        ['Any', 'Yes', 'No'],
                                        Icons.flight_takeoff_rounded,
                                        const Color(0xFFD4AF37),
                                        (v) => setState(() => _studyingAbroad = v!),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDropdown(
                                        'વ્યવસાય (Occupation)',
                                        _occupation,
                                        ['Any', 'Job', 'Business'],
                                        Icons.work_rounded,
                                        const Color(0xFF008272),
                                        (v) => setState(() => _occupation = v!),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDropdown(
                                        'ધર્મ (Religion)',
                                        _religion,
                                        ['Any', ...masterData.religionOptions.where((e) => e != 'Select Religion')],
                                        Icons.brightness_high_rounded,
                                        const Color(0xFFD4AF37),
                                        (v) => setState(() => _religion = v!),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDropdown(
                                        'વાર્ષિક આવક (Yearly Income)',
                                        _income,
                                        ['Any', ...masterData.incomeRanges.where((e) => e != 'Select Income')],
                                        Icons.monetization_on_rounded,
                                        const Color(0xFF006D77),
                                        (v) => setState(() => _income = v!),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDropdown(
                                        'માતૃભાષા (Mother Tongue)',
                                        _motherTongue,
                                        ['Any', 'Gujarati'],
                                        Icons.chat_bubble_rounded,
                                        const Color(0xFF008272),
                                        (v) => setState(() => _motherTongue = v!),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDropdown(
                                        'દિવ્યાંગતા (PwBD Category)',
                                        _pwbdCategory,
                                        [
                                          'Any',
                                          'VI - Visual Impairment (દૃષ્ટિ દિવ્યાંગતા)',
                                          'HI - Hearing Impairment (શ્રવણ દિવ્યાંગતા)',
                                          'LD - Locomotor Disability (હલનચલન સંબંધિત દિવ્યાંગતા)',
                                          'MD - Multiple Disabilities (બહુવિધ દિવ્યાંગતા)',
                                          'B - Blindness (અંધત્વ)',
                                          'LV - Low Vision (ઓછી દૃષ્ટિ)',
                                          'D - Deaf (બહેરાશ)',
                                          'HH - Hard of Hearing (સાંભળવામાં તકલીફ)',
                                          'OA - One Arm Affected (એક હાથથી દિવ્યાંગતા)',
                                          'OL - One Leg Affected (એક પગથી દિવ્યાંગતા)',
                                          'BA - Both Arms Affected (બંને હાથથી દિવ્યાંગતા)',
                                          'BL - Both Legs Affected (બંને પગથી દિવ્યાંગતા)',
                                          'OAL - One Arm and One Leg Affected (એક હાથ અને એક પગથી દિવ્યાંગતા)',
                                          'CP - Cerebral Palsy (સેરેબ્રલ પાલ્સી)'
                                        ],
                                        Icons.wheelchair_pickup_rounded,
                                        const Color(0xFF006D77),
                                        (v) => setState(() => _pwbdCategory = v!),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Royal Peacock Jewel Search Button
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      // Parse Age Range
                                      int? minAge;
                                      int? maxAge;
                                      if (_ageRange != 'Any') {
                                        final matches = RegExp(r'(\d+) to (\d+)').firstMatch(_ageRange);
                                        if (matches != null) {
                                          minAge = int.tryParse(matches.group(1)!);
                                          maxAge = int.tryParse(matches.group(2)!);
                                        }
                                      }

                                      // Parse Gender
                                      String gender = _lookingFor == 'Groom' ? 'MALE' : 'FEMALE';

                                      // Parse Occupation Category
                                      String? occCat;
                                      if (_occupation != 'Any') {
                                        occCat = _occupation.toUpperCase();
                                      }

                                      // Perform the search
                                      final keyword = _idSearchController.text.trim();
                                      final apiMarital = ProfileModel.normalizeMaritalStatusToApi(_maritalStatus);
                                      ref.read(profileNotifierProvider.notifier).updateFilters(
                                        search: keyword.isNotEmpty ? keyword : null,
                                        gender: gender,
                                        maritalStatus: apiMarital,
                                        status: apiMarital,
                                        minAge: minAge,
                                        maxAge: maxAge,
                                        occupationCategory: occCat,
                                      );

                                      // Navigate to search results with filters applied
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (ctx) {
                                          Future.delayed(const Duration(milliseconds: 600), () {
                                            if (ctx.mounted) {
                                              Navigator.of(ctx).pop();
                                            }
                                            if (context.mounted) {
                                              context.push('/search-results?gender=$gender&maritalStatus=$apiMarital');
                                            }
                                          });
                                          return AlertDialog(
                                            backgroundColor: const Color(0xFF042636),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              side: const BorderSide(color: Color(0xFFD4AF37), width: 1.8),
                                            ),
                                            content: const Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircularProgressIndicator(color: Color(0xFFFFD700)),
                                                SizedBox(height: 16),
                                                Text(
                                                  'Searching profiles...',
                                                  style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                                                ),
                                                SizedBox(height: 6),
                                                Text(
                                                  'ઉમેદવારો શોધાઈ રહ્યા છે...',
                                                  style: TextStyle(fontSize: 12, color: Colors.white70),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(28),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF003D3D), Color(0xFF001F22)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(color: const Color(0xFFFFDF73), width: 2.0),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black45,
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.search_rounded, color: Color(0xFFFFD700), size: 22),
                                          SizedBox(width: 8),
                                          Text(
                                            'Search Profiles (ઉમેદવાર શોધો)',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFD700), size: 14),
                                        ],
                                      ),
                                    ),
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  // Header with Ornate Back Button & Filigree
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
                // Ornate Golden Back Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
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
                      padding: const EdgeInsets.all(2.5),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF003834),
                          border: Border.all(color: const Color(0xFFFFDF73), width: 1.0),
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_back, color: Color(0xFFFFD700), size: 21),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Title with Gold Glow
                const Expanded(
                  child: Text(
                    'Advance Search (વિસ્તૃત શોધ)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                const SizedBox(width: 52), // Balance layout for circular back button
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    IconData prefixIcon,
    Color iconColor,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F2D37),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Container(
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFDF8), Color(0xFFFAF3E5)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(prefixIcon, color: iconColor, size: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      isExpanded: true,
                      dropdownColor: const Color(0xFFFFFDF8),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0F2D37)),
                      style: const TextStyle(
                        color: Color(0xFF0F2D37),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                      items: options.map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
