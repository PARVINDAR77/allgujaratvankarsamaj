#!/usr/bin/env bash
# ==============================================================================
# All Gujarat Vankar Samaj - Stage 3: Idempotent Database Index Migration
# Features:
# 1. Fully Idempotent Execution (AddIndexIfNotExists checks information_schema)
# 2. Non-Destructive: Modifies zero existing table rows and alters no existing columns
# 3. Post-migration Index Verification in information_schema.statistics
# 4. Independent Gate: Runs completely decoupled from application code deployment
# ==============================================================================

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
BACKEND_DIR="$PROJECT_ROOT/next-nest/backend"
MIGRATION_SQL="$BACKEND_DIR/prisma/migrations/20261030100000_performance_and_search_indexes/migration.sql"
ROLLBACK_SQL="$BACKEND_DIR/prisma/migrations/20261030100000_performance_and_search_indexes/rollback.sql"

echo "================================================================="
echo "  All Gujarat Vankar Samaj - Stage 3: Database Index Migration   "
echo "  Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')                     "
echo "================================================================="

ENV_FILE="$PROJECT_ROOT/.env.production"
if [ ! -f "$ENV_FILE" ]; then
    ENV_FILE="$BACKEND_DIR/.env"
fi

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: Production environment configuration not found at $ENV_FILE"
    exit 1
fi

set -a
source "$ENV_FILE"
set +a

if [ -z "${DB_HOST:-}" ] || [ -z "${DB_USER:-}" ] || [ -z "${DB_PASSWORD:-}" ] || [ -z "${DB_NAME:-}" ]; then
    echo "❌ Error: Database credentials missing in $ENV_FILE"
    exit 1
fi

ACTION="${1:-apply}"

if [ "$ACTION" = "rollback" ]; then
    echo "⏮️ Executing idempotent index rollback..."
    if [ ! -f "$ROLLBACK_SQL" ]; then
        echo "❌ Error: Rollback SQL file not found at $ROLLBACK_SQL"
        exit 1
    fi
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$ROLLBACK_SQL"
    echo "✅ Index rollback completed successfully."
    exit 0
fi

echo "🗄️ Applying 10 query-driven performance indexes idempotently..."
if [ ! -f "$MIGRATION_SQL" ]; then
    echo "❌ Error: Migration SQL file not found at $MIGRATION_SQL"
    exit 1
fi

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$MIGRATION_SQL"
echo "✅ SQL migration execution complete."

echo ""
echo "🔍 Verifying registered performance indexes in information_schema..."
INDEX_STATS=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "
    SELECT table_name AS 'Table', index_name AS 'Index', GROUP_CONCAT(column_name ORDER BY seq_in_index) AS 'Columns'
    FROM information_schema.statistics 
    WHERE table_schema = '$DB_NAME' 
      AND index_name IN (
          'idx_matrimonial_profiles_search_composite',
          'idx_matrimonial_profiles_district_taluka',
          'idx_matrimonial_profiles_date_of_birth',
          'idx_verification_requests_profile_created',
          'idx_verification_requests_status_created',
          'idx_match_interests_receiver_created',
          'idx_match_interests_sender_created',
          'idx_govt_emp_active_status_created',
          'idx_govt_emp_featured_active_updated',
          'idx_govt_emp_employment_type'
      )
    GROUP BY table_name, index_name;
")

echo "$INDEX_STATS"

REGISTERED_COUNT=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -N -e "
    SELECT COUNT(DISTINCT index_name) FROM information_schema.statistics 
    WHERE table_schema = '$DB_NAME' 
      AND index_name IN (
          'idx_matrimonial_profiles_search_composite',
          'idx_matrimonial_profiles_district_taluka',
          'idx_matrimonial_profiles_date_of_birth',
          'idx_verification_requests_profile_created',
          'idx_verification_requests_status_created',
          'idx_match_interests_receiver_created',
          'idx_match_interests_sender_created',
          'idx_govt_emp_active_status_created',
          'idx_govt_emp_featured_active_updated',
          'idx_govt_emp_employment_type'
      );
")

echo ""
echo "Performance indexes active: $REGISTERED_COUNT / 10"

if [ "$REGISTERED_COUNT" -eq 10 ]; then
    echo "================================================================="
    echo "✅ STAGE 3 SUCCESS: All 10 performance indexes are active!       "
    echo "================================================================="
else
    echo "⚠️ Warning: Found $REGISTERED_COUNT of 10 indexes. Review table definitions."
fi

