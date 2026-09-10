# Database Architecture

The PostgreSQL database uses Prisma ORM for schema definition, client generation, and database migrations.

## Applied Migrations
1. **Migration `20260909060958_init`**:
   - **Entity:** `SystemHealth` (`system_health` table)
     - `id`: UUID Primary Key
     - `status`: String default 'ok'
     - `checkedAt`: Timestamp default `now()`
2. **Migration `20260909070243_add_user_authentication` (Step 4)**:
   - **Entity:** `User` (`users` table)
     - `id`: UUID Primary Key
     - `email`: String (Unique)
     - `password_hash`: String (bcrypt hashed password)
     - `role`: Enum `Role` (`USER`, `ADMIN`) default `USER`
     - `status`: Enum `Status` (`ACTIVE`, `INACTIVE`) default `ACTIVE`
     - `created_at`: Timestamp default `now()`
     - `updated_at`: Timestamp `@updatedAt`

3. **Migration `20260909072013_add_matrimonial_profile` (Step 5)**:
   - **Entity:** `MatrimonialProfile` (`matrimonial_profiles` table)
     - `id`: UUID Primary Key
     - `user_id`: UUID (Unique, Foreign Key → `User.id` CASCADE)
     - `first_name`: String
     - `last_name`: String
     - `date_of_birth`: Timestamp
     - `gender`: Enum `Gender` (`MALE`, `FEMALE`, `OTHER`)
     - `marital_status`: Enum `MaritalStatus` (`NEVER_MARRIED`, `DIVORCED`, `WIDOWED`, `SEPARATED`)
     - `religion`: Nullable String (no hardcoded DB default)
     - `caste`: Nullable String (no hardcoded DB default)
     - `city`, `state`, `country`: Nullable Strings (no hardcoded DB defaults)
     - `education`, `occupation`, `about`: Nullable Strings
     - `created_at`: Timestamp default `now()`
     - `updated_at`: Timestamp `@updatedAt`

## Domain Relationships
- **User 1 ─── 1 MatrimonialProfile**: Each authenticated `User` can own at most one `MatrimonialProfile`. Deleting a profile does not delete the `User` account. Deleting a `User` cascades deletion to their profile.

## Migration Principles
- **No db push:** Schema modifications must strictly occur via `prisma migrate dev` (in development) and `prisma migrate deploy` (in production).
- **Docker Compose Source of Truth:** The database runs as container `vankar_matrimony_postgres` using persistent volume `postgres_data`.
- **Internal DNS:** Backend communicates via `postgres:5432`.


