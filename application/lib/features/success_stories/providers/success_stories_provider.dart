import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/success_story_model.dart';
import '../../../core/network/api_client.dart';
import '../data/datasources/success_stories_remote_data_source.dart';
import '../data/repositories/success_stories_repository.dart';

final successStoriesRemoteDataSourceProvider =
    Provider<SuccessStoriesRemoteDataSource>((ref) {
  return SuccessStoriesRemoteDataSource(ref.watch(apiClientProvider));
});

final successStoriesRepositoryProvider =
    Provider<SuccessStoriesRepository>((ref) {
  return SuccessStoriesRepository(
      ref.watch(successStoriesRemoteDataSourceProvider));
});

/// Public FutureProvider — GET /success-stories (no auth).
/// Returns only published stories; backend filters them.
final successStoriesProvider =
    FutureProvider<List<SuccessStoryModel>>((ref) async {
  return ref.watch(successStoriesRepositoryProvider).getPublicStories();
});
