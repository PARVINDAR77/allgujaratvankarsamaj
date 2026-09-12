import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/api_config.dart';
import '../data/location_models.dart';

// States Provider
final statesProvider = FutureProvider<List<StateModel>>((ref) async {
  const apiConfig = ApiConfig();
  final dio = Dio();

  try {
    final response = await dio.get('${apiConfig.baseUrl}/locations/states').timeout(const Duration(seconds: 5));
    if (response.statusCode == 200 && response.data is List) {
      final List<dynamic> data = response.data;
      return data.map((j) => StateModel.fromJson(j)).toList();
    }
  } catch (_) {}

  return [
    StateModel(id: 'st-1', name: 'Gujarat', gujaratiName: 'ગુજરાત', code: 'GJ'),
  ];
});

// Districts Provider (Family/State filter)
final districtsProvider = FutureProvider.family<List<DistrictModel>, String?>((ref, stateId) async {
  const apiConfig = ApiConfig();
  final dio = Dio();

  try {
    final url = stateId != null && stateId.isNotEmpty
        ? '${apiConfig.baseUrl}/locations/districts?stateId=$stateId'
        : '${apiConfig.baseUrl}/locations/districts';
    final response = await dio.get(url).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200 && response.data is List) {
      final List<dynamic> data = response.data;
      return data.map((j) => DistrictModel.fromJson(j)).toList();
    }
  } catch (_) {}

  return [
    DistrictModel(id: 'dist-1', stateId: 'st-1', name: 'Sabarkantha', gujaratiName: 'સાબરકાંઠા', code: 'SK'),
    DistrictModel(id: 'dist-2', stateId: 'st-1', name: 'Mehsana', gujaratiName: 'મહેસાણા', code: 'MS'),
    DistrictModel(id: 'dist-3', stateId: 'st-1', name: 'Anand', gujaratiName: 'આણંદ', code: 'AN'),
  ];
});

// Talukas Provider (District filter)
final talukasProvider = FutureProvider.family<List<TalukaModel>, String?>((ref, districtId) async {
  const apiConfig = ApiConfig();
  final dio = Dio();

  try {
    final url = districtId != null && districtId.isNotEmpty
        ? '${apiConfig.baseUrl}/locations/talukas?districtId=$districtId'
        : '${apiConfig.baseUrl}/locations/talukas';
    final response = await dio.get(url).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200 && response.data is List) {
      final List<dynamic> data = response.data;
      return data.map((j) => TalukaModel.fromJson(j)).toList();
    }
  } catch (_) {}

  return [
    TalukaModel(id: 'tal-1', districtId: 'dist-1', name: 'Idar', gujaratiName: 'ઈડર', code: 'IDAR'),
  ];
});

// Villages Provider (Pargana/Taluka/Search filter)
final villagesProvider = FutureProvider.family<List<VillageModel>, ({String? parganaId, String? talukaId, String? search})>((ref, query) async {
  const apiConfig = ApiConfig();
  final dio = Dio();

  try {
    final queryParams = <String, String>{};
    if (query.parganaId != null && query.parganaId!.isNotEmpty) queryParams['parganaId'] = query.parganaId!;
    if (query.talukaId != null && query.talukaId!.isNotEmpty) queryParams['talukaId'] = query.talukaId!;
    if (query.search != null && query.search!.isNotEmpty) queryParams['search'] = query.search!;

    final Uri uri = Uri.parse('${apiConfig.baseUrl}/locations/villages').replace(queryParameters: queryParams);
    final response = await dio.get(uri.toString()).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200 && response.data is List) {
      final List<dynamic> data = response.data;
      return data.map((j) => VillageModel.fromJson(j)).toList();
    }
  } catch (_) {}

  return [
    VillageModel(id: 'vil-1', parganaId: 'pg-1', talukaId: 'tal-1', name: 'Vasan', gujaratiName: 'વાસણ', pincode: '383430'),
  ];
});
