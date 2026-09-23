/// Query parameters for GET /api/v1/government-employees.
/// Only includes parameters verified in Sprint 1 backend contract.
class GovtEmployeeQuery {
  final int page;
  final int limit;
  final String? search;
  final String? gender;
  final String? departmentId;
  final String? designationId;
  final String? districtId;
  final String? talukaId;
  final String? stateId;
  final String? maritalStatus;
  final String? sortBy;
  final String? sortOrder;

  const GovtEmployeeQuery({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.gender,
    this.departmentId,
    this.designationId,
    this.districtId,
    this.talukaId,
    this.stateId,
    this.maritalStatus,
    this.sortBy,
    this.sortOrder,
  });

  GovtEmployeeQuery copyWith({
    int? page,
    int? limit,
    String? search,
    String? gender,
    String? departmentId,
    String? designationId,
    String? districtId,
    String? talukaId,
    String? stateId,
    String? maritalStatus,
    String? sortBy,
    String? sortOrder,
    bool clearSearch = false,
    bool clearGender = false,
    bool clearDepartmentId = false,
    bool clearDesignationId = false,
    bool clearDistrictId = false,
    bool clearTalukaId = false,
  }) {
    return GovtEmployeeQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: clearSearch ? null : (search ?? this.search),
      gender: clearGender ? null : (gender ?? this.gender),
      departmentId: clearDepartmentId ? null : (departmentId ?? this.departmentId),
      designationId: clearDesignationId ? null : (designationId ?? this.designationId),
      districtId: clearDistrictId ? null : (districtId ?? this.districtId),
      talukaId: clearTalukaId ? null : (talukaId ?? this.talukaId),
      stateId: stateId ?? this.stateId,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Convert to query parameters map, omitting null values.
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (gender != null && gender!.isNotEmpty) params['gender'] = gender;
    if (departmentId != null && departmentId!.isNotEmpty) params['departmentId'] = departmentId;
    if (designationId != null && designationId!.isNotEmpty) params['designationId'] = designationId;
    if (districtId != null && districtId!.isNotEmpty) params['districtId'] = districtId;
    if (talukaId != null && talukaId!.isNotEmpty) params['talukaId'] = talukaId;
    if (stateId != null && stateId!.isNotEmpty) params['stateId'] = stateId;
    if (maritalStatus != null && maritalStatus!.isNotEmpty) params['maritalStatus'] = maritalStatus;
    if (sortBy != null && sortBy!.isNotEmpty) params['sortBy'] = sortBy;
    if (sortOrder != null && sortOrder!.isNotEmpty) params['sortOrder'] = sortOrder;
    return params;
  }

  /// Reset to page 1. Used when any filter changes.
  GovtEmployeeQuery resetPage() => copyWith(page: 1);
}
