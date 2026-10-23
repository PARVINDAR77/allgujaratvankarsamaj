import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/govt_employee_model.dart';
import '../../data/models/govt_employee_query.dart';
import '../../providers/govt_employees_provider.dart';
import '../../../../core/network/api_failure.dart';
import '../../../profile/providers/master_data_provider.dart';
import '../../../../shared/constants/app_data.dart';
import '../../../home/presentation/widgets/web_home_header.dart';

class GovtEmployeesScreen extends ConsumerStatefulWidget {
  const GovtEmployeesScreen({super.key});

  @override
  ConsumerState<GovtEmployeesScreen> createState() => _GovtEmployeesScreenState();
}

class _GovtEmployeesScreenState extends ConsumerState<GovtEmployeesScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Local filter state — reflects what is sent to the backend.
  String? _selectedDepartmentId;
  String? _selectedDesignationId;
  String? _selectedDistrictId;
  String? _selectedGender;

  // Employment type tab: 0 = All (null), 1 = STATE_GOVT, 2 = CENTRAL_GOVT
  String? get _employmentTypeFilter {
    final idx = _tabController?.index ?? 0;
    if (idx == 1) return 'STATE_GOVT';
    if (idx == 2) return 'CENTRAL_GOVT';
    return null;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        _resetFiltersAndReload();
      }
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300) {
      final empState = ref.read(govtEmployeesProvider);
      if (empState.meta.hasNextPage &&
          empState.status == GovtEmployeesStatus.success) {
        ref.read(govtEmployeesProvider.notifier).loadMore();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _resetFiltersAndReload() {
    setState(() {
      _selectedDepartmentId = null;
      _selectedDesignationId = null;
      _selectedDistrictId = null;
      _selectedGender = null;
      _searchController.clear();
    });
    ref.read(govtEmployeesProvider.notifier).applyFilter(
      GovtEmployeeQuery(employmentType: _employmentTypeFilter),
    );
  }

  void _applyCurrentFilters() {
    final query = GovtEmployeeQuery(
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      gender: _selectedGender,
      departmentId: _selectedDepartmentId,
      designationId: _selectedDesignationId,
      districtId: _selectedDistrictId,
      employmentType: _employmentTypeFilter,
    );
    ref.read(govtEmployeesProvider.notifier).applyFilter(query);
  }

  bool _isNonGovtEmployee(GovtEmployeeModel emp) {
    final dept = emp.departmentName.toLowerCase();
    final deptGu = emp.departmentGujaratiName.toLowerCase();
    final desig = emp.designationName.toLowerCase();
    final desigGu = emp.designationGujaratiName.toLowerCase();
    final loc = (emp.officeLocation ?? '').toLowerCase();
    final name = emp.fullName.toLowerCase();

    const forbidden = [
      'it company',
      'private',
      'ખાનગી',
      'pvt',
      'ltd',
      'llp',
      'business',
      'વેપાર',
      'સ્વરોજગાર',
      'self',
      'not working',
      'કોઈ નોકરી નથી',
      'parvindar',
      'takhatsing',
    ];

    for (final term in forbidden) {
      if (dept.contains(term) ||
          deptGu.contains(term) ||
          desig.contains(term) ||
          desigGu.contains(term) ||
          loc.contains(term) ||
          name.contains(term)) {
        return true;
      }
    }
    return false;
  }

  List<GovtEmployeeModel> _filterGovtOnly(List<GovtEmployeeModel> items) {
    return items.where((emp) => !_isNonGovtEmployee(emp)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final empState = ref.watch(govtEmployeesProvider);

    return Scaffold(
      appBar: kIsWeb ? const WebHomeHeader(activeRoute: '/government-employees') : null,
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        top: !kIsWeb,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 850;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 1280 : 1000),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: isDesktop ? 36 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(isDesktop, context),
                      _buildTabBar(isDesktop),
                      _buildFilters(isDesktop, empState),
                      _buildBody(empState, isDesktop),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: isDesktop ? 12 : 8,
            left: isDesktop ? 8 : 4,
            right: isDesktop ? 8 : 4,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bannerWidth = constraints.maxWidth;
              // Native banner aspect ratio is 1600 x 592 (2.7027:1)
              final bannerHeight = bannerWidth * (592.0 / 1600.0);

              return Container(
                width: bannerWidth,
                height: bannerHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isDesktop ? 14 : 10),
                  border: Border.all(
                    color: const Color(0xFFD6A34A).withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF101B36).withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/govt_section_banner_clean.png',
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/govt_section_banner_new.png',
                    fit: BoxFit.fill,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFD6A34A), width: 1.6),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD6A34A).withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isDesktop ? 36 : 32,
                height: isDesktop ? 36 : 32,
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFDF7A), Color(0xFFD6A34A), Color(0xFF8C6D15)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD6A34A).withValues(alpha: 0.35),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => CircleAvatar(
                      backgroundColor: const Color(0xFFA4143D),
                      radius: isDesktop ? 18 : 16,
                      child: Icon(Icons.groups, color: Colors.white, size: isDesktop ? 20 : 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Government Employees',
                    style: TextStyle(
                      color: const Color(0xFF101B36),
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'સરકારી સેવા - સમાજની સેવા',
                    style: TextStyle(
                      color: const Color(0xFFA4143D),
                      fontSize: isDesktop ? 11.5 : 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildTabBar(bool isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5D5BA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        labelColor: const Color(0xFFA4143D),
        unselectedLabelColor: const Color(0xFF4B5563),
        indicatorColor: const Color(0xFFA4143D),
        indicatorWeight: 3.5,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.2),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'All (તમામ સરકારી)'),
          Tab(text: 'Gujarat Gov (ગુજરાત સરકાર)'),
          Tab(text: 'Central Gov (કેન્દ્ર સરકાર)'),
        ],
      ),
    );
  }

  static const Map<String, String> _districtTranslations = {
    'Ahmedabad': 'અમદાવાદ',
    'Amreli': 'અમરેલી',
    'Anand': 'આણંદ',
    'Aravalli': 'અરવલ્લી',
    'Banaskantha': 'બનાસકાંઠા',
    'Bharuch': 'ભરૂચ',
    'Bhavnagar': 'ભાવનગર',
    'Botad': 'બોટાદ',
    'Chhota Udaipur': 'છોટા ઉદેપુર',
    'Dahod': 'દાહોદ',
    'Dang': 'ડાંગ',
    'Devbhoomi Dwarka': 'દેવભૂમિ દ્વારકા',
    'Gandhinagar': 'ગાંધીનગર',
    'Gir Somnath': 'ગીર સોમનાથ',
    'Jamnagar': 'જામનગર',
    'Junagadh': 'જૂનાગઢ',
    'Kheda': 'ખેડા',
    'Kutch': 'કચ્છ',
    'Mahisagar': 'મહીસાગર',
    'Mehsana': 'મહેસાણા',
    'Morbi': 'મોરબી',
    'Narmada': 'નર્મદા',
    'Navsari': 'નવસારી',
    'Panchmahal': 'પંચમહાલ',
    'Patan': 'પાટણ',
    'Porbandar': 'પોરબંદર',
    'Rajkot': 'રાજકોટ',
    'Sabarkantha': 'સાબરકાંઠા',
    'Surat': 'સુરત',
    'Surendranagar': 'સુરેન્દ્રનગર',
    'Tapi': 'તાપી',
    'Vadodara': 'વડોદરા',
    'Valsad': 'વલસાડ',
  };

  Widget _buildDropdown(
    String hint,
    String? value,
    List<DropdownMenuItem<String?>> items,
    ValueChanged<String?> onChanged, {
    IconData? prefixIcon,
  }) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD6A34A).withValues(alpha: 0.45), width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, color: const Color(0xFFA4143D), size: 16),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: value,
                isExpanded: true,
                dropdownColor: Colors.white,
                menuMaxHeight: 380,
                borderRadius: BorderRadius.circular(12),
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD6A34A), size: 22),
                style: const TextStyle(fontSize: 12, color: Color(0xFF101B36), fontWeight: FontWeight.w600),
                hint: Text(hint, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.normal)),
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((DropdownMenuItem<String?> item) {
                    final itemText = (item.child as Text).data ?? '';
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        itemText,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF101B36),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList();
                },
                items: items.map((item) {
                  final isSelected = item.value == value;
                  final itemText = (item.child as Text).data ?? '';
                  return DropdownMenuItem<String?>(
                    value: item.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              itemText,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? const Color(0xFFA4143D) : const Color(0xFF101B36),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check, size: 16, color: Color(0xFFA4143D)),
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

  Widget _buildFilters(bool isDesktop, GovtEmployeesState empState) {
    final deptsAsync = ref.watch(govtDepartmentsProvider);
    final departments = deptsAsync.valueOrNull ?? [];

    List<DropdownMenuItem<String?>> deptItems = [
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('All Dept (બધા વિભાગ)', overflow: TextOverflow.ellipsis),
      ),
    ];
    deptItems.addAll(departments.map((d) {
      final name = d['name']?.toString() ?? '';
      final guj = d['gujaratiName']?.toString() ?? '';
      final fullLabel = guj.isNotEmpty ? '$name ($guj)' : name;
      return DropdownMenuItem<String?>(
        value: d['id'].toString(),
        child: Text(fullLabel, overflow: TextOverflow.ellipsis),
      );
    }));

    List<DropdownMenuItem<String?>> desigItems = [
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('All Posts (બધા હોદ્દા)', overflow: TextOverflow.ellipsis),
      ),
    ];
    if (_selectedDepartmentId != null) {
      final dept = departments.firstWhere((d) => d['id'].toString() == _selectedDepartmentId, orElse: () => {});
      if (dept.isNotEmpty && dept['designations'] != null) {
        final designations = (dept['designations'] as List).cast<Map<String, dynamic>>();
        desigItems.addAll(designations.map((d) {
          final name = d['name']?.toString() ?? '';
          final guj = d['gujaratiName']?.toString() ?? '';
          final fullLabel = guj.isNotEmpty ? '$name ($guj)' : name;
          return DropdownMenuItem<String?>(
            value: d['id'].toString(),
            child: Text(fullLabel, overflow: TextOverflow.ellipsis),
          );
        }));
      }
    }

    final masterData = ref.watch(masterDataProvider);
    final districtSource = (masterData.gujaratDistricts.keys.where((d) => d != 'Select District').length > 1)
        ? masterData.gujaratDistricts
        : AppData.gujaratDistricts;

    final List<DropdownMenuItem<String?>> districtItems = [
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('All Districts (બધા જિલ્લા)', overflow: TextOverflow.ellipsis),
      ),
      ...districtSource.keys
          .where((d) => d != 'Select District')
          .map((d) {
            final guj = _districtTranslations[d];
            final label = guj != null ? '$d ($guj)' : d;
            return DropdownMenuItem<String?>(
              value: d,
              child: Text(label, overflow: TextOverflow.ellipsis),
            );
          }),
    ];

    final List<DropdownMenuItem<String?>> genderItems = [
      const DropdownMenuItem<String?>(value: null, child: Text('All Genders (બધા)')),
      const DropdownMenuItem<String?>(value: 'Male', child: Text('Male (પુરુષ)')),
      const DropdownMenuItem<String?>(value: 'Female', child: Text('Female (સ્ત્રી)')),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5D5BA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101B36).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter Dropdowns
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: _buildDropdown('Department (વિભાગ)', _selectedDepartmentId, deptItems, (v) {
                    setState(() { _selectedDepartmentId = v; _selectedDesignationId = null; });
                    _applyCurrentFilters();
                  }, prefixIcon: Icons.account_balance),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown('Designation (હોદ્દો)', _selectedDesignationId, desigItems, (v) {
                    setState(() => _selectedDesignationId = v);
                    _applyCurrentFilters();
                  }, prefixIcon: Icons.badge),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown('District (જિલ્લો)', _selectedDistrictId, districtItems, (v) {
                    setState(() => _selectedDistrictId = v);
                    _applyCurrentFilters();
                  }, prefixIcon: Icons.location_on),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown('Gender (જાતિ)', _selectedGender, genderItems, (v) {
                    setState(() => _selectedGender = v);
                    _applyCurrentFilters();
                  }, prefixIcon: Icons.people),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildDropdown('Department (વિભાગ)', _selectedDepartmentId, deptItems, (v) {
                  setState(() { _selectedDepartmentId = v; _selectedDesignationId = null; });
                  _applyCurrentFilters();
                }, prefixIcon: Icons.account_balance),
                const SizedBox(height: 8),
                _buildDropdown('Designation (હોદ્દો)', _selectedDesignationId, desigItems, (v) {
                  setState(() => _selectedDesignationId = v);
                  _applyCurrentFilters();
                }, prefixIcon: Icons.badge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown('District (જિલ્લો)', _selectedDistrictId, districtItems, (v) {
                        setState(() => _selectedDistrictId = v);
                        _applyCurrentFilters();
                      }, prefixIcon: Icons.location_on),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdown('Gender (જાતિ)', _selectedGender, genderItems, (v) {
                        setState(() => _selectedGender = v);
                        _applyCurrentFilters();
                      }, prefixIcon: Icons.people),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 12),
          // Search row
          Row(
            children: [
              Expanded(
                flex: isDesktop ? 6 : 4,
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF101B36), fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFFA4143D), size: 20),
                      hintText: 'Search by Name (નામથી શોધો)...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: const Color(0xFFD6A34A).withValues(alpha: 0.45)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: const Color(0xFFD6A34A).withValues(alpha: 0.45)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFA4143D), width: 1.5),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _applyCurrentFilters(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: isDesktop ? 2 : 3,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFA4143D), Color(0xFF7E102F)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD6A34A), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFA4143D).withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _applyCurrentFilters,
                            borderRadius: BorderRadius.circular(10),
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search, size: 15, color: Color(0xFFFFDF7A)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Search (શોધો)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _resetFiltersAndReload,
                            borderRadius: BorderRadius.circular(10),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.refresh, size: 14, color: Colors.grey.shade700),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Reset (રીસેટ)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Pagination info
          if (empState.status == GovtEmployeesStatus.success ||
              empState.status == GovtEmployeesStatus.loadingMore) ...[
            Builder(
              builder: (context) {
                final validItems = _filterGovtOnly(empState.items);
                final total = validItems.length < empState.items.length
                    ? validItems.length
                    : empState.meta.total;
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5D5BA)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, size: 13, color: Color(0xFFA4143D)),
                      const SizedBox(width: 6),
                      Text(
                        'Showing ${validItems.length} of $total verified employees',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF101B36),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(GovtEmployeesState empState, bool isDesktop) {
    final validItems = _filterGovtOnly(empState.items);

    switch (empState.status) {
      case GovtEmployeesStatus.initial:
      case GovtEmployeesStatus.loading:
      case GovtEmployeesStatus.refreshing:
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFA4143D)),
                SizedBox(height: 12),
                Text('Loading...', style: TextStyle(color: Color(0xFF6B7280))),
              ],
            ),
          ),
        );

      case GovtEmployeesStatus.empty:
        return _buildEmptyState();

      case GovtEmployeesStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_iconForFailure(empState.failure?.type),
                    size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  empState.failure?.message ?? 'An error occurred.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(govtEmployeesProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA4143D),
                      foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        );

      case GovtEmployeesStatus.success:
      case GovtEmployeesStatus.loadingMore:
      case GovtEmployeesStatus.paginationError:
        if (validItems.isEmpty && empState.status == GovtEmployeesStatus.success) {
          return _buildEmptyState();
        }
        return _buildTable(empState, validItems, isDesktop);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No government employees found.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or filters.',
              style: TextStyle(fontSize: 13, color: Colors.black38),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _resetFiltersAndReload,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Filters'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA4143D),
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(GovtEmployeesState empState, List<GovtEmployeeModel> items, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - (isDesktop ? 16 : 8);
        const double baseIndex = 55.0;
        const double basePhoto = 70.0;
        const double baseAge = 70.0;
        const double baseAction = 105.0;
        const double fixedTotal = baseIndex + basePhoto + baseAge + baseAction; // 300.0

        // Minimum flexible widths
        const double minName = 220.0;
        const double minDept = 220.0;
        const double minPost = 200.0;
        const double minDistrict = 170.0;
        const double minFlexTotal = minName + minDept + minPost + minDistrict; // 810.0
        const double minTableWidth = fixedTotal + minFlexTotal; // 1110.0

        final double tableWidth = availableWidth > minTableWidth ? availableWidth : minTableWidth;
        final double extraWidth = tableWidth - minTableWidth;

        final double nameWidth = minName + (extraWidth * 0.30);
        final double deptWidth = minDept + (extraWidth * 0.28);
        final double postWidth = minPost + (extraWidth * 0.22);
        final double districtWidth = minDistrict + (extraWidth * 0.20);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: tableWidth,
            margin: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5D5BA), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF101B36).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                  child: Container(
                    width: tableWidth,
                    color: const Color(0xFF101B36),
                    child: Row(
                      children: [
                        _buildHeaderCell('#', 'ક્રમ', baseIndex),
                        _buildHeaderCell('Photo', 'ફોટો', basePhoto),
                        _buildHeaderCell('Name', 'નામ', nameWidth),
                        _buildHeaderCell('Department', 'વિભાગ', deptWidth),
                        _buildHeaderCell('Post', 'હોદ્દો', postWidth),
                        _buildHeaderCell('District', 'જિલ્લો', districtWidth),
                        _buildHeaderCell('Age', 'ઉંમર', baseAge),
                        _buildHeaderCell('Action', 'વિગત', baseAction, isLast: true),
                      ],
                    ),
                  ),
                ),
                ...items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final emp = entry.value;
                  final isEven = idx % 2 == 0;
                  return _buildRow(
                    idx + 1,
                    emp,
                    isEven,
                    baseIndex: baseIndex,
                    basePhoto: basePhoto,
                    nameWidth: nameWidth,
                    deptWidth: deptWidth,
                    postWidth: postWidth,
                    districtWidth: districtWidth,
                    baseAge: baseAge,
                    baseAction: baseAction,
                  );
                }),
                if (empState.status == GovtEmployeesStatus.loadingMore)
                  Container(
                    width: tableWidth,
                    padding: const EdgeInsets.all(16.0),
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFFA4143D)),
                    ),
                  ),
                if (empState.status == GovtEmployeesStatus.paginationError)
                  Container(
                    width: tableWidth,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed to load more.',
                            style: TextStyle(color: Colors.red)),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () =>
                              ref.read(govtEmployeesProvider.notifier).loadMore(),
                          child: const Text('Retry',
                              style: TextStyle(
                                  color: Color(0xFFA4143D),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                if (!empState.meta.hasNextPage && items.isNotEmpty)
                  Container(
                    width: tableWidth,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF8F5),
                      borderRadius:
                          const BorderRadius.vertical(bottom: Radius.circular(11)),
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFFD6A34A).withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 15, color: Color(0xFFD6A34A)),
                        SizedBox(width: 7),
                        Text(
                          'All results loaded (તમામ રેકોર્ડ લોડ થયેલ છે)',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(
    int index,
    GovtEmployeeModel emp,
    bool isEven, {
    required double baseIndex,
    required double basePhoto,
    required double nameWidth,
    required double deptWidth,
    required double postWidth,
    required double districtWidth,
    required double baseAge,
    required double baseAction,
  }) {
    final hasCustomGujaratiDept = emp.departmentGujaratiName.isNotEmpty &&
        emp.departmentGujaratiName.trim().toLowerCase() !=
            emp.departmentName.trim().toLowerCase();

    final hasCustomGujaratiPost = emp.designationGujaratiName.isNotEmpty &&
        emp.designationGujaratiName.trim().toLowerCase() !=
            emp.designationName.trim().toLowerCase();

    return Container(
      color: isEven ? Colors.white : const Color(0xFFFAF8F5),
      child: Row(
        children: [
          _buildDataCell(
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF8F5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFD6A34A).withValues(alpha: 0.4),
                    width: 0.9,
                  ),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101B36),
                    fontSize: 11.5,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
            baseIndex,
          ),
          _buildDataCell(
            Center(
              child: InkWell(
                onTap: () => _showGovtEmployeeDetails(emp),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD6A34A),
                      width: 1.2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: const Color(0xFFFAF8F5),
                    child: ClipOval(
                      child: (emp.photoUrl != null &&
                              emp.photoUrl!.trim().isNotEmpty)
                          ? Image.network(
                              emp.photoUrl!,
                              width: 34,
                              height: 34,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.person,
                                color: Color(0xFFA4143D),
                                size: 20,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: Color(0xFFA4143D),
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            basePhoto,
          ),
          _buildDataCell(
            InkWell(
              onTap: () => _showGovtEmployeeDetails(emp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emp.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101B36),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (emp.gender.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      emp.gender == 'MALE'
                          ? 'Male (પુરુષ)'
                          : (emp.gender == 'FEMALE' ? 'Female (સ્ત્રી)' : emp.gender),
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF6B7280),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
            nameWidth,
          ),
          _buildDataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emp.departmentName,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (hasCustomGujaratiDept) ...[
                  const SizedBox(height: 2),
                  Text(
                    emp.departmentGujaratiName,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
            deptWidth,
          ),
          _buildDataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emp.designationName,
                  style: const TextStyle(
                    color: Color(0xFFA4143D),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (hasCustomGujaratiPost) ...[
                  const SizedBox(height: 2),
                  Text(
                    emp.designationGujaratiName,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
            postWidth,
          ),
          _buildDataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emp.districtName ?? '—',
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (emp.districtName != null &&
                    _districtTranslations.containsKey(emp.districtName!)) ...[
                  const SizedBox(height: 2),
                  Text(
                    _districtTranslations[emp.districtName!]!,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
            districtWidth,
          ),
          _buildDataCell(
            Center(
              child: Text(
                emp.age != null ? '${emp.age} yrs' : '—',
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            baseAge,
          ),
          _buildDataCell(
            Center(
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA4143D), Color(0xFF7E102F)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFD6A34A),
                    width: 0.9,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA4143D).withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showGovtEmployeeDetails(emp),
                    borderRadius: BorderRadius.circular(15),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 13, color: Color(0xFFFFDF7A)),
                          SizedBox(width: 4),
                          Text(
                            'View',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            baseAction,
            isLast: true,
          ),
        ],
      ),
    );
  }

  void _showGovtEmployeeDetails(GovtEmployeeModel emp) {
    final deptDisplay = (emp.departmentGujaratiName.isNotEmpty &&
            emp.departmentGujaratiName.trim() != emp.departmentName.trim())
        ? '${emp.departmentName} (${emp.departmentGujaratiName})'
        : emp.departmentName;

    final desigDisplay = (emp.designationGujaratiName.isNotEmpty &&
            emp.designationGujaratiName.trim() != emp.designationName.trim())
        ? '${emp.designationName} (${emp.designationGujaratiName})'
        : emp.designationName;

    final districtGuj = emp.districtName != null ? _districtTranslations[emp.districtName!] : null;
    final districtDisplay = (districtGuj != null &&
            districtGuj.trim().isNotEmpty &&
            districtGuj.trim() != emp.districtName!.trim())
        ? '${emp.districtName!} ($districtGuj)'
        : (emp.districtName ?? '');

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Material(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFA4143D), Color(0xFF101B36)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD6A34A), width: 1.5),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white24,
                          backgroundImage: (emp.photoUrl != null && emp.photoUrl!.isNotEmpty)
                              ? NetworkImage(emp.photoUrl!)
                              : null,
                          child: (emp.photoUrl == null || emp.photoUrl!.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white, size: 30)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              emp.fullName,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD6A34A),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified, size: 12, color: Color(0xFF101B36)),
                                      SizedBox(width: 3),
                                      Text(
                                        'Verified Govt (પ્રમાણિત)',
                                        style: TextStyle(fontSize: 10, color: Color(0xFF101B36), fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  emp.employmentType == 'CENTRAL_GOVT' ? 'Central Gov' : 'Gujarat Gov',
                                  style: const TextStyle(color: Color(0xFFFFDF7A), fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),

                // Details Body
                Flexible(
                  child: Container(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.account_balance, 'Department (વિભાગ)', deptDisplay),
                          const Divider(height: 16),
                          _buildDetailRow(Icons.badge, 'Post / Role (હોદ્દો)', desigDisplay),
                          const Divider(height: 16),
                          if (emp.officeLocation != null && emp.officeLocation!.isNotEmpty) ...[
                            _buildDetailRow(Icons.business, 'Office / Posting (કચેરી)', emp.officeLocation!),
                            const Divider(height: 16),
                          ],
                          if (districtDisplay.isNotEmpty) ...[
                            _buildDetailRow(Icons.location_on, 'District (જિલ્લો)', districtDisplay),
                            const Divider(height: 16),
                          ],
                          if (emp.joiningYear != null) ...[
                            _buildDetailRow(Icons.calendar_today, 'Joining Year (સેવા વર્ષ)', '${emp.joiningYear}'),
                            const Divider(height: 16),
                          ],
                          if (emp.education != null && emp.education!.isNotEmpty) ...[
                            _buildDetailRow(Icons.school, 'Education (શિક્ષણ)', emp.education!),
                            const Divider(height: 16),
                          ],
                          if (emp.age != null) ...[
                            _buildDetailRow(Icons.cake, 'Age (ઉંમર)', '${emp.age} Years (વર્ષ)'),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text('બંધ કરો (Close)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                      const Spacer(),
                      if (emp.profileId.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.push(
                              '/candidate-profile-details?id=${emp.profileId}',
                              extra: {
                                'id': emp.profileId,
                                'fullName': emp.fullName,
                                'gender': emp.gender,
                                'age': emp.age,
                                'education': emp.education,
                                'maritalStatus': emp.maritalStatus,
                                'photoUrl': emp.photoUrl,
                                'district': emp.districtName,
                                'taluka': emp.talukaName,
                                'employmentType': emp.employmentType,
                                'department': emp.departmentName,
                                'designation': emp.designationName,
                              },
                            );
                          },
                          icon: const Icon(Icons.person_search, size: 16),
                          label: const Text('સંપૂર્ણ પ્રોફાઇલ (View Profile)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA4143D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFA4143D)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF101B36))),
            ],
          ),
        ),
      ],
    );
  }

  IconData _iconForFailure(ApiFailureType? type) {
    return switch (type) {
      ApiFailureType.noConnection => Icons.wifi_off,
      ApiFailureType.networkTimeout => Icons.timer_off,
      ApiFailureType.unauthorized => Icons.lock,
      ApiFailureType.serverError => Icons.cloud_off,
      _ => Icons.error_outline,
    };
  }

  Widget _buildHeaderCell(String en, String gu, double width, {bool isLast = false}) {
    return Container(
      width: width,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF101B36),
        border: isLast
            ? null
            : Border(
                right: BorderSide(
                  color: const Color(0xFFD6A34A).withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            en,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '($gu)',
            style: const TextStyle(
              color: Color(0xFFFFDF7A),
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(Widget child, double width, {bool isLast = false}) {
    return Container(
      width: width,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFE5E7EB), width: 0.6),
          bottom: const BorderSide(color: Color(0xFFE5E7EB), width: 0.6),
        ),
      ),
      child: child,
    );
  }
}
