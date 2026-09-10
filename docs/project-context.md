# Project Context

## Project Name
All Gujarat Vankar Samaj Matrimony

## Organization
All Gujarat Vankar Samaj

## Product Purpose
A moderate-to-advanced matrimonial platform designed primarily for the Vankar Samaj community in Gujarat. It allows users to register, create profiles, search for partners, express interest, and communicate.

## Target Users
Members of the Vankar Samaj community seeking matrimonial matches.

## Current Development Phase
**Phase 1 — Foundation**
- Setting up the initial Flutter architecture.
- Setting up the NestJS backend and PostgreSQL/Prisma foundation.
- Creating the core API layer for authentication.
- Developing the first Flutter UI screens based on provided layout images.

## Technology Stack
- **User Application:** Flutter
- **Admin Frontend:** Next.js (Future Phase)
- **Backend/API:** NestJS
- **Database:** PostgreSQL with Prisma ORM

## Repository Structure
```
vankarsamajmatrimony/
├── layoutimages/          # Client-provided reference images
├── application/           # Flutter application
├── next-nest/
│   ├── frontend/          # Next.js admin application (future)
│   └── backend/           # NestJS API/backend
├── docs/                  # Project documentation
├── README.md
└── CHANGELOG.md
```

## Important Non-Negotiable Rules
1. No static business data inside Flutter widgets.
2. All dynamic application data must come from NestJS APIs.
3. Flutter must never directly access PostgreSQL.
4. Next.js must never directly access PostgreSQL.
5. NestJS is the central backend/API layer.
6. Business logic belongs on the backend.
7. Use strongly typed Dart models.
8. Use DTO validation in NestJS.
9. Use PostgreSQL migrations.
10. Use environment variables for secrets/configuration.
11. Use the provided layoutimages as the UI reference.
12. Do not replace the client's intended UI with a generic template.
13. Build incrementally.
14. Keep the architecture scalable for a moderate-to-advanced platform.
15. Do not build the Next.js admin UI until explicitly requested.

## Definition of Done (Feature Completeness)
The AI agent must never consider a feature complete merely because the Flutter UI renders.

A feature is complete only when its required API/backend flow, validation, persistence, error handling, and Flutter integration are correctly implemented and documented.

UI-only implementations are considered incomplete unless the feature is explicitly defined as a static presentation component.

## Current Implementation Status
- Flutter project: **Authentication & Backend API Integration Complete (Step 8)**
- NestJS project: **Profile Reference Data & Business Rules Backend Complete (Step 6)**
- PostgreSQL: **Initialized & Healthy in Docker (Steps 1-8)**
- Prisma: **Configured with Migrations Applied (Init + User Auth + Matrimonial Profile)**
- Authentication: **Full Stack Complete (Backend NestJS + Flutter Register/Login/JWT/SecureStorage/Riverpod/Routing)**
- Matrimonial Profile: **Backend Complete (`POST /profile`, `GET /profile/me`, `PATCH /profile/me`, `DELETE /profile/me`, `GET /profile/reference-data`, `GET /profile/completeness`)**
- Business Validation: **Enforced (`IsMinAge(18)`, non-whitespace, length limits, 13-field completeness calculation)**
- Flutter Application: **Complete Auth Module (LoginScreen, RegisterScreen, AuthFormField, AuthLoadingScreen, AuthNotifier, AuthRepository, AuthInterceptor, SecureStorageService)**
- API layer: **Initialized with /api/v1 prefix, Swagger, Health Check, Global Validation, Filters, Logging, Auth, & Profiles (Steps 2-8)**
- UI: **Authentication UI & Protected Routing Complete (Step 8)**
- Documentation: **Updated**



