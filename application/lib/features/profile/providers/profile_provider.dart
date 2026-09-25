import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/profile_model.dart';
import '../data/profile_repository.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<List<ProfileModel>>> {
  final ProfileRepository repository;

  ProfileNotifier(this.repository) : super(const AsyncValue.loading()) {
    fetchProfiles();
  }

  Future<void> fetchProfiles() async {
    state = const AsyncValue.loading();
    try {
      final result = await repository.fetchProfiles();
      state = AsyncValue.data(result.items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addProfile(ProfileModel profile) {
    if (state.hasValue) {
      state = AsyncValue.data([profile, ...state.value!]);
    }
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<List<ProfileModel>>>((ref) {
  return ProfileNotifier(ref.watch(profileRepositoryProvider));
});
