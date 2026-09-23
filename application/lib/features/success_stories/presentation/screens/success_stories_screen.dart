import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/success_story_model.dart';
import '../../../success_stories/providers/success_stories_provider.dart';

class SuccessStoriesScreen extends ConsumerWidget {
  const SuccessStoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(successStoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Success Stories (સફળ દાંપત્ય)',
          style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.secondary),
        centerTitle: true,
      ),
      body: SafeArea(
        child: storiesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          ),
          error: (err, _) => _buildError(context, ref, err),
          data: (stories) => stories.isEmpty
              ? _buildEmpty()
              : _buildList(stories),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: AppColors.accentRed, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load stories.\n$err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(successStoriesProvider),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.black),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, color: AppColors.secondary, size: 56),
            SizedBox(height: 16),
            Text(
              'No success stories yet.\nCheck back soon!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<SuccessStoryModel> stories) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stories.length,
      itemBuilder: (context, index) => _StoryCard(story: stories[index]),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final SuccessStoryModel story;
  const _StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo (if available)
          if (story.imageUrl != null && story.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                story.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: const Color(0xFF1A1A1A),
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.white38, size: 40),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Couple names
                Row(
                  children: [
                    const Icon(Icons.favorite,
                        color: AppColors.secondary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${story.brideName} & ${story.groomName}',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (story.weddingDate != null &&
                    story.weddingDate!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.white54, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        story.weddingDate!,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  story.story,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
