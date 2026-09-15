import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/govt_employee_model.dart';
import '../providers/govt_employees_provider.dart';

class GovtEmployeesScreen extends ConsumerStatefulWidget {
  const GovtEmployeesScreen({super.key});

  @override
  ConsumerState<GovtEmployeesScreen> createState() => _GovtEmployeesScreenState();
}

class _GovtEmployeesScreenState extends ConsumerState<GovtEmployeesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedGender;
  String? _selectedDeptId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    ref.read(govtSearchFilterProvider.notifier).state = GovtSearchFilter(
      gender: _selectedGender,
      departmentId: _selectedDeptId,
      search: _searchController.text.trim(),
    );
  }

  void _resetFilter() {
    _searchController.clear();
    setState(() {
      _selectedGender = null;
      _selectedDeptId = null;
    });
    ref.read(govtSearchFilterProvider.notifier).state = GovtSearchFilter();
  }

  @override
  Widget build(BuildContext context) {
    final deptsAsync = ref.watch(govtDepartmentsProvider);
    final featuredAsync = ref.watch(featuredGovtEmployeesProvider);
    final searchAsync = ref.watch(filteredGovtEmployeesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF061224),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1E36),
        elevation: 2,
        title: const Text(
          'સરકારી કર્મચારી મેટ્રિમોની',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFFD700)),
            onPressed: () {
              ref.refresh(filteredGovtEmployeesProvider);
              ref.refresh(featuredGovtEmployeesProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F2B48), Color(0xFF061224)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFB8860B), width: 1.5),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Color(0xFFFFD700), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'ALL GUJARAT VANKAR SAMAJ',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'GOVERNMENT EMPLOYEES MATRIMONY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'ચકાસાયેલ સરકારી કર્મચારી વણકર પાત્રો શોધો',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Search & Filter Box
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1E36),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB8860B).withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.search, color: Color(0xFFFFD700), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Search & Filters / ફિલ્ટર',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Search text input
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search by name, designation or office...',
                        hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF061224),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: const Color(0xFFB8860B).withOpacity(0.3)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dropdowns Row
                    Row(
                      children: [
                        // Gender Dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF061224),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFB8860B).withOpacity(0.3)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGender,
                                hint: const Text('Gender', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                                dropdownColor: const Color(0xFF0B1E36),
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700)),
                                items: const [
                                  DropdownMenuItem(value: 'MALE', child: Text('Male / વર', style: TextStyle(color: Colors.white, fontSize: 13))),
                                  DropdownMenuItem(value: 'FEMALE', child: Text('Female / કન્યા', style: TextStyle(color: Colors.white, fontSize: 13))),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedGender = val;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Department Dropdown
                        Expanded(
                          child: deptsAsync.when(
                            data: (depts) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF061224),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFB8860B).withOpacity(0.3)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedDeptId,
                                    hint: const Text('Department', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                                    dropdownColor: const Color(0xFF0B1E36),
                                    isExpanded: true,
                                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700)),
                                    items: depts.map((d) {
                                      return DropdownMenuItem(
                                        value: d.id,
                                        child: Text(
                                          d.name,
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedDeptId = val;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                            error: (_, __) => const Text('Error', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Filter Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _applyFilter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB8860B),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Search Profiles',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: _resetFilter,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF6B7280)),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Reset', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Featured Carousel Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Featured Government Employees',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Featured List
            SizedBox(
              height: 230,
              child: featuredAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(child: Text('No featured profiles at present', style: TextStyle(color: Colors.grey)));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final p = list[index];
                      return _buildFeaturedCard(p);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const Center(child: Text('Unable to load featured profiles', style: TextStyle(color: Colors.red))),
              ),
            ),

            const SizedBox(height: 16),

            // Search Results Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'All Verified Government Profiles',
                style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            searchAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    width: double.infinity,
                    child: Column(
                      children: [
                        const Icon(Icons.search_off, color: Color(0xFF6B7280), size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'No Government Employee profiles matching your criteria',
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _resetFilter,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                          child: const Text('Clear Filters', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildGovtProfileCard(items[index]);
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Text('Unable to load government profiles from server.', style: TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.refresh(filteredGovtEmployeesProvider),
                      child: const Text('Retry Connection'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(GovtEmployeeModel p) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1E36),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1E3A8A),
                child: Text(
                  p.fullName.isNotEmpty ? p.fullName[0] : 'V',
                  style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              const Icon(Icons.verified, color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            p.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            p.designationName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Text(
            p.departmentName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              p.districtName ?? 'Gujarat',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGovtProfileCard(GovtEmployeeModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1E36),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB8860B).withOpacity(0.3), width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF1E3A8A),
                child: Text(
                  p.fullName.isNotEmpty ? p.fullName[0] : 'V',
                  style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.fullName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        const Icon(Icons.verified, color: Color(0xFF10B981), size: 18),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.designationGujaratiName} (${p.designationName})',
                      style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    Text(
                      '${p.departmentGujaratiName} • ${p.districtName ?? "Gujarat"}',
                      style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF1F2937), height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Education: ${p.education}',
                style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 11),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Matrimonial Interest sent to ${p.fullName}!')),
                  );
                },
                icon: const Icon(Icons.favorite, size: 14, color: Colors.white),
                label: const Text('Send Interest', style: TextStyle(fontSize: 11, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB8860B),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
