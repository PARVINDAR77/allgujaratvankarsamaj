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
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.remove_red_eye, color: Color(0xFFD4AF37), size: 16),
              const SizedBox(width: 6),
              Text(
                '$count Views',
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
