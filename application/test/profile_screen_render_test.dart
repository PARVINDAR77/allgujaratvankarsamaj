import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:application/features/profile/presentation/screens/profile_screen.dart';
import 'package:application/features/profile/providers/profile_provider.dart';
import 'package:application/shared/models/profile_model.dart';
import 'package:application/features/auth/providers/auth_provider.dart';
import 'package:application/features/auth/data/auth_models.dart';

void main() {
  testWidgets('ProfileScreen renders on desktop with fallback profile', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myProfileProvider.overrideWith((ref) async {
            throw Exception('Profile not found');
          }),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('ProfileScreen renders on desktop with valid profile data', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    const dummyProfile = ProfileModel(
      id: 'test-123',
      firstName: 'Parvindar',
      lastName: 'Panjabi',
      gender: 'Male (પુરુષ)',
      maritalStatus: 'Never Married (અપરિણીત)',
      dateOfBirth: '1995-05-15',
      education: 'B.Tech IT',
      employmentType: 'Private Job',
      department: 'Software',
      designation: 'Engineer',
      district: 'Ahmedabad',
      taluka: 'Ahmedabad',
      pargana: 'Ahmedabad',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myProfileProvider.overrideWith((ref) async => dummyProfile),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('Clicking Update Password opens dialog with password fields', (tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myProfileProvider.overrideWith((ref) async {
            throw Exception('Profile not found');
          }),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    
    // Find any widget containing 'પાસવર્ડ બદલો'
    final passwordBtn = find.textContaining('પાસવર્ડ બદલો');
    expect(passwordBtn, findsWidgets);

    // Tap the first one
    await tester.tap(passwordBtn.first);
    await tester.pumpAndSettle();

    // Verify dialog opened
    expect(find.textContaining('Update Password'), findsWidgets);
    expect(find.textContaining('Current Password'), findsOneWidget);
    expect(find.textContaining('New Password'), findsWidgets);
  });
}
