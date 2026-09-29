import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/profile_model.dart';
import '../../../shared/models/profile_query_model.dart';
import '../../profile/data/profile_repository.dart';

class UniversalListingState {
  final ProfileQueryModel query;
  final List<ProfileModel> profiles;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String? error;

  const UniversalListingState({
    required this.query,
    this.profiles = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.error,
  });

  UniversalListingState copyWith({
    ProfileQueryModel? query,
    List<ProfileModel>? profiles,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? error,
    bool clearError = false,
  }) {
    return UniversalListingState(
      query: query ?? this.query,
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class UniversalListingNotifier extends StateNotifier<UniversalListingState> {
  final ProfileRepository _repository;

  UniversalListingNotifier(
    this._repository,
    ProfileQueryModel initialQuery,
  ) : super(UniversalListingState(query: initialQuery, isLoading: true)) {
    _fetchInitial();
  }

  Future<void> _fetchInitial() async {
    try {
      final result = await _repository.fetchProfiles(state.query);
      
      final totalPages = result.meta['totalPages'] as int? ?? 1;
      
      state = state.copyWith(
        profiles: result.items,
        isLoading: false,
        hasReachedMax: state.query.page >= totalPages,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedMax) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextQuery = state.query.copyWith(page: state.query.page + 1);
      final result = await _repository.fetchProfiles(nextQuery);
      
      final totalPages = result.meta['totalPages'] as int? ?? 1;
      
      // Merge unique profiles based on ID to avoid duplicates if backend shifts
      final existingIds = state.profiles.map((e) => e.id).toSet();
      final newUniqueProfiles = result.items.where((p) => !existingIds.contains(p.id)).toList();

      state = state.copyWith(
        query: nextQuery,
        profiles: [...state.profiles, ...newUniqueProfiles],
        isLoadingMore: false,
        hasReachedMax: nextQuery.page >= totalPages,
        clearError: true,
      );
    } catch (e) {
      // Failed to load more, but keep existing profiles!
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  void updateQuery(ProfileQueryModel newQuery) {
    // Reset pagination to page 1
    final resetQuery = newQuery.copyWith(page: 1);
    state = UniversalListingState(
      query: resetQuery,
      isLoading: true,
    );
    _fetchInitial();
  }
}

final universalListingProvider = StateNotifierProvider.family<UniversalListingNotifier, UniversalListingState, ProfileQueryModel>((ref, initialQuery) {
  final repository = ref.watch(profileRepositoryProvider);
  return UniversalListingNotifier(repository, initialQuery);
});
