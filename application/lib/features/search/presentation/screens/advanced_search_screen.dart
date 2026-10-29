import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../profile/providers/master_data_provider.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../../shared/constants/pargana_constants.dart';
import '../../../../shared/constants/app_data.dart';
import '../../../home/presentation/widgets/web_home_header.dart';
import '../../../home/presentation/widgets/web_home_footer.dart';
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
  String _maritalStatus = 'Any';
  String _ageRange = 'Any';
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

  static String normalizeLookingFor(String? input) {
    if (input == null) return 'Groom';
    final s = input.trim().toLowerCase();
    if (s == 'bride' || s == 'female' || s == 'girl' || s == 'kanya' || s.contains('bride') || s.contains('girl')) {
      return 'Bride';
    }
    return 'Groom';
  }

  @override
  void dispose() {
    _idSearchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _lookingFor = normalizeLookingFor(widget.initialLookingFor);
  }

  @override
  void didUpdateWidget(covariant AdvancedSearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLookingFor != widget.initialLookingFor) {
      setState(() {
        _lookingFor = normalizeLookingFor(widget.initialLookingFor);
      });
    }
  }

  void _executeSearch() {
    // 1. Parse Age Range
    int? minAge;
    int? maxAge;
    if (_ageRange != 'Any') {
      final matches = RegExp(r'(\d+)\s*to\s*(\d+)').firstMatch(_ageRange);
      if (matches != null) {
        minAge = int.tryParse(matches.group(1)!);
        maxAge = int.tryParse(matches.group(2)!);
      } else if (_ageRange.contains('55+')) {
        minAge = 55;
      }
    }

    // 2. Parse Gender
    final String gender = _lookingFor == 'Groom' ? 'MALE' : 'FEMALE';

    // 3. Parse Marital Status
    String? apiMarital;
    if (_maritalStatus != 'Any') {
      apiMarital = ProfileModel.normalizeMaritalStatusToApi(_maritalStatus);
    }

    // 4. Parse Occupation
    String? occCat;
    if (_occupation != 'Any') {
      if (_occupation.contains('Government')) {
        occCat = 'GOVERNMENT';
      } else if (_occupation.contains('Private')) {
        occCat = 'PRIVATE';
      } else if (_occupation.contains('Business')) {
        occCat = 'BUSINESS';
      } else {
        occCat = _occupation;
      }
    }

    // 5. Parse District
    String? district;
    if (_livingIn != 'Any') {
      district = _livingIn;
    }

    final keyword = _idSearchController.text.trim();

    // 6. Update Riverpod Filters
    ref.read(profileNotifierProvider.notifier).updateFilters(
      search: keyword.isNotEmpty ? keyword : null,
      gender: gender,
      maritalStatus: apiMarital,
      status: apiMarital,
      minAge: minAge,
      maxAge: maxAge,
      districtId: district,
      occupationCategory: occCat,
    );

    // 7. Direct navigation to search results with all active parameters
    final qParams = <String, String>{
      'gender': gender,
      if (apiMarital != null) 'maritalStatus': apiMarital,
      if (minAge != null) 'minAge': minAge.toString(),
      if (maxAge != null) 'maxAge': maxAge.toString(),
      if (district != null) 'districtId': district,
      if (keyword.isNotEmpty) 'search': keyword,
    };
    final uri = Uri(path: '/search-results', queryParameters: qParams);
    context.push(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final masterData = ref.watch(masterDataProvider);
    final isGroom = _lookingFor == 'Groom';

    // Resolve districts cleanly from master data or app data
    final List<String> availableDistricts = masterData.gujaratDistricts.keys
        .where((k) => k != 'Select District' && k.trim().isNotEmpty)
        .toList();
    if (availableDistricts.isEmpty) {
      availableDistricts.addAll(
        AppData.gujaratDistricts.keys.where((k) => k != 'Select District'),
      );
    }

    // Resolve degrees cleanly
    final List<String> availableDegrees = masterData.educationDegrees
        .where((d) => d != 'Select Degree' && d.trim().isNotEmpty)
        .toList();
    if (availableDegrees.isEmpty) {
      availableDegrees.addAll(
        AppData.educationDegrees.where((d) => d != 'Select Degree'),
      );
    }

    // Resolve religion options cleanly
    final List<String> availableReligions = masterData.religionOptions
        .where((r) => r != 'Select Religion' && r != 'Any' && r.trim().isNotEmpty)
        .toList();
    if (availableReligions.isEmpty) {
      availableReligions.addAll(
        AppData.religionOptions.where((r) => r != 'Select Religion' && r != 'Any'),
      );
    }

    // Resolve income ranges cleanly
    final List<String> availableIncomes = masterData.incomeRanges
        .where((i) => i != 'Select Income' && i != 'Any' && i.trim().isNotEmpty)
        .toList();
    if (availableIncomes.isEmpty) {
      availableIncomes.addAll(
        AppData.incomeRanges.where((i) => i != 'Select Income' && i != 'Any'),
      );
    }

    final formContent = Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  Center(
                    child: Container(
                      height: 2.5,
                      width: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFEA88), Color(0xFFD4AF37), Color(0xFF8B5A10)],
                        ),
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
                              onSubmitted: (_) => _executeSearch(),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _executeSearch,
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
                        child: _buildSafeDropdown(
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
                        child: _buildSafeDropdown(
                          'વૈવાહિક સ્થિતિ (Marital Status)',
                          _maritalStatus,
                          [
                            'Any',
                            'Never Married (અપરિણીત)',
                            'Divorced (છૂટાછેડા થયેલ)',
                            'Widowed (વિધવા / વિધુર)',
                            'Awaiting Divorce (છૂટાછેડા પ્રક્રિયા)',
                          ],
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
                        child: _buildSafeDropdown(
                          'ઉંમર (Age)',
                          _ageRange,
                          [
                            'Any',
                            '18 to 22 Years',
                            '22 to 30 Years',
                            '30 to 40 Years',
                            '40 to 55 Years',
                            '55+ Years',
                          ],
                          Icons.calendar_today_rounded,
                          const Color(0xFFD4AF37),
                          (v) => setState(() => _ageRange = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSafeDropdown(
                          'લંબાઈ (Height)',
                          _height,
                          ['Any', "Below 5'0\"", "5'0\" to 5'5\"", "5'6\" to 6'0\"", "Above 6'0\""],
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
                        child: _buildSafeDropdown(
                          'પરગણા (Pargana)',
                          _pargana,
                          ['Any', ...kSearchParganaOptions.where((p) => p != 'Any' && p != 'Select Pargana')],
                          Icons.people_rounded,
                          const Color(0xFF006D77),
                          (v) => setState(() => _pargana = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSafeDropdown(
                          'રહેઠાણ જિલ્લો (Living District)',
                          _livingIn,
                          ['Any', ...availableDistricts],
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
                        child: _buildSafeDropdown(
                          'શિક્ષણ (Education)',
                          _education,
                          ['Any', ...availableDegrees],
                          Icons.school_rounded,
                          const Color(0xFF006D77),
                          (v) => setState(() => _education = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSafeDropdown(
                          'વિદેશમાં અભ્યાસ? (Studying Abroad)',
                          _studyingAbroad,
                          ['Any', 'Yes (હા)', 'No (ના)'],
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
                        child: _buildSafeDropdown(
                          'વ્યવસાય (Occupation)',
                          _occupation,
                          [
                            'Any',
                            'Government Sector (સરકારી)',
                            'Private Sector (ખાનગી)',
                            'Business (વેપાર / સ્વરોજગાર)',
                            'Doctor / Medical',
                            'Engineer / IT',
                            'Not Working / Homemaker',
                          ],
                          Icons.work_rounded,
                          const Color(0xFF008272),
                          (v) => setState(() => _occupation = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSafeDropdown(
                          'ધર્મ (Religion)',
                          _religion,
                          ['Any', ...availableReligions],
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
                        child: _buildSafeDropdown(
                          'વાર્ષિક આવક (Yearly Income)',
                          _income,
                          ['Any', ...availableIncomes],
                          Icons.monetization_on_rounded,
                          const Color(0xFF006D77),
                          (v) => setState(() => _income = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSafeDropdown(
                          'માતૃભાષા (Mother Tongue)',
                          _motherTongue,
                          ['Any', 'Gujarati (ગુજરાતી)', 'Hindi (હિન્દી)', 'English (અંગ્રેજી)', 'Other (અન્ય)'],
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
                        child: _buildSafeDropdown(
                          'દિવ્યાંગતા (PwBD Category)',
                          _pwbdCategory,
                          [
                            'Any',
                            'VI - Visual Impairment (દૃષ્ટિ દિવ્યાંગતા)',
                            'HI - Hearing Impairment (શ્રવણ દિવ્યાંગતા)',
                            'LD - Locomotor Disability (હલનચલન સંબંધિત)',
                            'MD - Multiple Disabilities (બહુવિધ દિવ્યાંગતા)',
                            'B - Blindness (અંધત્વ)',
                            'LV - Low Vision (ઓછી દૃષ્ટિ)',
                            'D - Deaf (બહેરાશ)',
                            'HH - Hard of Hearing (સાંભળવામાં તકલીફ)',
                            'OA - One Arm Affected (એક હાથથી)',
                            'OL - One Leg Affected (એક પગથી)',
                            'BA - Both Arms Affected (બંને હાથથી)',
                            'BL - Both Legs Affected (બંને પગથી)',
                            'CP - Cerebral Palsy (સેરેબ્રલ પાલ્સી)',
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
                      onTap: _executeSearch,
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF005652), Color(0xFF00292B)],
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
                                fontSize: 15,
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
    );

    return Scaffold(
      backgroundColor: const Color(0xFF011A28),
      appBar: kIsWeb ? const WebHomeHeader(activeRoute: '/search') : null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              if (!kIsWeb) _buildRoyalHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Column(
                        children: [
                          formContent,
                          if (kIsWeb) ...[
                            const SizedBox(height: 32),
                            const WebHomeFooter(),
                          ],
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

  // Header with Ornate Back Button & Filigree (Mobile Mode)
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

  /// Bulletproof Safe Dropdown Widget that guarantees NO Flutter Assertion crashes.
  /// Deduplicates options and guarantees `value` exists in `items`.
  Widget _buildSafeDropdown(
    String label,
    String value,
    List<String> options,
    IconData prefixIcon,
    Color iconColor,
    ValueChanged<String?> onChanged,
  ) {
    // 1. Strictly deduplicate options and sanitize empty values
    final List<String> cleanOptions = [];
    for (final opt in options) {
      final trimmed = opt.trim();
      if (trimmed.isNotEmpty && !cleanOptions.contains(trimmed)) {
        cleanOptions.add(trimmed);
      }
    }
    if (cleanOptions.isEmpty) {
      cleanOptions.add('Any');
    }

    // 2. Guarantee that effectiveValue exists in cleanOptions
    String effectiveValue = value.trim();
    if (!cleanOptions.contains(effectiveValue)) {
      // Try to find a matching option case-insensitively or by prefix
      final matched = cleanOptions.where((o) => o.toLowerCase() == effectiveValue.toLowerCase()).firstOrNull;
      if (matched != null) {
        effectiveValue = matched;
      } else if (cleanOptions.contains('Any')) {
        effectiveValue = 'Any';
      } else {
        effectiveValue = cleanOptions.first;
      }
    }

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
                      value: effectiveValue,
                      isExpanded: true,
                      dropdownColor: const Color(0xFFFFFDF8),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0F2D37)),
                      style: const TextStyle(
                        color: Color(0xFF0F2D37),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                      items: cleanOptions.map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        if (newVal != null) {
                          onChanged(newVal);
                        }
                      },
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
