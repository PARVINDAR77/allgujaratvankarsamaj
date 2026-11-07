import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';

/// Performance-Optimized Views Notifier with in-memory cache and optimistic increment.
/// Prevents excessive network polling on Hostinger shared hosting.
class ViewsNotifier extends StateNotifier<AsyncValue<Map<String, int>>> {
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(seconds: 45);

  ViewsNotifier() : super(const AsyncValue.loading()) {
    fetchViews();
  }

  Future<void> fetchViews({bool force = false}) async {
    if (!force && _lastFetchTime != null && DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return; // Return immediately from cache
    }

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 6),
      ));
      final response = await dio.get('${AppConfig.baseUrl}/statistics/views');
      dynamic raw = response.data;
      if (raw is String) {
        try {
          raw = jsonDecode(raw);
        } catch (_) {}
      }
      if (raw is Map && raw.containsKey('data')) {
        raw = raw['data'];
      }
      final Map<String, int> views = {};
      if (raw is List) {
        for (var item in raw) {
          if (item is Map) {
            final sName = item['sectionName']?.toString() ?? '';
            final vCount = int.tryParse(item['viewCount']?.toString() ?? '0') ?? 0;
            if (sName.isNotEmpty) {
              views[sName] = vCount;
            }
          }
        }
      }
      _lastFetchTime = DateTime.now();
      state = AsyncValue.data(views);
    } catch (e, st) {
      if (state.hasValue && state.value != null && state.value!.isNotEmpty) {
        // Retain existing state gracefully if network dropped
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> incrementView(String sectionName) async {
    // 1. Optimistic update: increment local count instantly for 0ms UI lag
    final current = state.value ?? {};
    final updated = Map<String, int>.from(current);
    updated[sectionName] = (updated[sectionName] ?? 0) + 1;
    state = AsyncValue.data(updated);

    // 2. Fire backend increment in background without triggering full map refetch
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      await dio.post('${AppConfig.baseUrl}/statistics/views/$sectionName/increment');
    } catch (_) {
      // Background tracking drop ignored
    }
  }
}

final viewsNotifierProvider = StateNotifierProvider<ViewsNotifier, AsyncValue<Map<String, int>>>((ref) {
  return ViewsNotifier();
});

final viewsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  return ref.watch(viewsNotifierProvider);
});

final incrementViewProvider = Provider((ref) => (String sectionName) {
  ref.read(viewsNotifierProvider.notifier).incrementView(sectionName);
});
