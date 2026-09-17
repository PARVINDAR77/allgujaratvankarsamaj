class DirectoryDistrict {
  final String id;
  final String nameEn;
  final String nameGu;
  final int sortOrder;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DirectoryDistrict({
    required this.id,
    required this.nameEn,
    required this.nameGu,
    required this.sortOrder,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory DirectoryDistrict.fromJson(Map<String, dynamic> json) {
    return DirectoryDistrict(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameGu: json['nameGu'] as String,
      sortOrder: json['sortOrder'] as int,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }
}

class DirectoryPargana {
  final String id;
  final String districtId;
  final String nameEn;
  final String nameGu;
  final String type;
  final String? areaDescriptionEn;
  final String? areaDescriptionGu;
  final int? sortOrder;
  final bool? isActive;

  const DirectoryPargana({
    required this.id,
    required this.districtId,
    required this.nameEn,
    required this.nameGu,
    required this.type,
    this.areaDescriptionEn,
    this.areaDescriptionGu,
    this.sortOrder,
    this.isActive,
  });

  factory DirectoryPargana.fromJson(Map<String, dynamic> json) {
    return DirectoryPargana(
      id: json['id'] as String,
      districtId: json['districtId'] as String,
      nameEn: json['nameEn'] as String,
      nameGu: json['nameGu'] as String,
      type: json['type'] as String,
      areaDescriptionEn: json['areaDescriptionEn'] as String?,
      areaDescriptionGu: json['areaDescriptionGu'] as String?,
      sortOrder: json['sortOrder'] as int?,
      isActive: json['isActive'] as bool?,
    );
  }
}

class DirectoryTaluka {
  final String id;
  final String districtId;
  final String nameEn;
  final String nameGu;
  final int sortOrder;
  final bool? isActive;

  const DirectoryTaluka({
    required this.id,
    required this.districtId,
    required this.nameEn,
    required this.nameGu,
    required this.sortOrder,
    this.isActive,
  });

  factory DirectoryTaluka.fromJson(Map<String, dynamic> json) {
    return DirectoryTaluka(
      id: json['id'] as String,
      districtId: json['districtId'] as String,
      nameEn: json['nameEn'] as String,
      nameGu: json['nameGu'] as String,
      sortOrder: json['sortOrder'] as int,
      isActive: json['isActive'] as bool?,
    );
  }
}

class DirectoryLocation {
  final String id;
  final String districtId;
  final String talukaId;
  final String nameEn;
  final String nameGu;
  final String type;
  final int? sortOrder;
  final bool? isActive;

  const DirectoryLocation({
    required this.id,
    required this.districtId,
    required this.talukaId,
    required this.nameEn,
    required this.nameGu,
    required this.type,
    this.sortOrder,
    this.isActive,
  });

  factory DirectoryLocation.fromJson(Map<String, dynamic> json) {
    return DirectoryLocation(
      id: json['id'] as String,
      districtId: json['districtId'] as String,
      talukaId: json['talukaId'] as String,
      nameEn: json['nameEn'] as String,
      nameGu: json['nameGu'] as String,
      type: json['type'] as String,
      sortOrder: json['sortOrder'] as int?,
      isActive: json['isActive'] as bool?,
    );
  }
}
