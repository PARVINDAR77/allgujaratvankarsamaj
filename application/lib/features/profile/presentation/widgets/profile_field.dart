import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Reusable row that displays a profile label and its value.
/// Handles null values gracefully with "Not provided" fallback.
class ProfileField extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;

  const ProfileField({
    super.key,
    required this.label,
    required this.icon,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null && value!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasValue ? value! : 'Not provided',
                  style: TextStyle(
                    color: hasValue ? Colors.white : Colors.white38,
                    fontSize: 14,
                    fontWeight: hasValue ? FontWeight.bold : FontWeight.w400,
                    fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
