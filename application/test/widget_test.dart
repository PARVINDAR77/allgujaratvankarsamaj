import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vankar_samaj_matrimony/app/app.dart';

void main() {
  testWidgets('VankarMatrimonyApp renders auth splash screen initially', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: VankarMatrimonyApp(),
      ),
    );

    // Verify that splash screen content is displayed
    expect(find.text('Vankar Samaj Matrimony'), findsOneWidget);
    expect(find.text('Verifying session...'), findsOneWidget);
  });
}
