class UserModel {
  final String id;
  final String email;
  final String? phone;
  final String? name;
  final String role;
  final String status;
  final bool isVerified;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final bool hasProfile;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.phone,
    this.name,
    required this.role,
    required this.status,
    this.isVerified = false,
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
    this.hasProfile = false,
    this.createdAt,
    this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    String? role,
    String? status,
    bool? isVerified,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    bool? hasProfile,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      hasProfile: hasProfile ?? this.hasProfile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '1',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String? ?? 'USER',
      status: json['status'] as String? ?? 'ACTIVE',
      isVerified: json['isVerified'] == true ||
          json['isVerified'] == 1 ||
          json['isVerified'] == 'true',
      isPhoneVerified: json['isPhoneVerified'] == true || json['is_phone_verified'] == 1 || json['is_phone_verified'] == true,
      isEmailVerified: json['isEmailVerified'] == true || json['is_email_verified'] == 1 || json['is_email_verified'] == true,
      hasProfile: json['hasProfile'] == true ||
          json['hasProfile'] == 1 ||
          json['hasProfile'] == 'true' ||
          (json['profileId'] != null && json['profileId'].toString().trim().isNotEmpty) ||
          (json['profile'] != null && json['profile'] is Map && (json['profile'] as Map)['id'] != null),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'role': role,
      'status': status,
      'isVerified': isVerified,
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerified': isEmailVerified,
      'hasProfile': hasProfile,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ─── Role helpers (match Prisma Role enum) ───────────────────────────────

  /// USER | ADMIN | SUPER_ADMIN | VERIFICATION_ADMIN | CONTENT_ADMIN
  bool hasRole(String r) => role == r;

  bool hasAnyRole(List<String> roles) => roles.contains(role);

  bool get isAdmin => role == 'ADMIN' || role == 'SUPER_ADMIN';

  bool get isSuperAdmin => role == 'SUPER_ADMIN';

  bool get isVerificationAdmin =>
      role == 'VERIFICATION_ADMIN' || role == 'SUPER_ADMIN';

  bool get isContentAdmin =>
      role == 'CONTENT_ADMIN' || role == 'SUPER_ADMIN';
}
