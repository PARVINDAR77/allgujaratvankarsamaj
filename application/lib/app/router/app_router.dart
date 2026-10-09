import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/community/presentation/screens/pavan_prernadata_screen.dart';
import '../../features/community/presentation/screens/samaj_services_screen.dart';
import '../../features/community/presentation/screens/samaj_super_stars_screen.dart';
import '../../features/community/presentation/screens/samaj_super_stars_poster_screen.dart';
import '../../features/family/presentation/screens/family_details_screen.dart';
import '../../features/family/presentation/screens/family_directory_poster_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/match/presentation/screens/mutual_interest_screen.dart';
import '../../features/pargana/presentation/screens/pargana_overview_screen.dart';
import '../../features/profile/presentation/screens/create_profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/privacy_contact_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';
import '../../features/profile/presentation/screens/delete_account_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/profile_under_review_screen.dart';
import '../../features/profile/presentation/screens/verified_profile_screen.dart';
import '../../features/search/presentation/screens/advanced_search_screen.dart';
import '../../features/search/presentation/screens/search_results_screen.dart';
import '../../features/community/presentation/screens/samaj_ratna_screen.dart';
import '../../features/profile/presentation/screens/candidate_profile_detail_screen.dart';
import '../../features/profile/presentation/screens/liked_profiles_screen.dart';
import '../../shared/models/profile_model.dart';

import '../../shared/presentation/screens/main_navigation_screen.dart';
import '../../features/home/presentation/screens/main_poster_screen.dart';
import '../../features/home/presentation/screens/live_statistics_screen.dart';
import '../../features/home/presentation/screens/birthdays_screen.dart';
import '../../features/success_stories/presentation/screens/success_stories_screen.dart';
import '../../features/advertisements/presentation/screens/advertisements_screen.dart';
import '../../features/government_employees/presentation/screens/govt_employees_screen.dart';
import '../../features/government_employees/presentation/screens/private_employees_screen.dart';
import '../../features/education/presentation/screens/education_screen.dart';
import '../../features/chat/presentation/screens/chat_room_screen.dart';
import '../../features/chat/presentation/screens/conversations_list_screen.dart';

class AuthRouterListenable extends ChangeNotifier {
  AuthRouterListenable(Ref ref) {
    ref.listen<AuthState>(authNotifierProvider, (_, _) {
      notifyListeners();
    });
  }
}

final authRouterListenableProvider = Provider<AuthRouterListenable>((ref) {
  return AuthRouterListenable(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final authListenable = ref.watch(authRouterListenableProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final location = state.uri.toString();
      final isLoggingIn = location == '/login' || location == '/register';
      final isCommunityPublicRoute = location.startsWith('/pavan-prernadata') ||
          location.startsWith('/samaj-services') ||
          location.startsWith('/samaj-super-stars') ||
          location.startsWith('/government-employees');

      final isPublicRoute = isLoggingIn ||
          location == '/privacy-policy' ||
          location == '/delete-account' ||
          location == '/privacy-contact' ||
          isCommunityPublicRoute;

      if (authState.status == AuthStatus.initial) {
        return null;
      }

      if (!authState.isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      if (authState.isAuthenticated) {
        final user = authState.user;
        final hasProfile = user?.hasProfile ?? false;
        final isVerified = user?.isVerified ?? false;

        // If candidate has not yet created their profile:
        if (!hasProfile) {
          final isAllowedNoProfileRoute = location == '/profile/create' ||
              location == '/privacy-policy' ||
              location == '/delete-account' ||
              location == '/privacy-contact' ||
              isCommunityPublicRoute;

          if (!isAllowedNoProfileRoute) {
            return '/profile/create';
          }
          return null;
        }

        // If candidate created profile but is not yet approved by admin:
        if (!isVerified) {
          final isAllowedUnverifiedRoute = location == '/verified-profile' ||
              location == '/profile-under-review' ||
              location == '/profile/create' ||
              location == '/profile/edit' ||
              location == '/privacy-policy' ||
              location == '/delete-account' ||
              location == '/privacy-contact' ||
              isCommunityPublicRoute;

          if (!isAllowedUnverifiedRoute) {
            return '/profile-under-review';
          }
          return null;
        }

        // Verified member or admin attempting to visit auth pages or review page should go to /main-poster
        if (isLoggingIn || location == '/profile-under-review') {
          return '/main-poster';
        }
      }

      return null;
    },
    routes: [
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
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/main-poster',
        name: 'main-poster',
        builder: (context, state) => const MainPosterScreen(),
      ),
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        builder: (context, state) => const LiveStatisticsScreen(),
      ),
      GoRoute(
        path: '/birthdays',
        name: 'birthdays',
        builder: (context, state) => const BirthdaysScreen(),
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
        path: '/privacy-policy',
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/delete-account',
        name: 'delete-account',
        builder: (context, state) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: '/verified-profile',
        name: 'verified-profile',
        builder: (context, state) => const VerifiedProfileScreen(),
      ),
      GoRoute(
        path: '/profile/create',
        name: 'profile-create',
        builder: (context, state) => const CreateProfileScreen(),
      ),
      GoRoute(
        path: '/profile-under-review',
        name: 'profile-under-review',
        builder: (context, state) => const ProfileUnderReviewScreen(),
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
        path: '/pavan-prernadata',
        name: 'pavan-prernadata',
        builder: (context, state) => const PavanPrernadataScreen(),
      ),
      GoRoute(
        path: '/samaj-super-stars-poster',
        name: 'samaj-super-stars-poster',
        builder: (context, state) => const SamajSuperStarsPosterScreen(),
      ),
      GoRoute(
        path: '/family-directory-poster',
        name: 'family-directory-poster',
        builder: (context, state) => const FamilyDirectoryPosterScreen(),
      ),
      GoRoute(
        path: '/government-employees',
        name: 'government-employees',
        builder: (context, state) => const GovtEmployeesScreen(),
      ),
      GoRoute(
        path: '/samaj-ratna',
        name: 'samaj-ratna',
        builder: (context, state) => const SamajRatnaScreen(),
      ),
      GoRoute(
        path: '/education',
        name: 'education',
        builder: (context, state) => const EducationScreen(),
      ),
      GoRoute(
        path: '/advertisement',
        name: 'advertisement',
        builder: (context, state) {
          final placement = state.uri.queryParameters['placement'];
          return AdvertisementsScreen(placement: placement);
        },
      ),
      GoRoute(
        path: '/private-employees',
        name: 'private-employees',
        builder: (context, state) => const PrivateEmployeesScreen(),
      ),
      GoRoute(
        path: '/success-stories',
        name: 'success-stories',
        builder: (context, state) => const SuccessStoriesScreen(),
      ),
      GoRoute(
        path: '/search-results',
        name: 'search-results',
        builder: (context, state) {
          final gender = state.uri.queryParameters['gender'];
          final marital = state.uri.queryParameters['maritalStatus'] ?? state.uri.queryParameters['status'];
          return SearchResultsScreen(
            initialGender: gender,
            initialMaritalStatus: marital,
          );
        },
      ),
      GoRoute(
        path: '/candidate-profile-details',
        name: 'candidate-profile-details',
        builder: (context, state) {
          ProfileModel? profile;
          String? profileId = state.uri.queryParameters['id'] ?? state.uri.queryParameters['profileId'];

          if (state.extra is ProfileModel) {
            profile = state.extra as ProfileModel;
            profileId ??= profile.id;
          } else if (state.extra is String) {
            final str = (state.extra as String).trim();
            if (str.isNotEmpty) {
              profileId ??= str;
            }
          } else if (state.extra is Map) {
            final map = state.extra as Map;
            final extractedId = map['id'] ?? map['profileId'];
            if (extractedId != null && extractedId.toString().trim().isNotEmpty) {
              profileId ??= extractedId.toString().trim();
            }
            if (map.containsKey('firstName') ||
                map.containsKey('first_name') ||
                map.containsKey('fullName') ||
                map.containsKey('name')) {
              try {
                profile = ProfileModel.fromJson(Map<String, dynamic>.from(map));
              } catch (_) {}
            }
          }

          return CandidateProfileDetailScreen(
            profile: profile,
            profileId: profileId,
          );
        },
      ),
      GoRoute(
        path: '/liked-profiles',
        name: 'liked-profiles',
        builder: (context, state) => const LikedProfilesScreen(),
      ),
      GoRoute(
        path: '/profile-details',
        name: 'profile-details',
        builder: (context, state) {
          final profile = state.extra is ProfileModel ? state.extra as ProfileModel : null;
          final profileId = state.uri.queryParameters['id'];
          return CandidateProfileDetailScreen(
            profile: profile,
            profileId: profileId,
          );
        },
      ),
      GoRoute(
        path: '/conversations',
        name: 'conversations',
        builder: (context, state) => const ConversationsListScreen(),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        name: 'chat-room',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          return ChatRoomScreen(
            conversationId: conversationId,
            partnerName: extra?['partnerName']?.toString(),
            partnerPhotoUrl: extra?['partnerPhotoUrl']?.toString(),
            partnerGender: extra?['partnerGender']?.toString(),
          );
        },
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
                builder: (context, state) {
                  final lookingFor = state.uri.queryParameters['lookingFor'];
                  String? gender;
                  if (lookingFor != null) {
                    gender = (lookingFor.toLowerCase() == 'groom' || lookingFor.toLowerCase() == 'boy')
                        ? 'MALE'
                        : 'FEMALE';
                  } else {
                    gender = state.uri.queryParameters['gender'];
                  }
                  final marital = state.uri.queryParameters['maritalStatus'] ?? state.uri.queryParameters['status'];
                  return SearchResultsScreen(
                    initialGender: gender,
                    initialMaritalStatus: marital,
                  );
                },
              ),
              GoRoute(
                path: '/advanced-search',
                name: 'advanced-search',
                builder: (context, state) {
                  final lookingFor = state.uri.queryParameters['lookingFor'] ?? 'Groom';
                  return AdvancedSearchScreen(initialLookingFor: lookingFor);
                },
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
                builder: (context, state) => const ConversationsListScreen(),
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
                    name: 'profile-create-nested',
                    builder: (context, state) => const CreateProfileScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    name: 'profile-edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'under-review',
                    name: 'profile-under-review-nested',
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
