class SamajService {
  final String id;
  final String title;
  final String slug;
  final String category;
  final String icon;

  SamajService({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    required this.icon,
  });

  factory SamajService.fromJson(Map<String, dynamic> json) {
    return SamajService(
      id: json['id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      slug: json['slug'] ?? '',
      category: json['category'] ?? 'General',
      icon: json['icon'] ?? '🤝',
    );
  }
}
