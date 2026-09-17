import 'package:application/shared/models/directory_models.dart';

/// Temporary mock repository for Directory API.
/// This will be replaced by HTTP calls to the NestJS backend.
class DirectoryRepository {
  // All 13 extracted regions
  final List<DirectoryDistrict> _mockDistricts = [
    const DirectoryDistrict(id: 'd1', nameEn: 'Ahmedabad / Gandhinagar', nameGu: 'અમદાવાદ / ગાંધીનગર', sortOrder: 1),
    const DirectoryDistrict(id: 'd2', nameEn: 'Surat / Valsad', nameGu: 'સુરત / વલસાડ', sortOrder: 2),
    const DirectoryDistrict(id: 'd3', nameEn: 'Bharuch', nameGu: 'ભરૂચ', sortOrder: 3),
    const DirectoryDistrict(id: 'd4', nameEn: 'Vadodara', nameGu: 'વડોદરા', sortOrder: 4),
    const DirectoryDistrict(id: 'd5', nameEn: 'Anand / Kheda / Mahisagar', nameGu: 'આણંદ / ખેડા / મહિસાગર', sortOrder: 5),
    const DirectoryDistrict(id: 'd6', nameEn: 'Mehsana / Patan / Visnagar', nameGu: 'મહેસાણા / પાટણ / વિસનગર', sortOrder: 6),
    const DirectoryDistrict(id: 'd7', nameEn: 'Sabarkantha', nameGu: 'સાબરકાંઠા', sortOrder: 7),
    const DirectoryDistrict(id: 'd8', nameEn: 'Surendranagar', nameGu: 'સુરેન્દ્રનગર', sortOrder: 8),
    const DirectoryDistrict(id: 'd9', nameEn: 'Banaskantha', nameGu: 'બનાસકાંઠા', sortOrder: 9),
    const DirectoryDistrict(id: 'd10', nameEn: 'Bhavnagar', nameGu: 'ભાવનગર', sortOrder: 10),
    const DirectoryDistrict(id: 'd11', nameEn: 'Amreli / Saurashtra', nameGu: 'અમરેલી / સૌરાષ્ટ્ર', sortOrder: 11),
    const DirectoryDistrict(id: 'd12', nameEn: 'Jamnagar', nameGu: 'જામનગર', sortOrder: 12),
    const DirectoryDistrict(id: 'd13', nameEn: 'Kutch', nameGu: 'કચ્છ', sortOrder: 13),
  ];

  final List<DirectoryPargana> _mockParganas = [
    // Ahmedabad
    const DirectoryPargana(id: 'p1_1', districtId: 'd1', nameEn: '', nameGu: 'બાવન (52) ગામ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'બારેજડી, વટવા, ઈસનપુર અને આસપાસ'),
    const DirectoryPargana(id: 'p1_2', districtId: 'd1', nameEn: '', nameGu: 'મોટી દશકોશી', type: 'SAMAJ', areaDescriptionGu: 'જેટલપુર, વટવા, બારેજડી'),
    const DirectoryPargana(id: 'p1_3', districtId: 'd1', nameEn: '', nameGu: 'નાની દશકોશી', type: 'SAMAJ', areaDescriptionGu: 'ઓઢવથી કુહાગામ વિસ્તાર'),
    const DirectoryPargana(id: 'p1_4', districtId: 'd1', nameEn: '', nameGu: 'દશકોશી ગામ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'સરખેજ રોડ અને દશકોશી તાલુકો'),
    const DirectoryPargana(id: 'p1_5', districtId: 'd1', nameEn: '', nameGu: 'નળકાંઠા વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'સાણંદ, વિરમગામ, લખતર વિસ્તાર'),
    const DirectoryPargana(id: 'p1_6', districtId: 'd1', nameEn: '', nameGu: 'મૂળગામી વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'અમદાવાદ શહેર અને ગાંધીનગર'),
    const DirectoryPargana(id: 'p1_7', districtId: 'd1', nameEn: '', nameGu: 'હવેલી પરગણા', type: 'PARGANA', areaDescriptionGu: 'અમદાવાદ શહેર અને ગાંધીનગર'),
    // Surat
    const DirectoryPargana(id: 'p2_1', districtId: 'd2', nameEn: '', nameGu: 'સુરત પરજીયા માયાવંશી સમાજ', type: 'SAMAJ', areaDescriptionGu: 'સુરત શહેર, નવસારી, વલસાડ'),
    const DirectoryPargana(id: 'p2_2', districtId: 'd2', nameEn: '', nameGu: 'માયાવંશી સમાજ', type: 'SAMAJ', areaDescriptionGu: 'સુરત જીલ્લાના કેટલાંક ગામો'),
    // Bharuch
    const DirectoryPargana(id: 'p3_1', districtId: 'd3', nameEn: '', nameGu: 'દેશી વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'ભરુચ જીલ્લો'),
    const DirectoryPargana(id: 'p3_2', districtId: 'd3', nameEn: '', nameGu: 'ચરોતર વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'ઓડ, ઉમરેઠ, નડિયાદ, આણંદ તાલુકાના કેટલાક ગામો'),
    // Vadodara
    const DirectoryPargana(id: 'p4_1', districtId: 'd4', nameEn: '', nameGu: 'વણકર પરગણું', type: 'PARGANA', areaDescriptionGu: 'પાદરા તાલુકો'),
    const DirectoryPargana(id: 'p4_2', districtId: 'd4', nameEn: '', nameGu: 'કાનમ પરગણું', type: 'PARGANA', areaDescriptionGu: 'કરજણ તાલુકો'),
    // Bhavnagar
    const DirectoryPargana(id: 'p10_1', districtId: 'd10', nameEn: '', nameGu: 'ગોહિલવાડ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'ભાવનગર શહેર'),
    const DirectoryPargana(id: 'p10_2', districtId: 'd10', nameEn: '', nameGu: 'વાણાંક પરગણું', type: 'PARGANA', areaDescriptionGu: 'મહુવા, સાવરકુંડલા, તળાજા અને અમરેલીનાં ગામો'),
    // Jamnagar
    const DirectoryPargana(id: 'p12_1', districtId: 'd12', nameEn: '', nameGu: 'મેઘવાળ વણકર સમાજ', type: 'SAMAJ', areaDescriptionGu: 'જામનગર જીલ્લાનાં ગામો'),
    // (Other parganas will be added sequentially, this is just to fill out the UI properly for now)
  ];

  final List<DirectoryTaluka> _mockTalukas = [
    const DirectoryTaluka(id: 't1', districtId: 'd1', nameEn: 'Ahmedabad City', nameGu: 'અમદાવાદ શહેર', sortOrder: 1),
    const DirectoryTaluka(id: 't2', districtId: 'd1', nameEn: 'Daskroi', nameGu: 'દસક્રોઇ', sortOrder: 2),
  ];

  final List<DirectoryLocation> _mockLocations = [
    const DirectoryLocation(id: 'l1', districtId: 'd1', talukaId: 't1', nameEn: 'Ahmedabad', nameGu: 'અમદાવાદ', type: 'CITY'),
  ];

  /// GET /directory/districts
  Future<List<DirectoryDistrict>> getDistricts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockDistricts;
  }

  /// GET /directory/districts/:districtId/parganas
  Future<List<DirectoryPargana>> getParganasByDistrict(String districtId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockParganas.where((p) => p.districtId == districtId).toList();
  }

  /// GET /directory/locations/districts
  Future<List<DirectoryDistrict>> getLocationDistricts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockDistricts; // Using same mock data for now
  }

  /// GET /directory/locations/districts/:districtId/talukas
  Future<List<DirectoryTaluka>> getTalukasByDistrict(String districtId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockTalukas.where((t) => t.districtId == districtId).toList();
  }

  /// GET /directory/locations/talukas/:talukaId/villages
  Future<List<DirectoryLocation>> getVillagesByTaluka(String talukaId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockLocations.where((l) => l.talukaId == talukaId).toList();
  }
}
