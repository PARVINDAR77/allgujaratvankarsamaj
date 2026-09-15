import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/community/presentation/screens/samaj_services_screen.dart';
import '../../features/community/presentation/screens/samaj_super_stars_screen.dart';
import '../../features/government_employees/presentation/screens/govt_employees_screen.dart';
import '../../features/family/presentation/screens/family_details_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/match/presentation/screens/mutual_interest_screen.dart';
import '../../features/pargana/presentation/screens/pargana_overview_screen.dart';
import '../../features/profile/presentation/screens/create_profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/privacy_contact_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/profile_under_review_screen.dart';
import '../../features/profile/presentation/screens/verified_profile_screen.dart';
import '../../features/search/presentation/screens/advanced_search_screen.dart';
import '../../shared/presentation/screens/main_navigation_screen.dart';

/// Helper to convert AuthNotifier changes into a Listenable for GoRouter refresh
class AuthRouterListenable extends ChangeNotifier {
  AuthRouterListenable(Ref ref) {
    ref.listen<AuthState>(authNotifierProvider, (_, __) {
      notifyListeners();
    });
  }
}

final authRouterListenableProvider = Provider<AuthRouterListenable>((ref) {
  return AuthRouterListenable(ref);
});

/// Central GoRouter configuration with Riverpod authentication state redirection
final appRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = ref.watch(authRouterListenableProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final location = state.uri.toString();

      // Redirect welcome/splash/poster or root to /login
      if (location == '/welcome' || location == '/splash' || location == '/poster') {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          final pageParam = state.uri.queryParameters['page'];
          final initialPage = (pageParam != null && pageParam == '1') ? 1 : 0;
          return LoginScreen(initialPage: initialPage);
        },
      ),
      GoRoute(
        path: '/poster',
        name: 'poster',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/family-details',
        name: 'family-details',
        builder: (context, state) => const FamilyDetailsScreen(),
      ),
      GoRoute(
        path: '/pargana-overview',
        name: 'pargana-overview',
        builder: (context, state) => const ParganaOverviewScreen(),
      ),
      GoRoute(
        path: '/privacy-contact',
        name: 'privacy-contact',
        builder: (context, state) => const PrivacyContactScreen(),
      ),
      GoRoute(
        path: '/verified-profile',
        name: 'verified-profile',
        builder: (context, state) => const VerifiedProfileScreen(),
      ),
      GoRoute(
        path: '/samaj-services',
        name: 'samaj-services',
        builder: (context, state) => const SamajServicesScreen(),
      ),
      GoRoute(
        path: '/samaj-super-stars',
        name: 'samaj-super-stars',
        builder: (context, state) => const SamajSuperStarsScreen(),
      ),
      GoRoute(
        path: '/government-employees',
        name: 'government-employees',
        builder: (context, state) => const GovtEmployeesScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: 'search',
                builder: (context, state) => const AdvancedSearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/match',
                name: 'match',
                builder: (context, state) => const MutualInterestScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                name: 'messages',
                builder: (context, state) => Scaffold(
                  backgroundColor: const Color(0xFF061121),
                  appBar: AppBar(
                    title: const Text('Messages (મેસેજ)', style: TextStyle(color: Color(0xFFFFD700))),
                    backgroundColor: const Color(0xFF061121),
                    iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
                  ),
                  body: const Center(
                    child: Text('No active conversations', style: TextStyle(color: Colors.white70)),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: 'profile-create',
                    builder: (context, state) => const CreateProfileScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    name: 'profile-edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'under-review',
                    name: 'profile-under-review',
                    builder: (context, state) => const ProfileUnderReviewScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});
