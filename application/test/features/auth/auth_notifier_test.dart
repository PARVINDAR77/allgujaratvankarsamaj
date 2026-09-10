import 'package:flutter_test/flutter_test.dart';
import 'package:vankar_samaj_matrimony/features/auth/data/auth_repository.dart';
import 'package:vankar_samaj_matrimony/features/auth/providers/auth_provider.dart';

import 'auth_repository_test.dart';

void main() {
  late FakeAuthApi fakeApi;
  late FakeSecureStorageService fakeStorage;
  late AuthRepository repository;
  late AuthNotifier authNotifier;

  setUp(() {
    fakeApi = FakeAuthApi();
    fakeStorage = FakeSecureStorageService();
    repository = AuthRepository(api: fakeApi, storageService: fakeStorage);
    authNotifier = AuthNotifier(repository);
  });

  test('initializeAuth sets unauthenticated when no token exists', () async {
    await authNotifier.initializeAuth();
    expect(authNotifier.state.status, AuthStatus.unauthenticated);
    expect(authNotifier.state.isAuthenticated, false);
  });

  test('initializeAuth sets authenticated when valid token exists', () async {
    await fakeStorage.saveToken('valid-token');
    await authNotifier.initializeAuth();

    expect(authNotifier.state.status, AuthStatus.authenticated);
    expect(authNotifier.state.user?.email, 'test@example.com');
  });

  test('login success updates state to authenticated', () async {
    final success = await authNotifier.login('test@example.com', 'Password123!');

    expect(success, true);
    expect(authNotifier.state.status, AuthStatus.authenticated);
    expect(authNotifier.state.user?.email, 'test@example.com');
  });

  test('login failure updates state to error', () async {
    fakeApi.shouldFailLogin = true;
    final success = await authNotifier.login('wrong@example.com', 'wrong');

    expect(success, false);
    expect(authNotifier.state.status, AuthStatus.error);
    expect(authNotifier.state.errorMessage, isNotNull);
  });

  test('logout purges state and sets unauthenticated', () async {
    await authNotifier.login('test@example.com', 'Password123!');
    expect(authNotifier.state.isAuthenticated, true);

    await authNotifier.logout();
    expect(authNotifier.state.status, AuthStatus.unauthenticated);
    expect(await fakeStorage.getToken(), isNull);
  });
}
