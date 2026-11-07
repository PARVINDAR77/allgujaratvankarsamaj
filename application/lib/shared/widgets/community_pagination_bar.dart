import 'package:flutter/material.dart';

/// Reusable Bottom Pagination Box for Community Portals (Government, Private, Business / Samaj Services, Matrimony).
/// Enforces 15 items per page with clear bilingual navigation: "Previous (પાછળ)" and "Next 15 Profiles (આગળની 15 પ્રોફાઇલ)".
class CommunityPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool isLoading;
  final ValueChanged<int> onPageChanged;

  const CommunityPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.pageSize = 15,
    this.isLoading = false,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalItems <= 0 || totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final startItem = totalItems == 0 ? 0 : (currentPage - 1) * pageSize + 1;
    final endItem = (currentPage * pageSize).clamp(0, totalItems);
    final hasPrevious = currentPage > 1 && !isLoading;
    final hasNext = currentPage < totalPages && !isLoading;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5D5BA), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA4143D).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Counter & Page Indicator Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD6A34A).withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_alt_outlined, size: 14, color: Color(0xFFA4143D)),
                    const SizedBox(width: 6),
                    Text(
                      'Showing $startItem–$endItem of $totalItems profiles ($startItem થી $endItem / કુલ $totalItems)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101B36),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFA4143D).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA4143D).withValues(alpha: 0.2)),
                ),
                child: Text(
                  'Page $currentPage of $totalPages (પેજ $currentPage / $totalPages)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFA4143D),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE5D5BA)),
          const SizedBox(height: 14),

          // Main Navigation Buttons Box
          Row(
            children: [
              // Previous Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasPrevious ? () => onPageChanged(currentPage - 1) : null,
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text(
                    'Previous (પાછળ)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFA4143D),
                    disabledForegroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: hasPrevious
                          ? const Color(0xFFA4143D).withValues(alpha: 0.5)
                          : Colors.grey.shade300,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Next 15 Profiles Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasNext ? () => onPageChanged(currentPage + 1) : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(
                    hasNext ? 'Next 15 (આગળની 15)' : 'Last Page (છેલ્લું પેજ)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA4143D),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: hasNext ? 3 : 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

