import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_models.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_failure.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.authenticated(UserModel user) => AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() => const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  factory AuthState.error(String message) => AuthState(status: AuthStatus.error, errorMessage: message);

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorageService _storage;
  final Dio _dio;

  AuthNotifier(this._storage, this._dio) : super(AuthState.initial()) {
    _checkAuth();
  }

  UserModel? _decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      String payload = parts[1];
      String normalized = base64Url.normalize(payload);
      String decoded = utf8.decode(base64Url.decode(normalized));
      
      final data = jsonDecode(decoded);
      if (data is! Map<String, dynamic>) return null;

      // Check token expiration if 'exp' is present
      if (data['exp'] != null) {
        final expSeconds = data['exp'] is int ? data['exp'] as int : int.tryParse(data['exp'].toString());
        if (expSeconds != null) {
          final expDate = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
          if (DateTime.now().isAfter(expDate)) {
            print('JWT Token expired at $expDate');
            return null;
          }
        }
      }

      return UserModel(
        id: data['sub']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        role: data['role']?.toString() ?? 'USER',
        status: 'ACTIVE',
        isVerified: data['isVerified'] == true,
        hasProfile: data['hasProfile'] == true,
      );
    } catch (e) {
      print('JWT Decode error: $e');
      return null;
    }
  }

  Future<void> _checkAuth() async {
    try {
      final token = await _storage.getToken();
      if (token == null || token.trim().isEmpty) {
        await _storage.deleteUserData();
        state = AuthState.unauthenticated();
        return;
      }

      final decodedUser = _decodeToken(token);
      if (decodedUser == null) {
        // Token is invalid or expired, clean up
        await _storage.deleteToken();
        await _storage.deleteUserData();
        state = AuthState.unauthenticated();
        return;
      }

      // Check for cached user data in localStorage (0ms latency on browser refresh)
      UserModel? resolvedUser;
      try {
        final cachedData = await _storage.getUserData();
        if (cachedData != null) {
          final cachedUser = UserModel.fromJson(cachedData);
          if (cachedUser.id == decodedUser.id || cachedUser.email == decodedUser.email) {
            resolvedUser = cachedUser;
            // If cached user already has a profile or is verified, immediately set authenticated
            if (resolvedUser.hasProfile || resolvedUser.isVerified) {
              state = AuthState.authenticated(resolvedUser);
            }
          }
        }
      } catch (e) {
        debugPrint('[Auth] Error reading cached user: $e');
      }

      // If state is not yet authenticated, keep it in loading (never emit unverified authenticated)
      if (!state.isAuthenticated) {
        state = AuthState.loading();
      }

      // Fetch fresh user profile details from /auth/me
      try {
        final meRes = await _dio.get('/auth/me');
        if (meRes.data != null && meRes.data is Map<String, dynamic>) {
          final meUser = UserModel.fromJson(meRes.data);
          final effectiveHasProfile = meUser.hasProfile || (resolvedUser?.hasProfile ?? false) || decodedUser.hasProfile;
          final effectiveIsVerified = meUser.isVerified || (resolvedUser?.isVerified ?? false) || decodedUser.isVerified;
          resolvedUser = meUser.copyWith(
            hasProfile: effectiveHasProfile,
            isVerified: effectiveIsVerified,
          );
        }
      } catch (e) {
        debugPrint('[Auth] /auth/me fetch error: $e');
      }

      // If still not verified or hasProfile is false, cross-check /verifications/my-status
      if (resolvedUser == null || !resolvedUser.isVerified || !resolvedUser.hasProfile) {
        try {
          final vRes = await _dio.get('/verifications/my-status');
          if (vRes.data != null && vRes.data is Map<String, dynamic>) {
            final isVer = vRes.data['isVerified'] == true ||
                vRes.data['isVerified'] == 1 ||
                vRes.data['isVerified'] == 'true';
            final hasProf = vRes.data['hasProfile'] == true ||
                vRes.data['hasProfile'] == 1 ||
                vRes.data['hasProfile'] == 'true' ||
                (vRes.data['profileStatus'] != null && vRes.data['profileStatus'] != 'NOT_CREATED') ||
                vRes.data['latestRequest'] != null ||
                isVer;

            resolvedUser = (resolvedUser ?? decodedUser).copyWith(
              isVerified: isVer || (resolvedUser?.isVerified ?? false),
              hasProfile: hasProf || (resolvedUser?.hasProfile ?? false),
            );
          }
        } catch (_) {}
      }

      // Fallback check to /profiles/me
      if (resolvedUser == null || !resolvedUser.hasProfile) {
        try {
          final pRes = await _dio.get('/profiles/me');
          if (pRes.data != null && pRes.data is Map<String, dynamic>) {
            final isVer = pRes.data['isVerified'] == true || pRes.data['isVerified'] == 1 || pRes.data['isVerified'] == 'true';
            final hasProf = (pRes.data['id'] != null && pRes.data['id'].toString().isNotEmpty) || isVer;
            resolvedUser = (resolvedUser ?? decodedUser).copyWith(
              isVerified: isVer || (resolvedUser?.isVerified ?? false),
              hasProfile: hasProf || (resolvedUser?.hasProfile ?? false),
            );
          }
        } catch (_) {}
      }

      final finalUser = resolvedUser ?? decodedUser;
      state = AuthState.authenticated(finalUser);
      await _storage.saveUserData(finalUser.toJson());
      return;
    } catch (e) {
      debugPrint('[Auth] JWT auth check error: $e');
    }
    state = AuthState.unauthenticated();
  }

  Future<void> updateUser(UserModel user) async {
    state = AuthState.authenticated(user);
    try {
      await _storage.saveUserData(user.toJson());
    } catch (e) {
      debugPrint('[Auth] Error saving updated user: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final identifier = email.trim();
      final isEmail = identifier.contains('@');
      final payload = <String, dynamic>{
        if (isEmail) 'email': identifier else 'phone': identifier,
        'password': password,
      };

      final response = await _dio.post('/auth/login', data: payload);

      final token = response.data['accessToken'];
      if (token != null) {
        await _storage.saveToken(token);
        var user = _decodeToken(token);
        final userData = response.data['user'];
        if (userData is Map<String, dynamic>) {
          user = UserModel.fromJson(userData);
        }
        if (user != null) {
          state = AuthState.authenticated(user);
          await _storage.saveUserData(user.toJson());
          checkVerificationStatus();
          return true;
        } else {
          state = AuthState.error('Failed to decode user token. Invalid token format.');
          return false;
        }
      }
      
      // If we reach here, token was null
      final rawData = response.data.toString();
      final preview = rawData.length > 100 ? rawData.substring(0, 100) + '...' : rawData;
      state = AuthState.error('Missing accessToken in response. Raw: $preview');
      return false;
    } on DioException catch (e) {
      final failure = _mapDioException(e);
      state = AuthState.error(failure.message);
      return false;
    } catch (e) {
      state = AuthState.error('An unexpected error occurred: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> sendRegistrationOtp({
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      final res = await _dio.post('/auth/register/send-otp', data: {
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
      });
      return {
        'success': true,
        'message': res.data['message'] ?? 'ચકાસણી કોડ મોકલવામાં આવ્યા છે',
        'maskedPhone': res.data['maskedPhone'] ?? phone,
        'maskedEmail': res.data['maskedEmail'] ?? email,
        'expiresInSeconds': res.data['expiresInSeconds'] ?? 600,
        'resendCooldownSeconds': res.data['resendCooldownSeconds'] ?? 60,
        'maxAttempts': res.data['maxAttempts'] ?? 4,
        'emailConfigured': res.data['emailConfigured'] == true,
        'smsDelivered': res.data['smsDelivered'] != false,
      };
    } on DioException catch (e) {
      final failure = _mapDioException(e);
      return {
        'success': false,
        'message': failure.message,
        'isLocked': e.response?.statusCode == 429,
        'remainingSeconds': e.response?.data is Map ? e.response?.data['remainingSeconds'] : null,
      };
    } catch (e) {
      return {'success': false, 'message': 'ભૂલ: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyRegistrationOtp({
    required String phone,
    required String email,
    required String phoneOtp,
    required String emailOtp,
  }) async {
    try {
      final res = await _dio.post('/auth/register/verify-otp', data: {
        'phone': phone.trim(),
        'email': email.trim(),
        'phoneOtp': phoneOtp.trim(),
        'emailOtp': emailOtp.trim(),
      });
      return {
        'success': true,
        'verified': true,
        'registrationToken': res.data['registrationToken'],
        'message': res.data['message'] ?? 'ચકાસણી સફળ થઈ છે',
      };
    } on DioException catch (e) {
      final failure = _mapDioException(e);
      return {
        'success': false,
        'message': failure.message,
        'isLocked': e.response?.statusCode == 429,
        'remainingSeconds': e.response?.data is Map ? e.response?.data['remainingSeconds'] : null,
      };
    } catch (e) {
      return {'success': false, 'message': 'ભૂલ: $e'};
    }
  }

  Future<Map<String, dynamic>> sendProfileContactOtp({
    String? name,
    String? phone,
    String? email,
    String? channel,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (channel != null && channel.isNotEmpty) 'channel': channel,
        if (state.user?.id != null && state.user!.id.isNotEmpty) 'userId': state.user!.id,
      };
      final res = await _dio.post('/auth/profile/send-contact-otp', data: payload);
      return {
        'success': true,
        'message': res.data['message'] ?? 'ચકાસણી કોડ મોકલવામાં આવ્યા છે',
        'maskedPhone': res.data['maskedPhone'] ?? phone,
        'maskedEmail': res.data['maskedEmail'] ?? email,
        'channel': res.data['channel'] ?? channel ?? 'BOTH',
        'expiresInSeconds': res.data['expiresInSeconds'] ?? 600,
        'resendCooldownSeconds': res.data['resendCooldownSeconds'] ?? 40,
        'maxAttempts': res.data['maxAttempts'] ?? 4,
        'emailConfigured': true,
        'smsDelivered': res.data['smsDelivered'] != false,
      };
    } on DioException catch (e) {
      final failure = _mapDioException(e);
      return {
        'success': false,
        'message': failure.message,
        'isLocked': e.response?.statusCode == 429,
        'remainingSeconds': e.response?.data is Map ? e.response?.data['remainingSeconds'] : null,
      };
    } catch (e) {
      return {'success': false, 'message': 'ભૂલ: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyProfileContactOtp({
    String? phone,
    String? email,
    String? phoneOtp,
    String? emailOtp,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (phoneOtp != null && phoneOtp.trim().isNotEmpty) 'phoneOtp': phoneOtp.trim(),
        if (emailOtp != null && emailOtp.trim().isNotEmpty) 'emailOtp': emailOtp.trim(),
        if (state.user?.id != null && state.user!.id.isNotEmpty) 'userId': state.user!.id,
      };
      final res = await _dio.post('/auth/profile/verify-contact-otp', data: payload);
      final isPhVer = res.data['isPhoneVerified'] == true;
      final isEmVer = res.data['isEmailVerified'] == true;

      if (state.user != null) {
        state = state.copyWith(
          user: state.user!.copyWith(
            phone: (phone != null && phone.trim().isNotEmpty) ? phone.trim() : state.user!.phone,
            email: (email != null && email.trim().isNotEmpty) ? email.trim() : state.user!.email,
            isPhoneVerified: isPhVer ? true : state.user!.isPhoneVerified,
            isEmailVerified: isEmVer ? true : state.user!.isEmailVerified,
          ),
        );
      }

      return {
        'success': true,
        'verified': true,
        'isPhoneVerified': isPhVer,
        'isEmailVerified': isEmVer,
        'message': res.data['message'] ?? 'ચકાસણી સફળ થઈ',
      };
    } on DioException catch (e) {
      final failure = _mapDioException(e);
      return {
        'success': false,
        'message': failure.message,
        'isLocked': e.response?.statusCode == 429,
        'remainingSeconds': e.response?.data is Map ? e.response?.data['remainingSeconds'] : null,
      };
    } catch (e) {
      return {'success': false, 'message': 'ભૂલ: $e'};
    }
  }

  Future<bool> register(
    String email,
    String password, {
    String? phone,
    String? name,
    String? gender,
    String? registrationToken,
  }) async {
    state = AuthState.loading();
    try {
      await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (name != null) 'name': name,
        if (gender != null) 'gender': gender,
        if (registrationToken != null) 'registrationToken': registrationToken,
      });
      // Immediately log in after successful registration
      return await login(phone ?? email, password);
    } on DioException catch (e) {
      final failure = _mapDioException(e);
      state = AuthState.error(failure.message);
      return false;
    } catch (e) {
      state = AuthState.error('An unexpected error occurred: $e');
      return false;
    }
  }

  Future<bool> checkVerificationStatus() async {
    if (!state.isAuthenticated || state.user == null) return false;
    try {
      final res = await _dio.get('/verifications/my-status');
      if (res.data != null && res.data is Map<String, dynamic>) {
        final isVerified = res.data['isVerified'] == true ||
            res.data['isVerified'] == 1 ||
            res.data['isVerified'] == 'true';
        final hasProfile = res.data['hasProfile'] == true ||
            res.data['hasProfile'] == 1 ||
            res.data['hasProfile'] == 'true' ||
            (res.data['profileStatus'] != null && res.data['profileStatus'] != 'NOT_CREATED') ||
            res.data['latestRequest'] != null ||
            isVerified;
        if (state.user!.isVerified != isVerified || state.user!.hasProfile != hasProfile) {
          final updated = state.user!.copyWith(
            isVerified: isVerified,
            hasProfile: hasProfile,
          );
          state = AuthState.authenticated(updated);
          await _storage.saveUserData(updated.toJson());
        }
        return isVerified;
      }
    } catch (e) {
      try {
        final res = await _dio.get('/profiles/me');
        if (res.data != null && res.data is Map<String, dynamic>) {
          final isVerified = res.data['isVerified'] == true ||
              res.data['isVerified'] == 1 ||
              res.data['isVerified'] == 'true';
          final hasProfile = (res.data['id'] != null && res.data['id'].toString().isNotEmpty) || isVerified;
          if (state.user!.isVerified != isVerified || state.user!.hasProfile != hasProfile) {
            final updated = state.user!.copyWith(
              isVerified: isVerified,
              hasProfile: hasProfile,
            );
            state = AuthState.authenticated(updated);
            await _storage.saveUserData(updated.toJson());
          }
          return isVerified;
        }
      } catch (_) {}
    }
    return state.user?.isVerified ?? false;
  }

  Future<void> logout() async {
    await _storage.deleteToken();
    await _storage.deleteUserData();
    state = AuthState.unauthenticated();
  }

  Future<Map<String, dynamic>> requestPasswordReset(String identifier) async {
    try {
      final res = await _dio.post('/auth/forgot-password', data: {
        'identifier': identifier.trim(),
      });
      return {
        'success': true,
        'message': res.data['message'] ?? 'ચકાસણી કોડ મોકલવામાં આવ્યો છે',
        'maskedContact': res.data['maskedContact'],
        'channel': res.data['channel'],
        'resendCooldownSeconds': res.data['resendCooldownSeconds'] ?? 60,
        'maxAttempts': res.data['maxAttempts'] ?? 4,
      };
    } on DioException catch (e) {
      final failure = _mapDioException(e);
      return {
        'success': false,
        'message': failure.message,
        'isLocked': e.response?.statusCode == 429,
        'remainingSeconds': e.response?.data is Map ? e.response?.data['remainingSeconds'] : null,
      };
    } catch (e) {
      return {'success': false, 'message': 'ભૂલ: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyResetCode({
    required String identifier,
    required String code,
  }) async {
    try {
      final res = await _dio.post('/auth/verify-reset-code', data: {
        'identifier': identifier.trim(),
        'code': code.trim(),
      });
      return {
        'success': true,
        'verified': true,
        'resetToken': res.data['resetToken'],
        'message': res.data['message'] ?? 'ચકાસણી સફળ',
      };
    } on DioException catch (e) {
      final failure = _mapDioException(e);
      return {
        'success': false,
        'message': failure.message,
        'isLocked': e.response?.statusCode == 429,
        'remainingSeconds': e.response?.data is Map ? e.response?.data['remainingSeconds'] : null,
      };
    } catch (e) {
      return {'success': false, 'message': 'ભૂલ: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    try {
      final res = await _dio.post('/auth/reset-password', data: {
        'identifier': identifier.trim(),
        'code': code.trim(),
        'newPassword': newPassword,
      });
      return {
        'success': true,
        'message': res.data['message'] ?? 'પાસવર્ડ સફળતાપૂર્વક બદલાઈ ગયો છે',
      };
    } on DioException catch (e) {
      final failure = _mapDioException(e);
      return {'success': false, 'message': failure.message};
    } catch (e) {
      return {'success': false, 'message': 'ભૂલ: $e'};
    }
  }

  Future<Map<String, dynamic>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final res = await _dio.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      return {
        'success': true,
        'message': res.data != null && res.data['message'] != null
            ? res.data['message']
            : 'પાસવર્ડ સફળતાપૂર્વક અપડેટ થયો છે (Password updated successfully)',
      };
    } on DioException catch (e) {
      final failure = _mapDioException(e);
      return {'success': false, 'message': failure.message};
    } catch (e) {
      return {'success': false, 'message': 'ભૂલ: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final res = await _dio.delete('/auth/account/me');
      await logout();
      return {
        'success': true,
        'message': res.data['message'] ?? 'એકાઉન્ટ સફળતાપૂર્વક કાઢી નાખવામાં આવ્યું છે',
      };
    } on DioException catch (e) {
      final failure = _mapDioException(e);
      return {'success': false, 'message': failure.message};
    } catch (e) {
      return {'success': false, 'message': 'ભૂલ: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteProfile() async {
    try {
      final res = await _dio.delete('/profiles/me');
      if (state.user != null) {
        state = AuthState.authenticated(state.user!.copyWith(
          hasProfile: false,
          isVerified: false,
        ));
      }
      return {
        'success': true,
        'message': res.data['message'] ?? 'પ્રોફાઇલ સફળતાપૂર્વક કાઢી નાખવામાં આવી છે',
      };
    } on DioException catch (e) {
      final failure = _mapDioException(e);
      return {'success': false, 'message': failure.message};
    } catch (e) {
      return {'success': false, 'message': 'ભૂલ: $e'};
    }
  }

  ApiFailure _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiFailure(
        type: ApiFailureType.networkTimeout,
        message: 'Connection timed out. Please check your internet.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const ApiFailure(
        type: ApiFailureType.noConnection,
        message: 'સર્વર સાથે કનેક્ટ થઈ શકતું નથી. કૃપા કરીને થોડીવાર પછી ફરી પ્રયાસ કરો. (Server connection error)',
      );
    }
    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      dynamic data = e.response?.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      final serverMessage = (data is Map<String, dynamic>) ? data['message'] : null;
      final messageString = serverMessage is List ? serverMessage.first : serverMessage?.toString();
      return ApiFailure.fromStatusCode(statusCode, messageString);
    }
    return ApiFailure(
      type: ApiFailureType.unknown,
      message: e.message ?? 'An unexpected error occurred.',
    );
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final dio = ref.watch(apiClientProvider);
  return AuthNotifier(storage, dio);
});
