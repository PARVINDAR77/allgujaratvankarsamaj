import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/samaj_service.dart';
import '../repositories/samaj_services_repository.dart';

import '../../../core/network/dio_client.dart';

final samajServiceRepositoryProvider = Provider<SamajServiceRepository>((ref) {
  return SamajServiceRepository(ref.watch(dioProvider));
});

final samajServicesProvider = FutureProvider<List<SamajService>>((ref) async {
  final repository = ref.watch(samajServiceRepositoryProvider);
  return repository.fetchServices();
});
