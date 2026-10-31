-- Migration: 20261030100000_performance_and_search_indexes
-- Description: Idempotent query-driven performance indexes for Matrimonial Profiles, Government Employments, Verification Requests, and Match Interests.
-- Safety: Verifies information_schema.statistics before creating any index; completely idempotent across MySQL 5.7, 8.0, and MariaDB.

DELIMITER $$

DROP PROCEDURE IF EXISTS `AddIndexIfNotExists` $$
CREATE PROCEDURE `AddIndexIfNotExists`(
    IN p_table VARCHAR(64),
    IN p_index VARCHAR(64),
    IN p_cols VARCHAR(255)
)
BEGIN
    DECLARE index_count INT DEFAULT 0;
    
    SELECT COUNT(1) INTO index_count
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = p_table
      AND index_name = p_index;

    IF index_count = 0 THEN
        SET @sql = CONCAT('CREATE INDEX `', p_index, '` ON `', p_table, '` (', p_cols, ')');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SELECT CONCAT('CREATED index `', p_index, '` on `', p_table, '`') AS result;
    ELSE
        SELECT CONCAT('EXISTS index `', p_index, '` on `', p_table, '` (skipped)') AS result;
    END IF;
END $$

DELIMITER ;

-- 1. Matrimonial Profiles Search & Filtering Acceleration
CALL AddIndexIfNotExists('matrimonial_profiles', 'idx_matrimonial_profiles_search_composite', '`status`, `show_in_matrimony`, `gender`, `created_at`');
CALL AddIndexIfNotExists('matrimonial_profiles', 'idx_matrimonial_profiles_district_taluka', '`district_id`, `taluka_id`');
CALL AddIndexIfNotExists('matrimonial_profiles', 'idx_matrimonial_profiles_date_of_birth', '`date_of_birth`');

-- 2. Verification Requests Foreign Key & Admin Queue Acceleration
CALL AddIndexIfNotExists('verification_requests', 'idx_verification_requests_profile_created', '`profile_id`, `created_at`');
CALL AddIndexIfNotExists('verification_requests', 'idx_verification_requests_status_created', '`status`, `created_at`');

-- 3. Match Interests Inbox/Outbox Chronological Acceleration
CALL AddIndexIfNotExists('match_interests', 'idx_match_interests_receiver_created', '`receiver_profile_id`, `created_at`');
CALL AddIndexIfNotExists('match_interests', 'idx_match_interests_sender_created', '`sender_profile_id`, `created_at`');

-- 4. Government Employments Directory & Featured Listings Acceleration
CALL AddIndexIfNotExists('government_employments', 'idx_govt_emp_active_status_created', '`is_active`, `verification_status`, `created_at`');
CALL AddIndexIfNotExists('government_employments', 'idx_govt_emp_featured_active_updated', '`is_featured`, `is_active`, `updated_at`');
CALL AddIndexIfNotExists('government_employments', 'idx_govt_emp_employment_type', '`employment_type`');

-- Cleanup temporary procedure
DROP PROCEDURE IF EXISTS `AddIndexIfNotExists`;
