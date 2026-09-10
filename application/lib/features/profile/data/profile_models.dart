/// MatrimonialProfile model matching Prisma MatrimonialProfile schema exactly.
/// Backend serializes dateOfBirth as full ISO 8601 (e.g. "1995-08-15T00:00:00.000Z").
class MatrimonialProfileModel {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String maritalStatus;
  final String? religion;
  final String? caste;
  final String? city;
  final String? state;
  final String? country;
  final String? education;
  final String? occupation;
  final String? about;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MatrimonialProfileModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.maritalStatus,
    this.religion,
    this.caste,
    this.city,
    this.state,
    this.country,
    this.education,
    this.occupation,
    this.about,
    this.createdAt,
    this.updatedAt,
  });

  factory MatrimonialProfileModel.fromJson(Map<String, dynamic> json) {
    return MatrimonialProfileModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      maritalStatus: json['maritalStatus'] as String,
      religion: json['religion'] as String?,
      caste: json['caste'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      education: json['education'] as String?,
      occupation: json['occupation'] as String?,
      about: json['about'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Returns dateOfBirth formatted for display: DD/MM/YYYY
  String get displayDateOfBirth {
    return '${dateOfBirth.day.toString().padLeft(2, '0')}/'
        '${dateOfBirth.month.toString().padLeft(2, '0')}/'
        '${dateOfBirth.year}';
  }

  /// Returns full name
  String get fullName => '$firstName $lastName';
}

/// Reference data response: gender and maritalStatus enum string arrays
class ReferenceDataModel {
  final List<String> gender;
  final List<String> maritalStatus;

  const ReferenceDataModel({
    required this.gender,
    required this.maritalStatus,
  });

  factory ReferenceDataModel.fromJson(Map<String, dynamic> json) {
    return ReferenceDataModel(
      gender: List<String>.from(json['gender'] as List),
      maritalStatus: List<String>.from(json['maritalStatus'] as List),
    );
  }

  /// Default fallback reference data when loading or offline
  factory ReferenceDataModel.defaultData() => const ReferenceDataModel(
        gender: ['MALE', 'FEMALE', 'OTHER'],
        maritalStatus: ['NEVER_MARRIED', 'DIVORCED', 'WIDOWED', 'SEPARATED'],
      );
}

/// Profile completeness response
class CompletenessModel {
  final int completedFields;
  final int totalFields;
  final int percentage;
  final bool isComplete;

  const CompletenessModel({
    required this.completedFields,
    required this.totalFields,
    required this.percentage,
    required this.isComplete,
  });

  factory CompletenessModel.fromJson(Map<String, dynamic> json) {
    return CompletenessModel(
      completedFields: json['completedFields'] as int,
      totalFields: json['totalFields'] as int,
      percentage: json['percentage'] as int,
      isComplete: json['isComplete'] as bool,
    );
  }

  /// Zero state (no profile yet)
  factory CompletenessModel.zero() => const CompletenessModel(
        completedFields: 0,
        totalFields: 13,
        percentage: 0,
        isComplete: false,
      );
}

/// DTO for creating a profile — matches CreateProfileDto exactly.
/// NEVER includes userId; backend derives ownership from JWT.
class CreateProfileRequest {
  final String firstName;
  final String lastName;
  /// Must be sent as YYYY-MM-DD
  final String dateOfBirth;
  final String gender;
  final String maritalStatus;
  final String? religion;
  final String? caste;
  final String? city;
  final String? state;
  final String? country;
  final String? education;
  final String? occupation;
  final String? about;

  const CreateProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.maritalStatus,
    this.religion,
    this.caste,
    this.city,
    this.state,
    this.country,
    this.education,
    this.occupation,
    this.about,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'maritalStatus': maritalStatus,
    };
    if (religion != null) map['religion'] = religion;
    if (caste != null) map['caste'] = caste;
    if (city != null) map['city'] = city;
    if (state != null) map['state'] = state;
    if (country != null) map['country'] = country;
    if (education != null) map['education'] = education;
    if (occupation != null) map['occupation'] = occupation;
    if (about != null) map['about'] = about;
    return map;
  }
}

/// DTO for updating a profile — all fields optional (PATCH semantics).
/// NEVER includes userId.
class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? religion;
  final String? caste;
  final String? city;
  final String? state;
  final String? country;
  final String? education;
  final String? occupation;
  final String? about;

  const UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    this.religion,
    this.caste,
    this.city,
    this.state,
    this.country,
    this.education,
    this.occupation,
    this.about,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstName != null) map['firstName'] = firstName;
    if (lastName != null) map['lastName'] = lastName;
    if (dateOfBirth != null) map['dateOfBirth'] = dateOfBirth;
    if (gender != null) map['gender'] = gender;
    if (maritalStatus != null) map['maritalStatus'] = maritalStatus;
    if (religion != null) map['religion'] = religion;
    if (caste != null) map['caste'] = caste;
    if (city != null) map['city'] = city;
    if (state != null) map['state'] = state;
    if (country != null) map['country'] = country;
    if (education != null) map['education'] = education;
    if (occupation != null) map['occupation'] = occupation;
    if (about != null) map['about'] = about;
    return map;
  }
}
