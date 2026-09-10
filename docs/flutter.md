# Flutter Application Architecture (Step 8 — Authentication & API Integration)

## Overview
The Flutter user application (`application/`) serves as the mobile and web client for the **Vankar Samaj Matrimony** platform. It communicates strictly with the NestJS REST API (`/api/v1`) and never connects directly to PostgreSQL.

---

## Directory Structure
```text
application/
├── pubspec.yaml
├── analysis_options.yaml
├── test/
│   ├── widget_test.dart
│   └── features/
│       └── auth/
│           ├── auth_notifier_test.dart
│           └── auth_repository_test.dart
└── lib/
    ├── main.dart                  # Entry point with ProviderScope
    ├── app/
    │   ├── app.dart               # VankarMatrimonyApp with MaterialApp.router
    │   ├── router/
    │   │   └── app_router.dart    # GoRouter configuration & session redirection
    │   └── theme/
    │       ├── app_colors.dart    # Color palette tokens (Maroon, Amber, Slate)
    │       ├── app_text_styles.dart # Material 3 typography definitions
    │       └── app_theme.dart     # Light & Dark ThemeData configuration
    ├── core/
    │   ├── config/
    │   │   └── api_config.dart    # Platform-aware environment & base URL resolver
    │   ├── errors/
    │   │   └── app_exception.dart # Core exception hierarchy (Network, Server, Auth)
    │   ├── network/
    │   │   ├── auth_interceptor.dart # Attach Bearer token & redact sensitive log data
    │   │   └── dio_client.dart    # Configured Dio instance with interceptors
    │   └── storage/
    │       └── secure_storage_service.dart # Platform-safe JWT storage
    ├── features/
    │   └── auth/
    │       ├── data/
    │       │   ├── auth_api.dart        # Calls /auth/register, /auth/login, /auth/me
    │       │   ├── auth_models.dart     # UserModel, LoginResponse, DTOs
    │       │   └── auth_repository.dart # Orchestrates API & Secure Storage
    │       ├── providers/
    │       │   └── auth_provider.dart   # Riverpod AuthNotifier & AuthState
    │       └── presentation/
    │           ├── screens/
    │           │   ├── auth_loading_screen.dart # Initial session splash
    │           │   ├── login_screen.dart        # Login UI with form validation
    │           │   └── register_screen.dart     # Register UI with form validation
    │           └── widgets/
    │               └── auth_form_field.dart    # Custom Material 3 form field
    └── shared/
        ├── providers/
        │   └── api_config_provider.dart # Riverpod providers for ApiConfig & DioClient
        └── widgets/
            ├── app_loading.dart   # Standardized loading indicator
            ├── app_error.dart     # Standardized error display widget
            └── primary_button.dart# Standardized Material 3 action button
```

---

## Key Architectural Decisions

### 1. Platform-Safe JWT Secure Storage
The `SecureStorageService` (`lib/core/storage/secure_storage_service.dart`) handles JWT access token storage:
* Uses `flutter_secure_storage: ^9.2.2`.
* Configured with `AndroidOptions(encryptedSharedPreferences: true)`.
* Configured with `WebOptions(dbName: 'vankar_matrimony_secure_store', publicKey: 'vankar_matrimony_app_key')` for Web/Chrome target compatibility.

### 2. Networking & Sensitive Data Redaction
* **AuthInterceptor**: Automatically attaches `Authorization: Bearer <token>` to protected API requests (`/auth/me`).
* **Redaction Rules**: `Authorization` headers, `accessToken` strings, and `password` payload fields are strictly redacted in network logs.
* **401 Handling**: Authoritative session validation is performed by `/auth/me` via `AuthRepository`. 401 response on `/auth/me` triggers token deletion and sets state to `unauthenticated`.

### 3. Riverpod State & Protected Routing
* `AuthNotifier` manages `AuthState` (`initial`, `authenticated`, `unauthenticated`, `loading`, `error`).
* `GoRouter` guards protected routes:
  * Unauthenticated users attempting to access `/home` are redirected to `/login`.
  * Authenticated users attempting to access `/login` or `/register` are redirected to `/home`.

---

## Verification Results
- **Dependencies (`flutter pub get`)**: Resolved cleanly.
- **Static Analysis (`flutter analyze`)**: 0 issues found (`No issues found!`).
- **Unit Testing (`flutter test`)**: Passed 10/10 tests (`00:00 +10: All tests passed!`).
- **Live Backend Verification**: Verified `POST /auth/register`, `POST /auth/login`, `GET /auth/me` against containerized NestJS instance.
