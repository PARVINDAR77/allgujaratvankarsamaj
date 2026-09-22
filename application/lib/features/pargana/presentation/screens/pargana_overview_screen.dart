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

  final Color _bgColor = Colors.white;
  final Color _cardColor = const Color(0xFFF8FAFC);
  final Color _goldColor = const Color(0xFFD4AF37);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profileNotifierProvider);

    List<String> availableParganas = ['All'];
    List<String> availableDistricts = ['All'];
    List<String> availableTalukas = ['All'];
    List<String> availableVillages = ['All'];

    for (var p in profiles) {
      if (p.pargana.isNotEmpty && !availableParganas.contains(p.pargana)) availableParganas.add(p.pargana);
    }
    for (var p in profiles) {
      if (_selectedPargana != 'All' && p.pargana != _selectedPargana) continue;
      if (p.district.isNotEmpty && !availableDistricts.contains(p.district)) availableDistricts.add(p.district);
    }
    for (var p in profiles) {
      if (_selectedPargana != 'All' && p.pargana != _selectedPargana) continue;
      if (_selectedDistrict != 'All' && p.district != _selectedDistrict) continue;
      if (p.taluka.isNotEmpty && !availableTalukas.contains(p.taluka)) availableTalukas.add(p.taluka);
    }

    if (!availableParganas.contains(_selectedPargana)) _selectedPargana = 'All';
    if (!availableDistricts.contains(_selectedDistrict)) _selectedDistrict = 'All';
    if (!availableTalukas.contains(_selectedTaluka)) _selectedTaluka = 'All';

    final filteredProfiles = profiles.where((p) {
      if (_selectedPargana != 'All' && p.pargana != _selectedPargana) return false;
      if (_selectedDistrict != 'All' && p.district != _selectedDistrict) return false;
      if (_selectedTaluka != 'All' && p.taluka != _selectedTaluka) return false;
      if (_searchQuery.isNotEmpty && !p.fullName.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleCard(),
                          const SizedBox(height: 16),
                          Text(
                            'ફિલ્ટર કરો (Filter By):',
                            style: TextStyle(color: _goldColor, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildFilterGrid(availableParganas, availableDistricts, availableTalukas, availableVillages),
                          const SizedBox(height: 16),
                          _buildSearchBar(),
                          const SizedBox(height: 16),
                          Text(
                            '${filteredProfiles.length} પ્રોફાઈલ મળ્યા (profiles found)',
                            style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildProfileList(filteredProfiles),
                        ],
                      ),
                    ),
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
    return SizedBox(
      height: 120, // Fixed height to prevent overflow
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/vankar_header_banner.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              color: Colors.black.withValues(alpha: 0.3), // Darken the image slightly for text readability
              colorBlendMode: BlendMode.darken,
              errorBuilder: (context, error, stackTrace) => Container(
                color: _bgColor,
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Text(
                  'પરગણા (વિશેષ) (Pargana Overview)',
                  style: TextStyle(color: _goldColor, fontSize: 18, fontWeight: FontWeight.bold, shadows: const [Shadow(color: Colors.black, blurRadius: 4)]),
                ),
                const SizedBox(height: 4),
                const Text(
                  'All Gujarat Vankar Samaj Directory',
                  style: TextStyle(color: Colors.white, fontSize: 14, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: GestureDetector(
              onTap: () => context.canPop() ? context.pop() : context.go('/home'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _cardColor.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: _goldColor, width: 1.5),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _goldColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.domain, color: _goldColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Samaj Family Directory',
                  style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'વણકર સમાજ - પરગણા પ્રમાણે સૂચિ',
                  style: TextStyle(color: _goldColor, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterGrid(List<String> parganas, List<String> districts, List<String> talukas, List<String> villages) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDropdown(_selectedPargana, parganas, (v) {
              setState(() {
                _selectedPargana = v ?? 'All';
                _selectedDistrict = 'All';
                _selectedTaluka = 'All';
              });
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildDropdown(_selectedDistrict, districts, (v) {
              setState(() {
                _selectedDistrict = v ?? 'All';
                _selectedTaluka = 'All';
              });
            })),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDropdown(_selectedTaluka, talukas, (v) => setState(() => _selectedTaluka = v ?? 'All'))),
            const SizedBox(width: 12),
            Expanded(child: _buildDropdown(_selectedVillage, villages, (v) => setState(() => _selectedVillage = v ?? 'All'))),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(String value, List<String> options, void Function(String?) onChanged) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _goldColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : 'All',
          isExpanded: true,
          dropdownColor: _cardColor,
          icon: Icon(Icons.keyboard_arrow_down, color: _goldColor),
          style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
          onChanged: onChanged,
          items: options.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _goldColor),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: _goldColor),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'નામ શોધો... (Search by Name)',
                hintStyle: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold),
                border: InputBorder.none,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList(List<ProfileModel> profiles) {
    if (profiles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(Icons.search_off, color: Colors.black38, size: 48),
            SizedBox(height: 16),
            Text('કોઈ પ્રોફાઇલ મળી નથી', style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _goldColor),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _goldColor),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: _goldColor, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: _goldColor, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${profile.pargana} / ${profile.taluka}',
                            style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.business, color: Colors.black38, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            profile.district,
                            style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.designation.isNotEmpty ? profile.designation : 'N/A',
                      style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: _goldColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: _bgColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomIcon(Icons.school, 'શિક્ષણ', const Color(0xFF673AB7)), // Purple
          _buildBottomIcon(Icons.people, 'સંપર્ક', const Color(0xFF1976D2)), // Blue
          _buildBottomIcon(Icons.bar_chart, 'વિકાસ', const Color(0xFF388E3C)), // Green
          _buildBottomIcon(Icons.favorite, 'સહયોગ', const Color(0xFFE91E63)), // Pink
          _buildBottomIcon(Icons.eco, 'ઉજ્જવળ ભવ.', const Color(0xFF009688)), // Teal
        ],
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, String label, Color bgColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: bgColor, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
