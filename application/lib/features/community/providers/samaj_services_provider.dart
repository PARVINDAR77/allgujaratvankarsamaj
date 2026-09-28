import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/samaj_service.dart';
import '../../../shared/models/samaj_service_person.dart';
import '../../../shared/repositories/samaj_services_repository.dart';

final samajServicesProvider = FutureProvider<List<SamajService>>((ref) async {
  final repository = ref.watch(samajServiceRepositoryProvider);
  return repository.fetchServices();
});
final samajServicePersonsProvider = FutureProvider.family<List<SamajServicePerson>, String>((ref, serviceId) async {
  final repository = ref.watch(samajServiceRepositoryProvider);
  return repository.fetchPersonsByServiceId(serviceId);
});
