import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/profile_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_failure.dart';
import '../../../shared/models/pagination_meta.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/datasources/profile_remote_data_source.dart';
import '../data/repositories/profile_repository.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final dio = ref.watch(apiClientProvider);
  return ProfileRemoteDataSource(dio);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remote = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepository(remote);
});

class ProfileState {
  final bool isLoading;
  final bool isLoadingNextPage;
  final List<ProfileModel> profiles;
  final PaginationMeta? meta;
  final ApiFailure? error;

  ProfileState({
    this.isLoading = false,
    this.isLoadingNextPage = false,
    this.profiles = const [],
    this.meta,
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isLoadingNextPage,
    List<ProfileModel>? profiles,
    PaginationMeta? meta,
    ApiFailure? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
      profiles: profiles ?? this.profiles,
      meta: meta ?? this.meta,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  // Filter states
  String? _searchQuery;
  String? _gender;
  String? _status;
  int? _minAge;
  int? _maxAge;
  String? _districtId;
  String? _occupationCategory;

  ProfileNotifier(this._repository) : super(ProfileState(isLoading: true)) {
    Future.microtask(() => fetchFirstPage());
  }

  void updateFilters({
    String? search,
    String? gender,
    String? status,
    int? minAge,
    int? maxAge,
    String? districtId,
    String? occupationCategory,
  }) {
    _searchQuery = search;
    _gender = gender;
    _status = status;
    _minAge = minAge;
    _maxAge = maxAge;
    _districtId = districtId;
    _occupationCategory = occupationCategory;
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.getProfiles(
        page: 1,
        limit: 20,
        search: _searchQuery,
        gender: _gender,
        status: _status,
        minAge: _minAge,
        maxAge: _maxAge,
        districtId: _districtId,
        occupationCategory: _occupationCategory,
      );
      state = state.copyWith(
        isLoading: false,
        profiles: result.profiles,
        meta: result.meta,
      );
    } on ApiFailure catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiFailure(type: ApiFailureType.unknown, message: e.toString()),
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || state.isLoadingNextPage || state.meta == null || !state.meta!.hasNextPage) {
      return;
    }
    
    state = state.copyWith(isLoadingNextPage: true, error: null);
    try {
      final nextPage = state.meta!.page + 1;
      final result = await _repository.getProfiles(
        page: nextPage,
        limit: state.meta!.limit,
        search: _searchQuery,
        gender: _gender,
        status: _status,
        minAge: _minAge,
        maxAge: _maxAge,
        districtId: _districtId,
        occupationCategory: _occupationCategory,
      );
      state = state.copyWith(
        isLoadingNextPage: false,
        profiles: [...state.profiles, ...result.profiles],
        meta: result.meta,
      );
    } on ApiFailure catch (e) {
      state = state.copyWith(isLoadingNextPage: false, error: e);
    } catch (e) {
      state = state.copyWith(
        isLoadingNextPage: false,
        error: ApiFailure(type: ApiFailureType.unknown, message: e.toString()),
      );
    }
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

final myProfileProvider = FutureProvider<ProfileModel>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  if (!authState.isAuthenticated) {
    throw const ApiFailure(type: ApiFailureType.unauthorized, message: 'Not authenticated');
  }
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getMyProfile();
});

final profileCompletenessProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getProfileCompleteness();
});
