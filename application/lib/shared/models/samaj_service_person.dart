class SamajServicePerson {
  final String id;
  final String serviceId;
  final String name;
  final String? gujaratiName;
  final String? photoUrl;
  final String phone;
  final String? address;
  final String? city;
  final String? description;
  final String? experience;
  final String? serviceTitle;
  final String? serviceIcon;
  final String? profileId;
  final String? userId;
  final bool hasCandidateProfile;

  SamajServicePerson({
    required this.id,
    required this.serviceId,
    required this.name,
    this.gujaratiName,
    this.photoUrl,
    required this.phone,
    this.address,
    this.city,
    this.description,
    this.experience,
    this.serviceTitle,
    this.serviceIcon,
    this.profileId,
    this.userId,
    this.hasCandidateProfile = false,
  });

  factory SamajServicePerson.fromJson(Map<String, dynamic> json) {
    String? svcTitle;
    String? svcIcon;
    if (json['service'] is Map) {
      svcTitle = json['service']['title']?.toString();
      svcIcon = json['service']['icon']?.toString();
    }
    final pId = json['profileId']?.toString() ??
        json['profile_id']?.toString() ??
        json['candidateProfileId']?.toString();
    final uId = json['userId']?.toString() ?? json['user_id']?.toString();
    final hasCandidate = json['hasCandidateProfile'] == true ||
        (pId != null && pId.trim().isNotEmpty);

    return SamajServicePerson(
      id: json['id'] ?? '',
      serviceId: json['serviceId'] ?? json['service_id'] ?? '',
      name: json['name'] ?? '',
      gujaratiName: json['gujaratiName'] ?? json['gujarati_name'],
      photoUrl: json['photoUrl'] ?? json['photo_url'],
      phone: json['phone'] ?? '',
      address: json['address'],
      city: json['city'],
      description: json['description'],
      experience: json['experience'],
      serviceTitle: svcTitle,
      serviceIcon: svcIcon,
      profileId: pId,
      userId: uId,
      hasCandidateProfile: hasCandidate,
    );
  }
}
