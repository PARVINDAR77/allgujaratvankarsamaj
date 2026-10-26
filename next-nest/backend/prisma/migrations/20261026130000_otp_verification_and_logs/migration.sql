-- Migration: 20261026130000_otp_verification_and_logs
-- Adds user email/phone verification flags and tables for OTP sessions & logs

-- 1. Add verification flags to users
ALTER TABLE `users` ADD COLUMN IF NOT EXISTS `is_email_verified` BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE `users` ADD COLUMN IF NOT EXISTS `is_phone_verified` BOOLEAN NOT NULL DEFAULT false;

-- 2. Create otp_sessions table
CREATE TABLE IF NOT EXISTS `otp_sessions` (
    `id` VARCHAR(191) NOT NULL,
    `target` VARCHAR(191) NOT NULL,
    `channel` ENUM('SMS', 'EMAIL') NOT NULL,
    `purpose` ENUM('REGISTRATION', 'FORGOT_PASSWORD') NOT NULL,
    `code` VARCHAR(191) NOT NULL,
    `attempts` INTEGER NOT NULL DEFAULT 0,
    `max_attempts` INTEGER NOT NULL DEFAULT 4,
    `is_verified` BOOLEAN NOT NULL DEFAULT false,
    `verified_at` DATETIME(3) NULL,
    `expires_at` DATETIME(3) NOT NULL,
    `locked_until` DATETIME(3) NULL,
    `token` VARCHAR(191) NULL UNIQUE,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`),
    INDEX `otp_sessions_target_purpose_idx` (`target`, `purpose`),
    INDEX `otp_sessions_token_idx` (`token`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 3. Create otp_logs table
CREATE TABLE IF NOT EXISTS `otp_logs` (
    `id` VARCHAR(191) NOT NULL,
    `channel` ENUM('SMS', 'EMAIL') NOT NULL,
    `purpose` ENUM('REGISTRATION', 'FORGOT_PASSWORD') NOT NULL,
    `recipient` VARCHAR(191) NOT NULL,
    `ip_address` VARCHAR(191) NULL,
    `status` ENUM('SENT', 'DELIVERED', 'FAILED') NOT NULL DEFAULT 'SENT',
    `gateway_id` VARCHAR(191) NULL,
    `gateway_response` TEXT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`),
    INDEX `otp_logs_created_at_idx` (`created_at`),
    INDEX `otp_logs_recipient_idx` (`recipient`),
    INDEX `otp_logs_channel_idx` (`channel`),
    INDEX `otp_logs_purpose_idx` (`purpose`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
