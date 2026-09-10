import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class ParganaFooterBar extends StatelessWidget {
  final Function(String pargana)? onParganaTap;

  const ParganaFooterBar({
    super.key,
    this.onParganaTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'count': '35', 'label': 'પરગણા', 'color': AppColors.pillPargana35},
      {'count': '27', 'label': 'પરગણા', 'color': AppColors.pillPargana27},
      {'count': '16', 'label': 'પરગણા', 'color': AppColors.pillPargana16},
      {'count': '14', 'label': 'પરગણા', 'color': AppColors.pillPargana14},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: items.map((item) {
          final count = item['count'] as String;
          final label = item['label'] as String;
          final color = item['color'] as Color;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (onParganaTap != null) {
                  onParganaTap!(count);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.secondary, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.groups,
                          color: AppColors.secondary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          count,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.goldAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
