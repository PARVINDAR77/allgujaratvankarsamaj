import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:application/core/config/app_config.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final bool isRead;
  final String? route;
  final IconData icon;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    this.route,
    this.icon = Icons.notifications,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? time,
    bool? isRead,
    String? route,
    IconData? icon,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      route: route ?? this.route,
      icon: icon ?? this.icon,
    );
  }
}

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _storageKeyReadIds = 'read_notifications_ids_v1';
  Set<String> _readIds = {};

  NotificationsNotifier() : super([]) {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    try {
      final storedReadIdsJson = await _storage.read(key: _storageKeyReadIds);
      if (storedReadIdsJson != null) {
        final List<dynamic> list = jsonDecode(storedReadIdsJson);
        _readIds = list.map((e) => e.toString()).toSet();
      }
    } catch (_) {}

    // Default system notification (e.g. Welcome notification)
    const welcomeId = 'welcome_samaj_v1';
    final isWelcomeRead = _readIds.contains(welcomeId);

    // Initial state: starts with real system notification
    // If user has already opened/read it, isRead is true (unreadCount = 0)
    // If not yet opened, unreadCount = 1
    final List<AppNotification> items = [
      AppNotification(
        id: welcomeId,
        title: 'ઓલ ગુજરાત વણકર સમાજમાં આપનું સ્વાગત છે',
        message: 'તમારી પ્રોફાઇલ અને સમાજના સંબંધો સરળતાથી શોધો અને જોડાઓ.',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: isWelcomeRead,
        route: '/search',
        icon: Icons.celebration,
      ),
    ];

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      final res = await dio.get('${AppConfig.baseUrl}/notifications');
      dynamic raw = res.data;
      if (raw is String) {
        try {
          raw = jsonDecode(raw);
        } catch (_) {}
      }
      if (raw is Map && raw.containsKey('data')) {
        raw = raw['data'];
      }
      if (raw is List) {
        for (final item in raw) {
          if (item is! Map) continue;
          final map = Map<String, dynamic>.from(item);
          final id = map['id']?.toString() ?? '';
          if (id.isEmpty) continue;
          final title = map['title']?.toString() ?? '';
          final message = map['message']?.toString() ?? '';
          final route = map['route']?.toString();
          final createdAtStr = map['createdAt']?.toString();
          final time = createdAtStr != null
              ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
              : DateTime.now();
          final isRead = _readIds.contains(id);

          items.insert(
            0,
            AppNotification(
              id: id,
              title: title,
              message: message,
              time: time,
              isRead: isRead,
              route: route,
              icon: Icons.notifications_active,
            ),
          );
        }
      }
    } catch (_) {}

    state = items;
  }

  Future<void> refresh() => _initNotifications();

  int get unreadCount => state.where((n) => !n.isRead).length;

  Future<void> _saveReadIds() async {
    try {
      await _storage.write(
        key: _storageKeyReadIds,
        value: jsonEncode(_readIds.toList()),
      );
    } catch (_) {}
  }

  void addNotification({
    required String title,
    required String message,
    String? route,
    IconData icon = Icons.notifications_active,
  }) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newNotif = AppNotification(
      id: newId,
      title: title,
      message: message,
      time: DateTime.now(),
      isRead: false,
      route: route,
      icon: icon,
    );
    state = [newNotif, ...state];
  }

  void markAsRead(String id) {
    _readIds.add(id);
    _saveReadIds();
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllAsRead() {
    for (final n in state) {
      _readIds.add(n.id);
    }
    _saveReadIds();
    state = [
      for (final n in state)
        if (!n.isRead) n.copyWith(isRead: true) else n,
    ];
  }

  void clearAll() {
    for (final n in state) {
      _readIds.add(n.id);
    }
    _saveReadIds();
    state = [];
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationsProvider);
  return notifs.where((n) => !n.isRead).length;
});
