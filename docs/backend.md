# NestJS Backend Architecture

## Folder Structure
```
next-nest/backend/
├── prisma/
│   ├── migrations/
│   └── schema.prisma
├── src/
│   ├── common/
│   │   ├── filters/
│   │   │   └── http-exception.filter.ts
│   │   └── middleware/
│   │       └── request-id.middleware.ts
│   ├── config/
│   │   └── env.validation.ts
│   ├── prisma/
│   │   ├── prisma.module.ts
│   │   └── prisma.service.ts
│   ├── health/
│   │   ├── health.controller.ts
│   │   ├── health.module.ts
│   │   └── health.service.ts
│   ├── users/
│   │   ├── users.module.ts
│   │   └── users.service.ts
│   ├── auth/
│   │   ├── dto/
│   │   │   ├── login.dto.ts
│   │   │   └── register.dto.ts
│   │   ├── guards/
│   │   │   └── jwt-auth.guard.ts
│   │   ├── strategies/
│   │   │   └── jwt.strategy.ts
│   │   ├── auth.controller.ts
│   │   ├── auth.module.ts
│   │   └── auth.service.ts
│   ├── profiles/
│   │   ├── dto/
│   │   │   ├── create-profile.dto.ts
│   │   │   └── update-profile.dto.ts
│   │   ├── profiles.controller.ts
│   │   ├── profiles.module.ts
│   │   └── profiles.service.ts
│   ├── app.module.ts
│   └── main.ts
├── Dockerfile
├── .dockerignore
├── package.json
└── tsconfig.json
```

## Technologies
- **Framework:** NestJS v10 (Node.js 20, TypeScript 5)
- **ORM:** Prisma v5
- **Authentication:** Passport.js, JWT (`@nestjs/jwt`), bcrypt password hashing
- **Validation:** class-validator, class-transformer
- **Security:** Helmet headers, CORS, request ID tracking (`uuid`), safe exception filter
- **Documentation:** @nestjs/swagger, swagger-ui-express
- **Configuration:** @nestjs/config with strict environment schema validation

## Containerized Environment & Configuration
The backend runs in a Docker container orchestrated via `docker-compose.yml`.

- **Configuration:** Stored in `.env` (derived from `.env.example`).
- **Database Connection:** Defined via `DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?schema=public` where `postgres` matches the Docker service name.
- **Port:** Exposed on host port `3000` (mapped from container port `3000`, listening on `0.0.0.0`).
- **Startup Guarantee:** `backend` container waits for PostgreSQL health checks to pass before starting.

## API Foundation & Endpoints
- **Global Prefix:** `/api/v1`
- **Swagger Documentation:** `http://localhost:3000/api/docs` (JSON available at `/api/docs-json`)
- **Health Check:** `GET /api/v1/health` returning application status and live PostgreSQL connectivity verification.
- **User Registration:** `POST /api/v1/auth/register` (DTO validation, bcrypt hashing, conflict check for duplicate emails, safe return).
- **User Login:** `POST /api/v1/auth/login` (Generic error responses for invalid credentials, returns Bearer JWT access token).
- **Current User Profile:** `GET /api/v1/auth/me` (Protected route requiring `Authorization: Bearer <JWT>`, resolves authenticated user profile omitting password hashes).
- **Create Matrimonial Profile:** `POST /api/v1/profile` (Protected route, strictly 1 profile per user derived from JWT, DTO validated, rejects extra/client-supplied `userId`).
- **Get Own Matrimonial Profile:** `GET /api/v1/profile/me` (Protected route, returns authenticated user's matrimonial profile or 404).
- **Update Own Matrimonial Profile:** `PATCH /api/v1/profile/me` (Protected route, partial update of own profile fields).
- **Delete Own Matrimonial Profile:** `DELETE /api/v1/profile/me` (Protected route, deletes matrimonial profile while preserving the User account).
- **Profile Reference Data:** `GET /api/v1/profile/reference-data` (Protected route, returns authoritative enum options for `gender` and `maritalStatus`).
- **Profile Completeness:** `GET /api/v1/profile/completeness` (Protected route, calculates exact completed fields out of 13 required fields, percentage 0-100%, and `isComplete` flag).

## Profile Business Rules & Validation
- **Minimum Age Rule:** Enforced via custom `@IsMinAge(18)` validator ensuring date of birth represents an age of at least 18 years calculated from exact birth year, month, and day. Rejects future dates.
- **Text & Length Limits:** Trims strings without altering case/content, rejects whitespace-only values (`@Matches(/^(?!\s*$).+/)`), and enforces maximum lengths (`firstName`/`lastName`/`city`/`state`/`country`/`religion`/`caste` <= 100, `education`/`occupation` <= 200, `about` <= 2000).




