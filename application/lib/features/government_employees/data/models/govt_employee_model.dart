class GovtEmployeeModel {
  final String id;
  final String profileId;
  final String fullName;
  final String gender;
  final int? age;
  final String education;
  final String maritalStatus;
  final String? photoUrl;
  final String? districtName;
  final String? talukaName;
  final String employmentType;
  final String departmentName;
  final String departmentGujaratiName;
  final String designationName;
  final String designationGujaratiName;
  final String? officeLocation;
  final int? joiningYear;
  final bool isVerified;
  final bool isFeatured;

  GovtEmployeeModel({
    required this.id,
    required this.profileId,
    required this.fullName,
    required this.gender,
    this.age,
    required this.education,
    required this.maritalStatus,
    this.photoUrl,
    this.districtName,
    this.talukaName,
    required this.employmentType,
    required this.departmentName,
    required this.departmentGujaratiName,
    required this.designationName,
    required this.designationGujaratiName,
    this.officeLocation,
    this.joiningYear,
    required this.isVerified,
    required this.isFeatured,
  });

  factory GovtEmployeeModel.fromJson(Map<String, dynamic> json) {
    return GovtEmployeeModel(
      id: json['id']?.toString() ?? '',
      profileId: json['profileId']?.toString() ?? '',
      fullName: json['fullName'] ?? 'Vankar Member',
      gender: json['gender'] ?? 'MALE',
      age: json['age'] is int ? json['age'] : int.tryParse(json['age']?.toString() ?? ''),
      education: json['education'] ?? 'Graduate',
      maritalStatus: json['maritalStatus'] ?? 'NEVER_MARRIED',
      photoUrl: json['photoUrl'],
      districtName: json['districtName'],
      talukaName: json['talukaName'],
      employmentType: json['employmentType'] ?? 'STATE_GOVT',
      departmentName: json['departmentName'] ?? 'Government Department',
      departmentGujaratiName: json['departmentGujaratiName'] ?? 'સરકારી વિભાગ',
      designationName: json['designationName'] ?? 'Officer / Employee',
      designationGujaratiName: json['designationGujaratiName'] ?? 'સરકારી કર્મચારી',
      officeLocation: json['officeLocation'],
      joiningYear: json['joiningYear'] is int ? json['joiningYear'] : int.tryParse(json['joiningYear']?.toString() ?? ''),
      isVerified: json['isVerified'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
    );
  }
}

class GovtDepartmentModel {
  final String id;
  final String name;
  final String? gujaratiName;
  final String? code;
  final List<GovtDesignationModel> designations;

  GovtDepartmentModel({
    required this.id,
    required this.name,
    this.gujaratiName,
    this.code,
    required this.designations,
  });

  factory GovtDepartmentModel.fromJson(Map<String, dynamic> json) {
    var rawDesigs = json['designations'] as List? ?? [];
    return GovtDepartmentModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      gujaratiName: json['gujaratiName'],
      code: json['code'],
      designations: rawDesigs.map((d) => GovtDesignationModel.fromJson(d)).toList(),
    );
  }
}

class GovtDesignationModel {
  final String id;
  final String departmentId;
  final String name;
  final String? gujaratiName;

  GovtDesignationModel({
    required this.id,
    required this.departmentId,
    required this.name,
    this.gujaratiName,
  });

  factory GovtDesignationModel.fromJson(Map<String, dynamic> json) {
    return GovtDesignationModel(
      id: json['id']?.toString() ?? '',
      departmentId: json['departmentId']?.toString() ?? '',
      name: json['name'] ?? '',
      gujaratiName: json['gujaratiName'],
    );
  }
}
