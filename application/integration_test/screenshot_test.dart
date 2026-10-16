import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:application/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture Screenshots for PlayStore', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: VankarMatrimonyApp()));

    // Wait for initial routing and animations to finish
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 3));

    // Capture the Home / Initial screen
    await takeScreenshot(binding, '01_home_screen');

    // NOTE: To capture other sections, you would simulate taps here,
    // wait for the new page to settle, and then call takeScreenshot.
    // Example:
    // await tester.tap(find.text('Login'));
    // await tester.pumpAndSettle();
    // await takeScreenshot(binding, '02_login_screen');

  });
}

Future<void> takeScreenshot(IntegrationTestWidgetsFlutterBinding binding, String name) async {
  print('Taking screenshot: $name');
  final List<int> bytes = await binding.takeScreenshot(name);
  
  final Directory dir = Directory('screenshots');
  if (!dir.existsSync()) {
    dir.createSync();
  }
  
  final File file = File('${dir.path}/$name.png');
  await file.writeAsBytes(bytes);
  print('Screenshot saved to: ${file.path}');
}
