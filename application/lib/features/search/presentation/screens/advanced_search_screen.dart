import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../../shared/models/profile_query_model.dart';
import '../../../../shared/constants/gov_departments.dart';
import '../../../../shared/constants/app_data.dart';
import '../../../profile/providers/master_data_provider.dart';

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
  Widget build(BuildContext context) {
    final masterData = ref.watch(masterDataProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: Stack(
        children: [
          // Form Card
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 170, left: 16, right: 16, bottom: 30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.blue.shade100, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade900.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    // Title
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, color: Color(0xFF0056D2), size: 36),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Advance Search',
                              style: TextStyle(color: Color(0xFF0056D2), fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'વિસ્તૃત શોધ',
                              style: TextStyle(color: Color(0xFF0056D2), fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(height: 2, width: 100, color: const Color(0xFFF3C34D)), // Gold underline
                    const SizedBox(height: 20),
                    
                    // Search by ID/Name Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(width: 12),
                            const Icon(Icons.badge, color: Color(0xFF0056D2)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _idSearchController,
                                decoration: const InputDecoration(
                                  hintText: 'Search Name or ID (નામ અથવા આઈડી)',
                                  hintStyle: TextStyle(color: Colors.black45, fontSize: 13),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                final id = _idSearchController.text.trim();
                                if (id.isEmpty) return;
                                
                                final profileState = ref.read(profileNotifierProvider);
                                final foundProfile = profileState.profiles.where((p) => p.id == id).firstOrNull;
                                
                                if (foundProfile != null) {
                                  context.push('/family-details');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Profile not found for this ID! (આ ID માટે પ્રોફાઇલ મળેલ નથી!)'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(11)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0056D2),
                                  borderRadius: BorderRadius.horizontal(right: Radius.circular(11)),
                                ),
                                child: const Text('Find', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Dynamic Boy/Girl Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _lookingFor == 'Groom' ? const Color(0xFFE1F0FF) : const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _lookingFor == 'Groom' 
                              ? const Color(0xFF0056D2).withValues(alpha: 0.5)
                              : const Color(0xFFE91E63).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _lookingFor == 'Groom' ? Icons.male : Icons.female, 
                            color: _lookingFor == 'Groom' ? const Color(0xFF0056D2) : const Color(0xFFE91E63), 
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _lookingFor == 'Groom' 
                                ? 'ફક્ત છોકરાઓ માટે શોધ (Showing Boys Only)'
                                : 'ફક્ત છોકરીઓ માટે શોધ (Showing Girls Only)',
                            style: TextStyle(
                              color: _lookingFor == 'Groom' ? const Color(0xFF0056D2) : const Color(0xFFE91E63), 
                              fontSize: 14, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Grid (Only supported filters)
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('હું શોધી રહ્યો છું (Looking For)', _lookingFor, ['Groom', 'Bride'], Icons.person, Colors.orange, (v) => setState(() => _lookingFor = v!))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('વૈવાહિક સ્થિતિ (Marital Status)', _maritalStatus, ['Never Married', 'Widowed', 'Divorced'], Icons.favorite, Colors.red, (v) => setState(() => _maritalStatus = v!))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('ઉંમર (Age)', _ageRange, ['18 to 22 Years', '22 to 30 Years', '30 to 40 Years'], Icons.calendar_today, Colors.orange, (v) => setState(() => _ageRange = v!))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('લંબાઈ (Height)', _height, ['Any', "Below 5'", "5' to 6'"], Icons.height, Colors.orange, (v) => setState(() => _height = v!))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('પરગણા (Pargana)', _pargana, ['Any', '35 Pargana'], Icons.people, Colors.orange, (v) => setState(() => _pargana = v!))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('રહેઠાણ (Living In)', _livingIn, ['Any', 'Ahmedabad'], Icons.location_on, Colors.orange, (v) => setState(() => _livingIn = v!))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('શિક્ષણ (Education)', _education, ['Any', 'Graduate'], Icons.school, Colors.orange, (v) => setState(() => _education = v!))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('વિદેશમાં અભ્યાસ? (Studying Abroad)', _studyingAbroad, ['Any', 'Yes', 'No'], Icons.flight_takeoff, Colors.orange, (v) => setState(() => _studyingAbroad = v!))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('વ્યવસાય (Occupation)', _occupation, ['Any', 'Job', 'Business'], Icons.work, Colors.orange, (v) => setState(() => _occupation = v!))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('ધર્મ (Religion)', _religion, ['Any', ...masterData.religionOptions.where((e) => e != 'Select Religion')], Icons.brightness_high, Colors.orange, (v) => setState(() => _religion = v!))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('વાર્ષિક આવક (Yearly Income)', _income, ['Any', ...masterData.incomeRanges.where((e) => e != 'Select Income')], Icons.monetization_on, Colors.orange, (v) => setState(() => _income = v!))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('માતૃભાષા (Mother Tongue)', _motherTongue, ['Any', 'Gujarati'], Icons.chat_bubble, const Color(0xFF0056D2), (v) => setState(() => _motherTongue = v!))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('દિવ્યાંગતા (PwBD Category)', _pwbdCategory, [
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
                        ], Icons.wheelchair_pickup, Colors.orange, (v) => setState(() => _pwbdCategory = v!))),
                        const SizedBox(width: 12),
                        const Spacer(),
                      ],
                    ),
                    
                    // Gap Note
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        '* More advanced filters like Marital Status, Education, and Location are currently pending backend API support.',
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Search Button
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00A2FF), Color(0xFF0056D2)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0056D2).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
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
                          ref.read(profileNotifierProvider.notifier).updateFilters(
                            search: keyword.isNotEmpty ? keyword : null,
                            gender: gender,
                            minAge: minAge,
                            maxAge: maxAge,
                            occupationCategory: occCat,
                          );

                          // Simulate search and navigate to matches
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) {                              Future.delayed(const Duration(seconds: 1), () {
                                if (ctx.mounted) {
                                  Navigator.of(ctx).pop(); // Safely close the dialog
                                }
                                if (context.mounted) {
                                  context.push('/search-results');
                                }
                              });
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircularProgressIndicator(color: Color(0xFF0056D2)),
                                    const SizedBox(height: 16),
                                    const Text('Searching profiles...', style: TextStyle(color: Color(0xFF0056D2), fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text('Looking for $_lookingFor in $_livingIn', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: Colors.white, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'Search | શોધો',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Header Image Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: Transform.scale(
                scale: 1.2,
                child: Image.asset(
                  'assets/images/vankar_header_banner.png',
                  fit: BoxFit.cover,
                  height: 180,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.blue.shade100,
                    child: const Center(child: Text('Logo Graphic Missing')),
                  ),
                ),
              ),
            ),
          ),
          // Back Button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF0056D2)),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    int? ageMin;
    int? ageMax;
    
    if (_ageRange == '18 to 22 Years') {
      ageMin = 18; ageMax = 22;
    } else if (_ageRange == '22 to 30 Years') {
      ageMin = 22; ageMax = 30;
    } else if (_ageRange == '30 to 40 Years') {
      ageMin = 30; ageMax = 40;
    }

    final query = ProfileQueryModel(
      gender: _lookingFor == 'Groom' ? 'MALE' : 'FEMALE',
      ageMin: ageMin,
      ageMax: ageMax,
      search: _idSearchController.text.trim().isNotEmpty ? _idSearchController.text.trim() : null,
    );

    context.push('/advanced-search', extra: query);
  }

  Widget _buildDropdown(String label, String value, List<String> options, IconData prefixIcon, Color iconColor, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF0056D2), fontSize: 11, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade100, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(prefixIcon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0056D2)),
                      style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
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
