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
  });

  factory SamajServicePerson.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
