import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/govt_employee_model.dart';
import '../../data/models/govt_employee_query.dart';
import '../../providers/govt_employees_provider.dart';
import '../../../../core/network/api_failure.dart';
import '../../../profile/providers/master_data_provider.dart';
import '../../../../shared/constants/app_data.dart';

class GovtEmployeesScreen extends ConsumerStatefulWidget {
  const GovtEmployeesScreen({super.key});

  @override
  ConsumerState<GovtEmployeesScreen> createState() => _GovtEmployeesScreenState();
}

class _GovtEmployeesScreenState extends ConsumerState<GovtEmployeesScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.dispose();
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

  @override
  Widget build(BuildContext context) {
    final empState = ref.watch(govtEmployeesProvider);

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
                    _buildHeader(isDesktop, context),
                    _buildTabBar(),
                    _buildFilters(isDesktop, empState),
                    Expanded(child: _buildBody(empState, isDesktop)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop, BuildContext context) {
    return SizedBox(
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
                        Text('પાછા જાઓ (Back)',
                            style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
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
              padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 40 : 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFF3C34D), width: 2.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF0056D2),
                    radius: isDesktop ? 24 : 20,
                    child: Icon(Icons.groups,
                        color: Colors.white, size: isDesktop ? 28 : 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Government Employees',
                        style: TextStyle(
                            color: const Color(0xFF0056D2),
                            fontSize: isDesktop ? 24 : 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'સરકારી સેવા - સમાજની સેવા',
                        style: TextStyle(
                            color: const Color(0xFF0056D2),
                            fontSize: isDesktop ? 14 : 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF0056D2),
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: const Color(0xFF0056D2),
        labelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        indicatorWeight: 3,
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
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, color: const Color(0xFF0056D2), size: 16),
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
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0056D2), size: 20),
                style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
                hint: Text(hint, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.normal)),
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
                          color: Color(0xFF0056D2),
                          fontWeight: FontWeight.w600,
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
                                color: isSelected ? const Color(0xFF0056D2) : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check, size: 16, color: Color(0xFF0056D2)),
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
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
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
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search,
                          color: Color(0xFF0056D2), size: 20),
                      hintText: 'Search by Name (નામથી શોધો)...',
                      hintStyle: const TextStyle(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _applyCurrentFilters(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: isDesktop ? 2 : 3,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyCurrentFilters,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          backgroundColor: const Color(0xFF00A2FF),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Search\n(શોધો)',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, height: 1.1)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _resetFiltersAndReload,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, size: 12),
                            SizedBox(width: 2),
                            Text('Reset\n(રીસેટ)',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, height: 1.1)),
                          ],
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
              empState.status == GovtEmployeesStatus.loadingMore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Showing ${empState.items.length} of ${empState.meta.total} employees',
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(GovtEmployeesState empState, bool isDesktop) {
    switch (empState.status) {
      case GovtEmployeesStatus.initial:
      case GovtEmployeesStatus.loading:
      case GovtEmployeesStatus.refreshing:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF0056D2)),
              SizedBox(height: 12),
              Text('Loading...', style: TextStyle(color: Colors.black54)),
            ],
          ),
        );

      case GovtEmployeesStatus.empty:
        return Center(
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
                    backgroundColor: const Color(0xFF0056D2)),
              ),
            ],
          ),
        );

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
                      backgroundColor: const Color(0xFF0056D2)),
                ),
              ],
            ),
          ),
        );

      case GovtEmployeesStatus.success:
      case GovtEmployeesStatus.loadingMore:
      case GovtEmployeesStatus.paginationError:
        return _buildTable(empState, isDesktop);
    }
  }

  Widget _buildTable(GovtEmployeesState empState, bool isDesktop) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            empState.meta.hasNextPage &&
            empState.status == GovtEmployeesStatus.success) {
          ref.read(govtEmployeesProvider.notifier).loadMore();
        }
        return false;
      },
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
                Row(
                  children: [
                    _buildHeaderCell('#\n(ક્રમ)', const Color(0xFF00A2FF), 55),
                    _buildHeaderCell('Photo\n(ફોટો)', const Color(0xFF0056D2), 65),
                    _buildHeaderCell('Name\n(નામ)', const Color(0xFFE91E63), 165),
                    _buildHeaderCell('Department\n(વિભાગ)', const Color(0xFF4CAF50), 180),
                    _buildHeaderCell('Post\n(હોદ્દો)', const Color(0xFFFF9800), 170),
                    _buildHeaderCell('District\n(જિલ્લો)', const Color(0xFF9C27B0), 130),
                    _buildHeaderCell('Age\n(ઉંમર)', const Color(0xFF009688), 65),
                    _buildHeaderCell('Action\n(વિગત)', const Color(0xFF0056D2), 85),
                  ],
                ),
                ...empState.items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final emp = entry.value;
                  final isEven = idx % 2 == 0;
                  return _buildRow(idx + 1, emp, isEven);
                }),
                if (empState.status == GovtEmployeesStatus.loadingMore)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF0056D2))),
                  ),
                if (empState.status == GovtEmployeesStatus.paginationError)
                  Padding(
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
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                if (!empState.meta.hasNextPage && empState.items.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('All results loaded.',
                          style: TextStyle(color: Colors.black38, fontSize: 12)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int index, GovtEmployeeModel emp, bool isEven) {
    return Container(
      color: isEven ? Colors.blue.shade50.withValues(alpha: 0.3) : Colors.white,
      child: Row(
        children: [
          _buildDataCell(
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200, width: 0.8),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0056D2),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
            55,
          ),
          _buildDataCell(
            Center(
              child: InkWell(
                onTap: () => _showGovtEmployeeDetails(emp),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: (emp.photoUrl != null && emp.photoUrl!.isNotEmpty)
                      ? NetworkImage(emp.photoUrl!)
                      : null,
                  child: (emp.photoUrl == null || emp.photoUrl!.isEmpty)
                      ? const Icon(Icons.person, color: Color(0xFF0056D2), size: 20)
                      : null,
                ),
              ),
            ),
            65,
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
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0056D2),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (emp.gender.isNotEmpty)
                    Text(
                      emp.gender == 'MALE'
                          ? 'Male (પુરુષ)'
                          : (emp.gender == 'FEMALE' ? 'Female (સ્ત્રી)' : emp.gender),
                      style: const TextStyle(fontSize: 10, color: Colors.black45),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
            165,
          ),
          _buildDataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emp.departmentName,
                  style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (emp.departmentGujaratiName.isNotEmpty)
                  Text(
                    emp.departmentGujaratiName,
                    style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
            180,
          ),
          _buildDataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emp.designationName,
                  style: const TextStyle(color: Color(0xFF0056D2), fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (emp.designationGujaratiName.isNotEmpty)
                  Text(
                    emp.designationGujaratiName,
                    style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
            170,
          ),
          _buildDataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emp.districtName ?? '—',
                  style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (emp.districtName != null && _districtTranslations.containsKey(emp.districtName!))
                  Text(
                    _districtTranslations[emp.districtName!]!,
                    style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
            130,
          ),
          _buildDataCell(
            Center(
              child: Text(
                emp.age != null ? '${emp.age} yrs' : '—',
                style: const TextStyle(color: Colors.black87, fontSize: 12),
              ),
            ),
            65,
          ),
          _buildDataCell(
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _showGovtEmployeeDetails(emp),
                icon: const Icon(Icons.remove_red_eye, size: 12),
                label: const Text('View', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: const Size(64, 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            85,
          ),
        ],
      ),
    );
  }

  void _showGovtEmployeeDetails(GovtEmployeeModel emp) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0056D2), Color(0xFF0A2540)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white24,
                      backgroundImage: (emp.photoUrl != null && emp.photoUrl!.isNotEmpty)
                          ? NetworkImage(emp.photoUrl!)
                          : null,
                      child: (emp.photoUrl == null || emp.photoUrl!.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white, size: 30)
                          : null,
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
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 11, color: Colors.white),
                                    SizedBox(width: 3),
                                    Text('Verified Govt (પ્રમાણિત)', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                emp.employmentType == 'CENTRAL_GOVT' ? 'Central Gov' : 'Gujarat Gov',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.account_balance, 'Department (વિભાગ)', '${emp.departmentName} (${emp.departmentGujaratiName})'),
                      const Divider(height: 16),
                      _buildDetailRow(Icons.badge, 'Post / Role (હોદ્દો)', '${emp.designationName} (${emp.designationGujaratiName})'),
                      const Divider(height: 16),
                      if (emp.officeLocation != null && emp.officeLocation!.isNotEmpty) ...[
                        _buildDetailRow(Icons.business, 'Office / Posting (કચેરી)', emp.officeLocation!),
                        const Divider(height: 16),
                      ],
                      if (emp.districtName != null && emp.districtName!.isNotEmpty) ...[
                        _buildDetailRow(Icons.location_on, 'District (જિલ્લો)', '${emp.districtName!} (${_districtTranslations[emp.districtName!] ?? ''})'),
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
                          context.push('/candidate-profile-details', extra: {'id': emp.profileId});
                        },
                        icon: const Icon(Icons.person_search, size: 16),
                        label: const Text('સંપૂર્ણ પ્રોફાઇલ (View Profile)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0056D2),
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
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0056D2)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
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

  Widget _buildHeaderCell(String text, Color color, double width) {
    return Container(
      width: width,
      height: 48,
      color: color,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
            height: 1.2),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(Widget child, double width) {
    return Container(
      width: width,
      height: 58,
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
}
