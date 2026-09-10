import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:vankar_samaj_matrimony/core/errors/app_exception.dart';
import 'package:vankar_samaj_matrimony/features/profile/data/profile_models.dart';
import 'package:vankar_samaj_matrimony/features/profile/data/profile_repository.dart';
import 'package:vankar_samaj_matrimony/features/profile/providers/profile_provider.dart';
import 'profile_notifier_test.mocks.dart';

/// Helper: creates a test notifier from a mock repository.
ProfileNotifier _makeNotifier(MockProfileRepository repo) =>
    ProfileNotifier(repo);

MatrimonialProfileModel _buildProfile() => MatrimonialProfileModel(
      id: 'profile-uuid-1',
      userId: 'user-uuid-1',
      firstName: 'Ramesh',
      lastName: 'Parmar',
      dateOfBirth: DateTime(1995, 8, 15),
      gender: 'MALE',
      maritalStatus: 'NEVER_MARRIED',
    );

ReferenceDataModel _buildRefData() => const ReferenceDataModel(
      gender: ['MALE', 'FEMALE', 'OTHER'],
      maritalStatus: ['NEVER_MARRIED', 'DIVORCED', 'WIDOWED', 'SEPARATED'],
    );

CompletenessModel _buildCompleteness({int percentage = 38}) =>
    CompletenessModel(
      completedFields: 5,
      totalFields: 13,
      percentage: percentage,
      isComplete: percentage == 100,
    );

@GenerateMocks([ProfileRepository])
void main() {
  late MockProfileRepository mockRepo;
  late ProfileNotifier notifier;

  setUp(() {
    mockRepo = MockProfileRepository();
    notifier = _makeNotifier(mockRepo);
  });

  // ─── Initial state ──────────────────────────────────────────────────────────

  test('initial state is ProfileStatus.initial', () {
    expect(notifier.state.status, equals(ProfileStatus.initial));
    expect(notifier.state.profile, isNull);
  });

  // ─── loadProfile ────────────────────────────────────────────────────────────

  group('loadProfile', () {
    test('transitions to loaded on successful fetch', () async {
      when(mockRepo.getReferenceData())
          .thenAnswer((_) async => _buildRefData());
      when(mockRepo.getMyProfile()).thenAnswer((_) async => _buildProfile());
      when(mockRepo.getCompleteness())
          .thenAnswer((_) async => _buildCompleteness());

      await notifier.loadProfile();

      expect(notifier.state.status, equals(ProfileStatus.loaded));
      expect(notifier.state.profile?.firstName, equals('Ramesh'));
      expect(notifier.state.completeness?.percentage, equals(38));
      expect(notifier.state.referenceData?.gender, contains('MALE'));
    });

    test('transitions to empty on ProfileNotFoundException (no profile yet)',
        () async {
      when(mockRepo.getReferenceData())
          .thenAnswer((_) async => _buildRefData());
      when(mockRepo.getMyProfile())
          .thenThrow(const ProfileNotFoundException());

      await notifier.loadProfile();

      expect(notifier.state.status, equals(ProfileStatus.empty));
      expect(notifier.state.profile, isNull);
      expect(notifier.state.completeness?.percentage, equals(0));
      expect(notifier.state.referenceData, isNotNull);
    });

    test('transitions to error on network failure', () async {
      when(mockRepo.getReferenceData())
          .thenThrow(const NetworkException('No network'));

      await notifier.loadProfile();

      expect(notifier.state.status, equals(ProfileStatus.error));
      expect(notifier.state.errorMessage, isNotNull);
    });
  });

  // ─── createProfile ──────────────────────────────────────────────────────────

  group('createProfile', () {
    test('transitions to loaded on success and returns true', () async {
      // Pre-populate ref data
      when(mockRepo.getReferenceData())
          .thenAnswer((_) async => _buildRefData());
      when(mockRepo.getMyProfile()).thenThrow(const ProfileNotFoundException());
      await notifier.loadProfile();

      const request = CreateProfileRequest(
        firstName: 'Ramesh',
        lastName: 'Parmar',
        dateOfBirth: '1995-08-15',
        gender: 'MALE',
        maritalStatus: 'NEVER_MARRIED',
      );
      when(mockRepo.createProfile(request))
          .thenAnswer((_) async => _buildProfile());
      when(mockRepo.getCompleteness())
          .thenAnswer((_) async => _buildCompleteness());

      final success = await notifier.createProfile(request);

      expect(success, isTrue);
      expect(notifier.state.status, equals(ProfileStatus.loaded));
      expect(notifier.state.profile?.firstName, equals('Ramesh'));
    });

    test('transitions to error on API failure and returns false', () async {
      const request = CreateProfileRequest(
        firstName: 'Ramesh',
        lastName: 'Parmar',
        dateOfBirth: '1995-08-15',
        gender: 'MALE',
        maritalStatus: 'NEVER_MARRIED',
      );
      when(mockRepo.createProfile(request))
          .thenThrow(const ServerException('Profile already exists', 409));

      final success = await notifier.createProfile(request);

      expect(success, isFalse);
      expect(notifier.state.status, equals(ProfileStatus.error));
    });
  });

  // ─── updateProfile ──────────────────────────────────────────────────────────

  group('updateProfile', () {
    test('transitions to loaded with updated profile on success', () async {
      when(mockRepo.getReferenceData())
          .thenAnswer((_) async => _buildRefData());
      when(mockRepo.getMyProfile()).thenAnswer((_) async => _buildProfile());
      when(mockRepo.getCompleteness())
          .thenAnswer((_) async => _buildCompleteness());
      await notifier.loadProfile();

      const request = UpdateProfileRequest(city: 'Surat');
      final updated = MatrimonialProfileModel(
        id: 'profile-uuid-1',
        userId: 'user-uuid-1',
        firstName: 'Ramesh',
        lastName: 'Parmar',
        dateOfBirth: DateTime(1995, 8, 15),
        gender: 'MALE',
        maritalStatus: 'NEVER_MARRIED',
        city: 'Surat',
      );
      when(mockRepo.updateProfile(request)).thenAnswer((_) async => updated);
      when(mockRepo.getCompleteness())
          .thenAnswer((_) async => _buildCompleteness());

      final success = await notifier.updateProfile(request);

      expect(success, isTrue);
      expect(notifier.state.status, equals(ProfileStatus.loaded));
      expect(notifier.state.profile?.city, equals('Surat'));
    });
  });

  // ─── deleteProfile ──────────────────────────────────────────────────────────

  group('deleteProfile', () {
    test('transitions to EMPTY (not logout) on success and returns true',
        () async {
      when(mockRepo.getReferenceData())
          .thenAnswer((_) async => _buildRefData());
      when(mockRepo.getMyProfile()).thenAnswer((_) async => _buildProfile());
      when(mockRepo.getCompleteness())
          .thenAnswer((_) async => _buildCompleteness());
      await notifier.loadProfile();

      when(mockRepo.deleteProfile()).thenAnswer((_) async {});

      final success = await notifier.deleteProfile();

      expect(success, isTrue);
      // Critical: user is NOT logged out — status is empty, not initial/unauthenticated
      expect(notifier.state.status, equals(ProfileStatus.empty));
      expect(notifier.state.profile, isNull);
      // Reference data is preserved so user can create a new profile immediately
      expect(notifier.state.referenceData, isNotNull);
    });

    test('transitions to error when API fails and returns false', () async {
      when(mockRepo.deleteProfile())
          .thenThrow(const ServerException('Profile not found', 404));

      final success = await notifier.deleteProfile();

      expect(success, isFalse);
      expect(notifier.state.status, equals(ProfileStatus.error));
    });
  });
}
