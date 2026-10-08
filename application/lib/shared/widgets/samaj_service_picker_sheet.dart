import 'package:flutter/material.dart';
import '../models/samaj_service.dart';

class SamajServicePickerSheet extends StatefulWidget {
  final List<SamajService> allServices;
  final String? initialCategory;
  final String? initialService;
  final void Function(String category, String serviceTitle) onSelected;

  const SamajServicePickerSheet({
    super.key,
    required this.allServices,
    this.initialCategory,
    this.initialService,
    required this.onSelected,
  });

  @override
  State<SamajServicePickerSheet> createState() =>
      _SamajServicePickerSheetState();
}

class _SamajServicePickerSheetState extends State<SamajServicePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    if (_selectedCategory == 'Select Industry') {
      _selectedCategory = null;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.allServices
        .map((s) => s.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final filteredServices = widget.allServices.where((s) {
      if (_selectedCategory != null &&
          _selectedCategory!.isNotEmpty &&
          _selectedCategory != 'All') {
        if (s.category != _selectedCategory) return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = s.title.toLowerCase().contains(q);
        final matchDesc = s.description.toLowerCase().contains(q);
        final matchCat = s.category.toLowerCase().contains(q);
        return matchTitle || matchDesc || matchCat;
      }

      return true;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'સમાજ સેવા પસંદ કરો',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF041126),
                      ),
                    ),
                    Text(
                      'Select Business / Samaj Service',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'સર્વિસ શોધો (દા.ત. અનાજ, Doctor, Electrician...)',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFFD4AF37), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
              ),
            ),
          ),

          // Category Chips Bar
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: categories.length + 1,
              itemBuilder: (context, idx) {
                final isAll = idx == 0;
                final catName = isAll ? 'All (બધી કેટેગરી)' : categories[idx - 1];
                final isSelected = isAll
                    ? (_selectedCategory == null || _selectedCategory == 'All')
                    : _selectedCategory == catName;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      catName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1D4ED8),
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF1D4ED8)
                          : Colors.grey.shade300,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = isAll ? null : catName;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(height: 16),

          // Results Counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'કુલ સેવાઓ: ${filteredServices.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                if (_selectedCategory != null || _searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _selectedCategory = null;
                      });
                    },
                    child: const Text(
                      'બધી સેવાઓ બતાવો (Show All)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Services List
          Expanded(
            child: filteredServices.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'કોઈ સેવા મળી નથી',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'બીજો શબ્દ શોધો અથવા બધી સેવાઓ જુઓ',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: filteredServices.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
                      final isSelected = widget.initialService == service.title;

                      return InkWell(
                        onTap: () {
                          widget.onSelected(service.category, service.title);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEFF6FF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF3B82F6)
                                  : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFDBEAFE)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  service.icon.isNotEmpty
                                      ? service.icon
                                      : '💼',
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Title & Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? const Color(0xFF1D4ED8)
                                            : const Color(0xFF041126),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        service.category,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (service.description.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        service.description,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Color(0xFF1D4ED8), size: 22)
                              else
                                Icon(Icons.chevron_right,
                                    color: Colors.grey.shade400, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
