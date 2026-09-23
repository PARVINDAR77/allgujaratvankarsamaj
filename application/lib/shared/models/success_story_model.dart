/// SuccessStoryModel — matches NestJS SuccessStory entity exactly.
/// Prisma contract: id, bride_name, groom_name, wedding_date?, story, image_url?, is_published, created_at
/// NestJS serializes to camelCase: brideName, groomName, weddingDate, imageUrl, isPublished, createdAt
class SuccessStoryModel {
  final String id;
  final String brideName;
  final String groomName;
  final String? weddingDate;
  final String story;
  final String? imageUrl;
  final bool isPublished;
  final String? createdAt;

  const SuccessStoryModel({
    required this.id,
    required this.brideName,
    required this.groomName,
    this.weddingDate,
    required this.story,
    this.imageUrl,
    required this.isPublished,
    this.createdAt,
  });

  factory SuccessStoryModel.fromJson(Map<String, dynamic> json) {
    return SuccessStoryModel(
      id: json['id'] as String? ?? '',
      brideName: json['brideName'] as String? ?? '',
      groomName: json['groomName'] as String? ?? '',
      weddingDate: json['weddingDate'] as String?,
      story: json['story'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      isPublished: json['isPublished'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
    );
  }
}
