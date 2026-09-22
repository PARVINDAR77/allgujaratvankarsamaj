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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'dateOfBirth': dateOfBirth,
      'education': education,
      'employmentType': employmentType,
      'department': department,
      'designation': designation,
      'district': district,
      'taluka': taluka,
      'pargana': pargana,
    };
  }
}
