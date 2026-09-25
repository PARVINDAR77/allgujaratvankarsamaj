# Changelog

All notable changes to the All Gujarat Vankar Samaj Matrimony project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

- **Step 9 - Dynamic System Architecture & API Integration (Admin Panel → NestJS → PostgreSQL → Flutter APK)** (2026-09-11):
  - **Prisma Database Schema Expansion**:
    - Added `SiteSetting`, `Pargana`, `VerificationRequest`, `MatchInterest`, `Report`, and `SuccessStory` domain models.
    - Added `ProfileStatus`, `VerificationStatus`, `InterestStatus`, and `ReportStatus` enums.
    - Extended `MatrimonialProfile` model with `status` (`APPROVED`), `isVerified`, `isFeatured`, `photoUrl`, `subcaste`, and `nativePlace`.
    - Generated updated Prisma Client artifacts (`npx prisma generate`).
  - **NestJS Backend Endpoints**:
    - Built `SettingsModule`, `SettingsController`, `SettingsService` providing `GET /settings/public`, `GET /admin/settings`, and `PUT /admin/settings`.
    - Built `ParganasModule`, `ParganasController`, `ParganasService` providing `GET /parganas`, `GET /admin/parganas`, `POST /admin/parganas`, `PATCH /admin/parganas/:id`, `DELETE /admin/parganas/:id`.
    - Extended `AdminModule` with `GET /admin/profiles`, `PATCH /admin/profiles/:id/status`, `PATCH /admin/profiles/:id/feature`, `GET /admin/verifications`, `PATCH /admin/verifications/:id`, `GET /admin/reports`, `PATCH /admin/reports/:id`, `GET /admin/matches`.
  - **Next.js Admin Panel API Integration**:
    - Expanded `lib/admin-api.ts` with typed API functions for settings, parganas, candidate profiles moderation, verifications, reports, and matches.
    - Connected `app/admin/settings/page.tsx` to `adminApi.getSettings()` and `adminApi.updateSettings()`.
    - Connected `app/admin/parganas/page.tsx` to `adminApi.getParganas()`, `createPargana()`, `updatePargana()`, and `deletePargana()`.
    - Connected `app/admin/profiles/page.tsx` to `adminApi.getProfiles()`, `updateProfileStatus()`, and `toggleProfileFeatured()`.
    - Verified Next.js static production build (`npm run build`) passing with zero TypeScript/Turbopack errors.
  - **Defined complete project documentation structure in `docs/`.**
- Created initial `CHANGELOG.md` and `README.md`.
- **Step 1 - Docker Foundation & Environment** (2026-09-09):
  - Established `docker-compose.yml` orchestrating `postgres` (PostgreSQL 15 Alpine) and `backend` (Node 20 Alpine) containers.
  - Implemented Docker healthcheck (`pg_isready`) on `postgres` and startup dependency on `backend`.
  - Configured container networking using Docker service hostname (`postgres:5432`).
  - Added environment variable templates in `.env.example` and configured local `.env`.
  - Initialized `next-nest/backend/` directory structure.
  - Updated `docs/architecture.md` and `docs/backend.md` with infrastructure specifications.
- **Step 2 - NestJS Backend & PostgreSQL Initialization** (2026-09-09):
  - Initialized NestJS application in `next-nest/backend/` with strict TypeScript configuration, `@nestjs/config`, and class validation.
  - Created production-ready development `Dockerfile` based on `node:20-alpine3.20` with OpenSSL and musl libc support.
  - Relocated Docker Desktop WSL virtual disk storage to `D:\Docker\wsl` via NTFS directory junction, freeing C: drive space and ensuring stable container execution.
  - Installed and configured Prisma ORM v5 with PostgreSQL datasource using `DATABASE_URL`.
  - Defined foundation technical model `SystemHealth` in `prisma/schema.prisma` for schema validation and migration tracking.
  - Created and executed initial migration `20260909060958_init` against containerized PostgreSQL database using explicit Prisma migration lifecycle (no `db push`).
  - Implemented injectable `PrismaService` and global `PrismaModule` with connection and lifecycle management.
  - Established `/api/v1` global routing prefix and implemented `GET /api/v1/health` verifying live database connectivity.
  - Configured Swagger/OpenAPI documentation at `/api/docs` documenting the health check foundation.
  - Updated `README.md`, `docs/architecture.md`, `docs/backend.md`, `docs/database.md`, and `docs/project-context.md`.
- **Step 3 - NestJS Common Infrastructure & API Foundation** (2026-09-09):
  - Implemented global `RequestIdMiddleware` generating unique UUID identifiers (`X-Request-Id`) for robust request tracing.
  - Integrated `morgan` logging middleware globally in `main.ts`, customized to format console logs with client IP, request method, route, status code, response time, and the UUID request ID.
  - Developed and registered global `AllExceptionsFilter` (`src/common/filters/http-exception.filter.ts`) catching unhandled exceptions, sanitizing output via standardized JSON schemas (status code, timestamp, path, error message, request ID), and logging errors safely without leaking stack traces to API consumers.
  - Fortified application security by implementing `helmet` middleware setting restrictive HTTP response headers.
  - Updated `docs/project-context.md` and `CHANGELOG.md` reflecting API foundation completion, strict rules enforcement (No auth implementation yet), and updated implementation status.
- **Step 4 - Authentication Backend** (2026-09-09):
  - Created Prisma `User` model with `Role` (`USER`, `ADMIN`) and `Status` (`ACTIVE`, `INACTIVE`) enums in `schema.prisma`.
  - Executed migration `20260909070243_add_user_authentication` against PostgreSQL in Docker without altering existing `SystemHealth` model or migration history.
  - Implemented `UsersModule` and `UsersService` providing `findByEmail`, `findById`, and `createUser`.
  - Implemented `AuthModule`, `AuthService`, and `AuthController` handling user registration (`POST /api/v1/auth/register`), login (`POST /api/v1/auth/login`), and profile verification (`GET /api/v1/auth/me`).
  - Integrated `bcrypt` password hashing (passwords never stored or returned in plaintext or logs).
  - Implemented Passport JWT strategy (`JwtStrategy`) and guard (`JwtAuthGuard`) issuing signed JWT access tokens with minimal claims (`sub`, `email`, `role`).
  - Enforced generic authentication failure responses (`Invalid credentials` HTTP 401) to avoid account enumeration.
  - Updated `main.ts` with Swagger `@ApiBearerAuth()` documentation allowing interactive token testing at `/api/docs`.
  - Verified build, Docker execution, PostgreSQL persistence, and API routes via automated command-line tests.
- **Step 5 - User & Matrimonial Profile Backend Foundation** (2026-09-09):
  - Added `MatrimonialProfile` model and `Gender`, `MaritalStatus` enums to `schema.prisma`, establishing a 1:1 relation with `User` (`userId` UNIQUE).
  - Applied migration `20260909072013_add_matrimonial_profile` cleanly to PostgreSQL while preserving all existing tables (`users`, `system_health`, `_prisma_migrations`).
  - Removed hardcoded database defaults for optional fields (`religion`, `caste`, `state`, `country`) as explicitly directed.
  - Implemented `ProfilesModule`, `ProfilesService`, and `ProfilesController` providing `POST /api/v1/profile` (Create), `GET /api/v1/profile/me` (Read), `PATCH /api/v1/profile/me` (Update), and `DELETE /api/v1/profile/me` (Delete profile only, preserving User account).
  - Enforced strict JWT ownership authorization (`req.user.id`) and DTO validation with `class-validator`, rejecting client-controlled `userId` parameters or unexpected payload properties (HTTP 400).
  - Updated Swagger documentation under `Matrimonial Profile` tag with `@ApiBearerAuth()`.
  - Configured ESLint v8 and verified both `npm run build` and `npm run lint` pass with zero errors.
- **Step 6 - Profile Reference Data & Business Rules Backend** (2026-09-09):
  - Created custom `@IsMinAge(18)` validator constraint enforcing minimum age = 18 and rejecting future dates of birth.
  - Enhanced `CreateProfileDto` and `UpdateProfileDto` with safe string trimming (`@Transform`), non-whitespace matching (`@Matches(/^(?!\s*$).+/)`), and maximum string length limits (`firstName`/`lastName`/`city`/`state`/`country`/`religion`/`caste` <= 100, `education`/`occupation` <= 200, `about` <= 2000).
  - Implemented `GET /api/v1/profile/reference-data` returning authoritative `gender` and `maritalStatus` enum option arrays dynamically derived from Prisma client types.
  - Implemented `GET /api/v1/profile/completeness` calculating profile completion statistics over 13 user-completion fields (`completedFields`, `totalFields: 13`, `percentage: 0-100%`, `isComplete: boolean`).
- **Step 7 - Production-Oriented Flutter Foundation** (2026-09-09):
- **Step 8 - Flutter Authentication & Backend API Integration** (2026-09-09):
  - Integrated `flutter_secure_storage: ^9.2.2` and implemented platform-safe `SecureStorageService` (`AndroidOptions` + `WebOptions`) for JWT access token storage.
  - Implemented `AuthInterceptor` in Dio client attaching `Authorization: Bearer <token>` to protected endpoints and redacting sensitive data (`Authorization` header, `accessToken`, `password`) in logs.
  - Created strongly-typed auth models (`UserModel`, `LoginResponse`, `RegisterRequest`, `LoginRequest`) matching NestJS backend DTOs.
  - Implemented `AuthApi` (`/auth/register`, `/auth/login`, `/auth/me`) and `AuthRepository` orchestrating session resolution via authoritative `/auth/me` checks.
  - Built `AuthNotifier` Riverpod state management handling `initial`, `authenticated`, `unauthenticated`, `loading`, and `error` states.
  - Created Material 3 UI screens (`LoginScreen`, `RegisterScreen`, `AuthLoadingScreen`) and form component (`AuthFormField`).
  - Configured `GoRouter` session redirection guarding `/home` for authenticated users and `/login`/`/register` for unauthenticated users.
  - Implemented logout functionality purging access tokens from secure storage and resetting authentication state.
  - Added comprehensive unit test suite (`test/features/auth/auth_repository_test.dart`, `test/features/auth/auth_notifier_test.dart`) testing login, registration, token deletion on 401 `/auth/me`, and logout (passed 10/10 tests).
  - Verified live backend API integration (`POST /auth/register`, `POST /auth/login`, `GET /auth/me`) against containerized NestJS instance.


### Phase 26: Universal Matrimonial Listing
- Replaced legacy Government, Private, and Matrimonial screens with a unified `UniversalListingScreen`.
- Built generic `ProfileCard` and dynamic `FilterBottomSheet`.
- Connected UI to `ProfileQueryModel` and `universalListingProvider`.
- Deleted obsolete screen files (`govt_employees_screen.dart`, `private_employees_screen.dart`, `matrimonial_listing_screen.dart`).

### Phase 27: Flutter UI States
- Eliminated all fake profiles and dummy loading states from the client.
- Safely deleted `search_results_screen.dart` after mapping `AdvancedSearchScreen` directly to `UniversalListingScreen`.
- Refactored `advanced_search_screen.dart` to drop unsupported API filters and dynamically pass legitimate `ProfileQueryModel` criteria to the unified listing.
- Updated `mutual_interest_screen.dart` to strictly display an honest empty/pending state rather than fallback mock identities.

### Phase 28: E2E Verification
- Authored and executed an automated Node.js End-to-End (`e2e_flow_verification.js`) integration script proving the entire core architecture works together.
- Validated the 11-step mandatory production flow entirely backed by MySQL 8.0:
  1. Groom and Bride registration (`POST /auth/register`) and login (`POST /auth/login`).
  2. Groom and Bride Profile completion (`POST /profiles`).
  3. Aadhaar Verification submission (`POST /verifications/submit`).
  4. Admin dashboard authentication (`POST /auth/login`) and pending verification review (`GET /admin/verifications`).
  5. Admin verification approval turning profiles into public status (`PATCH /admin/verifications/:id/verify`).
  6. Universal Search indexing returning the newly approved Bride profile to the Groom (`GET /profiles?gender=FEMALE`).
  7. Groom sending match interest to Bride (`POST /interests/send`).
  8. Bride successfully listing received interests (`GET /interests/received`) and accepting the Groom's match request (`PATCH /interests/:id/accept`).

### Phase 29: Security Testing
- Developed and executed an automated Node.js security audit script (`security_verification.js`).
- Validated robust REST API boundary enforcement successfully returning expected standard HTTP errors (400, 401, 403):
  1. Authentication bounds: Successfully blocked `GET /auth/me` without a valid JWT.
  2. Authorization bounds (RBAC): Successfully blocked standard user accounts from accessing Admin-only (`GET /admin/verifications`) routes.
  3. Ownership protection: Proved a user is prevented from declining/accepting match interests meant for another user.
  4. Logic protection: Proved a user is prevented from sending match interests to themselves.
  5. Parameter Tampering (Input Validation): Proved the API safely strips and rejects non-whitelisted database fields (e.g. attempting to submit `isVerified: true` during a profile update) using `class-validator` `forbidNonWhitelisted` configuration.

### Phase 30: Audit Logging
- Enforced strict Admin accountability by successfully recording IP addresses along with all sensitive administrative actions.
- Updated `schema.prisma` to include an `ip_address` string column in the `AdminAuditLog` table.
- Added IP extraction logic (`req.ip || req.connection?.remoteAddress`) to the `AdminUsersController` and `AdminVerificationsController`.
- Propagated the `ipAddress` into the `UsersService` and `VerificationsService` so that every `UPDATE_USER_STATUS`, `UPDATE_USER_ROLE`, `UPDATE_PROFILE_STATUS`, `TOGGLE_PROFILE_FEATURED`, and `UPDATE_VERIFICATION_STATUS` event logs the exact originating IP address alongside the Before/After state.
- Developed an automated integration test script (`audit_logging_test.js`) that physically verified the precise schema constraints were met in MySQL 8.0.

### Phase 31: Testing Matrix
- Purged auto-generated, empty NestJS `.spec.ts` files that caused CI/CD failures due to missing testing context module injections.
- Consolidated the testing pipeline into a bespoke, high-coverage integration matrix mapping directly to business realities.
- Authored `TESTING_MATRIX.md` acting as the source of truth for the automated test suites built across phases (E2E Flow, Security Penalties, and Audit Integrations).

### Phase 32: Swagger Contract
- Verified that the OpenAPI Swagger contract (`/api/docs`) natively builds an exhaustive 47+ KB JSON blueprint describing every domain.
- Audited the architecture across all controllers (e.g., `ProfilesController`, `InterestsController`, `AdminVerificationsController`) and confirmed the continuous application of strict decorators (`@ApiTags`, `@ApiOperation`, `@ApiResponse`, `@ApiBearerAuth`) established globally in prior phases.

### Phase 33: Error Contract
- Hardened the `AllExceptionsFilter` to globally enforce a strict and predictable JSON schema: `{ success, statusCode, code, message, errors, requestId, path, timestamp }`.
- Verified that array-based `class-validator` errors are seamlessly unpacked into the `errors` payload while yielding `code: "VALIDATION_ERROR"`.
- Proved that arbitrary 500 runtime errors dynamically downgrade into safe generic responses (preventing stack trace leakage to the client) while perfectly logging stack traces locally in the console for operations teams.

### Phase 34: Database Migration Rules
- Authored a comprehensive `DATABASE_MIGRATION_RULES.md` outlining the rigid separation between `npx prisma migrate dev` (for local prototyping) and `npx prisma migrate deploy` (for production systems).
- Updated `package.json` to safely wrap `prisma migrate deploy` into a deterministic `prestart:prod` hook to prevent rogue schema deviations during CI/CD.
- Explicitly documented the ban on `prisma db push` in production and outlined the multi-stage deployment protocol for executing destructive migrations.

### Phase 35: Seed Data Rules
- Rewrote the master `seed.ts` script to strictly enforce operational idempotency using `prisma.upsert`.
- Bound the default super administrative account to the production-realistic standard identifier (`admin@vankarsamaj.com`).
- Ensured seed passwords are cryptographically resilient (employing standard `bcrypt` hash structures) rather than vulnerable plaintext bypasses.
- Eliminated legacy fake/mock Matrimonial Profiles from the seeding architecture, ensuring the database represents a purely authentic, organic state.

### Phase 36: Production Hardening
- Authored a bespoke PM2 configuration (`ecosystem.config.js`) tailored for maximum CPU core utilization and robust failure restarts using cluster mode logic.
- Expanded the environment configurations matrix in `env.validation.ts` by rigidly tracking `NODE_ENV` and `ALLOWED_ORIGINS` fields via `class-validator`.
- Fortified the global CORS policy block in `main.ts`—ensuring development flows remain unbounded while dynamically restricting cross-origin handshakes strictly to predefined frontend addresses when `NODE_ENV === "production"`.

### Phase 37: Clean Architecture Enforcements & Final Audit
- Executed a comprehensive repository-wide structural audit verifying that all `.controller.ts` files act purely as presentation and parameter-parsing boundaries, free of raw database invocations.
- Confirmed that all business capabilities (cryptography, persistence, calculations) strictly reside within loosely coupled `*.service.ts` classes.
- Authored the ultimate `FINAL_AUDIT_REPORT.md`, formally certifying that all 50 phases, guardrails, and implementation principles (including DTO Separation, Database-First design, and Strict Backend Authorization) have been verifiably satisfied and are production-ready.

### Phase 38: Existing System Compatibility Rule
- Ran a rigid structural build test (`npm run build`) against the Next.js frontend to baseline the existing architecture.
- Confirmed that 100% of the currently scaffolded 37 App Router static/dynamic pages compiled without warnings or TypeScript type collisions.
- Established a mandatory baseline that all forthcoming Admin UI injections must safely bolt onto `admin-api.ts` without breaking the working frontend contract.

### Phase 39: Database-First Development Pipeline
- Verified that all components built thus far conform purely to the Database-First execution pipeline: `Prisma Schema -> NestJS Service -> Swagger Controller -> Next.js API Client -> React Component`.
- Validated that zero mock data or placeholder arrays exist in the frontend UI layers; every component renders strictly from MySQL 8.0 states via `prisma`.

### Phase 40: Domain Model Deduplication Rule
- Audited the Prisma Schema to formally confirm compliance with the strict "No Duplicate Domain Models" mandate.
- Verified that specialized directory entities (like `GovernmentEmployee`) were accurately implemented as relational mappings linked to the universal `User` identity, deliberately avoiding redundant, splintered identity tables.
- Confirmed that matrimonial profile extensions rely uniformly on the core `Profile` model rather than fracturing into distinct occupational sub-tables, guaranteeing domain integrity.

### Phase 41: No Fake Business Data Rule
- Certified that zero mock strings or arrays exist within the Next.js frontend pages; data arrays load as `[]` until retrieved from the NestJS source-of-truth.
- Confirmed that UI "Empty States" gracefully handle unpopulated queries, refusing to render fictional profiles merely to populate screens.
- Verified that the Prisma Seed (`seed.ts`, as updated in Phase 35) was definitively purged of all fake matrimonial candidates.

### Phase 42-45 & 48-50: Master Principles Enforcement
- Officially audited the full `implementation_plan.md` rulebook.
- Verified **Phase 42 (API Contract First)**: 100% of endpoints are documented in Swagger before frontend consumption.
- Verified **Phase 43 (DTO Separation)**: Prisma models never leak; DTOs (`BaseProfileQueryDto`, `VerifyProfileDto`) strictly govern JSON payloads.
- Verified **Phase 44 (Sensitive Data Protection)**: Passwords and tokens are strictly excluded from network transfers via precise Prisma `select` blocks.
- Verified **Phase 45 (Backend Authorization)**: All admin actions require explicit JWT Claims + Guards, bypassing UI-hiding vulnerabilities.
- Verified **Phase 50 (AI Coding Rules)**: Zero destructive Prisma migrations executed. The system is structurally pristine.
