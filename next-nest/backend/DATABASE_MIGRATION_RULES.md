# Database Migration Rules

This document outlines the strict guidelines for evolving and deploying the MySQL 8.0 schema for the All Gujarat Vankar Samaj Matrimony platform.

## Core Directives

### 1. Development vs. Production
- **Development**: Use `npx prisma migrate dev` (or `npm run prisma:migrate`). This creates a new SQL migration file, resets the database if drift is detected, and applies the migration.
- **Production**: **NEVER USE `prisma migrate dev` OR `prisma db push` IN PRODUCTION.** Always use `npx prisma migrate deploy` (or `npm run prisma:deploy`).

### 2. The Danger of `db push`
The `prisma db push` command syncs the schema without tracking history. It can cause destructive, unrecoverable data loss in production environments. 
**Rule**: `db push` is strictly banned for staging and production targets. It is only permitted for local, throw-away SQLite prototyping.

### 3. Pipeline Integration
The production deployment pipeline must follow this exact sequence:
1. Extract new code
2. Run `npm install`
3. Run `npm run build`
4. Run `npm run prestart:prod` (Which triggers `prisma migrate deploy` followed by `prisma generate`)
5. Run `npm run start:prod`

### 4. Safe Destructive Rules
If a schema change requires dropping a table or column (e.g., renaming a column), you must:
1. Add the new column first.
2. Deploy the application.
3. Write a script to migrate data from the old column to the new column.
4. Verify the data migration.
5. In a subsequent release, remove the old column.
Never combine column destruction and creation in a single deployment if the data within is critical (such as User profiles or authentication records).

### 5. Tracking Drift
If the production database schema drifts from the Prisma migration history (e.g., manual DBA intervention), `prisma migrate deploy` will fail. You must use `prisma migrate resolve` to mark failed or manually-applied migrations as resolved.

By adhering to these rules, the persistence layer remains completely stable, auditable, and rollback-ready.
