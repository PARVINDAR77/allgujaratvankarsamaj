import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            
            // Gender Filter
            const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildChoiceChip('All', _currentQuery.gender == null, () {
                  setState(() => _currentQuery = _currentQuery.copyWith(gender: null));
                }),
                _buildChoiceChip('Male', _currentQuery.gender == 'MALE', () {
                  setState(() => _currentQuery = _currentQuery.copyWith(gender: 'MALE'));
                }),
                _buildChoiceChip('Female', _currentQuery.gender == 'FEMALE', () {
                  setState(() => _currentQuery = _currentQuery.copyWith(gender: 'FEMALE'));
                }),
              ],
            ),
            const SizedBox(height: 16),

            // Age Range Filter
            const Text('Age Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final resetQuery = ProfileQueryModel(
                        occupationCategory: widget.initialQuery.occupationCategory,
                      );
                      widget.onApply(resetQuery);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_currentQuery);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0056D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
