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
  String? _selectedDeptId;
  String? _selectedPost;
  String? _selectedDistrict;
  String? _selectedTaluka;

  // Sample static directory employees matching reference image table rows
  final List<Map<String, String>> _sampleEmployees = [
    {
      'id': '1',
      'name': 'Dipak R. Vankar',
      'dept': 'IAS',
      'post': 'IAS Officer',
      'district': 'Gandhinagar',
      'deptIcon': '🏛️',
    },
    {
      'id': '2',
      'name': 'Riddhi M. Vankar',
      'dept': 'Education',
      'post': 'Teacher',
      'district': 'Ahmedabad',
      'deptIcon': '📕',
    },
    {
      'id': '3',
      'name': 'Hardik P. Vankar',
      'dept': 'Police',
      'post': 'Police Inspector',
      'district': 'Surat',
      'deptIcon': '🛡️',
    },
    {
      'id': '4',
      'name': 'Kavita B. Vankar',
      'dept': 'Health',
      'post': 'Staff Nurse',
      'district': 'Vadodara',
      'deptIcon': '➕',
    },
    {
      'id': '5',
      'name': 'Jigneshkumar V. Vankar',
      'dept': 'Revenue',
      'post': 'Talati',
      'district': 'Rajkot',
      'deptIcon': '📑',
    },
    {
      'id': '6',
      'name': 'Rekhaben V. Vankar',
      'dept': 'Panchayat',
      'post': 'Gram Sevak',
      'district': 'Jamnagar',
      'deptIcon': '👥',
    },
    {
      'id': '7',
      'name': 'Manish D. Vankar',
      'dept': 'Forest',
      'post': 'Forest Guard',
      'district': 'Junagadh',
      'deptIcon': '🌿',
    },
    {
      'id': '8',
      'name': 'Hetal K. Vankar',
      'dept': 'Judiciary',
      'post': 'Court Clerk',
      'district': 'Bhavnagar',
      'deptIcon': '⚖️',
    },
    {
      'id': '9',
      'name': 'Sanjay L. Vankar',
      'dept': 'GEB',
      'post': 'Junior Engineer',
      'district': 'Mehsana',
      'deptIcon': '⚡',
    },
    {
      'id': '10',
      'name': 'Devangiben S. Vankar',
      'dept': 'Social Justice',
      'post': 'Welfare Officer',
      'district': 'Kutch',
      'deptIcon': '🤝',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    ref.read(govtSearchFilterProvider.notifier).state = GovtSearchFilter(
      departmentId: _selectedDeptId,
      search: _searchController.text.trim(),
    );
  }

  void _resetFilter() {
    _searchController.clear();
    setState(() {
      _selectedDeptId = null;
      _selectedPost = null;
      _selectedDistrict = null;
      _selectedTaluka = null;
    });
    ref.read(govtSearchFilterProvider.notifier).state = GovtSearchFilter();
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(filteredGovtEmployeesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEBF4FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Top Header Artwork Section with Lord Buddha Head Logo, Peacocks & Crest
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Stack(
                  children: [
                    // Full Peacock & Lord Buddha Header Image Banner Background
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/5.jpeg',
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -0.65), // Focus exactly on top Lord Buddha face
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/WhatsApp Image 2026-09-08 at 10.08.45 PM.jpeg',
                          fit: BoxFit.cover,
                          alignment: const Alignment(0, -0.65),
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF021B3D),
                          ),
                        ),
                      ),
                    ),

                    // Top Navigation Overlay Action Bar
                    Positioned(
                      top: 8,
                      left: 10,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFF003875).withOpacity(0.85),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFF003875).withOpacity(0.85),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.notifications, color: Colors.white, size: 16),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Lower Floating Government Employees Section Badge Ribbon
                    Positioned(
                      bottom: 6,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.96),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFF0056B3), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0056B3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.groups_rounded, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 8),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Government Employees',
                                  style: TextStyle(
                                    color: Color(0xFF002B5B),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'સરકારી સેવા - સમાજની સેવા',
                                  style: TextStyle(
                                    color: Color(0xFFD90429),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
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

              const SizedBox(height: 10),

              // Filter Dropdowns Pill Bar (Department, Post, District, Taluka)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    _buildFilterDropdown('Department', _selectedDeptId, ['IAS', 'Education', 'Police', 'Health', 'Revenue'], (val) => setState(() => _selectedDeptId = val)),
                    const SizedBox(width: 6),
                    _buildFilterDropdown('Post', _selectedPost, ['Officer', 'Teacher', 'Inspector', 'Nurse', 'Talati'], (val) => setState(() => _selectedPost = val)),
                    const SizedBox(width: 6),
                    _buildFilterDropdown('District', _selectedDistrict, ['Gandhinagar', 'Ahmedabad', 'Surat', 'Vadodara', 'Rajkot'], (val) => setState(() => _selectedDistrict = val)),
                    const SizedBox(width: 6),
                    _buildFilterDropdown('Taluka', _selectedTaluka, ['All', 'City', 'North', 'South'], (val) => setState(() => _selectedTaluka = val)),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Search Bar & Search/Reset Buttons Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF0056B3)),
                            hintText: 'Search by Name...',
                            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: _applyFilter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      onPressed: _resetFilter,
                      icon: const Icon(Icons.refresh, size: 14, color: Colors.white),
                      label: const Text('Reset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE63946),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Government Employees Directory Data Table
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Table Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(7),
                            topRight: Radius.circular(7),
                          ),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 24, child: Text('#', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
                            SizedBox(width: 42, child: Text('Photo', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
                            Expanded(flex: 3, child: Text('Name', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
                            Expanded(flex: 2, child: Text('Department', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
                            Expanded(flex: 3, child: Text('Post / Designation', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
                            Expanded(flex: 2, child: Text('District', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
                            SizedBox(width: 52, child: Text('View', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
                          ],
                        ),
                      ),

                      // Data Rows (Displaying Backend API or Dynamic Reference Directory List)
                      searchAsync.when(
                        data: (items) {
                          final displayList = items.isNotEmpty
                              ? items.map((e) => {
                                    'id': e.id,
                                    'name': e.fullName,
                                    'dept': e.departmentName,
                                    'post': e.designationName,
                                    'district': e.districtName ?? 'Gujarat',
                                    'deptIcon': '🏛️',
                                  }).toList()
                              : _sampleEmployees;

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayList.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.8, color: Color(0xFFE2E8F0)),
                            itemBuilder: (context, index) {
                              final item = displayList[index];
                              final rowBg = index % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC);

                              return Container(
                                color: rowBg,
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      child: Text(
                                        '${index + 1}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF1E293B)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 42,
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: const Color(0xFFE2E8F0),
                                        child: Text(
                                          item['name']![0],
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0056B3)),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        item['name']!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF0F172A)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(item['deptIcon']!, style: const TextStyle(fontSize: 10)),
                                          const SizedBox(width: 2),
                                          Expanded(
                                            child: Text(
                                              item['dept']!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 9, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        item['post']!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 9, color: Color(0xFF475569)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        item['district']!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 9, color: Color(0xFF475569)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 52,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Viewing Govt Employee Profile: ${item['name']}')),
                                          );
                                        },
                                        icon: const Icon(Icons.remove_red_eye, size: 10, color: Colors.white),
                                        label: const Text('View', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF10B981),
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(48, 22),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, __) => const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Error loading directory profiles', style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom 5 Feature Action Icons Row (Education, Connect, Progress, Support, Bright Future)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomFeatureIcon('🎓', 'Education', const Color(0xFFD90429)),
                    _buildBottomFeatureIcon('👥', 'Connect', const Color(0xFF0056B3)),
                    _buildBottomFeatureIcon('📊', 'Progress', const Color(0xFF0284C7)),
                    _buildBottomFeatureIcon('💖', 'Support', const Color(0xFFD90429)),
                    _buildBottomFeatureIcon('🌿', 'Bright Future', const Color(0xFF16A34A)),
                  ],
                ),
              ),

              // Bottom Banner Ribbon
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: const Color(0xFF003875),
                child: const Column(
                  children: [
                    Text(
                      'સેવામાં સમાજ, વિકાસમાં સહયોગ',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      'Proud to be Vankar',
                      style: TextStyle(color: Color(0xFFFFD700), fontStyle: FontStyle.italic, fontSize: 11),
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

  Widget _buildFilterDropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Expanded(
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF0056B3)),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomFeatureIcon(String iconStr, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(iconStr, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
        ),
      ],
    );
  }
}
