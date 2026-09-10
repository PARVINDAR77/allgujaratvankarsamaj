# Decision 001: API-First Architecture

## Context
The matrimonial platform needs a mobile app (Flutter) and eventually an admin dashboard (Next.js). Data needs to be secure and centralized.

## Decision
Adopt a strict API-first architecture where the NestJS backend is the sole gatekeeper to the PostgreSQL database. No static business data is allowed in the Flutter frontend.

## Alternatives Considered
- Direct database access from frontend (Firebase/Supabase): Rejected due to complex custom matrimonial business logic and data security requirements.
- Monolithic app: Rejected as it doesn't allow separate mobile and web frontends cleanly.

## Reason
Centralizing business logic in NestJS ensures consistency across multiple clients (Flutter, Next.js), enforces security, and makes the system scalable and easier to test.

## Consequences
- Positive: High security, decoupled clients, centralized business rules.
- Negative: Requires slightly more upfront boilerplate for API contracts and DTOs.
