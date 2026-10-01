import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views_provider.dart';

class ViewBadge extends ConsumerWidget {
  final String sectionName;
  const ViewBadge({Key? key, required this.sectionName}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewsAsync = ref.watch(viewsProvider);
    return viewsAsync.when(
      data: (views) {
        final count = views[sectionName] ?? 0;
        return _buildBadge(count);
      },
      loading: () => _buildBadge(0, isLoading: true),
      error: (_, __) => _buildBadge(0),
    );
  }

  Widget _buildBadge(int count, {bool isLoading = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(isLoading ? 0.5 : 1.0), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.remove_red_eye, color: const Color(0xFFD4AF37).withOpacity(isLoading ? 0.5 : 1.0), size: 12),
          const SizedBox(width: 4),
          Text(
            isLoading ? '...' : '$count Views',
            style: TextStyle(color: const Color(0xFFD4AF37).withOpacity(isLoading ? 0.5 : 1.0), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
