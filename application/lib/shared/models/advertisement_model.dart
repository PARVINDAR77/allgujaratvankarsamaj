import 'package:application/core/config/app_config.dart';

/// AdvertisementModel — matches NestJS Advertisement entity exactly.
/// Prisma contract: id, title, image_url, target_url?, placement, is_active,
///                  start_at?, end_at?, sort_order, created_by?, created_at, updated_at
/// NestJS serializes to camelCase.
/// NOTE: Flutter does NOT implement client-side date filtering.
/// The backend's findAllPublic() already applies active/date window logic.
class AdvertisementModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? targetUrl;
  final String placement; // AdPlacement enum: HOME_BANNER | DIRECTORY_BANNER | POPUP
  final bool isActive;
  final String? startAt;
  final String? endAt;
  final int sortOrder;
  final String? createdAt;

  const AdvertisementModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.targetUrl,
    required this.placement,
    required this.isActive,
    this.startAt,
    this.endAt,
    required this.sortOrder,
    this.createdAt,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: AppConfig.resolveMediaUrl(json['imageUrl'] as String? ?? ''),
      targetUrl: json['targetUrl'] as String?,
      placement: json['placement'] as String? ?? 'HOME_BANNER',
      isActive: json['isActive'] as bool? ?? true,
      startAt: json['startAt'] as String?,
      endAt: json['endAt'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: json['createdAt'] as String?,
    );
  }
}
