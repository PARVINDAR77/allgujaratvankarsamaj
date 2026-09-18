import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../../shared/models/profile_model.dart';

class ParganaOverviewScreen extends ConsumerStatefulWidget {
  const ParganaOverviewScreen({super.key});

  @override
  ConsumerState<ParganaOverviewScreen> createState() => _ParganaOverviewScreenState();
}

class _ParganaOverviewScreenState extends ConsumerState<ParganaOverviewScreen> {
  String _selectedPargana = 'All';
  String _selectedDistrict = 'All';
  String _selectedTaluka = 'All';
  String _selectedVillage = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profileNotifierProvider);
    
    // 1. Generate unique options for dropdowns based on real profile data
    List<String> availableParganas = ['All'];
    List<String> availableDistricts = ['All'];
    List<String> availableTalukas = ['All'];
    List<String> availableVillages = ['All']; // Since village isn't in ProfileModel, keep static for now

    for (var p in profiles) {
      if (p.pargana.isNotEmpty && !availableParganas.contains(p.pargana)) {
        availableParganas.add(p.pargana);
      }
    }

    // Filter profiles for District dropdown based on selected Pargana
    for (var p in profiles) {
      if (_selectedPargana != 'All' && p.pargana != _selectedPargana) continue;
      if (p.district.isNotEmpty && !availableDistricts.contains(p.district)) {
        availableDistricts.add(p.district);
      }
    }

    // Filter profiles for Taluka dropdown based on selected District
    for (var p in profiles) {
      if (_selectedPargana != 'All' && p.pargana != _selectedPargana) continue;
      if (_selectedDistrict != 'All' && p.district != _selectedDistrict) continue;
      if (p.taluka.isNotEmpty && !availableTalukas.contains(p.taluka)) {
        availableTalukas.add(p.taluka);
      }
    }
    
    // Add 'Other' to every dropdown list
    if (!availableParganas.contains('Other')) availableParganas.add('Other');
    if (!availableDistricts.contains('Other')) availableDistricts.add('Other');
    if (!availableTalukas.contains('Other')) availableTalukas.add('Other');
    if (!availableVillages.contains('Other')) availableVillages.add('Other');
    
    // Ensure current selections are still valid, otherwise reset them to 'All'
    if (!availableParganas.contains(_selectedPargana)) _selectedPargana = 'All';
    if (!availableDistricts.contains(_selectedDistrict)) _selectedDistrict = 'All';
    if (!availableTalukas.contains(_selectedTaluka)) _selectedTaluka = 'All';

    // 2. Filter the profiles for the Data Table
    final filteredProfiles = profiles.where((p) {
      bool matches = true;
      if (_selectedPargana != 'All' && _selectedPargana != 'Other' && p.pargana != _selectedPargana) matches = false;
      if (_selectedDistrict != 'All' && _selectedDistrict != 'Other' && p.district != _selectedDistrict) matches = false;
      if (_selectedTaluka != 'All' && _selectedTaluka != 'Other' && p.taluka != _selectedTaluka) matches = false;
      
      if (_searchQuery.isNotEmpty) {
        if (!p.fullName.toLowerCase().contains(_searchQuery.toLowerCase())) matches = false;
      }
      return matches;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header (Cropped Image)
            _buildHeader(),
            
            // 2. Main Content Area (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Title Card
                    _buildTitleCard(),
                    
                    const SizedBox(height: 12),
                    // Filters (Dropdowns)
                    _buildFilters(availableParganas, availableDistricts, availableTalukas, availableVillages),
                    
                    // Search & Buttons
                    _buildSearchRow(),
                    
                    const SizedBox(height: 8),
                    // Data Table
                    _buildDataTable(filteredProfiles),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // 3. Bottom Action Buttons
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 160, // Compact height
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/vankar_header_banner.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 12,
            top: 12,
            child: InkWell(
              onTap: () => context.canPop() ? context.pop() : context.go('/home'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5), // Gold border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.family_restroom, size: 36, color: Color(0xFF1E3A8A)),
          const SizedBox(width: 12),
          Column(
            children: [
              const Text(
                'Samaj Family Dictionary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A), // Navy blue
                ),
              ),
              Text(
                'વણકર સમાજ પરિવારની વિગત',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(List<String> parganas, List<String> districts, List<String> talukas, List<String> villages) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(child: _buildDropdown('પરગણા', _selectedPargana, Icons.location_on, parganas, (v) {
            setState(() {
              _selectedPargana = v ?? 'All';
              _selectedDistrict = 'All'; // Reset child
              _selectedTaluka = 'All';   // Reset child
            });
          })),
          Expanded(child: _buildDropdown('જિલ્લો', _selectedDistrict, Icons.business, districts, (v) {
            setState(() {
              _selectedDistrict = v ?? 'All';
              _selectedTaluka = 'All';   // Reset child
            });
          })),
          Expanded(child: _buildDropdown('તાલુકો', _selectedTaluka, Icons.map, talukas, (v) {
            setState(() {
              _selectedTaluka = v ?? 'All';
            });
          })),
          Expanded(child: _buildDropdown('ગામ', _selectedVillage, Icons.home, villages, (v) => setState(() => _selectedVillage = v ?? 'All'))),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, IconData icon, List<String> options, Function(String?) onChanged) {
    return PopupMenuButton<String>(
      initialValue: value,
      color: Colors.white,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: onChanged,
      itemBuilder: (BuildContext context) {
        return options.map((String val) {
          return PopupMenuItem<String>(
            value: val,
            height: 36, // More compact items
            child: Text(val, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
          );
        }).toList();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue.shade300, width: 1.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: const Color(0xFF1E3A8A)),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Divider(height: 1, thickness: 1, color: Colors.blue.shade100),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF1E3A8A)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: TextField(
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'નામ શોધો...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.black45),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF1E3A8A), size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12), // Adjust for centering
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(0, 38),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('શોધો', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedPargana = 'All';
                  _selectedDistrict = 'All';
                  _selectedTaluka = 'All';
                  _selectedVillage = 'All';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                minimumSize: const Size(0, 38),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text('રીસેટ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<ProfileModel> profiles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DataTable(
            showCheckboxColumn: false, // Ensures checkboxes aren't shown when onSelectChanged is used
            headingRowHeight: 46,
            dataRowMinHeight: 36,
            dataRowMaxHeight: 36,
            columnSpacing: 0,
            horizontalMargin: 0,
            dividerThickness: 1,
            headingTextStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            columns: [
              DataColumn(label: _buildHeaderCell('#', Colors.blue.shade600, 30)),
              DataColumn(label: _buildHeaderCell('પરિવાર નો\nમુખ્ય માણસ', Colors.pink, 80)),
              DataColumn(label: _buildHeaderCell('નામ', const Color(0xFF1E3A8A), 100)),
              DataColumn(label: _buildHeaderCell('જોબ / વ્યવસાય', Colors.green, 100)),
              DataColumn(label: _buildHeaderCell('ઉંમર\n(વર્ષ)', Colors.orange, 50)),
              DataColumn(label: _buildHeaderCell('પરિવારના\nકુલ સભ્યો', Colors.purple, 70)),
              DataColumn(label: _buildHeaderCell('ફોન નંબર', Colors.blue, 90)),
            ],
            rows: List.generate(15, (index) {
              if (index < profiles.length) {
                final profile = profiles[index];
                return DataRow(
                  onSelectChanged: (selected) {
                    if (selected == true) {
                      context.push('/family-details');
                    }
                  },
                  color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                    return index.isEven ? Colors.blue.shade50.withValues(alpha: 0.3) : Colors.white;
                  }),
                  cells: [
                    DataCell(_buildDataCellText('${index + 1}', 30, isBold: true, color: const Color(0xFF1E3A8A))),
                    DataCell(_buildDataCellIcon(80)),
                    DataCell(_buildDataCellText(profile.fullName, 100)),
                    DataCell(_buildDataCellText(profile.designation, 100)),
                    DataCell(_buildDataCellText('30', 50)), // Mock age
                    DataCell(_buildDataCellText('4', 70)), // Mock members
                    DataCell(_buildDataCellText('9876543210', 90)), // Mock phone
                  ],
                );
              } else {
                // Empty rows to match the 15-row design
                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                    return index.isEven ? Colors.blue.shade50.withValues(alpha: 0.3) : Colors.white;
                  }),
                  cells: [
                    DataCell(_buildDataCellText('${index + 1}', 30, isBold: true, color: const Color(0xFF1E3A8A))),
                    DataCell(_buildDataCellIcon(80)),
                    DataCell(_buildDataCellText('', 100)),
                    DataCell(_buildDataCellText('', 100)),
                    DataCell(_buildDataCellText('', 50)),
                    DataCell(_buildDataCellText('', 70)),
                    DataCell(_buildDataCellText('', 90)),
                  ],
                );
              }
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, Color color, double width) {
    return Container(
      width: width,
      height: double.infinity,
      color: color,
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(height: 1.2),
      ),
    );
  }

  Widget _buildDataCellText(String text, double width, {bool isBold = false, Color color = Colors.black87}) {
    return Container(
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDataCellIcon(double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Icon(Icons.person, size: 16, color: Colors.grey.shade600),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomIcon(Icons.school, 'શિક્ષણ\n(Education)', Colors.purple),
          _buildBottomIcon(Icons.people, 'સંપર્ક\n(Connect)', Colors.blue),
          _buildBottomIcon(Icons.bar_chart, 'વિકાસ\n(Progress)', Colors.green),
          _buildBottomIcon(Icons.favorite, 'સહયોગ\n(Support)', Colors.pink),
          _buildBottomIcon(Icons.eco, 'આગામી પેઢી\n(Bright Future)', Colors.purple.shade300),
        ],
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A), // Navy blue
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
