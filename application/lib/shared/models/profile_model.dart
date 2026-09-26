class ProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? photoUrl;

  // Personal
  final String gender;
  final String maritalStatus;
  final String dateOfBirth;

  // Employment & Education
  final String education;
  final String employmentType;
  final String department;
  final String designation;

  // Location
  final String district;
  final String taluka;
  final String pargana;

  // Verification (Prisma: is_verified Boolean @default(false))
  final bool? isVerified;

  // Disability
  final bool? isPhysicallyDisabled;
  final String? pwbdCategory;

  // Abroad
  final bool? isAbroad;
  final String? abroadCountry;

  const ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    required this.gender,
    required this.maritalStatus,
    required this.dateOfBirth,
    required this.education,
    required this.employmentType,
    required this.department,
    required this.designation,
    required this.district,
    required this.taluka,
    required this.pargana,
    this.isVerified,
    this.isPhysicallyDisabled,
    this.pwbdCategory,
    this.isAbroad,
    this.abroadCountry,
  });

  String get fullName => '$firstName $lastName';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      photoUrl: json['photoUrl'] as String?,
      gender: json['gender'] as String? ?? 'Male (પુરુષ)',
      maritalStatus: json['maritalStatus'] as String? ?? 'Never Married (અપરિણીત)',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      education: json['education'] as String? ?? '',
      employmentType: json['employmentType'] as String? ?? '',
      department: json['department'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      district: json['district'] as String? ?? '',
      taluka: json['taluka'] as String? ?? '',
      pargana: json['pargana'] as String? ?? '',
      isVerified: json['isVerified'] as bool?,
      isPhysicallyDisabled: json['isPhysicallyDisabled'] as bool?,
      pwbdCategory: json['pwbdCategory'] as String?,
      isAbroad: json['isAbroad'] as bool?,
      abroadCountry: json['abroadCountry'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'gender': gender.contains('Male') ? 'MALE' : 'FEMALE',
      'maritalStatus': maritalStatus.contains('Divorced') ? 'DIVORCED' : (maritalStatus.contains('Widow') ? 'WIDOWED' : (maritalStatus.contains('Awaiting') ? 'SEPARATED' : 'NEVER_MARRIED')),
      'dateOfBirth': dateOfBirth, // backend expects YYYY-MM-DD or valid date string. In create profile it's formatted as DD-MM-YYYY, so we might need to parse it if backend is strict, but nestjs can parse ISO
      'education': education,
      'occupation': employmentType,
      'organizationName': department,
      'designation': designation,
      'nativePlace': pargana,
      'city': taluka,
      'state': district,
      'country': 'India',
      'isVerified': isVerified,
      'isPhysicallyDisabled': isPhysicallyDisabled,
      'pwbdCategory': pwbdCategory,
      'isAbroad': isAbroad,
      'abroadCountry': abroadCountry,
    };
  }
}
