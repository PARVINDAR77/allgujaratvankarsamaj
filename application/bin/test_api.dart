import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:application/core/config/app_config.dart';
import 'package:application/core/network/dio_client.dart';
import 'package:application/features/auth/data/auth_repository.dart';
import 'package:application/features/profile/data/profile_repository.dart';
import 'package:application/shared/repositories/samaj_services_repository.dart';

void main() async {
  print('Starting API test against: \${AppConfig.baseUrl}');
  
  final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
  // Add simple interceptors to log things
  dio.interceptors.add(LogInterceptor(responseBody: true));
  
  final authRepo = AuthRepository(dio);
  final profileRepo = ProfileRepository(dio);
  final samajRepo = SamajServiceRepository(dio);
  
  print('1. Testing Login...');
  try {
    final result = await authRepo.login('panjabiparvindar77@gmail.com', 'password123');
    print('✅ Login Success! Token: \${result['token']}');
    
    // Attach token to Dio for subsequent requests
    dio.options.headers['Authorization'] = 'Bearer \${result['token']}';
  } catch (e) {
    print('❌ Login Failed: \$e');
  }

  print('2. Testing Fetch Profiles...');
  try {
    final profiles = await profileRepo.fetchProfiles();
    print('✅ Fetched \${profiles.length} profiles successfully!');
    if (profiles.isNotEmpty) {
      print('   First profile: \${profiles.first.fullName}');
    }
  } catch (e) {
    print('❌ Fetch Profiles Failed: \$e');
  }

  print('3. Testing Fetch Samaj Services...');
  try {
    final services = await samajRepo.fetchServices();
    print('✅ Fetched \${services.length} samaj services successfully!');
  } catch (e) {
    print('❌ Fetch Samaj Services Failed: \$e');
  }
}
