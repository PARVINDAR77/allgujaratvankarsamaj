import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/profile_models.dart';

/// Animated card showing profile completeness percentage and field counts.
class ProfileCompletenessCard extends StatelessWidget {
  final CompletenessModel completeness;

  const ProfileCompletenessCard({super.key, required this.completeness});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _progressColor(completeness.percentage);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.92),
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                'Profile Completeness',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (completeness.isComplete)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.greenAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Complete',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${completeness.percentage}%',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${completeness.completedFields} / ${completeness.totalFields} fields',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completeness.percentage / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          if (!completeness.isComplete) ...[
            const SizedBox(height: 10),
            Text(
              'Add ${completeness.totalFields - completeness.completedFields} more field(s) to complete your profile.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white60,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _progressColor(int percentage) {
    if (percentage >= 80) return const Color(0xFF69F0AE); // green accent
    if (percentage >= 50) return const Color(0xFFFFD740); // amber
    return const Color(0xFFFF6D6D); // soft red
  }
}
