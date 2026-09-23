/// Government Employee model built from the verified Sprint 1 API contract.
///
/// Actual contract from GET /api/v1/government-employees response (transformToPublicDto):
/// {
///   "id": string,
///   "profileId": string,
///   "fullName": string,
///   "gender": "MALE"|"FEMALE",
///   "age": int|null,
///   "education": string|null,
///   "maritalStatus": string,
///   "photoUrl": string|null,
///   "districtName": string|null,
///   "talukaName": string|null,
///   "employmentType": "STATE_GOVT"|"CENTRAL_GOVT"|"PSU",
///   "departmentName": string,
///   "departmentGujaratiName": string,
///   "designationName": string,
///   "designationGujaratiName": string,
///   "officeLocation": string|null,
///   "joiningYear": int|null,
///   "isVerified": bool,
///   "isFeatured": bool
/// }
class GovtEmployeeModel {
  final String id;
  final String profileId;
  final String fullName;
  final String gender;
  final int? age;
  final String? education;
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

  const GovtEmployeeModel({
    required this.id,
    required this.profileId,
    required this.fullName,
    required this.gender,
    this.age,
    this.education,
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
      id: json['id'] as String? ?? '',
      profileId: json['profileId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Vankar Member',
      gender: json['gender'] as String? ?? 'MALE',
      age: json['age'] as int?,
      education: json['education'] as String?,
      maritalStatus: json['maritalStatus'] as String? ?? 'NEVER_MARRIED',
      photoUrl: json['photoUrl'] as String?,
      districtName: json['districtName'] as String?,
      talukaName: json['talukaName'] as String?,
      employmentType: json['employmentType'] as String? ?? 'STATE_GOVT',
      departmentName: json['departmentName'] as String? ?? 'Government Department',
      departmentGujaratiName: json['departmentGujaratiName'] as String? ?? 'સરકારી વિભાગ',
      designationName: json['designationName'] as String? ?? 'Officer',
      designationGujaratiName: json['designationGujaratiName'] as String? ?? 'અધિકારી',
      officeLocation: json['officeLocation'] as String?,
      joiningYear: json['joiningYear'] as int?,
      isVerified: json['isVerified'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }
}
