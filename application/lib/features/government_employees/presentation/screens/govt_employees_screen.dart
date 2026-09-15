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
      backgroundColor: const Color(0xFFF3F7FA), // Light Blue/White Background matching reference
      appBar: AppBar(
        backgroundColor: const Color(0xFF003875),
        elevation: 0,
        title: const Text(
          'Government Employee Matrimony',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Royal Hero Banner Header (Matching Reference Image Exact Palette)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF003875), Color(0xFF0056B3)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // Emblem & Golden Crest
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF061A3A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🏛️ ', style: TextStyle(fontSize: 14)),
                        Text(
                          'Government Employee Matrimony Section',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Gujarati Subtitle Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD90429), // Bright Red Ribbon Accent
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Government Employees • Trusted • Verified • Together',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'સુરક્ષિત જીવનસાથી માટે સરકારી કર્મચારીઓ માટે વિશેષ મેટ્રિમોની સેવા',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Feature Badges Bar (Verified Profiles | Secure Platform | Wide Network | Better Matches)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFeatureBadge('🏛️', 'Verified Profiles', 'Only verified\ngovt employees', const Color(0xFF0056B3)),
                  _buildFeatureBadge('🛡️', 'Secure Platform', 'Safe & trusted\nmatrimonial service', const Color(0xFF059669)),
                  _buildFeatureBadge('👥', 'Wide Network', 'All departments &\nservices', const Color(0xFF7C3AED)),
                  _buildFeatureBadge('💖', 'Better Matches', 'Find compatible\nlife partners', const Color(0xFFD90429)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. Search & Filter Bar (Matching Blue Container & Pill Filter Inputs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0056B3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.search, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Search Government Employee Profiles',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Dropdowns Pill Row
                    Row(
                      children: [
                        // Gender Filter
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGender,
                                hint: const Text('Gender', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 'MALE', child: Text('Male / વર', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: 'FEMALE', child: Text('Female / કન્યા', style: TextStyle(fontSize: 12))),
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
                        const SizedBox(width: 8),
                        // Department Filter
                        Expanded(
                          child: deptsAsync.when(
                            data: (depts) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedDeptId,
                                    hint: const Text('Department', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                    isExpanded: true,
                                    items: depts.map((d) {
                                      return DropdownMenuItem(
                                        value: d.id,
                                        child: Text(
                                          d.name,
                                          style: const TextStyle(fontSize: 12),
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
                            loading: () => const SizedBox(height: 38, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                            error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Search Input Text
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.black, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search by Name, Designation, Department...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Search & Reset Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _applyFilter,
                            icon: const Icon(Icons.search, size: 16, color: Colors.white),
                            label: const Text('Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007BFF),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _resetFilter,
                          icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF0F172A)),
                          label: const Text('Reset', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE2E8F0),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Featured Profiles Header Bar
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.stars, color: Color(0xFF0056B3), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Featured Government Employees',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 5. Grid of Verified Profile Cards (Clean 2-Column Responsive Cards)
            searchAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    width: double.infinity,
                    child: Column(
                      children: [
                        const Icon(Icons.search_off, color: Color(0xFF94A3B8), size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'No Government Employee profiles matching criteria',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _resetFilter,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056B3)),
                          child: const Text('Clear Filters', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildReferenceCard(items[index]);
                    },
                  ),
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
                    const Text('Unable to load profiles', style: TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.refresh(filteredGovtEmployeesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 6. "Register as a Government Employee" CTA Banner Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF38BDF8), width: 1),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF0056B3),
                      child: Icon(Icons.person_add, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Register as a Government Employee',
                            style: TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Create your profile & find perfect verified matches.',
                            style: TextStyle(color: Color(0xFF0C4A6E), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registration submitted! Admin will verify employment proof.')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Register Now →', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(String iconStr, String title, String subtitle, Color iconColor) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: iconColor.withOpacity(0.1),
          child: Text(iconStr, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
        ),
      ],
    );
  }

  // Profile Card recreated to match reference layout exactly
  Widget _buildReferenceCard(GovtEmployeeModel p) {
    final deptColor = p.gender == 'FEMALE' ? const Color(0xFFE0E7FF) : const Color(0xFFFFEDD5);
    final deptTextColor = p.gender == 'FEMALE' ? const Color(0xFF3730A3) : const Color(0xFF9A3412);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Avatar & Verified Badge Header
          Stack(
            alignment: Alignment.topRight,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE2E8F0),
                child: Text(
                  p.fullName.isNotEmpty ? p.fullName[0] : 'V',
                  style: const TextStyle(color: Color(0xFF0056B3), fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 10),
                    SizedBox(width: 2),
                    Text('Verified', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Department Tag Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: deptColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              p.departmentName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: deptTextColor, fontWeight: FontWeight.bold, fontSize: 9),
            ),
          ),
          const SizedBox(height: 6),

          // Name & Details
          Text(
            p.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            '${p.age ?? 28} Years • ${p.gender == 'MALE' ? 'Male' : 'Female'}',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
          ),
          Text(
            p.designationName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w600, fontSize: 11),
          ),
          Text(
            '📍 ${p.districtName ?? "Gujarat"}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
          ),

          const Spacer(),

          // Buttons Row (View Profile & Send Interest)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Viewing profile details for ${p.fullName}')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    side: const BorderSide(color: Color(0xFF007BFF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('View Profile', style: TextStyle(color: Color(0xFF007BFF), fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Matrimonial Interest sent to ${p.fullName}!')),
                    );
                  },
                  icon: const Icon(Icons.favorite, size: 10, color: Colors.white),
                  label: const Text('Send Interest', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
