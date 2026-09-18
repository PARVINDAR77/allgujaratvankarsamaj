import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../../shared/constants/gov_departments.dart';

class GovtEmployeesScreen extends ConsumerStatefulWidget {
  const GovtEmployeesScreen({super.key});

  @override
  ConsumerState<GovtEmployeesScreen> createState() => _GovtEmployeesScreenState();
}

class _GovtEmployeesScreenState extends ConsumerState<GovtEmployeesScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _department = 'All';
  String _post = 'All';
  String _district = 'All';
  String _taluka = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        _resetFilters();
      }
    });
  }

  List<Map<String, dynamic>> get _allData {
    final profiles = ref.watch(profileNotifierProvider);
    final isGujaratTab = (_tabController?.index ?? 0) == 0;
    
    final govtProfiles = profiles.where((p) {
      if (!p.employmentType.contains('Government')) return false;
      if (isGujaratTab) {
        return !GovDepartments.centralGov.contains(p.department);
      } else {
        return GovDepartments.centralGov.contains(p.department);
      }
    }).toList();
    
    return govtProfiles.map((p) => {
      'id': p.id.length > 5 ? p.id.substring(p.id.length - 4) : p.id, // Just showing a short ID
      'name': p.fullName,
      'dept': p.department,
      'post': p.designation,
      'district': p.district,
      'taluka': p.taluka,
      'icon': Icons.account_balance,
      'iconColor': Colors.grey.shade800,
    }).toList();
  }

  static const Map<String, String> _translations = {
    'Education': 'શિક્ષણ',
    'Forest': 'વન',
    'GEB': 'જી.ઈ.બી.',
    'Health': 'આરોગ્ય',
    'IAS': 'આઈએએસ',
    'Judiciary': 'ન્યાયતંત્ર',
    'Panchayat': 'પંચાયત',
    'Police': 'પોલીસ',
    'Revenue': 'મહેસૂલ',
    'Social Justice': 'સામાજિક ન્યાય',
    'IAS Officer': 'આઈએએસ અધિકારી',
    'Teacher': 'શિક્ષક',
    'Police Inspector': 'પોલીસ ઇન્સ્પેક્ટર',
    'Staff Nurse': 'સ્ટાફ નર્સ',
    'Talati': 'તલાટી',
    'Gram Sevak': 'ગ્રામ સેવક',
    'Forest Guard': 'વન રક્ષક',
    'Court Clerk': 'કોર્ટ ક્લાર્ક',
    'Junior Engineer': 'જુનિયર એન્જિનિયર',
    'Welfare Officer': 'કલ્યાણ અધિકારી',
    'Gandhinagar': 'ગાંધીનગર',
    'Ahmedabad': 'અમદાવાદ',
    'Surat': 'સુરત',
    'Vadodara': 'વડોદરા',
    'Rajkot': 'રાજકોટ',
    'Jamnagar': 'જામનગર',
    'Junagadh': 'જૂનાગઢ',
    'Bhavnagar': 'ભાવનગર',
    'Mehsana': 'મહેસાણા',
    'Kutch': 'કચ્છ',
    
    // Talukas
    'Ahmedabad City': 'અમદાવાદ શહેર',
    'Choryasi': 'ચોર્યાસી',
    'Vadodara City': 'વડોદરા શહેર',
    'Jasdan': 'જસદણ',
    'Jamnagar City': 'જામનગર શહેર',
    'Junagadh City': 'જૂનાગઢ શહેર',
    'Bhavnagar City': 'ભાવનગર શહેર',
    'Mehsana City': 'મહેસાણા શહેર',
    'Bhuj': 'ભુજ',
    'Kalol': 'કલોલ',
    'Dehgam': 'દહેગામ',
    'Mansa': 'માણસા',
    'Sanand': 'સાણંદ',
    'Daskroi': 'દસક્રોઈ',
    'Dholka': 'ધોળકા',
    'Viramgam': 'વિરમગામ',
    'Kamrej': 'કામરેજ',
    'Mandvi': 'માંડવી',
    'Mangrol': 'માંગરોળ',
    'Olpad': 'ઓલપાડ',
    'Padra': 'પાદરા',
    'Karjan': 'કરજણ',
    'Savli': 'સાવલી',
    'Waghodia': 'વાઘોડિયા',
    'Rajkot City': 'રાજકોટ શહેર',
    'Gondal': 'ગોંડલ',
    'Jetpur': 'જેતપુર',
    'Dhoraji': 'ધોરાજી',
    'Dhrol': 'ધ્રોલ',
    'Jodiya': 'જોડિયા',
    'Lalpur': 'લાલપુર',
    'Keshod': 'કેશોદ',
    'Mendarda': 'મેંદરડા',
    'Manavadar': 'માણાવદર',
    'Palitana': 'પાલીતાણા',
    'Mahuva': 'મહુવા',
    'Gariadhar': 'ગારિયાધાર',
    'Kadi': 'કડી',
    'Unjha': 'ઊંઝા',
    'Visnagar': 'વિસનગર',
    'Anjar': 'અંજાર',
    'Mandvi (Kutch)': 'માંડવી (કચ્છ)',
    'Mundra': 'મુંદ્રા',
    'Gandhidham': 'ગાંધીધામ',
  };

  static const Map<String, List<String>> _districtTalukas = {
    'Gandhinagar': ['Gandhinagar', 'Kalol', 'Dehgam', 'Mansa'],
    'Ahmedabad': ['Ahmedabad City', 'Sanand', 'Daskroi', 'Dholka', 'Viramgam'],
    'Surat': ['Choryasi', 'Kamrej', 'Mandvi', 'Mangrol', 'Olpad'],
    'Vadodara': ['Vadodara City', 'Padra', 'Karjan', 'Savli', 'Waghodia'],
    'Rajkot': ['Rajkot City', 'Jasdan', 'Gondal', 'Jetpur', 'Dhoraji'],
    'Jamnagar': ['Jamnagar City', 'Dhrol', 'Jodiya', 'Lalpur'],
    'Junagadh': ['Junagadh City', 'Keshod', 'Mendarda', 'Manavadar'],
    'Bhavnagar': ['Bhavnagar City', 'Palitana', 'Mahuva', 'Gariadhar'],
    'Mehsana': ['Mehsana City', 'Kadi', 'Unjha', 'Visnagar'],
    'Kutch': ['Bhuj', 'Anjar', 'Mandvi (Kutch)', 'Mundra', 'Gandhidham'],
  };

  String _getTranslatedText(String englishText) {
    if (_translations.containsKey(englishText)) {
      return '$englishText (${_translations[englishText]})';
    }
    return englishText;
  }

  List<String> get _departments {
    final isGujaratTab = (_tabController?.index ?? 0) == 0;
    List<String> list = isGujaratTab 
      ? GovDepartments.gujaratGov.where((e) => e != 'Select Category').toList()
      : GovDepartments.centralGov.where((e) => e != 'Select Category').toList();
    list.sort();
    return ['All', ...list];
  }

  List<String> get _posts {
    final allProfiles = ref.watch(profileNotifierProvider);
    final isGujaratTab = (_tabController?.index ?? 0) == 0;
    
    var govProfiles = allProfiles.where((p) {
      if (!p.employmentType.contains('Government')) return false;
      if (isGujaratTab) {
        return !GovDepartments.centralGov.contains(p.department);
      } else {
        return GovDepartments.centralGov.contains(p.department);
      }
    });

    if (_department != 'All') {
      govProfiles = govProfiles.where((p) => p.department == _department);
    }
    
    final list = govProfiles.map((p) => p.designation).where((d) => d.isNotEmpty).toSet().toList();
    list.sort();
    return ['All', ...list];
  }

  List<String> get _districts {
    final list = _districtTalukas.keys.toList();
    list.sort();
    return ['All', ...list];
  }

  List<String> get _talukas {
    if (_district == 'All') {
      return ['All'];
    }
    final list = _districtTalukas[_district] ?? [];
    return ['All', ...list];
  }

  List<Map<String, dynamic>> get _filteredData {
    return _allData.where((item) {
      if (_department != 'All' && item['dept'] != _department) return false;
      if (_post != 'All' && item['post'] != _post) return false;
      if (_district != 'All' && item['district'] != _district) return false;
      if (_taluka != 'All' && item['taluka'] != _taluka) return false;
      if (_searchController.text.isNotEmpty && 
          !item['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _department = 'All';
      _post = 'All';
      _district = 'All';
      _taluka = 'All';
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tabController ??= TabController(length: 2, vsync: this)..addListener(() {
      if (!_tabController!.indexIsChanging) {
        _resetFilters();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 850;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    // Header Stack
                    SizedBox(
                      height: isDesktop ? 240 : 200,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: isDesktop ? 200 : 160,
                            child: Image.asset(
                              'assets/images/vankar_header_banner.png',
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.blue.shade100,
                                child: const Center(child: Text('Header Image')),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF041126),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go('/home');
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: Row(
                                      children: [
                                        Icon(Icons.arrow_back, color: Color(0xFFD4AF37), size: 16),
                                        SizedBox(width: 4),
                                        Text('પાછા જાઓ (Back)', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: const Color(0xFFF3C34D), width: 2.5), // Gold border
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF0056D2),
                                    radius: isDesktop ? 24 : 20,
                                    child: Icon(Icons.groups, color: Colors.white, size: isDesktop ? 28 : 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Government Employees',
                                        style: TextStyle(color: const Color(0xFF0056D2), fontSize: isDesktop ? 24 : 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'સરકારી સેવા - સમાજની સેવા',
                                        style: TextStyle(color: const Color(0xFF0056D2), fontSize: isDesktop ? 14 : 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Filters Section
                    Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(top: 8),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: const Color(0xFF0056D2),
                        unselectedLabelColor: Colors.grey.shade600,
                        indicatorColor: const Color(0xFF0056D2),
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(text: 'Gujarat Gov (ગુજરાત સરકાર)'),
                          Tab(text: 'Central Gov (કેન્દ્ર સરકાર)'),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F9FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        children: [
                          if (isDesktop)
                            Row(
                              children: [
                                Expanded(child: _buildDropdown('Department (વિભાગ)', _department, _departments, (v) {
                                  setState(() {
                                    _department = v!;
                                    _post = 'All'; // Reset post when department changes
                                  });
                                })),
                                const SizedBox(width: 8),
                                Expanded(child: _buildDropdown('Post (હોદ્દો)', _post, _posts, (v) => setState(() => _post = v!))),
                                const SizedBox(width: 8),
                                Expanded(child: _buildDropdown('District (જિલ્લો)', _district, _districts, (v) {
                                  setState(() {
                                    _district = v!;
                                    _taluka = 'All'; // Reset taluka when district changes
                                  });
                                })),
                                const SizedBox(width: 8),
                                Expanded(child: _buildDropdown('Taluka (તાલુકો)', _taluka, _talukas, (v) => setState(() => _taluka = v!))),
                              ],
                            )
                          else
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: _buildDropdown('Department (વિભાગ)', _department, _departments, (v) {
                                   setState(() {
                                     _department = v!;
                                     _post = 'All'; // Reset post when department changes
                                   });
                                 })),
                                    const SizedBox(width: 8),
                                    Expanded(child: _buildDropdown('Post (હોદ્દો)', _post, _posts, (v) => setState(() => _post = v!))),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(child: _buildDropdown('District (જિલ્લો)', _district, _districts, (v) {
                                      setState(() {
                                        _district = v!;
                                        _taluka = 'All'; // Reset taluka when district changes
                                      });
                                    })),
                                    const SizedBox(width: 8),
                                    Expanded(child: _buildDropdown('Taluka (તાલુકો)', _taluka, _talukas, (v) => setState(() => _taluka = v!))),
                                  ],
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: isDesktop ? 6 : 3,
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF0056D2), size: 20),
                              hintText: 'Search by Name (નામથી શોધો)...',
                              hintStyle: const TextStyle(fontSize: 12),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {}); // Trigger rebuild to apply search text filter
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00A2FF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 0),
                                  minimumSize: const Size(0, 40),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Search\n(શોધો)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, height: 1.1)),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _resetFilters,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE91E63),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 0),
                                  minimumSize: const Size(0, 40),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.refresh, size: 14),
                                    SizedBox(width: 2),
                                    Text('Reset\n(રીસેટ)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, height: 1.1)),
                                  ],
                                ),
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
            
            // Custom Colorful Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Table Header
                        Row(
                          children: [
                            _buildHeaderCell('#', const Color(0xFF00A2FF), 40),
                            _buildHeaderCell('Photo\n(ફોટો)', const Color(0xFF0056D2), 70),
                            _buildHeaderCell('Name\n(નામ)', const Color(0xFFE91E63), 160),
                            _buildHeaderCell('Department\n(વિભાગ)', const Color(0xFF4CAF50), 140),
                            _buildHeaderCell('Post\n(હોદ્દો)', const Color(0xFFFF9800), 140),
                            _buildHeaderCell('District\n(જિલ્લો)', const Color(0xFF9C27B0), 120),
                            _buildHeaderCell('View\n(જુઓ)', const Color(0xFF0056D2), 80),
                          ],
                        ),
                        // Table Body
                        if (_filteredData.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(child: Text('No employees found matching criteria.', style: TextStyle(fontSize: 14, color: Colors.black54))),
                          ),
                        ..._filteredData.map((data) {
                          final isEven = _filteredData.indexOf(data) % 2 == 0;
                          return Container(
                            color: isEven ? Colors.blue.shade50.withValues(alpha: 0.3) : Colors.white,
                            child: Row(
                              children: [
                                _buildDataCell(
                                  Text(data['id']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0056D2))),
                                  40,
                                ),
                                _buildDataCell(
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.blue.shade50,
                                    child: const Icon(Icons.person, color: Color(0xFF0056D2), size: 20),
                                  ),
                                  70,
                                ),
                                _buildDataCell(
                                  Text(data['name']!, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0056D2), fontSize: 13)),
                                  160,
                                ),
                                _buildDataCell(
                                  Row(
                                    children: [
                                      Icon(data['icon'], color: data['iconColor'], size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(_getTranslatedText(data['dept']!), style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  140,
                                ),
                                _buildDataCell(
                                  Text(_getTranslatedText(data['post']!), style: const TextStyle(color: Color(0xFF0056D2), fontSize: 12)),
                                  140,
                                ),
                                _buildDataCell(
                                  Text(_getTranslatedText(data['district']!), style: const TextStyle(color: Colors.black87, fontSize: 12)),
                                  120,
                                ),
                                _buildDataCell(
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.remove_red_eye, size: 12),
                                    label: const Text('View', style: TextStyle(fontSize: 11)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4CAF50),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                      minimumSize: const Size(60, 26),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                  ),
                                  80,
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, Color color, double width) {
    return Container(
      width: width,
      height: 48,
      color: color,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, height: 1.2),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(Widget child, double width) {
    return Container(
      width: width,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.blue.shade100, width: 0.5),
          bottom: BorderSide(color: Colors.blue.shade100, width: 0.5),
        ),
      ),
      child: child,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    final validValue = options.contains(value) ? value : (options.isNotEmpty ? options.first : null);
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(Icons.business_center, color: Colors.grey.shade500, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: validValue,
                isExpanded: true,
                dropdownColor: Colors.white,
                menuMaxHeight: 350,
                borderRadius: BorderRadius.circular(16),
                elevation: 4,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500, size: 16),
                style: const TextStyle(color: Colors.black87, fontSize: 12),
                selectedItemBuilder: (BuildContext context) {
                  return options.map<Widget>((String val) {
                    final displayVal = val == 'All' ? label : _getTranslatedText(val);
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(displayVal, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0056D2))),
                    );
                  }).toList();
                },
                items: options.map((String val) {
                  final displayVal = val == 'All' ? label : _getTranslatedText(val);
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                      ),
                      child: Row(
                        children: [
                          Icon(val == 'All' ? Icons.filter_list : Icons.label_important, size: 16, color: val == value ? const Color(0xFFE91E63) : Colors.blue.shade300),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              displayVal,
                              style: TextStyle(
                                fontWeight: val == value ? FontWeight.bold : FontWeight.w500,
                                color: val == value ? const Color(0xFFE91E63) : Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (val == value)
                            const Icon(Icons.check_circle, size: 16, color: Color(0xFFE91E63)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
