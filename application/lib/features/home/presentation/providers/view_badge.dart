import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views_provider.dart';

class ViewBadge extends ConsumerWidget {
  final String sectionName;
  final bool isLight;
  const ViewBadge({super.key, required this.sectionName, this.isLight = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewsAsync = ref.watch(viewsProvider);
    return viewsAsync.when(
      data: (views) {
        final count = views[sectionName] ?? 0;
        return _buildBadge(count);
      },
      loading: () => _buildBadge(0, isLoading: true),
      error: (_, _) => _buildBadge(0),
    );
  }

  Widget _buildBadge(int count, {bool isLoading = false}) {
    final primaryColor = isLight ? const Color(0xFFB45309) : const Color(0xFFD4AF37);
    final bgColor = isLight ? const Color(0xFFFEF3C7) : Colors.black.withValues(alpha: 0.6);
    final borderColor = isLight ? const Color(0xFFFCD34D) : const Color(0xFFD4AF37).withValues(alpha: isLoading ? 0.5 : 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.remove_red_eye_rounded, color: primaryColor.withValues(alpha: isLoading ? 0.5 : 1.0), size: 13),
          const SizedBox(width: 4),
          Text(
            isLoading ? '...' : '$count Views',
            style: TextStyle(color: primaryColor.withValues(alpha: isLoading ? 0.5 : 1.0), fontSize: 10.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
