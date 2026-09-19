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
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profileNotifierProvider);

    // Generate unique dropdown options from real profile data
    List<String> availableParganas = ['All'];
    List<String> availableDistricts = ['All'];
    List<String> availableTalukas = ['All'];
    List<String> availableVillages = ['All'];

    for (var p in profiles) {
      if (p.pargana.isNotEmpty && !availableParganas.contains(p.pargana)) {
        availableParganas.add(p.pargana);
      }
    }
    for (var p in profiles) {
      if (_selectedPargana != 'All' && p.pargana != _selectedPargana) continue;
      if (p.district.isNotEmpty && !availableDistricts.contains(p.district)) {
        availableDistricts.add(p.district);
      }
    }
    for (var p in profiles) {
      if (_selectedPargana != 'All' && p.pargana != _selectedPargana) continue;
      if (_selectedDistrict != 'All' && p.district != _selectedDistrict) continue;
      if (p.taluka.isNotEmpty && !availableTalukas.contains(p.taluka)) {
        availableTalukas.add(p.taluka);
      }
    }

    if (!availableParganas.contains(_selectedPargana)) _selectedPargana = 'All';
    if (!availableDistricts.contains(_selectedDistrict)) _selectedDistrict = 'All';
    if (!availableTalukas.contains(_selectedTaluka)) _selectedTaluka = 'All';

    final filteredProfiles = profiles.where((p) {
      if (_selectedPargana != 'All' && p.pargana != _selectedPargana) return false;
      if (_selectedDistrict != 'All' && p.district != _selectedDistrict) return false;
      if (_selectedTaluka != 'All' && p.taluka != _selectedTaluka) return false;
      if (_searchQuery.isNotEmpty &&
          !p.fullName.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF041126),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleCard(),
                    const SizedBox(height: 12),
                    _buildFilterRow(availableParganas, availableDistricts, availableTalukas, availableVillages),
                    const SizedBox(height: 10),
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    _buildResultsCount(filteredProfiles.length),
                    const SizedBox(height: 8),
                    _buildProfileList(filteredProfiles),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 130,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/vankar_header_banner.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Stack(
        children: [
          // Dark overlay for readability
          Container(color: Colors.black.withValues(alpha: 0.25)),
          // Back button
          Positioned(
            left: 12,
            top: 12,
            child: GestureDetector(
              onTap: () => context.canPop() ? context.pop() : context.go('/home'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
            ),
          ),
          // Title
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'પરગણા વિહંગ (Pargana Overview)',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'All Gujarat Vankar Samaj Directory',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F3D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_tree, color: Color(0xFFD4AF37), size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Samaj Family Directory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'વણકર સમાજ – પરગણા પ્રમાણે સૂચિ',
                  style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(List<String> parganas, List<String> districts, List<String> talukas, List<String> villages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ફિલ્ટર કરો (Filter By):', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildDropdown('પરગણા', _selectedPargana, parganas, (v) {
              setState(() {
                _selectedPargana = v ?? 'All';
                _selectedDistrict = 'All';
                _selectedTaluka = 'All';
              });
            })),
            const SizedBox(width: 8),
            Expanded(child: _buildDropdown('જિલ્લો', _selectedDistrict, districts, (v) {
              setState(() {
                _selectedDistrict = v ?? 'All';
                _selectedTaluka = 'All';
              });
            })),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildDropdown('તાલુકો', _selectedTaluka, talukas, (v) {
              setState(() => _selectedTaluka = v ?? 'All');
            })),
            const SizedBox(width: 8),
            Expanded(child: _buildDropdown('ગામ', _selectedVillage, villages, (v) {
              setState(() => _selectedVillage = v ?? 'All');
            })),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, void Function(String?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F3D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : 'All',
          isExpanded: true,
          dropdownColor: const Color(0xFF0A1F3D),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFD4AF37), size: 18),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          hint: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          onChanged: onChanged,
          items: options.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(
                val,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: val == value ? const Color(0xFFD4AF37) : Colors.white,
                  fontSize: 12,
                  fontWeight: val == value ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F3D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'નામ શોધો... (Search by Name)',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Color(0xFFD4AF37), size: 22),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.clear, color: Colors.white38, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsCount(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$count પ્રોફાઈલ મળ્યા (profiles found)',
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        if (_selectedPargana != 'All' || _selectedDistrict != 'All' || _selectedTaluka != 'All' || _searchQuery.isNotEmpty)
          GestureDetector(
            onTap: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedPargana = 'All';
                _selectedDistrict = 'All';
                _selectedTaluka = 'All';
                _selectedVillage = 'All';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 14, color: Colors.redAccent),
                  SizedBox(width: 4),
                  Text('Reset', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileList(List<ProfileModel> profiles) {
    if (profiles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: const Column(
          children: [
            Icon(Icons.search_off, color: Colors.white30, size: 60),
            SizedBox(height: 16),
            Text(
              'કોઈ પ્રોફાઈલ મળ્યા નથી\n(No profiles found)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: profiles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return _buildProfileCard(profile, index);
      },
    );
  }

  Widget _buildProfileCard(ProfileModel profile, int index) {
    return GestureDetector(
      onTap: () => context.push('/family-details'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1F3D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: index % 2 == 0
                ? const Color(0xFFD4AF37).withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            // Avatar / Number
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Profile details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName.isNotEmpty ? profile.fullName : 'અજ્ઞાત (Unknown)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (profile.pargana.isNotEmpty) ...[
                        const Icon(Icons.location_on, size: 12, color: Color(0xFFD4AF37)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            profile.pargana,
                            style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (profile.district.isNotEmpty) ...[
                        const Icon(Icons.business, size: 12, color: Colors.white38),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            profile.district,
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (profile.designation.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      profile.designation,
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Arrow
            const Icon(Icons.chevron_right, color: Color(0xFFD4AF37), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF020B18),
        border: Border(top: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomIcon(Icons.school, 'શિક્ષણ', Colors.purple),
          _buildBottomIcon(Icons.people, 'સંપર્ક', Colors.blue),
          _buildBottomIcon(Icons.bar_chart, 'વિકાસ', Colors.green),
          _buildBottomIcon(Icons.favorite, 'સહયોગ', Colors.pink),
          _buildBottomIcon(Icons.eco, 'ઉજ્જ્વળ ભવ.', Colors.teal),
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
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 9, height: 1.2),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
