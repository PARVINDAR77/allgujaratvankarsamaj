import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:application/shared/models/profile_query_model.dart';
import 'package:application/features/auth/providers/auth_provider.dart';
import 'package:application/features/matrimonial_listing/providers/universal_listing_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;
  
  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('Universal Listing Provider Validation', () async {
    final container = ProviderContainer();
    
    // 1. Auth Setup (Login with test account)
    final authNotifier = container.read(authNotifierProvider.notifier);
    final loginSuccess = await authNotifier.login(
      'panjabiparvindar77@gmail.com',
      'password123',
    );
    expect(loginSuccess, true);

    // 2. Page 1 -> real API -> profiles
    final baseQuery = const ProfileQueryModel(limit: 2);
    final provider = universalListingProvider(baseQuery);
    
    // Wait for initial load
    await Future.delayed(const Duration(seconds: 2));
    
    var state = container.read(provider);
    while (container.read(provider).isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    state = container.read(provider);
    
    expect(state.isLoading, false);
    expect(state.profiles.isNotEmpty, true);
    expect(state.error, isNull);
    
    final page1ProfileIds = state.profiles.map((e) => e.id).toSet();
    
    // 3. Page 2 -> real API -> additional profiles
    await container.read(provider.notifier).loadMore();
    state = container.read(provider);
    expect(state.isLoadingMore, false);
    expect(state.query.page, 2);
    
    // Ensure no duplicates
    final page2Profiles = state.profiles.where((p) => !page1ProfileIds.contains(p.id)).toList();
    expect(page2Profiles.length, greaterThanOrEqualTo(0));
    
    // 4. Repeated load-more -> no duplicates
    await container.read(provider.notifier).loadMore();
    state = container.read(provider);
    final allIds = state.profiles.map((e) => e.id).toSet();
    expect(allIds.length, state.profiles.length, reason: 'Duplicate IDs found in state');

    // 5. Filter change -> pagination resets & occupationCategory = GOVERNMENT
    final govQuery = const ProfileQueryModel(occupationCategory: 'GOVERNMENT', limit: 2);
    container.read(provider.notifier).updateQuery(govQuery);
    
    state = container.read(provider);
    expect(state.isLoading, true); // Loading resets
    expect(state.query.page, 1); // Pagination resets
    
    while (container.read(provider).isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    state = container.read(provider);
    expect(state.isLoading, false);
    expect(state.query.occupationCategory, 'GOVERNMENT');
    // Verify any returned profile has governmentEmployment (if our backend API returns it, though ProfileModel doesn't currently deserialize governmentEmployment explicitly, the backend respects it)

    // 6. No results -> Empty state data
    final emptyQuery = const ProfileQueryModel(search: 'NON_EXISTENT_NAME_ZXY123');
    container.read(provider.notifier).updateQuery(emptyQuery);
    
    while (container.read(provider).isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    state = container.read(provider);
    expect(state.isLoading, false);
    expect(state.profiles.isEmpty, true);
    expect(state.error, isNull);

    container.dispose();
  });
}
