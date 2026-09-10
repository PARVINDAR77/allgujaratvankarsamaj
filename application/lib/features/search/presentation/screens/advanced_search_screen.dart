import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/vankar_header.dart';

class AdvancedSearchScreen extends ConsumerStatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  ConsumerState<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  // Form selections
  String _lookingFor = 'Bride';
  String _maritalStatus = 'Never Married';
  String _age = '22 to 30 Years';
  String _height = 'Any';
  String _pargana = 'Any';
  String _livingIn = 'Any';
  String _education = 'Any';
  String _diet = 'Any';
  String _occupation = 'Any';
  String _religion = 'Any';
  String _yearlyIncome = 'Any';
  String _motherTongue = 'Any';
  String _familyType = 'Any';
  final TextEditingController _keywordController = TextEditingController();

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _lookingFor = 'Bride';
      _maritalStatus = 'Never Married';
      _age = '22 to 30 Years';
      _height = 'Any';
      _pargana = 'Any';
      _livingIn = 'Any';
      _education = 'Any';
      _diet = 'Any';
      _occupation = 'Any';
      _religion = 'Any';
      _yearlyIncome = 'Any';
      _motherTongue = 'Any';
      _familyType = 'Any';
      _keywordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Standard Vankar Header
            const VankarHeader(
              subtitle: '“એક સમાજ, એક વિચાર, એક પરિવાર”',
              showBackButton: true,
            ),

            // Scrollable Search Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Column(
                  children: [
                    // Search Card Container
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF041026),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: 🔍 Advanced Search / વિસ્તૃત શોધ
                          Center(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.search, color: AppColors.secondary, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      'Advanced Search',
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(width: 24, height: 1, color: AppColors.secondary),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        'વિસ્તૃત શોધ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Container(width: 24, height: 1, color: AppColors.secondary),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Row 1: Looking For | Marital Status
                          _buildDualRow(
                            left: _buildSearchDropdown(
                              label: 'મને જોઈએ છે (Looking For)',
                              value: _lookingFor,
                              icon: Icons.person,
                              items: const ['Bride', 'Groom', 'Any'],
                              onChanged: (val) => setState(() => _lookingFor = val!),
                            ),
                            right: _buildSearchDropdown(
                              label: 'વૈવાહિક સ્થિતિ (Marital Status)',
                              value: _maritalStatus,
                              icon: Icons.ring_volume,
                              items: const ['Never Married', 'Divorced', 'Widowed', 'Any'],
                              onChanged: (val) => setState(() => _maritalStatus = val!),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Row 2: Age | Height
                          _buildDualRow(
                            left: _buildSearchDropdown(
                              label: 'ઉંમર (Age)',
                              value: _age,
                              icon: Icons.calendar_today,
                              items: const ['18 to 22 Years', '22 to 30 Years', '30 to 35 Years', '35+ Years', 'Any'],
                              onChanged: (val) => setState(() => _age = val!),
                            ),
                            right: _buildSearchDropdown(
                              label: 'લંબાઈ (Height)',
                              value: _height,
                              icon: Icons.height,
                              items: const ['5\'0" - 5\'4"', '5\'5" - 5\'9"', '5\'10"+', 'Any'],
                              onChanged: (val) => setState(() => _height = val!),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Row 3: Pargana | Living In
                          _buildDualRow(
                            left: _buildSearchDropdown(
                              label: 'પરગણા (Pargana)',
                              value: _pargana,
                              icon: Icons.groups,
                              items: const ['35 Pargana', '27 Pargana', '16 Pargana', '14 Pargana', 'Other', 'Any'],
                              onChanged: (val) => setState(() => _pargana = val!),
                            ),
                            right: _buildSearchDropdown(
                              label: 'રહેઠાણ (Living In)',
                              value: _livingIn,
                              icon: Icons.location_on,
                              items: const ['Ahmedabad', 'Himatnagar', 'Idar', 'Surat', 'Vadodara', 'Any'],
                              onChanged: (val) => setState(() => _livingIn = val!),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Row 4: Education | Diet
                          _buildDualRow(
                            left: _buildSearchDropdown(
                              label: 'શિક્ષણ (Education)',
                              value: _education,
                              icon: Icons.school,
                              items: const ['Graduate', 'Post Graduate', 'Doctor / Eng', 'H.S.C', 'Any'],
                              onChanged: (val) => setState(() => _education = val!),
                            ),
                            right: _buildSearchDropdown(
                              label: 'આહાર (Diet)',
                              value: _diet,
                              icon: Icons.restaurant,
                              items: const ['Vegetarian', 'Vegan', 'Non-Vegetarian', 'Any'],
                              onChanged: (val) => setState(() => _diet = val!),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Row 5: Occupation | Religion
                          _buildDualRow(
                            left: _buildSearchDropdown(
                              label: 'વ્યવસાય (Occupation)',
                              value: _occupation,
                              icon: Icons.work,
                              items: const ['Government Job', 'Private Job', 'Business', 'Self Employed', 'Any'],
                              onChanged: (val) => setState(() => _occupation = val!),
                            ),
                            right: _buildSearchDropdown(
                              label: 'ધર્મ (Religion)',
                              value: _religion,
                              icon: Icons.brightness_high,
                              items: const ['Hindu', 'Buddhist', 'Jain', 'Any'],
                              onChanged: (val) => setState(() => _religion = val!),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Row 6: Yearly Income | Mother Tongue
                          _buildDualRow(
                            left: _buildSearchDropdown(
                              label: 'વધુ આવક (Yearly Income)',
                              value: _yearlyIncome,
                              icon: Icons.currency_rupee,
                              items: const ['3-5 Lakh', '5-10 Lakh', '10-20 Lakh', '20+ Lakh', 'Any'],
                              onChanged: (val) => setState(() => _yearlyIncome = val!),
                            ),
                            right: _buildSearchDropdown(
                              label: 'માતૃભાષા (Mother Tongue)',
                              value: _motherTongue,
                              icon: Icons.chat,
                              items: const ['Gujarati', 'Hindi', 'English', 'Any'],
                              onChanged: (val) => setState(() => _motherTongue = val!),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Full-Width: Family Type
                          _buildSearchDropdown(
                            label: 'કુટુંબ પ્રકાર (Family Type)',
                            value: _familyType,
                            icon: Icons.people_outline,
                            items: const ['Nuclear Family (વિભક્ત કુટુંબ)', 'Joint Family (સંયુક્ત કુટુંબ)', 'Any'],
                            onChanged: (val) => setState(() => _familyType = val!),
                          ),
                          const SizedBox(height: 14),

                          // Full-Width: Keyword Search
                          const Text(
                            'કીવર્ડ દ્વારા શોધો (Keyword Search)',
                            style: TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF020917),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8), width: 1.2),
                            ),
                            child: TextField(
                              controller: _keywordController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'e.g. Name, Profession, Education, Location...',
                                hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                                prefixIcon: Icon(Icons.search, color: AppColors.secondary, size: 20),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Bottom Dual Action Bar: Reset (Left) & Search (Right)
                          Row(
                            children: [
                              // Reset Button
                              Expanded(
                                flex: 4,
                                child: InkWell(
                                  onTap: _resetFilters,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF031633),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: AppColors.cardBorder, width: 1.2),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.refresh, color: AppColors.goldAccent, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'Reset રીસેટ કરો',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Search Button
                              Expanded(
                                flex: 6,
                                child: InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.cardNavy,
                                        content: Text(
                                          'Searching: Looking for $_lookingFor in $_pargana...',
                                          style: const TextStyle(color: AppColors.goldLight),
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.goldGradient,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.secondary.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.search, color: Colors.black87, size: 20),
                                        SizedBox(width: 6),
                                        Text(
                                          'Search શોધો',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDualRow({required Widget left, required Widget right}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 8),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildSearchDropdown({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF020917),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8), width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              dropdownColor: const Color(0xFF061633),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondary, size: 18),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              onChanged: onChanged,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, color: AppColors.secondary, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
