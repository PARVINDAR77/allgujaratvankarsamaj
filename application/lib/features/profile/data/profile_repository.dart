import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/models/profile_model.dart';
import '../../../shared/models/profile_query_model.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<({List<ProfileModel> items, Map<String, dynamic> meta})> fetchProfiles([ProfileQueryModel? query]) async {
    try {
      final response = await _dio.get('/profiles', queryParameters: query?.toJson());
      
      final data = response.data['items'] as List<dynamic>;
      final meta = response.data['meta'] as Map<String, dynamic>;
      final items = data.map((json) => ProfileModel.fromJson(json)).toList();
      return (items: items, meta: meta);
    } catch (e) {
      throw Exception('Failed to fetch profiles');
    }
  }

  Future<ProfileModel> fetchMyProfile() async {
    try {
      final response = await _dio.get('/profiles/me');
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch my profile');
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(dioProvider));
});
