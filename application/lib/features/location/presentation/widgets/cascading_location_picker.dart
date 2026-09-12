import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/location_provider.dart';
import '../../data/location_models.dart';
import '../../../pargana/providers/pargana_provider.dart';

class CascadingLocationPicker extends ConsumerStatefulWidget {
  final String? initialStateId;
  final String? initialDistrictId;
  final String? initialTalukaId;
  final String? initialParganaId;
  final String? initialVillageId;
  final Function({
    StateModel? state,
    DistrictModel? district,
    TalukaModel? taluka,
    ParganaModel? pargana,
    VillageModel? village,
  }) onChanged;

  const CascadingLocationPicker({
    super.key,
    this.initialStateId,
    this.initialDistrictId,
    this.initialTalukaId,
    this.initialParganaId,
    this.initialVillageId,
    required this.onChanged,
  });

  @override
  ConsumerState<CascadingLocationPicker> createState() => _CascadingLocationPickerState();
}

class _CascadingLocationPickerState extends ConsumerState<CascadingLocationPicker> {
  StateModel? _selectedState;
  DistrictModel? _selectedDistrict;
  TalukaModel? _selectedTaluka;
  ParganaModel? _selectedPargana;
  VillageModel? _selectedVillage;

  void _notifyParent() {
    widget.onChanged(
      state: _selectedState,
      district: _selectedDistrict,
      taluka: _selectedTaluka,
      pargana: _selectedPargana,
      village: _selectedVillage,
    );
  }

  Widget _buildDropdownHeader(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 10.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2040),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF997D20).withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statesAsync = ref.watch(statesProvider);
    final districtsAsync = ref.watch(districtsProvider(_selectedState?.id));
    final talukasAsync = ref.watch(talukasProvider(_selectedDistrict?.id));
    final parganasAsync = ref.watch(parganasProvider);
    final villagesAsync = ref.watch(villagesProvider((
      parganaId: _selectedPargana?.id,
      talukaId: _selectedTaluka?.id,
      search: null,
    )));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. State Dropdown
        _buildDropdownHeader('રાજ્ય (Select State)', Icons.public),
        statesAsync.when(
          loading: () => const LinearProgressIndicator(color: Color(0xFFD4AF37)),
          error: (err, stack) => const Text('Error loading states', style: TextStyle(color: Colors.redAccent)),
          data: (states) {
            return _buildDropdownContainer(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<StateModel>(
                  isExpanded: true,
                  dropdownColor: const Color(0xFF041026),
                  hint: const Text('રાજ્ય પસંદ કરો', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  value: _selectedState,
                  items: states.map((s) {
                    return DropdownMenuItem<StateModel>(
                      value: s,
                      child: Text('${s.name} ${s.gujaratiName != null ? "(${s.gujaratiName})" : ""}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedState = val;
                      _selectedDistrict = null;
                      _selectedTaluka = null;
                      _selectedPargana = null;
                      _selectedVillage = null;
                    });
                    _notifyParent();
                  },
                ),
              ),
            );
          },
        ),

        // 2. District Dropdown
        _buildDropdownHeader('જિલ્લો (Select District)', Icons.location_city),
        districtsAsync.when(
          loading: () => const LinearProgressIndicator(color: Color(0xFFD4AF37)),
          error: (err, stack) => const Text('Error loading districts', style: TextStyle(color: Colors.redAccent)),
          data: (districts) {
            return _buildDropdownContainer(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DistrictModel>(
                  isExpanded: true,
                  dropdownColor: const Color(0xFF041026),
                  hint: const Text('જિલ્લો પસંદ કરો', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  value: _selectedDistrict,
                  items: districts.map((d) {
                    return DropdownMenuItem<DistrictModel>(
                      value: d,
                      child: Text('${d.name} ${d.gujaratiName != null ? "(${d.gujaratiName})" : ""}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedDistrict = val;
                      _selectedTaluka = null;
                      _selectedPargana = null;
                      _selectedVillage = null;
                    });
                    _notifyParent();
                  },
                ),
              ),
            );
          },
        ),

        // 3. Taluka Dropdown
        _buildDropdownHeader('તાલુકો (Select Taluka)', Icons.map),
        talukasAsync.when(
          loading: () => const LinearProgressIndicator(color: Color(0xFFD4AF37)),
          error: (err, stack) => const Text('Error loading talukas', style: TextStyle(color: Colors.redAccent)),
          data: (talukas) {
            return _buildDropdownContainer(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TalukaModel>(
                  isExpanded: true,
                  dropdownColor: const Color(0xFF041026),
                  hint: const Text('તાલુકો પસંદ કરો', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  value: _selectedTaluka,
                  items: talukas.map((t) {
                    return DropdownMenuItem<TalukaModel>(
                      value: t,
                      child: Text('${t.name} ${t.gujaratiName != null ? "(${t.gujaratiName})" : ""}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedTaluka = val;
                      _selectedVillage = null;
                    });
                    _notifyParent();
                  },
                ),
              ),
            );
          },
        ),

        // 4. Pargana Dropdown (Samaj Division)
        _buildDropdownHeader('પરગણું (Vankar Samaj Pargana)', Icons.account_balance),
        parganasAsync.when(
          loading: () => const LinearProgressIndicator(color: Color(0xFFD4AF37)),
          error: (err, stack) => const Text('Error loading parganas', style: TextStyle(color: Colors.redAccent)),
          data: (parganas) {
            return _buildDropdownContainer(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ParganaModel>(
                  isExpanded: true,
                  dropdownColor: const Color(0xFF041026),
                  hint: const Text('પરગણું પસંદ કરો', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  value: _selectedPargana,
                  items: parganas.map((p) {
                    return DropdownMenuItem<ParganaModel>(
                      value: p,
                      child: Text('${p.name} ${p.gujaratiName != null ? "(${p.gujaratiName})" : ""}', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedPargana = val;
                      _selectedVillage = null;
                    });
                    _notifyParent();
                  },
                ),
              ),
            );
          },
        ),

        // 5. Village Dropdown (Searchable Village)
        _buildDropdownHeader('ગામ / વતન (Select Village / Native)', Icons.home),
        villagesAsync.when(
          loading: () => const LinearProgressIndicator(color: Color(0xFFD4AF37)),
          error: (err, stack) => const Text('Error loading villages', style: TextStyle(color: Colors.redAccent)),
          data: (villages) {
            return _buildDropdownContainer(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<VillageModel>(
                  isExpanded: true,
                  dropdownColor: const Color(0xFF041026),
                  hint: const Text('ગામ પસંદ કરો', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  value: _selectedVillage,
                  items: villages.map((v) {
                    return DropdownMenuItem<VillageModel>(
                      value: v,
                      child: Text('${v.name} ${v.gujaratiName != null ? "(${v.gujaratiName})" : ""}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedVillage = val;
                    });
                    _notifyParent();
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
