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
    final rawSortOrder = json['sortOrder'];
    int sortOrder = 0;
    if (rawSortOrder is num) {
      sortOrder = rawSortOrder.toInt();
    } else if (rawSortOrder is String) {
      sortOrder = int.tryParse(rawSortOrder) ?? 0;
    }

    final rawIsActive = json['isActive'];
    bool isActive = true;
    if (rawIsActive is bool) {
      isActive = rawIsActive;
    } else if (rawIsActive is num) {
      isActive = rawIsActive != 0;
    } else if (rawIsActive is String) {
      isActive = rawIsActive.toLowerCase() == 'true' || rawIsActive == '1';
    }

    return AdvertisementModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: AppConfig.resolveMediaUrl(json['imageUrl']?.toString() ?? ''),
      targetUrl: json['targetUrl']?.toString(),
      placement: json['placement']?.toString() ?? 'HOME_BANNER',
      isActive: isActive,
      startAt: json['startAt']?.toString(),
      endAt: json['endAt']?.toString(),
      sortOrder: sortOrder,
      createdAt: json['createdAt']?.toString(),
    );
  }
}
