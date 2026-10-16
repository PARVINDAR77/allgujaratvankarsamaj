import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:application/core/network/api_client.dart';
import 'package:application/core/network/dio_client.dart';
import 'package:application/features/auth/providers/auth_provider.dart';
import 'package:application/features/profile/providers/profile_provider.dart';
import 'package:application/shared/providers/samaj_services_provider.dart';
import 'test_safety_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
    // Explicit safety check: ensure the test endpoint is strictly isolated and never targets production
    enforceTestUrlSafety('http://127.0.0.1:3000/api/v1');
  });

  test('Isolated Validation: Auth -> Profile -> Samaj Services (Mocked)', () async {
    final mockDio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api/v1'));
    mockDio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final path = options.path;
        if (path.contains('auth/login')) {
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'accessToken':
                  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0LXVzZXItMDAxIiwiZW1haWwiOiJ0ZXN0LXVzZXJAZXhhbXBsZS50ZXN0Iiwicm9sZSI6IlVTRVIiLCJpc1ZlcmlmaWVkIjp0cnVlLCJoYXNQcm9maWxlIjp0cnVlfQ.signature',
              'user': {
                'id': 'test-user-001',
                'email': 'test-user@example.test',
                'role': 'USER',
                'status': 'ACTIVE',
              },
            },
          ));
        }
        if (path.contains('profiles')) {
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'items': [
                {
                  'id': 'profile-001',
                  'userId': 'test-user-001',
                  'firstName': 'Priya',
                  'lastName': 'Vankar',
                  'gender': 'FEMALE',
                  'dateOfBirth': '1998-05-12T00:00:00.000Z',
                  'maritalStatus': 'NEVER_MARRIED',
                  'education': 'BE Computer',
                  'occupation': 'Software Engineer',
                  'city': 'Ahmedabad',
                  'state': 'Gujarat',
                },
              ],
              'meta': {'page': 1, 'limit': 10, 'total': 1, 'totalPages': 1},
            },
          ));
        }
        if (path.contains('samaj-services')) {
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: [
              {
                'id': 'service-001',
                'title': 'Education Counseling',
                'category': 'Education',
                'icon': '🎓',
              },
            ],
          ));
        }
        return handler.next(options);
      },
    ));

    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(mockDio),
        dioProvider.overrideWithValue(mockDio),
      ],
    );

    // 1. Initial auth state verification
    await Future.delayed(const Duration(milliseconds: 50));
    var authState = container.read(authNotifierProvider);

    // 2. Perform Login with safe test fixture
    final loginSuccess = await container.read(authNotifierProvider.notifier).login(
      'test-user@example.test',
      'TestPassword123!',
    );
    expect(loginSuccess, true, reason: 'Login should succeed against mock auth provider');

    authState = container.read(authNotifierProvider);
    expect(authState.isAuthenticated, true);
    expect(authState.user, isNotNull);
    expect(authState.user?.email, 'test-user@example.test');

    // 3. Fetch Profiles from provider
    await container.read(profileNotifierProvider.notifier).fetchFirstPage();

    final profileState = container.read(profileNotifierProvider);
    expect(profileState.error, isNull);
    expect(profileState.profiles.isNotEmpty, true);
    expect(profileState.profiles.first.firstName, 'Priya');

    // 4. Fetch Samaj Services from repository
    final samajServices = await container.read(samajServiceRepositoryProvider).fetchServices();
    expect(samajServices, isNotEmpty);
    expect(samajServices.first.title, 'Education Counseling');

    // 5. Cleanup
    container.dispose();
  });
}
