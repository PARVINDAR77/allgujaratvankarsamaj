# View Statistics Architecture

## Overview
This document outlines the API-driven View Statistics system for the All Gujarat Vankar Samaj application.
The feature tracks page views for specific fixed sections of the application, particularly the bottom 5 buttons on the Home Screen, and specific community features.

## Architecture Guidelines
- **Flutter**: Displays data natively via Riverpod providers. **NO** direct DB access. **NO** dynamically evaluated routes for these static sections.
- **NestJS**: Acts as the authoritative API and enforces strict validation of canonical keys.
- **MySQL/Prisma**: The Single Source of Truth for view counts.
- **Admin**: Views statistics via API only.

## Fixed Bottom-Five Navigation
The Home Screen features 5 fixed buttons at the very bottom:
1. Education
2. Unity
3. Progress
4. Service
5. Strong Roots

These routes are **FIXED** and their configuration has been cleanly separated from the dynamic `home-buttons` Admin functionality. Their taps record a view event and immediately navigate to their hardcoded fixed destinations.

## Valid Section Identifiers
The NestJS API employs a strict Allowlist Enum pattern. Valid identifiers are:
- `HOME_EDUCATION`
- `HOME_UNITY`
- `HOME_PROGRESS`
- `HOME_SERVICE`
- `HOME_STRONG_ROOTS`
- `PAVAN_PRERNADATA`
- `SAMAJ_SUPER_STARS`
- `SAMAJ_RATNA`
- `FAMILY_DIRECTORY`

Any identifier outside this list is immediately rejected by the NestJS API with a `400 Bad Request`.

## API Endpoints
**1. Fetching Statistics**
`GET /api/v1/statistics/views`
- Returns a list of all section view counts from the `SectionViewCount` table.

**2. Incrementing Statistics**
`POST /api/v1/statistics/views/:sectionName/increment`
- Atomically increments the view count for a specific valid `sectionName`.

## Database Behavior
- Prisma handles updates via a safe, atomic upsert `increment: 1` mechanism.
- The system is built to safely handle concurrent requests without race conditions.

## Duplicate-View Policy & Flutter Refresh Behavior
- Flutter uses an explicit `ref.read(incrementViewProvider)(sectionName)` call tied strictly to a navigation tap or an `initState` rendering of a specific page.
- Subsequent `build()` or UI refresh events **do not** trigger extra API increment requests. Riverpod state refreshes solely fetch the updated `GET` values.

## Security Validation
- The client cannot arbitrarily set totals.
- The `sectionName` param is strongly verified against an in-memory array of trusted values before any Prisma interaction occurs.
