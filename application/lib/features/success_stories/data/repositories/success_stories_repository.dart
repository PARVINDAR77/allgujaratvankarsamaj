import '../../../../shared/models/success_story_model.dart';
import '../datasources/success_stories_remote_data_source.dart';

class SuccessStoriesRepository {
  final SuccessStoriesRemoteDataSource _remote;

  SuccessStoriesRepository(this._remote);

  Future<List<SuccessStoryModel>> getPublicStories() async {
    final items = await _remote.getPublicStories();
    return items.map(SuccessStoryModel.fromJson).toList();
  }
}
