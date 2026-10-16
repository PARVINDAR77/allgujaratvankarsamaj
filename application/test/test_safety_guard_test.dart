import 'package:flutter_test/flutter_test.dart';
import 'package:application/core/config/app_config.dart';
import 'test_safety_guard.dart';

void main() {
  group('Test Safety Guard Verification', () {
    test('MUST reject production domain https://allgujaratvankarsamaj.com/api/v1', () {
      expect(
        () => enforceTestUrlSafety('https://allgujaratvankarsamaj.com/api/v1'),
        throwsA(isA<StateError>()),
      );
    });

    test('MUST reject production IP address http://217.21.94.138:3000/api/v1', () {
      expect(
        () => enforceTestUrlSafety('http://217.21.94.138:3000/api/v1'),
        throwsA(isA<StateError>()),
      );
    });

    test('MUST reject production admin subdomain https://admin.allgujaratvankarsamaj.com', () {
      expect(
        () => enforceTestUrlSafety('https://admin.allgujaratvankarsamaj.com'),
        throwsA(isA<StateError>()),
      );
    });

    test('MUST reject production configuration from AppConfig.baseUrl', () {
      if (AppConfig.baseUrl.contains('allgujaratvankarsamaj.com')) {
        expect(
          () => enforceTestUrlSafety(AppConfig.baseUrl),
          throwsA(isA<StateError>()),
        );
      }
    });

    test('MUST permit local mock or test URLs', () {
      expect(() => enforceTestUrlSafety('http://127.0.0.1:3000/api/v1'), returnsNormally);
      expect(() => enforceTestUrlSafety('http://localhost:3000/api/v1'), returnsNormally);
      expect(() => enforceTestUrlSafety('http://10.0.2.2:3000/api/v1'), returnsNormally);
    });
  });
}
