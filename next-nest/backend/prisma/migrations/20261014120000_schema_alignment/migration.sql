-- Migration: 20261014120000_schema_alignment
-- Harmonize all supplementary Prisma models into tracked migrations.
-- Safe to apply and idempotent across MySQL 8.0.19+.
-- All ADD COLUMN statements use IF NOT EXISTS. All CREATE TABLE statements use IF NOT EXISTS.
-- Enum modifications expand allowed values idempotently.

-- 1. Align matrimonial_profiles columns
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `photos` TEXT NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `is_physically_disabled` BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `pwbd_category` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `is_abroad` BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `abroad_country` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `business_industry` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `business_service` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `blood_group` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `is_vankar` BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `annual_income` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `father_name` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `father_occupation` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `father_contact` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `mother_name` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `mother_occupation` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `guardian_contact` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `siblings` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `mamas_village` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `address_line` TEXT NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `pincode` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `alt_phone` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `contact_email` VARCHAR(191) NULL;
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `mother_tongue` VARCHAR(191) NULL DEFAULT 'Gujarati (ગુજરાતી)';
ALTER TABLE `matrimonial_profiles` ADD COLUMN IF NOT EXISTS `privacy_settings` TEXT NULL;
ALTER TABLE `matrimonial_profiles` MODIFY COLUMN `marital_status` ENUM('NEVER_MARRIED', 'MARRIED', 'DIVORCED', 'WIDOWED', 'SEPARATED') NOT NULL DEFAULT 'NEVER_MARRIED';

-- 2. Align verification_requests columns
ALTER TABLE `verification_requests` ADD COLUMN IF NOT EXISTS `document_back_url` VARCHAR(191) NULL;

-- 3. Align samaj_service_persons columns
ALTER TABLE `samaj_service_persons` ADD COLUMN IF NOT EXISTS `user_id` VARCHAR(191) NULL;

-- 4. Align admin_audit_logs columns
ALTER TABLE `admin_audit_logs` ADD COLUMN IF NOT EXISTS `ip_address` VARCHAR(191) NULL;

-- 5. Advertisements placement ENUM update
ALTER TABLE `advertisements` MODIFY COLUMN `placement` ENUM('HOME_BANNER', 'DIRECTORY_BANNER', 'POPUP', 'BUTTON_1', 'BUTTON_2', 'BUTTON_3', 'BUTTON_4', 'BUTTON_5', 'PAVAN_PRERNADATA', 'SAMAJ_SUPER_STARS', 'SAMAJ_RATNA') NOT NULL DEFAULT 'HOME_BANNER';

-- 6. Samaj Ratna
CREATE TABLE IF NOT EXISTS `samaj_ratnas` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `gujarati_name` VARCHAR(191) NULL,
    `photo_url` VARCHAR(191) NULL,
    `description` VARCHAR(191) NULL,
    `designation` VARCHAR(191) NULL,
    `year` VARCHAR(191) NULL,
    `display_order` INTEGER NOT NULL DEFAULT 0,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 7. Home Button Configs
CREATE TABLE IF NOT EXISTS `home_button_configs` (
    `id` VARCHAR(191) NOT NULL,
    `button_id` INTEGER NOT NULL,
    `title` VARCHAR(191) NULL,
    `subtitle` VARCHAR(191) NULL,
    `icon` VARCHAR(191) NULL,
    `route` VARCHAR(191) NOT NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `home_button_configs_button_id_key`(`button_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 8. Section View Counts
CREATE TABLE IF NOT EXISTS `section_view_counts` (
    `id` VARCHAR(191) NOT NULL,
    `section_name` VARCHAR(191) NOT NULL,
    `view_count` INTEGER NOT NULL DEFAULT 0,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `section_view_counts_section_name_key`(`section_name`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 9. Pavan Prernadata
CREATE TABLE IF NOT EXISTS `pavan_prernadata` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `gujarati_name` VARCHAR(191) NULL,
    `photo_url` VARCHAR(191) NULL,
    `description` VARCHAR(191) NULL,
    `designation` VARCHAR(191) NULL,
    `year` VARCHAR(191) NULL,
    `display_order` INTEGER NOT NULL DEFAULT 0,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 10. Samaj Super Stars
CREATE TABLE IF NOT EXISTS `samaj_super_stars` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `gujarati_name` VARCHAR(191) NULL,
    `photo_url` VARCHAR(191) NULL,
    `description` VARCHAR(191) NULL,
    `designation` VARCHAR(191) NULL,
    `year` VARCHAR(191) NULL,
    `display_order` INTEGER NOT NULL DEFAULT 0,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 11. System Notifications
CREATE TABLE IF NOT EXISTS `system_notifications` (
    `id` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `message` TEXT NOT NULL,
    `target` VARCHAR(191) NOT NULL DEFAULT 'ALL',
    `route` VARCHAR(191) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 12. Education Content
CREATE TABLE IF NOT EXISTS `education_content` (
    `id` VARCHAR(191) NOT NULL DEFAULT 'default',
    `header_title` VARCHAR(191) NULL DEFAULT 'Education for Better Tomorrow',
    `header_subtitle` VARCHAR(191) NULL DEFAULT 'શિક્ષણ અને ઉજ્જવળ ભવિષ્ય માર્ગદર્શન',
    `box1_title` VARCHAR(191) NULL DEFAULT 'શિક્ષણ માર્ગદર્શિકા અને પરિપત્રો',
    `box1_subtitle` VARCHAR(191) NULL DEFAULT 'Download Official Educational Guidelines & Circulars',
    `box1_pdf_url` TEXT NULL,
    `box1_file_name` VARCHAR(191) NULL DEFAULT 'career_guidance.pdf',
    `box2_title` VARCHAR(191) NULL DEFAULT 'શિક્ષણ પ્રેરણા સંદેશ & કારકિર્દી સલાહ',
    `box2_content` TEXT NULL,
    `box2_author` VARCHAR(191) NULL DEFAULT 'શિક્ષણ સમિતિ, ઓલ ગુજરાત વણકર સમાજ',
    `box3_title` VARCHAR(191) NULL DEFAULT 'શૈક્ષણિક સેમિનાર & કારકિર્દી માર્ગદર્શન',
    `box3_youtube_url` TEXT NULL,
    `box3_description` VARCHAR(191) NULL,
    `box4_title` VARCHAR(191) NULL DEFAULT 'યુવા પ્રેરણા સંવાદ & સફળતાની વાર્તાઓ',
    `box4_youtube_url` TEXT NULL,
    `box4_description` VARCHAR(191) NULL,
    `box5_title` VARCHAR(191) NULL DEFAULT 'શૈક્ષણિક પોસ્ટર અને માહિતી',
    `box5_subtitle` VARCHAR(191) NULL DEFAULT 'Educational Poster & Circular Image',
    `box5_image_url` TEXT NULL,
    `box5_description` TEXT NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 13. User Notifications
CREATE TABLE IF NOT EXISTS `user_notifications` (
    `id` VARCHAR(191) NOT NULL,
    `user_id` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `message` TEXT NOT NULL,
    `type` VARCHAR(191) NOT NULL DEFAULT 'CONNECTION_REQUEST',
    `metadata` TEXT NULL,
    `is_read` BOOLEAN NOT NULL DEFAULT false,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `user_notifications_user_id_idx`(`user_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 14. Chat Conversations
CREATE TABLE IF NOT EXISTS `chat_conversations` (
    `id` VARCHAR(191) NOT NULL,
    `participant_1_id` VARCHAR(191) NOT NULL,
    `participant_2_id` VARCHAR(191) NOT NULL,
    `last_message` TEXT NULL,
    `last_message_at` DATETIME(3) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `chat_conversations_participant_1_id_participant_2_id_key`(`participant_1_id`, `participant_2_id`),
    INDEX `chat_conversations_participant_1_id_idx`(`participant_1_id`),
    INDEX `chat_conversations_participant_2_id_idx`(`participant_2_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 15. Chat Messages
CREATE TABLE IF NOT EXISTS `chat_messages` (
    `id` VARCHAR(191) NOT NULL,
    `conversation_id` VARCHAR(191) NOT NULL,
    `sender_id` VARCHAR(191) NOT NULL,
    `receiver_id` VARCHAR(191) NOT NULL,
    `content` TEXT NOT NULL,
    `is_read` BOOLEAN NOT NULL DEFAULT false,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `chat_messages_conversation_id_idx`(`conversation_id`),
    INDEX `chat_messages_sender_id_idx`(`sender_id`),
    INDEX `chat_messages_receiver_id_idx`(`receiver_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 16. Chat Messages Foreign Key with strict referential validation
SET @fk_valid = (
    SELECT COUNT(*)
    FROM information_schema.REFERENTIAL_CONSTRAINTS rc
    JOIN information_schema.KEY_COLUMN_USAGE kcu
      ON rc.CONSTRAINT_SCHEMA = kcu.CONSTRAINT_SCHEMA
     AND rc.CONSTRAINT_NAME   = kcu.CONSTRAINT_NAME
     AND rc.TABLE_NAME        = kcu.TABLE_NAME
    WHERE rc.CONSTRAINT_SCHEMA       = DATABASE()
      AND rc.TABLE_NAME              = 'chat_messages'
      AND rc.CONSTRAINT_NAME          = 'chat_messages_conversation_id_fkey'
      AND rc.REFERENCED_TABLE_NAME   = 'chat_conversations'
      AND kcu.COLUMN_NAME            = 'conversation_id'
      AND kcu.REFERENCED_COLUMN_NAME = 'id'
      AND rc.DELETE_RULE             = 'CASCADE'
      AND rc.UPDATE_RULE             = 'CASCADE'
);

-- Check if a stale constraint with this name exists
SET @fk_stale = (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'chat_messages'
      AND CONSTRAINT_NAME = 'chat_messages_conversation_id_fkey'
);

-- If stale and invalid, drop it first
SET @drop_fk_sql = IF(@fk_stale > 0 AND @fk_valid = 0,
    'ALTER TABLE `chat_messages` DROP FOREIGN KEY `chat_messages_conversation_id_fkey`;',
    'DO 0;'
);
PREPARE drop_stmt FROM @drop_fk_sql;
EXECUTE drop_stmt;
DEALLOCATE PREPARE drop_stmt;

-- Add valid constraint if not already present and valid
SET @add_fk_sql = IF(@fk_valid = 0,
    'ALTER TABLE `chat_messages` ADD CONSTRAINT `chat_messages_conversation_id_fkey` FOREIGN KEY (`conversation_id`) REFERENCES `chat_conversations`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;',
    'DO 0;'
);
PREPARE add_stmt FROM @add_fk_sql;
EXECUTE add_stmt;
DEALLOCATE PREPARE add_stmt;
