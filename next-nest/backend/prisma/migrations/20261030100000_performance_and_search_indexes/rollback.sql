-- Rollback Migration: 20261030100000_performance_and_search_indexes
-- Description: Idempotently drops only the 10 performance indexes created in migration.sql.
-- Safety: Verifies information_schema.statistics before dropping any index; safe to re-run multiple times.

DELIMITER $$

DROP PROCEDURE IF EXISTS `DropIndexIfExists` $$
CREATE PROCEDURE `DropIndexIfExists`(
    IN p_table VARCHAR(64),
    IN p_index VARCHAR(64)
)
BEGIN
    DECLARE index_count INT DEFAULT 0;
    
    SELECT COUNT(1) INTO index_count
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = p_table
      AND index_name = p_index;

    IF index_count > 0 THEN
        SET @sql = CONCAT('DROP INDEX `', p_index, '` ON `', p_table, '`');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SELECT CONCAT('DROPPED index `', p_index, '` from `', p_table, '`') AS result;
    ELSE
        SELECT CONCAT('NOT FOUND index `', p_index, '` on `', p_table, '` (skipped)') AS result;
    END IF;
END $$

DELIMITER ;

-- 1. Matrimonial Profiles
CALL DropIndexIfExists('matrimonial_profiles', 'idx_matrimonial_profiles_search_composite');
CALL DropIndexIfExists('matrimonial_profiles', 'idx_matrimonial_profiles_district_taluka');
CALL DropIndexIfExists('matrimonial_profiles', 'idx_matrimonial_profiles_date_of_birth');

-- 2. Verification Requests
CALL DropIndexIfExists('verification_requests', 'idx_verification_requests_profile_created');
CALL DropIndexIfExists('verification_requests', 'idx_verification_requests_status_created');

-- 3. Match Interests
CALL DropIndexIfExists('match_interests', 'idx_match_interests_receiver_created');
CALL DropIndexIfExists('match_interests', 'idx_match_interests_sender_created');

-- 4. Government Employments
CALL DropIndexIfExists('government_employments', 'idx_govt_emp_active_status_created');
CALL DropIndexIfExists('government_employments', 'idx_govt_emp_featured_active_updated');
CALL DropIndexIfExists('government_employments', 'idx_govt_emp_employment_type');

-- Cleanup temporary procedure
DROP PROCEDURE IF EXISTS `DropIndexIfExists`;
