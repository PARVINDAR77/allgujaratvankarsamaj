import 'package:dio/dio.dart';
import 'package:application/features/auth/data/auth_repository.dart';
import 'package:application/features/profile/data/profile_repository.dart';
import 'package:application/shared/repositories/samaj_services_repository.dart';

void main() async {
  const targetUrl = String.fromEnvironment('TEST_API_URL', defaultValue: 'http://127.0.0.1:3000/api/v1');
  if (targetUrl.contains('allgujaratvankarsamaj.com') || targetUrl.contains('217.21.94.138')) {
    throw StateError('SECURITY VIOLATION: Automated execution against production endpoints is strictly prohibited.');
  }

  print('Starting API test against isolated test endpoint: $targetUrl');

  final dio = Dio(BaseOptions(baseUrl: targetUrl));
  dio.interceptors.add(LogInterceptor(responseBody: true));

  final authRepo = AuthRepository(dio);
  final profileRepo = ProfileRepository(dio);
  final samajRepo = SamajServiceRepository(dio);

  print('1. Testing Login...');
  try {
    const testEmail = String.fromEnvironment('TEST_USER_EMAIL', defaultValue: 'test-user@example.test');
    const testPass = String.fromEnvironment('TEST_USER_PASSWORD', defaultValue: 'TestPassword123!');
    final result = await authRepo.login(testEmail, testPass);
    print('✅ Login Success! Token: ${result['token']}');

    // Attach token to Dio for subsequent requests
    dio.options.headers['Authorization'] = 'Bearer ${result['token']}';
  } catch (e) {
    print('❌ Login Failed: $e');
  }

  print('2. Testing Fetch Profiles...');
  try {
    final profiles = await profileRepo.fetchProfiles();
    print('✅ Fetched ${profiles.length} profiles successfully!');
    if (profiles.isNotEmpty) {
      print('   First profile: ${profiles.first.fullName}');
    }
  } catch (e) {
    print('❌ Fetch Profiles Failed: $e');
  }

  print('3. Testing Fetch Samaj Services...');
  try {
    final services = await samajRepo.fetchServices();
    print('✅ Fetched ${services.length} samaj services successfully!');
  } catch (e) {
    print('❌ Fetch Samaj Services Failed: $e');
  }
}
