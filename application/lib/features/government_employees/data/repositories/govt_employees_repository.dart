import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../models/govt_employee_model.dart';

class GovtEmployeesRepository {
  final Dio _dio = Dio();
  final ApiConfig _apiConfig = const ApiConfig();

  Future<List<GovtDepartmentModel>> fetchDepartments() async {
    try {
      final response = await _dio.get('${_apiConfig.baseUrl}/government-employees/departments').timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((json) => GovtDepartmentModel.fromJson(json)).toList();
      }
    } catch (e) {
      // Fallback matching NestJS seed
      return [
        GovtDepartmentModel(
          id: 'dept-1',
          name: 'Education Department',
          gujaratiName: 'શિક્ષણ વિભાગ',
          designations: [
            GovtDesignationModel(id: 'desig-1-1', departmentId: 'dept-1', name: 'Primary Teacher', gujaratiName: 'પ્રાથમિક શિક્ષક'),
            GovtDesignationModel(id: 'desig-1-2', departmentId: 'dept-1', name: 'High School Teacher', gujaratiName: 'ઉચ્ચતર માધ્યમિક શિક્ષક'),
            GovtDesignationModel(id: 'desig-1-3', departmentId: 'dept-1', name: 'College Lecturer / Professor', gujaratiName: 'અધ્યાપક / પ્રાધ્યાપક'),
          ],
        ),
        GovtDepartmentModel(
          id: 'dept-2',
          name: 'Revenue Department',
          gujaratiName: 'મહેસૂલ વિભાગ',
          designations: [
            GovtDesignationModel(id: 'desig-2-1', departmentId: 'dept-2', name: 'Talati Mantri', gujaratiName: 'તલાટી મંત્રી'),
            GovtDesignationModel(id: 'desig-2-2', departmentId: 'dept-2', name: 'Revenue Inspector', gujaratiName: 'મહેસૂલ નાયબ નિરીક્ષક'),
            GovtDesignationModel(id: 'desig-2-3', departmentId: 'dept-2', name: 'Mamlatdar', gujaratiName: 'મામલતદાર'),
          ],
        ),
        GovtDepartmentModel(
          id: 'dept-3',
          name: 'Police & Home Department',
          gujaratiName: 'પોલીસ અને ગૃહ વિભાગ',
          designations: [
            GovtDesignationModel(id: 'desig-3-1', departmentId: 'dept-3', name: 'Police Constable', gujaratiName: 'પોલીસ કોન્સ્ટેબલ'),
            GovtDesignationModel(id: 'desig-3-2', departmentId: 'dept-3', name: 'PSI', gujaratiName: 'પી.એસ.આઈ.'),
            GovtDesignationModel(id: 'desig-3-3', departmentId: 'dept-3', name: 'PI', gujaratiName: 'પી.આઈ.'),
          ],
        ),
      ];
    }
    return [];
  }

  Future<List<GovtEmployeeModel>> fetchFeaturedGovtEmployees() async {
    try {
      final response = await _dio.get('${_apiConfig.baseUrl}/government-employees/featured').timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((json) => GovtEmployeeModel.fromJson(json)).toList();
      }
    } catch (e) {
      // Fallback dataset
    }
    return [
      GovtEmployeeModel(
        id: 'ge-1',
        profileId: 'p-101',
        fullName: 'Rameshbhai Vankar',
        gender: 'MALE',
        age: 32,
        education: 'M.Ed, B.Ed',
        maritalStatus: 'NEVER_MARRIED',
        districtName: 'Gandhinagar',
        employmentType: 'STATE_GOVT',
        departmentName: 'Education Department',
        departmentGujaratiName: 'શિક્ષણ વિભાગ',
        designationName: 'High School Teacher',
        designationGujaratiName: 'ઉચ્ચતર માધ્યમિક શિક્ષક',
        officeLocation: 'Gandhinagar Govt School',
        isVerified: true,
        isFeatured: true,
      ),
      GovtEmployeeModel(
        id: 'ge-2',
        profileId: 'p-102',
        fullName: 'Priyankaben Parmar',
        gender: 'FEMALE',
        age: 28,
        education: 'B.Com, Revenue Audit',
        maritalStatus: 'NEVER_MARRIED',
        districtName: 'Ahmedabad',
        employmentType: 'STATE_GOVT',
        departmentName: 'Revenue Department',
        departmentGujaratiName: 'મહેસૂલ વિભાગ',
        designationName: 'Talati Mantri',
        designationGujaratiName: 'તલાટી મંત્રી',
        officeLocation: 'Revenue Collectorate',
        isVerified: true,
        isFeatured: true,
      ),
      GovtEmployeeModel(
        id: 'ge-3',
        profileId: 'p-103',
        fullName: 'Jigneshabhai Solanki',
        gender: 'MALE',
        age: 34,
        education: 'B.Sc, Police Training',
        maritalStatus: 'NEVER_MARRIED',
        districtName: 'Mehsana',
        employmentType: 'STATE_GOVT',
        departmentName: 'Police & Home Department',
        departmentGujaratiName: 'પોલીસ અને ગૃહ વિભાગ',
        designationName: 'Police Sub Inspector (PSI)',
        designationGujaratiName: 'પી.એસ.આઈ.',
        officeLocation: 'Mehsana Police HQ',
        isVerified: true,
        isFeatured: true,
      ),
    ];
  }

  Future<List<GovtEmployeeModel>> searchGovtEmployees({
    String? gender,
    String? departmentId,
    String? designationId,
    String? districtId,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;
      if (departmentId != null && departmentId.isNotEmpty) queryParams['departmentId'] = departmentId;
      if (designationId != null && designationId.isNotEmpty) queryParams['designationId'] = designationId;
      if (districtId != null && districtId.isNotEmpty) queryParams['districtId'] = districtId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get('${_apiConfig.baseUrl}/government-employees', queryParameters: queryParams).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && response.data is Map && response.data['items'] is List) {
        final List<dynamic> items = response.data['items'];
        return items.map((json) => GovtEmployeeModel.fromJson(json)).toList();
      }
    } catch (e) {
      // Fallback
    }

    return await fetchFeaturedGovtEmployees();
  }
}
