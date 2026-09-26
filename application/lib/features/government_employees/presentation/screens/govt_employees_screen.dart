import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/govt_employee_model.dart';
import '../../data/models/govt_employee_query.dart';
import '../../providers/govt_employees_provider.dart';
import '../../../../core/network/api_failure.dart';
import '../../../../shared/constants/app_data.dart';
import '../../../profile/providers/master_data_provider.dart';

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

  // Employment type tab: 0 = STATE_GOVT, 1 = CENTRAL_GOVT
  String get _employmentTypeFilter =>
      (_tabController?.index ?? 0) == 0 ? 'STATE_GOVT' : 'CENTRAL_GOVT';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    ref.read(govtEmployeesProvider.notifier).resetFilters();
  }

  void _applyCurrentFilters() {
    final query = GovtEmployeeQuery(
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      gender: _selectedGender,
      departmentId: _selectedDepartmentId,
      designationId: _selectedDesignationId,
      districtId: _selectedDistrictId,
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
              errorBuilder: (_, __, ___) => Container(
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
          Tab(text: 'Gujarat Gov (ગુજરાત સરકાર)'),
          Tab(text: 'Central Gov (કેન્દ્ર સરકાર)'),
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<DropdownMenuItem<String?>> items, ValueChanged<String?> onChanged) {
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<String?>(
        value: value,
        isExpanded: true,
        dropdownColor: Colors.white,
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0056D2)),
        style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11, color: Colors.black54),
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
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFilters(bool isDesktop, GovtEmployeesState empState) {
    final deptsAsync = ref.watch(govtDepartmentsProvider);
    final departments = deptsAsync.valueOrNull ?? [];

    List<DropdownMenuItem<String?>> deptItems = [
      const DropdownMenuItem<String?>(value: null, child: Text('All Dept (બધા વિભાગ)')),
    ];
    deptItems.addAll(departments.map((d) => DropdownMenuItem<String?>(
      value: d['id'].toString(),
      child: Text('${d['name']} - ${d['gujaratiName']}', overflow: TextOverflow.ellipsis),
    )));

    List<DropdownMenuItem<String?>> desigItems = [
      const DropdownMenuItem<String?>(value: null, child: Text('All Posts (બધા હોદ્દા)')),
    ];
    if (_selectedDepartmentId != null) {
      final dept = departments.firstWhere((d) => d['id'].toString() == _selectedDepartmentId, orElse: () => {});
      if (dept.isNotEmpty && dept['designations'] != null) {
        final designations = (dept['designations'] as List).cast<Map<String, dynamic>>();
        desigItems.addAll(designations.map((d) => DropdownMenuItem<String?>(
          value: d['id'].toString(),
          child: Text('${d['name']} - ${d['gujaratiName']}', overflow: TextOverflow.ellipsis),
        )));
      }
    }

    final masterData = ref.watch(masterDataProvider);
    final List<DropdownMenuItem<String?>> districtItems = [
      const DropdownMenuItem<String?>(value: null, child: Text('All Districts (બધા જિલ્લા)')),
      ...masterData.gujaratDistricts.keys.where((d) => d != 'Select District').map((d) => DropdownMenuItem<String?>(value: d, child: Text(d))),
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
                Expanded(child: _buildDropdown('Department', _selectedDepartmentId, deptItems, (v) {
                  setState(() { _selectedDepartmentId = v; _selectedDesignationId = null; });
                  _applyCurrentFilters();
                })),
                const SizedBox(width: 8),
                Expanded(child: _buildDropdown('Designation', _selectedDesignationId, desigItems, (v) {
                  setState(() => _selectedDesignationId = v);
                  _applyCurrentFilters();
                })),
                const SizedBox(width: 8),
                Expanded(child: _buildDropdown('District', _selectedDistrictId, districtItems, (v) {
                  setState(() => _selectedDistrictId = v);
                  _applyCurrentFilters();
                })),
                const SizedBox(width: 8),
                Expanded(child: _buildDropdown('Gender', _selectedGender, genderItems, (v) {
                  setState(() => _selectedGender = v);
                  _applyCurrentFilters();
                })),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildDropdown('Department', _selectedDepartmentId, deptItems, (v) {
                      setState(() { _selectedDepartmentId = v; _selectedDesignationId = null; });
                    })),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDropdown('Designation', _selectedDesignationId, desigItems, (v) {
                      setState(() => _selectedDesignationId = v);
                    })),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildDropdown('District', _selectedDistrictId, districtItems, (v) {
                      setState(() => _selectedDistrictId = v);
                    })),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDropdown('Gender', _selectedGender, genderItems, (v) {
                      setState(() => _selectedGender = v);
                    })),
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
                    _buildHeaderCell('#', const Color(0xFF00A2FF), 40),
                    _buildHeaderCell('Photo\n(ફોટો)', const Color(0xFF0056D2), 70),
                    _buildHeaderCell('Name\n(નામ)', const Color(0xFFE91E63), 160),
                    _buildHeaderCell('Department\n(વિભાગ)', const Color(0xFF4CAF50), 160),
                    _buildHeaderCell('Post\n(હોદ્દો)', const Color(0xFFFF9800), 160),
                    _buildHeaderCell('District\n(જિલ્લો)', const Color(0xFF9C27B0), 120),
                    _buildHeaderCell('Age\n(ઉંમર)', const Color(0xFF009688), 60),
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
            Text('$index',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF0056D2))),
            40,
          ),
          _buildDataCell(
            emp.photoUrl != null
                ? CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(emp.photoUrl!),
                  )
                : CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.person,
                        color: Color(0xFF0056D2), size: 20),
                  ),
            70,
          ),
          _buildDataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emp.fullName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0056D2),
                        fontSize: 13),
                    overflow: TextOverflow.ellipsis),
                if (emp.gender.isNotEmpty)
                  Text(emp.gender,
                      style: const TextStyle(fontSize: 10, color: Colors.black45)),
              ],
            ),
            160,
          ),
          _buildDataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emp.departmentName,
                    style: const TextStyle(color: Colors.black87, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
                Text(emp.departmentGujaratiName,
                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
            160,
          ),
          _buildDataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emp.designationName,
                    style: const TextStyle(color: Color(0xFF0056D2), fontSize: 12),
                    overflow: TextOverflow.ellipsis),
                Text(emp.designationGujaratiName,
                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
            160,
          ),
          _buildDataCell(
            Text(emp.districtName ?? '—',
                style: const TextStyle(color: Colors.black87, fontSize: 12)),
            120,
          ),
          _buildDataCell(
            Text(emp.age != null ? '${emp.age}' : '—',
                style: const TextStyle(color: Colors.black87, fontSize: 12)),
            60,
          ),
        ],
      ),
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
      height: 56,
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
