import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/profile_query_model.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  final ProfileQueryModel initialQuery;
  final ValueChanged<ProfileQueryModel> onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialQuery,
    required this.onApply,
  });

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late ProfileQueryModel _currentQuery;

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.initialQuery;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Profiles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0056D2),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 6),
            
            // Ultra-Prominent Top Card to open Old / Advance Search Form
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  final lookingFor = _currentQuery.gender == 'MALE' ? 'Groom' : (_currentQuery.gender == 'FEMALE' ? 'Bride' : 'Groom');
                  context.push('/advanced-search?lookingFor=$lookingFor');
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF003C9E), Color(0xFF0056D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0056D2).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.assignment_outlined, color: Color(0xFFFFD700), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'જૂનું વિસ્તૃત ફોર્મ (Old Form)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 6),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFD700),
                                    borderRadius: BorderRadius.all(Radius.circular(6)),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    child: Text(
                                      'OPEN',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              'પરગણા, જિલ્લો, શિક્ષણ, નોકરી જૂના ફોર્મથી શોધો',
                              style: TextStyle(fontSize: 10, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFD700), size: 14),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Gender Filter
            const Text('Gender (જાતિ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildChoiceChip('All (બધા)', _currentQuery.gender == null, () {
                  setState(() => _currentQuery = _currentQuery.copyWith(clearGender: true));
                }),
                _buildChoiceChip('Male (વર)', _currentQuery.gender == 'MALE', () {
                  setState(() => _currentQuery = _currentQuery.copyWith(gender: 'MALE'));
                }),
                _buildChoiceChip('Female (કન્યા)', _currentQuery.gender == 'FEMALE', () {
                  setState(() => _currentQuery = _currentQuery.copyWith(gender: 'FEMALE'));
                }),
              ],
            ),
            const SizedBox(height: 16),

            // Age Range Filter
            const Text('Age Range (ઉંમર)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            RangeSlider(
              values: RangeValues(
                (_currentQuery.ageMin ?? 18).toDouble(),
                (_currentQuery.ageMax ?? 60).toDouble(),
              ),
              min: 18,
              max: 60,
              divisions: 42,
              labels: RangeLabels(
                '${_currentQuery.ageMin ?? 18}',
                '${_currentQuery.ageMax ?? 60}',
              ),
              activeColor: const Color(0xFF0056D2),
              onChanged: (values) {
                setState(() {
                  _currentQuery = _currentQuery.copyWith(
                    ageMin: values.start.round(),
                    ageMax: values.end.round(),
                  );
                });
              },
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      final resetQuery = ProfileQueryModel(
                        occupationCategory: widget.initialQuery.occupationCategory,
                      );
                      widget.onApply(resetQuery);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      final lookingFor = _currentQuery.gender == 'MALE' ? 'Groom' : (_currentQuery.gender == 'FEMALE' ? 'Bride' : 'Groom');
                      context.push('/advanced-search?lookingFor=$lookingFor');
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFF6FF),
                      side: const BorderSide(color: Color(0xFF0056D2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('જૂનું ફોર્મ', style: TextStyle(color: Color(0xFF0056D2), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_currentQuery);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0056D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onSelect) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(),
      selectedColor: const Color(0xFF0056D2).withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF0056D2) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
