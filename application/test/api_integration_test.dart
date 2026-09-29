import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:application/features/auth/providers/auth_provider.dart';
import 'package:application/features/profile/providers/profile_provider.dart';
import 'package:application/shared/providers/samaj_services_provider.dart';
import 'package:application/features/home/data/statistics_api.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;
  
  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('E2E Validation: Auth -> Profile -> Real Data', () async {
    final container = ProviderContainer();
    
    // 1. Wait for initial auth state
    // Auth starts at initial because _checkAuth is async.
    await Future.delayed(const Duration(milliseconds: 100));
    var authState = container.read(authNotifierProvider);

    // 2. Perform Login with the real backend
    print('Attempting login with backend...');
    final loginSuccess = await container.read(authNotifierProvider.notifier).login(
      'panjabiparvindar77@gmail.com',
      'password123',
    );
    expect(loginSuccess, true, reason: 'Login should succeed against real MySQL backend');
    
    authState = container.read(authNotifierProvider);
    expect(authState.isAuthenticated, true);
    expect(authState.user, isNotNull);
    print('Login successful! Logged in as: ${authState.user?.email}');

    // 3. Fetch Profiles from the real backend
    print('Fetching profiles...');
    await container.read(profileNotifierProvider.notifier).fetchProfiles();
    
    final profileState = container.read(profileNotifierProvider);
    if (profileState.hasError) {
      print('Profile fetch error: ${profileState.error}');
      print('Profile fetch stacktrace: ${profileState.stackTrace}');
    }
    expect(profileState.hasValue, true);
    expect(profileState.value!.isNotEmpty, true, reason: 'Database should return real seeded profiles');
    print('Fetched ${profileState.value?.length} profiles successfully.');

    // 4. Fetch Samaj Services
    print('Fetching Samaj Services...');
    final samajServices = await container.read(samajServiceRepositoryProvider).fetchServices();
    expect(samajServices, isNotEmpty, reason: 'Database should return real Samaj Services');
    print('Fetched ${samajServices.length} samaj services successfully.');

    // 5. Cleanup
    container.dispose();
  });
}
