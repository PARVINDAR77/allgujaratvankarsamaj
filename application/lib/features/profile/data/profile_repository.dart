import '../../../core/errors/app_exception.dart';
import 'profile_api.dart';
import 'profile_models.dart';

/// Exception indicating the authenticated user has no matrimonial profile yet.
/// This is NOT an authentication error — it is a 404 from /profile/me.
class ProfileNotFoundException extends AppException {
  const ProfileNotFoundException([String message = 'Profile not found'])
      : super(message, 404);
}

/// Repository orchestrating ProfileApi calls and error mapping.
class ProfileRepository {
  final ProfileApi api;

  ProfileRepository({required this.api});

  /// Fetches the authenticated user's profile.
  /// Returns [MatrimonialProfileModel] on success.
  /// Throws [ProfileNotFoundException] when the user has no profile (404).
  /// Throws [AppException] for other errors (401, 500, network failures).
  Future<MatrimonialProfileModel> getMyProfile() async {
    try {
      return await api.getMyProfile();
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        throw const ProfileNotFoundException();
      }
      rethrow;
    }
  }

  /// Creates a new matrimonial profile.
  Future<MatrimonialProfileModel> createProfile(
      CreateProfileRequest request) async {
    return await api.createProfile(request);
  }

  /// Updates the authenticated user's profile (PATCH).
  Future<MatrimonialProfileModel> updateProfile(
      UpdateProfileRequest request) async {
    return await api.updateProfile(request);
  }

  /// Deletes the authenticated user's matrimonial profile.
  /// Does NOT delete the user account or invalidate the session.
  Future<void> deleteProfile() async {
    return await api.deleteProfile();
  }

  /// Loads reference data (gender & maritalStatus options).
  Future<ReferenceDataModel> getReferenceData() async {
    return await api.getReferenceData();
  }

  /// Loads profile completeness statistics.
  Future<CompletenessModel> getCompleteness() async {
    return await api.getCompleteness();
  }
}
