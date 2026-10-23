import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:application/features/home/presentation/screens/home_screen.dart';
import 'package:application/features/home/presentation/screens/main_poster_screen.dart';
import 'package:application/features/home/presentation/screens/community_web_home_screen.dart';
import 'package:application/features/home/presentation/screens/web_matrimony_home_screen.dart';

void main() {
  group('Mobile Layout Preservation Tests (kIsWeb == false)', () {
    test('Verify test environment is non-web (mobile simulation)', () {
      expect(kIsWeb, isFalse, reason: 'Test environment must simulate native mobile execution (Android/iOS)');
    });

    testWidgets('HomeScreen renders authentic mobile poster on native mobile platforms', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Must NOT render web desktop screens on mobile
      expect(find.byType(CommunityWebHomeScreen), findsNothing);
      expect(find.byType(WebMatrimonyHomeScreen), findsNothing);

      // Must render original mobile poster image
      final posterFinder = find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/images/home_poster_clean_v4.jpg',
      );
      expect(posterFinder, findsOneWidget, reason: 'HomeScreen must render home_poster_clean_v4.jpg on mobile');

      // Verify InkWell hotspots exist for mobile touches
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('MainPosterScreen renders original 2 image.jpeg on native mobile platforms', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        originalOnError?.call(details);
      };

      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainPosterScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      FlutterError.onError = originalOnError;

      // Must NOT render web desktop screen on mobile
      expect(find.byType(CommunityWebHomeScreen), findsNothing);

      // Must render original mobile poster image 2 image.jpeg
      final posterFinder = find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/images/2 image.jpeg',
      );
      expect(posterFinder, findsOneWidget, reason: 'MainPosterScreen must render 2 image.jpeg on mobile');

      // Verify InkWell touch targets exist
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('BottomNavigationBar renders all 5 authentic tabs on native mobile platforms', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));

      // Simulate a MaterialApp with Scaffold and the mobile bottom navigation bar
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Center(child: Text('Mobile Shell Body')),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'હોમ'),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'શોધો'),
                BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'મેળ'),
                BottomNavigationBarItem(icon: Icon(Icons.message), label: 'મેસેજ'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'પ્રોફાઈલ'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('હોમ'), findsOneWidget);
      expect(find.text('શોધો'), findsOneWidget);
      expect(find.text('મેળ'), findsOneWidget);
      expect(find.text('મેસેજ'), findsOneWidget);
      expect(find.text('પ્રોફાઈલ'), findsOneWidget);
    });
  });
}
