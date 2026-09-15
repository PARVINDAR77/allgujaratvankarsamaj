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
    return Scaffold(
      backgroundColor: const Color(0xFF030E22),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenW = constraints.maxWidth;
            // 5.jpeg poster aspect ratio calculation
            final posterH = screenW * (1600 / 736);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: screenW,
                height: posterH,
                child: Stack(
                  children: [
                    // 1. Full Master Theme Image (5.jpeg)
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/5.jpeg',
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/WhatsApp Image 2026-09-08 at 10.08.45 PM.jpeg',
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF030E22),
                          ),
                        ),
                      ),
                    ),

                    // 2. Top Navigation Back Button Overlay
                    Positioned(
                      top: posterH * 0.012,
                      left: screenW * 0.03,
                      width: screenW * 0.12,
                      height: posterH * 0.045,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),

                    // 3. Top Navigation Bell Button Overlay
                    Positioned(
                      top: posterH * 0.012,
                      right: screenW * 0.03,
                      width: screenW * 0.12,
                      height: posterH * 0.045,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {},
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
}
