import 'package:flutter_test/flutter_test.dart';
import 'package:vankar_samaj_matrimony/core/config/api_config.dart';
import 'package:vankar_samaj_matrimony/core/errors/app_exception.dart';
import 'package:vankar_samaj_matrimony/core/network/dio_client.dart';
import 'package:vankar_samaj_matrimony/core/storage/secure_storage_service.dart';
import 'package:vankar_samaj_matrimony/features/auth/data/auth_api.dart';
import 'package:vankar_samaj_matrimony/features/auth/data/auth_models.dart';
import 'package:vankar_samaj_matrimony/features/auth/data/auth_repository.dart';

class FakeSecureStorageService implements SecureStorageService {
  String? _token;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> getToken() async {
    return _token;
  }

  @override
  Future<void> deleteToken() async {
    _token = null;
  }

  @override
  Future<bool> hasToken() async {
    return _token != null && _token!.isNotEmpty;
  }
}

class FakeAuthApi extends AuthApi {
  bool shouldFailMe = false;
  bool shouldFailLogin = false;

  FakeAuthApi() : super(DioClient(const ApiConfig()));

  @override
  Future<UserModel> register(RegisterRequest request) async {
    return UserModel(
      id: 'test-user-id',
      email: request.email,
      role: 'USER',
      status: 'ACTIVE',
    );
  }

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    if (shouldFailLogin) {
      throw const UnauthorizedException('Invalid credentials');
    }
    return const LoginResponse(
      accessToken: 'fake-jwt-token',
      tokenType: 'Bearer',
      expiresIn: '1d',
    );
  }

  @override
  Future<UserModel> getCurrentUser() async {
    if (shouldFailMe) {
      throw const UnauthorizedException('Unauthorized access');
    }
    return const UserModel(
      id: 'test-user-id',
      email: 'test@example.com',
      role: 'USER',
      status: 'ACTIVE',
    );
  }
}

void main() {
  late FakeAuthApi fakeApi;
  late FakeSecureStorageService fakeStorage;
  late AuthRepository repository;

  setUp(() {
    fakeApi = FakeAuthApi();
    fakeStorage = FakeSecureStorageService();
    repository = AuthRepository(api: fakeApi, storageService: fakeStorage);
  });

  test('login saves token and returns user', () async {
    final user = await repository.login('test@example.com', 'Password123!');

    expect(user.email, 'test@example.com');
    expect(await fakeStorage.getToken(), 'fake-jwt-token');
  });

  test('login failure throws exception and does not save token', () async {
    fakeApi.shouldFailLogin = true;

    expect(
      () => repository.login('wrong@example.com', 'wrongpass'),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(await fakeStorage.getToken(), isNull);
  });

  test('getCurrentUser returns null and deletes token if /auth/me returns UnauthorizedException', () async {
    // Save token first
    await fakeStorage.saveToken('expired-token');
    fakeApi.shouldFailMe = true;

    final user = await repository.getCurrentUser();

    expect(user, isNull);
    expect(await fakeStorage.getToken(), isNull); // Token deleted!
  });

  test('logout purges token from storage', () async {
    await fakeStorage.saveToken('some-token');
    await repository.logout();

    expect(await fakeStorage.getToken(), isNull);
  });
}
