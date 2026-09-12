import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Custom ScrollBehavior that completely hides scrollbars across all platforms
class NoScrollbarBehavior extends MaterialScrollBehavior {
  const NoScrollbarBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

/// Root Application Widget configuring Material App with GoRouter and Riverpod
class VankarMatrimonyApp extends ConsumerWidget {
  const VankarMatrimonyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Vankar Samaj Matrimony',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      scrollBehavior: const NoScrollbarBehavior(),
      routerConfig: router,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const NoScrollbarBehavior(),
          child: Container(
            color: const Color(0xFF0D2952),
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: ClipRect(
                child: child ?? const SizedBox(),
              ),
            ),
          ),
        );
      },
    );
  }
}
