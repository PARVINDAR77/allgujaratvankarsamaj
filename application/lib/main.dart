import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VankarMatrimonyApp()));
}

class VankarMatrimonyApp extends ConsumerWidget {
  const VankarMatrimonyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Vankar Samaj Matrimony',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.secondary,
          secondary: AppColors.goldLight,
          surface: AppColors.background,
        ),
      ),
      routerConfig: router,
    );
  }
}
