import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:vankar_samaj_matrimony/features/profile/data/profile_api.dart';
import 'package:vankar_samaj_matrimony/features/profile/data/profile_models.dart';
import 'package:vankar_samaj_matrimony/features/profile/data/profile_repository.dart';
import 'package:vankar_samaj_matrimony/core/errors/app_exception.dart';
import 'profile_repository_test.mocks.dart';

/// Builds a canonical MatrimonialProfileModel for test use.
MatrimonialProfileModel _buildProfile() => MatrimonialProfileModel(
      id: 'profile-uuid-1',
      userId: 'user-uuid-1',
      firstName: 'Ramesh',
      lastName: 'Parmar',
      dateOfBirth: DateTime(1995, 8, 15),
      gender: 'MALE',
      maritalStatus: 'NEVER_MARRIED',
      religion: 'Hindu',
      caste: 'Vankar',
      city: 'Ahmedabad',
      state: 'Gujarat',
      country: 'India',
      education: 'B.Tech',
      occupation: 'Software Engineer',
      about: 'Family-oriented professional.',
    );

/// Builds sample reference data.
ReferenceDataModel _buildRefData() => const ReferenceDataModel(
      gender: ['MALE', 'FEMALE', 'OTHER'],
      maritalStatus: [
        'NEVER_MARRIED',
        'DIVORCED',
        'WIDOWED',
        'SEPARATED',
      ],
    );

/// Builds a sample completeness model.
CompletenessModel _buildCompleteness() => const CompletenessModel(
      completedFields: 13,
      totalFields: 13,
      percentage: 100,
      isComplete: true,
    );

@GenerateMocks([ProfileApi])
void main() {
  late MockProfileApi mockApi;
  late ProfileRepository repository;

  setUp(() {
    mockApi = MockProfileApi();
    repository = ProfileRepository(api: mockApi);
  });

  // ─── getMyProfile ───────────────────────────────────────────────────────────

  group('getMyProfile', () {
    test('returns MatrimonialProfileModel on success', () async {
      when(mockApi.getMyProfile()).thenAnswer((_) async => _buildProfile());

      final result = await repository.getMyProfile();

      expect(result.id, equals('profile-uuid-1'));
      expect(result.firstName, equals('Ramesh'));
      expect(result.gender, equals('MALE'));
      verify(mockApi.getMyProfile()).called(1);
    });

    test('throws ProfileNotFoundException when API returns 404', () async {
      when(mockApi.getMyProfile())
          .thenThrow(const ServerException('Profile not found', 404));

      expect(
        () => repository.getMyProfile(),
        throwsA(isA<ProfileNotFoundException>()),
      );
    });

    test('rethrows UnauthorizedException on 401', () async {
      when(mockApi.getMyProfile())
          .thenThrow(const UnauthorizedException('Unauthorized'));

      expect(
        () => repository.getMyProfile(),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('rethrows ServerException on 500', () async {
      when(mockApi.getMyProfile())
          .thenThrow(const ServerException('Internal server error', 500));

      expect(
        () => repository.getMyProfile(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ─── createProfile ──────────────────────────────────────────────────────────

  group('createProfile', () {
    test('returns created MatrimonialProfileModel on success', () async {
      const request = CreateProfileRequest(
        firstName: 'Ramesh',
        lastName: 'Parmar',
        dateOfBirth: '1995-08-15',
        gender: 'MALE',
        maritalStatus: 'NEVER_MARRIED',
      );
      when(mockApi.createProfile(request))
          .thenAnswer((_) async => _buildProfile());

      final result = await repository.createProfile(request);

      expect(result.firstName, equals('Ramesh'));
      verify(mockApi.createProfile(request)).called(1);
    });

    test('throws ServerException(409) when profile already exists', () async {
      const request = CreateProfileRequest(
        firstName: 'Ramesh',
        lastName: 'Parmar',
        dateOfBirth: '1995-08-15',
        gender: 'MALE',
        maritalStatus: 'NEVER_MARRIED',
      );
      when(mockApi.createProfile(request))
          .thenThrow(const ServerException('Profile already exists', 409));

      expect(
        () => repository.createProfile(request),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ─── updateProfile ──────────────────────────────────────────────────────────

  group('updateProfile', () {
    test('returns updated MatrimonialProfileModel on success', () async {
      const request = UpdateProfileRequest(city: 'Surat', state: 'Gujarat');
      final updated = _buildProfile();
      when(mockApi.updateProfile(request)).thenAnswer((_) async => updated);

      final result = await repository.updateProfile(request);

      expect(result.id, equals('profile-uuid-1'));
      verify(mockApi.updateProfile(request)).called(1);
    });
  });

  // ─── deleteProfile ──────────────────────────────────────────────────────────

  group('deleteProfile', () {
    test('completes without error on success', () async {
      when(mockApi.deleteProfile()).thenAnswer((_) async {});

      await expectLater(repository.deleteProfile(), completes);
      verify(mockApi.deleteProfile()).called(1);
    });

    test('throws ServerException(404) when profile not found', () async {
      when(mockApi.deleteProfile())
          .thenThrow(const ServerException('Profile not found', 404));

      expect(
        () => repository.deleteProfile(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ─── getReferenceData ───────────────────────────────────────────────────────

  group('getReferenceData', () {
    test('returns ReferenceDataModel with gender and maritalStatus arrays',
        () async {
      when(mockApi.getReferenceData())
          .thenAnswer((_) async => _buildRefData());

      final result = await repository.getReferenceData();

      expect(result.gender, containsAll(['MALE', 'FEMALE', 'OTHER']));
      expect(result.maritalStatus, hasLength(4));
    });
  });

  // ─── getCompleteness ────────────────────────────────────────────────────────

  group('getCompleteness', () {
    test('returns CompletenessModel with correct values', () async {
      when(mockApi.getCompleteness())
          .thenAnswer((_) async => _buildCompleteness());

      final result = await repository.getCompleteness();

      expect(result.percentage, equals(100));
      expect(result.isComplete, isTrue);
      expect(result.totalFields, equals(13));
    });
  });
}
