import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/advertisement_model.dart';
import '../../../core/network/api_client.dart';
import '../data/datasources/advertisements_remote_data_source.dart';
import '../data/repositories/advertisements_repository.dart';

final advertisementsRemoteDataSourceProvider =
    Provider<AdvertisementsRemoteDataSource>((ref) {
  return AdvertisementsRemoteDataSource(ref.watch(apiClientProvider));
});

final advertisementsRepositoryProvider =
    Provider<AdvertisementsRepository>((ref) {
  return AdvertisementsRepository(
      ref.watch(advertisementsRemoteDataSourceProvider));
});

/// Public FutureProvider — GET /advertisements (no auth).
/// Backend returns only currently active ads.
final advertisementsProvider =
    FutureProvider<List<AdvertisementModel>>((ref) async {
  return ref.watch(advertisementsRepositoryProvider).getActiveAdvertisements();
});
