import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/samaj_service.dart';
import '../../../shared/repositories/samaj_services_repository.dart';

final samajServicesProvider = FutureProvider<List<SamajService>>((ref) async {
  final repository = ref.watch(samajServiceRepositoryProvider);
  return repository.fetchServices();
});
