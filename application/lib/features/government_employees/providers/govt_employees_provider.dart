import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_failure.dart';
import '../../../../shared/models/pagination_meta.dart';
import '../data/datasources/govt_employee_remote_datasource.dart';
import '../data/models/govt_employee_model.dart';
import '../data/models/govt_employee_query.dart';

// ─── State ────────────────────────────────────────────────────────────────────

enum GovtEmployeesStatus {
  initial,
  loading,        // loading first page
  loadingMore,    // loading next page
  refreshing,     // pull-to-refresh
  success,
  empty,
  error,
  paginationError,
}

class GovtEmployeesState {
  final GovtEmployeesStatus status;
  final List<GovtEmployeeModel> items;
  final PaginationMeta meta;
  final GovtEmployeeQuery query;
  final ApiFailure? failure;

  const GovtEmployeesState({
    required this.status,
    required this.items,
    required this.meta,
    required this.query,
    this.failure,
  });

  factory GovtEmployeesState.initial() => GovtEmployeesState(
        status: GovtEmployeesStatus.initial,
        items: const [],
        meta: PaginationMeta.empty(),
        query: const GovtEmployeeQuery(),
      );

  GovtEmployeesState copyWith({
    GovtEmployeesStatus? status,
    List<GovtEmployeeModel>? items,
    PaginationMeta? meta,
    GovtEmployeeQuery? query,
    ApiFailure? failure,
    bool clearFailure = false,
  }) {
    return GovtEmployeesState(
      status: status ?? this.status,
      items: items ?? this.items,
      meta: meta ?? this.meta,
      query: query ?? this.query,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class GovtEmployeesNotifier extends StateNotifier<GovtEmployeesState> {
  final GovtEmployeeRemoteDatasource _datasource;

  GovtEmployeesNotifier(this._datasource) : super(GovtEmployeesState.initial()) {
    loadInitial();
  }

  /// Load the first page with the default query.
  Future<void> loadInitial() async {
    state = state.copyWith(
      status: GovtEmployeesStatus.loading,
      items: const [],
      query: const GovtEmployeeQuery(),
      clearFailure: true,
    );
    await _fetch(state.query);
  }

  /// Refresh — keeps existing filter but resets to page 1.
  Future<void> refresh() async {
    state = state.copyWith(
      status: GovtEmployeesStatus.refreshing,
      query: state.query.resetPage(),
      clearFailure: true,
    );
    await _fetch(state.query, replaceItems: true);
  }

  /// Load the next page, if available.
  Future<void> loadMore() async {
    if (!state.meta.hasNextPage) return;
    if (state.status == GovtEmployeesStatus.loadingMore) return;

    final nextQuery = state.query.copyWith(page: state.meta.page + 1);
    state = state.copyWith(status: GovtEmployeesStatus.loadingMore, query: nextQuery);
    await _fetch(nextQuery, replaceItems: false);
  }

  /// Apply a new filter — always resets to page 1 to avoid stale results.
  Future<void> applyFilter(GovtEmployeeQuery newQuery) async {
    final resetQuery = newQuery.resetPage();
    state = state.copyWith(
      status: GovtEmployeesStatus.loading,
      items: const [],
      query: resetQuery,
      clearFailure: true,
    );
    await _fetch(resetQuery);
  }

  /// Reset all filters and reload.
  Future<void> resetFilters() async {
    await applyFilter(const GovtEmployeeQuery());
  }

  Future<void> _fetch(GovtEmployeeQuery query, {bool replaceItems = true}) async {
    try {
      final response = await _datasource.fetchGovtEmployees(query);
      final newItems = replaceItems
          ? response.data
          : [...state.items, ...response.data];

      state = state.copyWith(
        status: newItems.isEmpty
            ? GovtEmployeesStatus.empty
            : GovtEmployeesStatus.success,
        items: newItems,
        meta: response.meta,
        clearFailure: true,
      );
    } on ApiFailure catch (failure) {
      final isLoadingMore = state.status == GovtEmployeesStatus.loadingMore;
      state = state.copyWith(
        status: isLoadingMore
            ? GovtEmployeesStatus.paginationError
            : GovtEmployeesStatus.error,
        failure: failure,
      );
    } catch (e) {
      state = state.copyWith(
        status: GovtEmployeesStatus.error,
        failure: ApiFailure(
          type: ApiFailureType.unknown,
          message: 'Unexpected error: $e',
        ),
      );
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final govtEmployeesProvider =
    StateNotifierProvider<GovtEmployeesNotifier, GovtEmployeesState>((ref) {
  final datasource = ref.watch(govtEmployeeRemoteDatasourceProvider);
  return GovtEmployeesNotifier(datasource);
});

/// Provider for the department list used in filter dropdowns.
/// Data comes from the backend — not hardcoded business records.
final govtDepartmentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final datasource = ref.watch(govtEmployeeRemoteDatasourceProvider);
  return datasource.fetchDepartments();
});
