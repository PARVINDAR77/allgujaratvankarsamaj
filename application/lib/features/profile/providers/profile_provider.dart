import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/config/api_config.dart';
import '../../../shared/providers/api_config_provider.dart';
import '../data/profile_api.dart';
import '../data/profile_models.dart';
import '../data/profile_repository.dart';

// ─── Status enum ────────────────────────────────────────────────────────────

enum ProfileStatus {
  initial,
  loading,
  loaded,
  empty,
  saving,
  deleting,
  error,
}

// ─── State class ────────────────────────────────────────────────────────────

class ProfileState {
  final ProfileStatus status;
  final MatrimonialProfileModel? profile;
  final CompletenessModel? completeness;
  final ReferenceDataModel? referenceData;
  final String? errorMessage;

  const ProfileState({
    required this.status,
    this.profile,
    this.completeness,
    this.referenceData,
    this.errorMessage,
  });

  factory ProfileState.initial() =>
      const ProfileState(status: ProfileStatus.initial);

  factory ProfileState.loading() =>
      const ProfileState(status: ProfileStatus.loading);

  factory ProfileState.empty({ReferenceDataModel? referenceData}) =>
      ProfileState(
          status: ProfileStatus.empty,
          referenceData: referenceData,
          completeness: CompletenessModel.zero());

  factory ProfileState.loaded({
    required MatrimonialProfileModel profile,
    CompletenessModel? completeness,
    ReferenceDataModel? referenceData,
  }) =>
      ProfileState(
        status: ProfileStatus.loaded,
        profile: profile,
        completeness: completeness,
        referenceData: referenceData,
      );

  factory ProfileState.saving({
    MatrimonialProfileModel? profile,
    ReferenceDataModel? referenceData,
    CompletenessModel? completeness,
  }) =>
      ProfileState(
        status: ProfileStatus.saving,
        profile: profile,
        referenceData: referenceData,
        completeness: completeness,
      );

  factory ProfileState.deleting({ReferenceDataModel? referenceData}) =>
      ProfileState(
          status: ProfileStatus.deleting, referenceData: referenceData);

  factory ProfileState.error(String message,
          {MatrimonialProfileModel? profile,
          ReferenceDataModel? referenceData,
          CompletenessModel? completeness}) =>
      ProfileState(
        status: ProfileStatus.error,
        errorMessage: message,
        profile: profile,
        referenceData: referenceData,
        completeness: completeness,
      );

  bool get isLoading => status == ProfileStatus.loading;
  bool get isLoaded => status == ProfileStatus.loaded;
  bool get isEmpty => status == ProfileStatus.empty;
  bool get isSaving => status == ProfileStatus.saving;
  bool get isDeleting => status == ProfileStatus.deleting;
  bool get hasError => status == ProfileStatus.error;

  ProfileState copyWith({
    ProfileStatus? status,
    MatrimonialProfileModel? profile,
    CompletenessModel? completeness,
    ReferenceDataModel? referenceData,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      completeness: completeness ?? this.completeness,
      referenceData: referenceData ?? this.referenceData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─── Providers ──────────────────────────────────────────────────────────────

final profileApiProvider = Provider<ProfileApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProfileApi(dioClient);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final api = ref.watch(profileApiProvider);
  return ProfileRepository(api: api);
});

// ─── Notifier ───────────────────────────────────────────────────────────────

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository repository;

  ProfileNotifier(this.repository) : super(ProfileState.initial());

  /// Loads the authenticated user's profile.
  /// Sets [ProfileStatus.empty] on 404 (no profile yet).
  Future<void> loadProfile() async {
    state = ProfileState.loading();
    try {
      // Load reference data alongside profile
      final refData = await repository.getReferenceData();
      try {
        final profile = await repository.getMyProfile();
        final completeness = await repository.getCompleteness();
        state = ProfileState.loaded(
          profile: profile,
          completeness: completeness,
          referenceData: refData,
        );
      } on ProfileNotFoundException {
        state = ProfileState.empty(referenceData: refData);
      }
    } catch (e) {
      state = ProfileState.error(_mapError(e));
    }
  }

  /// Creates a new matrimonial profile.
  /// If profile already exists (HTTP 409), falls back to updating the profile cleanly.
  Future<bool> createProfile(CreateProfileRequest request) async {
    final currentRefData = state.referenceData;
    state = ProfileState.saving(referenceData: currentRefData);
    try {
      final profile = await repository.createProfile(request);
      final completeness = await repository.getCompleteness();
      state = ProfileState.loaded(
        profile: profile,
        completeness: completeness,
        referenceData: currentRefData,
      );
      return true;
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('already exists') || errStr.contains('409')) {
        return await updateProfile(UpdateProfileRequest(
          firstName: request.firstName,
          lastName: request.lastName,
          dateOfBirth: request.dateOfBirth,
          gender: request.gender,
          maritalStatus: request.maritalStatus,
          religion: request.religion,
          caste: request.caste,
          city: request.city,
          state: request.state,
          country: request.country,
          education: request.education,
          occupation: request.occupation,
          about: request.about,
        ));
      }
      state = ProfileState.error(_mapError(e),
          referenceData: currentRefData,
          completeness: CompletenessModel.zero());
      return false;
    }
  }

  /// Updates the authenticated user's matrimonial profile.
  Future<bool> updateProfile(UpdateProfileRequest request) async {
    final currentProfile = state.profile;
    final currentRefData = state.referenceData;
    final currentCompleteness = state.completeness;
    state = ProfileState.saving(
      profile: currentProfile,
      referenceData: currentRefData,
      completeness: currentCompleteness,
    );
    try {
      final updated = await repository.updateProfile(request);
      final completeness = await repository.getCompleteness();
      state = ProfileState.loaded(
        profile: updated,
        completeness: completeness,
        referenceData: currentRefData,
      );
      return true;
    } catch (e) {
      state = ProfileState.error(_mapError(e),
          profile: currentProfile,
          referenceData: currentRefData,
          completeness: currentCompleteness);
      return false;
    }
  }

  /// Deletes the matrimonial profile.
  /// Does NOT log the user out. Sets state to [ProfileStatus.empty].
  Future<bool> deleteProfile() async {
    final currentRefData = state.referenceData;
    state = ProfileState.deleting(referenceData: currentRefData);
    try {
      await repository.deleteProfile();
      state = ProfileState.empty(referenceData: currentRefData);
      return true;
    } catch (e) {
      state = ProfileState.error(_mapError(e), referenceData: currentRefData);
      return false;
    }
  }

  String _mapError(Object e) {
    return e.toString().replaceAll('AppException: ', '').replaceAll('Exception: ', '');
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

// ─── Target Opposite Gender Filter System ─────────────────────────────────

/// Tracks the logged-in/registering user's gender ('MALE' or 'FEMALE').
class UserGenderNotifier extends StateNotifier<String> {
  UserGenderNotifier() : super('MALE'); // Default: Male user looking for Female

  void setUserGender(String gender) {
    final g = gender.toUpperCase().trim();
    if (g.contains('FEMALE') || g.contains('GIRL') || g.contains('BRIDE')) {
      state = 'FEMALE';
    } else {
      state = 'MALE';
    }
  }
}

final userGenderNotifierProvider =
    StateNotifierProvider<UserGenderNotifier, String>((ref) {
  return UserGenderNotifier();
});

/// Returns the target opposite gender to display across all application feeds:
/// - If current user is FEMALE (Girl) -> returns 'MALE' (Displays ONLY Boys Data)
/// - If current user is MALE (Boy) -> returns 'FEMALE' (Displays ONLY Girls Data)
final targetGenderProvider = Provider<String>((ref) {
  final selectedGender = ref.watch(userGenderNotifierProvider);
  final profileState = ref.watch(profileNotifierProvider);
  final profileGender = profileState.profile?.gender.toUpperCase() ?? '';

  final activeGender = profileGender.isNotEmpty ? profileGender : selectedGender;

  if (activeGender.contains('FEMALE') || activeGender.contains('GIRL') || activeGender.contains('BRIDE')) {
    return 'MALE'; // Girl logged in -> Show ONLY Boys data
  } else {
    return 'FEMALE'; // Boy logged in -> Show ONLY Girls data
  }
});

/// Returns the target looking for label ('Groom' for Boys, 'Bride' for Girls)
final targetLookingForLabelProvider = Provider<String>((ref) {
  final targetGender = ref.watch(targetGenderProvider);
  return targetGender == 'MALE' ? 'Groom' : 'Bride';
});

class SearchFilterState {
  final String lookingFor;
  final String maritalStatus;
  final String age;
  final String height;
  final String pargana;
  final String livingIn;
  final String education;
  final String diet;
  final String occupation;
  final String religion;
  final String yearlyIncome;
  final String motherTongue;
  final String familyType;
  final String keyword;

  const SearchFilterState({
    this.lookingFor = 'Bride',
    this.maritalStatus = 'Any',
    this.age = 'Any',
    this.height = 'Any',
    this.pargana = 'Any',
    this.livingIn = 'Any',
    this.education = 'Any',
    this.diet = 'Any',
    this.occupation = 'Any',
    this.religion = 'Any',
    this.yearlyIncome = 'Any',
    this.motherTongue = 'Any',
    this.familyType = 'Any',
    this.keyword = '',
  });

  SearchFilterState copyWith({
    String? lookingFor,
    String? maritalStatus,
    String? age,
    String? height,
    String? pargana,
    String? livingIn,
    String? education,
    String? diet,
    String? occupation,
    String? religion,
    String? yearlyIncome,
    String? motherTongue,
    String? familyType,
    String? keyword,
  }) {
    return SearchFilterState(
      lookingFor: lookingFor ?? this.lookingFor,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      age: age ?? this.age,
      height: height ?? this.height,
      pargana: pargana ?? this.pargana,
      livingIn: livingIn ?? this.livingIn,
      education: education ?? this.education,
      diet: diet ?? this.diet,
      occupation: occupation ?? this.occupation,
      religion: religion ?? this.religion,
      yearlyIncome: yearlyIncome ?? this.yearlyIncome,
      motherTongue: motherTongue ?? this.motherTongue,
      familyType: familyType ?? this.familyType,
      keyword: keyword ?? this.keyword,
    );
  }
}

class SearchFilterNotifier extends StateNotifier<SearchFilterState> {
  SearchFilterNotifier() : super(const SearchFilterState());

  void setFilter(SearchFilterState filter) {
    state = filter;
  }

  void reset(String defaultLookingFor) {
    state = SearchFilterState(lookingFor: defaultLookingFor);
  }
}

final searchFilterProvider =
    StateNotifierProvider<SearchFilterNotifier, SearchFilterState>((ref) {
  return SearchFilterNotifier();
});

/// Fetches candidate profiles dynamically from the backend live API database endpoint `POST /api/v1/profile/search-query`
final liveCandidateProfilesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final filter = ref.watch(searchFilterProvider);
  final targetLookingFor = ref.watch(targetLookingForLabelProvider);

  final lookingFor = filter.lookingFor.isNotEmpty ? filter.lookingFor : targetLookingFor;

  const apiConfig = ApiConfig();
  final dio = Dio();

  try {
    final response = await dio.post(
      '${apiConfig.baseUrl}/profile/search-query',
      data: {
        'lookingFor': lookingFor,
        'maritalStatus': filter.maritalStatus,
        'city': filter.livingIn,
        'education': filter.education,
        'occupation': filter.occupation,
        'keyword': filter.keyword,
      },
    ).timeout(const Duration(seconds: 4));

    if (response.statusCode == 200 && response.data is List) {
      final List<dynamic> data = response.data;
      return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
  } catch (_) {
    // Graceful fallback to local seed data if backend API is unreachable
  }

  return [];
});

