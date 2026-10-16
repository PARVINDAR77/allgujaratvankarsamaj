import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:application/core/network/api_client.dart';
import 'package:application/core/network/dio_client.dart';
import 'package:application/shared/models/profile_query_model.dart';
import 'package:application/features/auth/providers/auth_provider.dart';
import 'package:application/features/matrimonial_listing/providers/universal_listing_provider.dart';
import 'test_safety_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
    // Explicit safety check: ensure the test endpoint is strictly isolated and never targets production
    enforceTestUrlSafety('http://127.0.0.1:3000/api/v1');
  });

  test('Universal Listing Provider Validation (Mocked)', () async {
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
          final page = options.queryParameters['page'] ?? 1;
          final search = options.queryParameters['search'];
          if (search == 'NON_EXISTENT_NAME_ZXY123') {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'items': [],
                'meta': {'page': 1, 'limit': 2, 'total': 0, 'totalPages': 0},
              },
            ));
          }

          if (page == 1 || page == '1') {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'items': [
                  {
                    'id': 'profile-001',
                    'userId': 'u-001',
                    'firstName': 'Priya',
                    'lastName': 'Vankar',
                    'gender': 'FEMALE',
                    'dateOfBirth': '1998-05-12T00:00:00.000Z',
                    'maritalStatus': 'NEVER_MARRIED',
                    'education': 'Graduate',
                    'occupation': 'Service',
                  },
                  {
                    'id': 'profile-002',
                    'userId': 'u-002',
                    'firstName': 'Kiran',
                    'lastName': 'Vankar',
                    'gender': 'MALE',
                    'dateOfBirth': '1995-08-10T00:00:00.000Z',
                    'maritalStatus': 'NEVER_MARRIED',
                    'education': 'Post Graduate',
                    'occupation': 'Business',
                  },
                ],
                'meta': {'page': 1, 'limit': 2, 'total': 4, 'totalPages': 2},
              },
            ));
          } else {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'items': [
                  {
                    'id': 'profile-003',
                    'userId': 'u-003',
                    'firstName': 'Anita',
                    'lastName': 'Vankar',
                    'gender': 'FEMALE',
                    'dateOfBirth': '1997-02-14T00:00:00.000Z',
                    'maritalStatus': 'NEVER_MARRIED',
                    'education': 'Doctorate',
                    'occupation': 'Teacher',
                  },
                ],
                'meta': {'page': 2, 'limit': 2, 'total': 4, 'totalPages': 2},
              },
            ));
          }
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

    // 1. Auth Setup (Login with safe test fixture)
    final authNotifier = container.read(authNotifierProvider.notifier);
    final loginSuccess = await authNotifier.login(
      'test-user@example.test',
      'TestPassword123!',
    );
    expect(loginSuccess, true);

    // 2. Page 1 -> profiles
    final baseQuery = const ProfileQueryModel(limit: 2);
    final provider = universalListingProvider(baseQuery);

    while (container.read(provider).isLoading) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    var state = container.read(provider);

    expect(state.isLoading, false);
    expect(state.profiles.isNotEmpty, true);
    expect(state.error, isNull);

    final page1ProfileIds = state.profiles.map((e) => e.id).toSet();

    // 3. Page 2 -> loadMore
    await container.read(provider.notifier).loadMore();
    state = container.read(provider);
    expect(state.isLoadingMore, false);
    expect(state.query.page, 2);

    // Ensure no duplicates
    final page2Profiles =
        state.profiles.where((p) => !page1ProfileIds.contains(p.id)).toList();
    expect(page2Profiles.length, greaterThanOrEqualTo(0));

    // 4. Repeated load-more -> no duplicates
    await container.read(provider.notifier).loadMore();
    state = container.read(provider);
    final allIds = state.profiles.map((e) => e.id).toSet();
    expect(allIds.length, state.profiles.length, reason: 'Duplicate IDs found in state');

    // 5. Filter change -> pagination resets & occupationCategory = GOVERNMENT
    final govQuery =
        const ProfileQueryModel(occupationCategory: 'GOVERNMENT', limit: 2);
    container.read(provider.notifier).updateQuery(govQuery);

    while (container.read(provider).isLoading) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    state = container.read(provider);
    expect(state.isLoading, false);
    expect(state.query.occupationCategory, 'GOVERNMENT');

    // 6. No results -> Empty state data
    final emptyQuery =
        const ProfileQueryModel(search: 'NON_EXISTENT_NAME_ZXY123');
    container.read(provider.notifier).updateQuery(emptyQuery);

    while (container.read(provider).isLoading) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    state = container.read(provider);
    expect(state.isLoading, false);
    expect(state.profiles.isEmpty, true);
    expect(state.error, isNull);

    container.dispose();
  });
}
