import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/constants/app_data.dart';

class MasterDataState {
  final Map<String, List<String>> gujaratDistricts;
  final List<String> educationDegrees;
  final List<String> abroadCountries;
  final List<String> privateSectors;
  final List<String> businessSectors;
  final List<String> incomeRanges;
  final List<String> religionOptions;
  final bool isLoading;

  MasterDataState({
    required this.gujaratDistricts,
    required this.educationDegrees,
    required this.abroadCountries,
    required this.privateSectors,
    required this.businessSectors,
    required this.incomeRanges,
    required this.religionOptions,
    this.isLoading = false,
  });

  factory MasterDataState.initial() {
    return MasterDataState(
      gujaratDistricts: AppData.gujaratDistricts,
      educationDegrees: AppData.educationDegrees,
      abroadCountries: AppData.abroadCountries,
      privateSectors: AppData.privateSectors,
      businessSectors: AppData.businessSectors,
      incomeRanges: AppData.incomeRanges,
      religionOptions: AppData.religionOptions,
      isLoading: true,
    );
  }
}

class MasterDataNotifier extends StateNotifier<MasterDataState> {
  final Dio _dio;

  MasterDataNotifier(this._dio) : super(MasterDataState.initial()) {
    _fetchMasterData();
  }

  Future<void> _fetchMasterData() async {
    try {
      final response = await _dio.get('/master-data');
      final data = response.data as Map<String, dynamic>;
      
      Map<String, List<String>> districts = {};
      if (data['gujaratDistricts'] != null) {
        final rawDistricts = data['gujaratDistricts'] as Map<String, dynamic>;
        rawDistricts.forEach((key, value) {
          districts[key] = (value as List).map((e) => e.toString()).toList();
        });
      }

      state = MasterDataState(
        gujaratDistricts: districts.isNotEmpty ? districts : state.gujaratDistricts,
        educationDegrees: _parseList(data['educationDegrees']) ?? state.educationDegrees,
        abroadCountries: (_parseList(data['abroadCountries']) != null && _parseList(data['abroadCountries'])!.length > 50)
            ? _parseList(data['abroadCountries'])!
            : AppData.abroadCountries,
        privateSectors: _parseList(data['privateSectors']) ?? state.privateSectors,
        businessSectors: _parseList(data['businessSectors']) ?? state.businessSectors,
        incomeRanges: _parseList(data['incomeRanges']) ?? state.incomeRanges,
        religionOptions: _parseList(data['religionOptions']) ?? state.religionOptions,
        isLoading: false,
      );
    } catch (e) {
      state = MasterDataState(
        gujaratDistricts: state.gujaratDistricts,
        educationDegrees: state.educationDegrees,
        abroadCountries: state.abroadCountries,
        privateSectors: state.privateSectors,
        businessSectors: state.businessSectors,
        incomeRanges: state.incomeRanges,
        religionOptions: state.religionOptions,
        isLoading: false,
      );
    }
  }

  List<String>? _parseList(dynamic listData) {
    if (listData == null || listData is! List) return null;
    return listData.map((e) => e.toString()).toList();
  }
}

final masterDataProvider = StateNotifierProvider<MasterDataNotifier, MasterDataState>((ref) {
  return MasterDataNotifier(ref.watch(apiClientProvider));
});
