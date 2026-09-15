import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/govt_employee_model.dart';
import '../data/repositories/govt_employees_repository.dart';

final govtEmployeesRepositoryProvider = Provider<GovtEmployeesRepository>((ref) {
  return GovtEmployeesRepository();
});

final govtDepartmentsProvider = FutureProvider<List<GovtDepartmentModel>>((ref) async {
  final repo = ref.watch(govtEmployeesRepositoryProvider);
  return repo.fetchDepartments();
});

final featuredGovtEmployeesProvider = FutureProvider<List<GovtEmployeeModel>>((ref) async {
  final repo = ref.watch(govtEmployeesRepositoryProvider);
  return repo.fetchFeaturedGovtEmployees();
});

class GovtSearchFilter {
  final String? gender;
  final String? departmentId;
  final String? designationId;
  final String? districtId;
  final String? search;

  GovtSearchFilter({
    this.gender,
    this.departmentId,
    this.designationId,
    this.districtId,
    this.search,
  });

  GovtSearchFilter copyWith({
    String? gender,
    String? departmentId,
    String? designationId,
    String? districtId,
    String? search,
  }) {
    return GovtSearchFilter(
      gender: gender ?? this.gender,
      departmentId: departmentId ?? this.departmentId,
      designationId: designationId ?? this.designationId,
      districtId: districtId ?? this.districtId,
      search: search ?? this.search,
    );
  }
}

final govtSearchFilterProvider = StateProvider<GovtSearchFilter>((ref) {
  return GovtSearchFilter();
});

final filteredGovtEmployeesProvider = FutureProvider<List<GovtEmployeeModel>>((ref) async {
  final repo = ref.watch(govtEmployeesRepositoryProvider);
  final filter = ref.watch(govtSearchFilterProvider);

  return repo.searchGovtEmployees(
    gender: filter.gender,
    departmentId: filter.departmentId,
    designationId: filter.designationId,
    districtId: filter.districtId,
    search: filter.search,
  );
});
