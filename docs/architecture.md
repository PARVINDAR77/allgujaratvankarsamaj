# Technical Architecture

## High-Level Architecture

The system follows a strict API-first, service-oriented architecture:

```
Flutter (User App)
       │
       ▼ (REST API)
 NestJS Backend
       │
       ▼ (Prisma ORM)
   PostgreSQL
```

*(In the future, the Next.js Admin app will also interact with the NestJS Backend via REST API)*

## Infrastructure & Container Orchestration

Docker Compose serves as the single source of truth for the local backend runtime environment:

```text
docker compose up -d
        │
        ├── PostgreSQL (Service: 'postgres', Port 5432)
        │
        └── NestJS (Service: 'backend', Port 3000)
```

- **Service Resolution:** The `backend` container resolves the database via internal Docker network DNS using the service name `postgres` (`postgres:5432`), not `localhost`.
- **Health Checks & Startup Sequencing:** The `backend` container specifies `depends_on: postgres: condition: service_healthy` to ensure PostgreSQL is accepting connections (verified via `pg_isready`) before NestJS initializes.
- **Data Persistence:** Database storage is preserved across container lifecycles via the `postgres_data` named Docker volume.
- **Port Bindings:**
  - `5432:5432` mapped to host for database management/inspection tools.
  - `3000:3000` mapped to host for REST API access (accessible to Flutter emulators/devices).
- **API Versioning & Documentation:**
  - Base API prefix: `/api/v1`
  - Swagger/OpenAPI documentation: `/api/docs`
  - Health check endpoint: `/api/v1/health` verifying backend runtime and Prisma database query capability (`SELECT 1`).


## Responsibilities

### Flutter (Frontend)
- User Interface and Interaction.
- Local UI state management (Riverpod).
- API communication and error handling.
- Rendering backend data using strongly typed models.
- Client-side validation for UX.

### NestJS (Backend)
- Central authority for business logic and rules.
- Authentication (JWT) and Authorization.
- Data validation (DTOs).
- API contracts (Swagger/OpenAPI).
- Interacting with the database via Prisma.

### PostgreSQL (Database)
- Persistent data storage.
- Relational integrity and constraints.

## Data Flow (Example: Authentication)
1. **Flutter:** User submits login form.
2. **Flutter:** Client-side validation passes.
3. **Flutter Network Layer:** Sends `POST /auth/login` via Dio.
4. **NestJS Controller:** Receives request, validation pipe checks DTO.
5. **NestJS Service:** Verifies credentials against PostgreSQL via Prisma.
6. **NestJS Service:** Generates JWT token.
7. **NestJS Controller:** Returns standard success response with token.
8. **Flutter Network Layer:** Parses response, saves token securely.
9. **Flutter State:** Updates authentication state.
10. **Flutter UI:** Navigates to Home screen.
