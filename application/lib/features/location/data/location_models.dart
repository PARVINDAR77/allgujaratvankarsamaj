class StateModel {
  final String id;
  final String name;
  final String? gujaratiName;
  final String code;

  StateModel({
    required this.id,
    required this.name,
    this.gujaratiName,
    required this.code,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      gujaratiName: json['gujaratiName'],
      code: json['code'] ?? '',
    );
  }
}

class DistrictModel {
  final String id;
  final String stateId;
  final String name;
  final String? gujaratiName;
  final String? code;

  DistrictModel({
    required this.id,
    required this.stateId,
    required this.name,
    this.gujaratiName,
    this.code,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id']?.toString() ?? '',
      stateId: json['stateId']?.toString() ?? '',
      name: json['name'] ?? '',
      gujaratiName: json['gujaratiName'],
      code: json['code'],
    );
  }
}

class TalukaModel {
  final String id;
  final String districtId;
  final String name;
  final String? gujaratiName;
  final String? code;

  TalukaModel({
    required this.id,
    required this.districtId,
    required this.name,
    this.gujaratiName,
    this.code,
  });

  factory TalukaModel.fromJson(Map<String, dynamic> json) {
    return TalukaModel(
      id: json['id']?.toString() ?? '',
      districtId: json['districtId']?.toString() ?? '',
      name: json['name'] ?? '',
      gujaratiName: json['gujaratiName'],
      code: json['code'],
    );
  }
}

class VillageModel {
  final String id;
  final String? parganaId;
  final String? talukaId;
  final String name;
  final String? gujaratiName;
  final String? pincode;

  VillageModel({
    required this.id,
    this.parganaId,
    this.talukaId,
    required this.name,
    this.gujaratiName,
    this.pincode,
  });

  factory VillageModel.fromJson(Map<String, dynamic> json) {
    return VillageModel(
      id: json['id']?.toString() ?? '',
      parganaId: json['parganaId'],
      talukaId: json['talukaId'],
      name: json['name'] ?? '',
      gujaratiName: json['gujaratiName'],
      pincode: json['pincode'],
    );
  }
}
