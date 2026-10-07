class UserModel {
  final String id;
  final String email;
  final String role;
  final String status;
  final bool isVerified;
  final bool hasProfile;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.isVerified = false,
    this.hasProfile = false,
    this.createdAt,
    this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? role,
    String? status,
    bool? isVerified,
    bool? hasProfile,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      hasProfile: hasProfile ?? this.hasProfile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '1',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
      status: json['status'] as String? ?? 'ACTIVE',
      isVerified: json['isVerified'] == true,
      hasProfile: json['hasProfile'] == true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'status': status,
      'isVerified': isVerified,
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
