import 'package:dio/dio.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../../core/network/api_failure.dart';
import '../../../../shared/models/pagination_meta.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepository(this._remoteDataSource);

  Future<Map<String, List<String>>> getReferenceData() async {
    final data = await _remoteDataSource.getReferenceData();
    return {
      'gender': (data['gender'] as List?)?.map((e) => e.toString()).toList() ?? [],
      'maritalStatus': (data['maritalStatus'] as List?)?.map((e) => e.toString()).toList() ?? [],
    };
  }

  Future<({List<ProfileModel> profiles, PaginationMeta meta})> getProfiles({
    int page = 1,
    int limit = 20,
    String? search,
    String? gender,
    String? status,
    int? minAge,
    int? maxAge,
    String? districtId,
    String? occupationCategory,
  }) async {
    final data = await _remoteDataSource.getProfiles(
      page: page,
      limit: limit,
      search: search,
      gender: gender,
      status: status,
      minAge: minAge,
      maxAge: maxAge,
      districtId: districtId,
      occupationCategory: occupationCategory,
    );

    final items = (data['items'] as List?) ?? [];
    final profiles = items.map((e) => ProfileModel.fromJson(e)).toList();
    final meta = PaginationMeta.fromJson(data['meta'] ?? {});

    return (profiles: profiles, meta: meta);
  }

  Future<ProfileModel> getMyProfile() async {
    try {
      final data = await _remoteDataSource.getMyProfile();
      return ProfileModel.fromJson(data);
    } on ApiFailure catch (e) {
      if (e.statusCode == 404) {
        return const ProfileModel(
          id: 'NEW',
          firstName: '',
          lastName: '',
          gender: 'Male (પુરુષ)',
          maritalStatus: 'Never Married (અપરિણીત)',
          dateOfBirth: '',
          education: 'Select Degree',
          employmentType: 'Government Sector (સરકારી નોકરી / સેકટર)',
          department: 'State Government (રાજ્ય સરકાર)',
          designation: '',
          district: '',
          taluka: '',
          pargana: '',
        );
      }
      rethrow;
    }
  }

  Future<ProfileModel> createProfile(ProfileModel profile) async {
    final data = await _remoteDataSource.createProfile(profile.toJson());
    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel> updateMyProfile(Map<String, dynamic> updateData) async {
    final data = await _remoteDataSource.updateMyProfile(updateData);
    return ProfileModel.fromJson(data);
  }

  Future<Map<String, dynamic>> getProfileCompleteness() async {
    return await _remoteDataSource.getProfileCompleteness();
  }
}
