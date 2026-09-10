# Changelog

All notable changes to the All Gujarat Vankar Samaj Matrimony project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- Defined complete project documentation structure in `docs/`.
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





