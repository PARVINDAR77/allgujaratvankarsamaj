import 'package:flutter/material.dart';
import '../constants/gov_departments.dart';

class GovClassPickerSheet extends StatelessWidget {
  final String? initialClass;
  final void Function(String selectedClass) onSelected;

  const GovClassPickerSheet({
    super.key,
    this.initialClass,
    required this.onSelected,
  });

  static const List<Map<String, dynamic>> _classList = [
    {
      'title': 'Class 1 Officer (વર્ગ-૧ ગેઝેટેડ અધિકારી)',
      'subtitle': 'GAS, Collector, Dy. Collector, DDO, Class-1 Officers',
      'icon': Icons.stars_rounded,
      'color': Color(0xFFD4AF37),
    },
    {
      'title': 'Class 2 Officer (વર્ગ-૨ ગેઝેટેડ/બિન-ગેઝેટેડ અધિકારી)',
      'subtitle': 'Mamlatdar, TDO, Section Officer, Class-2 Officers',
      'icon': Icons.military_tech_rounded,
      'color': Color(0xFF1D4ED8),
    },
    {
      'title': 'Class 3 Employee (વર્ગ-૩ કર્મચારી / સ્ટાફ)',
      'subtitle': 'Talati, Clerk, Teacher, Police, Field / Admin Staff',
      'icon': Icons.badge_rounded,
      'color': Color(0xFF0D9488),
    },
    {
      'title': 'Class 4 Staff (વર્ગ-૪ કર્મચારી / સહાયક)',
      'subtitle': 'Support Staff, Peon, Assistant, Driver, Helper',
      'icon': Icons.handyman_rounded,
      'color': Color(0xFF7C3AED),
    },
    {
      'title': 'Other Government Staff (અન્ય સરકારી કર્મચારી)',
      'subtitle': 'Contractual / Board / Corporation / Semi-Govt Service',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF475569),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentSelection = (initialClass != null && initialClass != 'Select Officer / Employee Class')
        ? initialClass
        : null;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 600),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.military_tech_rounded,
                        color: Color(0xFFD4AF37),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'સરકારી વર્ગ / કેડર (Officer Class)',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'તમારો વર્ગ (Class 1, 2, 3, 4) પસંદ કરો',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.black54),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              // Class List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _classList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _classList[index];
                    final title = item['title'] as String;
                    final subtitle = item['subtitle'] as String;
                    final icon = item['icon'] as IconData;
                    final color = item['color'] as Color;
                    final isSelected = currentSelection == title;

                    return InkWell(
                      onTap: () {
                        onSelected(title);
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1D4ED8)
                                : Colors.grey.shade300,
                            width: isSelected ? 1.8 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, color: color, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF1D4ED8)
                                          : Colors.black87,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF1D4ED8),
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

