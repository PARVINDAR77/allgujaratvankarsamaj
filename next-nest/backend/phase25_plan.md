# Phase 25: Flutter API Integration — Audit & Execution Plan

## 1. Audit Findings

I have completed a thorough audit of the Flutter repository (`d:\vankarsamajmatrimony\application`) to assess its readiness for integration with the NestJS backend.

### API Infrastructure
* **Global Dio Client**: ❌ **No**. There is no centralized API client. A one-off `Dio` provider is defined inline inside `statistics_api.dart`.
* **API Base URL**: ⚠️ Defined in `core/config/app_config.dart`. It uses `String.fromEnvironment('ENV')` with a default of `10.0.2.2:3000/api/v1` (for Android Emulator), which is correct for development but is safely separated from staging/production URLs. However, current API implementations (like `statistics_api.dart`) hardcode `localhost:3000` and bypass this config entirely.
* **JWT Storage**: ✅ `flutter_secure_storage` is correctly set up in `SecureStorageService`.
* **Auth Interceptor & Token Refresh**: ❌ **No**. Neither exists.
* **HTTP Client Consistency**: ❌ The app mixes `dio` (`statistics_api.dart`) and `http` (`samaj_services_repository.dart`).

### Repositories & Data Models
* **Existing Repositories**: Only `DirectoryRepository` and `SamajServiceRepository` exist. Both return either hardcoded mock objects or unhandled HTTP responses. There is no `ProfileRepository` or `AuthRepository`.
* **Existing API Models**: `DirectoryDistrict`, `DirectoryPargana`, `DirectoryTaluka`, `DirectoryLocation`, `ProfileModel`, `SamajService`, and `UserModel`. There are no duplicate models, but they lack complete `fromJson` implementations for robust API parsing.
* **Mock / Hardcoded Business Data**: ⚠️ **Extensive**. Almost every Flutter screen (Profiles, Auth, Directory, Matches) relies directly on hardcoded state inside Riverpod providers (e.g., `ProfileNotifier` returns dummy profiles, `AuthNotifier` returns a `dummy_jwt_token_123` and a hardcoded user identity).
* **Missing Endpoints**: Everything except `/samaj-services` and `/statistics/*` needs to be wired up. This includes Authentication, Profiles, Matches, and the Directory API.
* **PostgreSQL References**: ✅ **0 matches**. No legacy DB references exist in the Flutter app.

### Contracts & Error Handling
* **Pagination & API Errors**: ❌ No standard pagination or error contracts exist in the Flutter app.
* **HTTP Status Code Handling (401, 403, 404, etc.)**: ❌ None. Exceptions are thrown wildly.
* **Loading/Empty/Error States**: Partially supported via Riverpod's `AsyncValue` in some UI components, but not standardized or guaranteed to handle network faults gracefully.
* **Route Guards**: ✅ **Yes**. `GoRouter` in `app_router.dart` already implements an authenticated redirect guard based on `AuthState.isAuthenticated`.

---

## 2. Minimal Required Changes (Execution Plan)

To meet the Phase 25 goal (proving a complete end-to-end flow from NestJS to the Flutter UI) without triggering a massive rewrite, I propose the following targeted implementation plan:

### Step 1: Centralized API Infrastructure (`lib/core/api`)
1. Create a `DioClient` singleton that consumes `AppConfig.baseUrl`.
2. Implement an `AuthInterceptor` that attaches the JWT from `SecureStorageService` to all requests.
3. Add a global error interceptor to translate 401s into `AuthStatus.unauthenticated`.

### Step 2: Authentication Wiring (`lib/features/auth`)
1. Create an `AuthRepository` that points to `POST /api/v1/auth/login`.
2. Connect `auth_provider.dart` to `AuthRepository` instead of returning mock tokens.
3. Validate that successful login persists the JWT and satisfies the `GoRouter` redirect.

### Step 3: Targeted Feature Integration (`lib/features/profile` & `lib/shared/repositories`)
1. Replace the mock array in `profile_provider.dart` with a call to a new `ProfileRepository` pointing at `GET /api/v1/profiles`.
2. Refactor `samaj_services_repository.dart` and `statistics_api.dart` to use the centralized `DioClient` instead of raw `http` or inline `Dio`.
3. Add error states for failed connections (e.g., 500s or timeouts).

### Step 4: End-to-End Validation
1. Boot the NestJS API connected to MySQL 8.0.
2. Log into the Flutter app via the Android Emulator (`10.0.2.2`).
3. Verify that real records (and no mock data) propagate to the Profile list and Home Dashboard.
4. Verify that loading, empty, and connection error states render cleanly in the UI.

This approach guarantees a complete data pipeline validation without over-engineering features that haven't been fully spec'd yet.

Are you ready to authorize the implementation of Phase 25 based on this execution plan?
