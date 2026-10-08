class SamajService {
  final String id;
  final String title;
  final String slug;
  final String category;
  final String icon;
  final String description;

  SamajService({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    required this.icon,
    this.description = '',
  });

  factory SamajService.fromJson(Map<String, dynamic> json) {
    return SamajService(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      icon: json['icon']?.toString() ?? '🤝',
      description: json['description']?.toString() ?? '',
    );
  }
}
