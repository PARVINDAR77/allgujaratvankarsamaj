# Database Architecture

The database uses Prisma ORM for schema definition, client generation, and database migrations.

## Applied Entities

1. **User Authentication (`users`)**
   - User authentication and identity.

2. **MatrimonialProfile (`matrimonial_profiles`)**
   - Biodata and search attributes.

3. **HomeButtonConfig (`home_button_configs`)**
   - Configures the 5 Home Screen buttons (Title, Subtitle, Icon, Status).
   - **Important**: The `route` field here is strictly controlled by the backend and mapping logic (1 -> Samaj Ratna). The Admin cannot arbitrarily change these routes.

4. **SamajRatna (`samaj_ratnas`)**
   - High-achieving community members (Jewels of the Community).
   - `id`: UUID Primary Key
   - `name`: String
   - `gujarati_name`: String (Optional)
   - `photo_url`: String (Optional)
   - `designation`: String (Optional)
   - `year`: String (Optional)
   - `display_order`: Int
   - `is_active`: Boolean

## Migration Principles
- **No db push in production:** Schema modifications must strictly occur via Prisma Migrations in production environments.
