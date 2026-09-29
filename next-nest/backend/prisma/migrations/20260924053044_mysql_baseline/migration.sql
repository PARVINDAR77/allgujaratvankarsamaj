-- CreateTable
CREATE TABLE `system_health` (
    `id` VARCHAR(191) NOT NULL,
    `status` VARCHAR(191) NOT NULL DEFAULT 'ok',
    `checkedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `users` (
    `id` VARCHAR(191) NOT NULL,
    `email` VARCHAR(191) NULL,
    `phone` VARCHAR(191) NULL,
    `name` VARCHAR(191) NULL,
    `gender` ENUM('MALE', 'FEMALE', 'OTHER') NULL,
    `password_hash` VARCHAR(191) NOT NULL,
    `role` ENUM('USER', 'SUPER_ADMIN', 'ADMIN', 'VERIFICATION_ADMIN', 'CONTENT_ADMIN') NOT NULL DEFAULT 'USER',
    `status` ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    UNIQUE INDEX `users_email_key`(`email`),
    UNIQUE INDEX `users_phone_key`(`phone`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `matrimonial_profiles` (
    `id` VARCHAR(191) NOT NULL,
    `user_id` VARCHAR(191) NOT NULL,
    `first_name` VARCHAR(191) NOT NULL,
    `last_name` VARCHAR(191) NOT NULL,
    `date_of_birth` DATETIME(3) NOT NULL,
    `gender` ENUM('MALE', 'FEMALE', 'OTHER') NOT NULL,
    `marital_status` ENUM('NEVER_MARRIED', 'DIVORCED', 'WIDOWED', 'SEPARATED') NOT NULL,
    `religion` VARCHAR(191) NULL,
    `caste` VARCHAR(191) NULL,
    `subcaste` VARCHAR(191) NULL,
    `native_place` VARCHAR(191) NULL,
    `city` VARCHAR(191) NULL,
    `state` VARCHAR(191) NULL,
    `country` VARCHAR(191) NULL,
    `education` VARCHAR(191) NULL,
    `occupation` VARCHAR(191) NULL,
    `organization_name` VARCHAR(191) NULL,
    `designation` VARCHAR(191) NULL,
    `about` VARCHAR(191) NULL,
    `photo_url` VARCHAR(191) NULL,
    `state_id` VARCHAR(191) NULL,
    `district_id` VARCHAR(191) NULL,
    `taluka_id` VARCHAR(191) NULL,
    `pargana_id` VARCHAR(191) NULL,
    `village_id` VARCHAR(191) NULL,
    `status` ENUM('PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED') NOT NULL DEFAULT 'APPROVED',
    `is_verified` BOOLEAN NOT NULL DEFAULT false,
    `is_featured` BOOLEAN NOT NULL DEFAULT false,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    UNIQUE INDEX `matrimonial_profiles_user_id_key`(`user_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `shortlists` (
    `id` VARCHAR(191) NOT NULL,
    `user_id` VARCHAR(191) NOT NULL,
    `target_profile_id` VARCHAR(191) NOT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `shortlists_user_id_target_profile_id_key`(`user_id`, `target_profile_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `site_settings` (
    `key` VARCHAR(191) NOT NULL,
    `value` VARCHAR(191) NOT NULL,
    `updated_at` DATETIME(3) NOT NULL,

    PRIMARY KEY (`key`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `states` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `gujarati_name` VARCHAR(191) NULL,
    `code` VARCHAR(191) NOT NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    UNIQUE INDEX `states_code_key`(`code`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `districts` (
    `id` VARCHAR(191) NOT NULL,
    `state_id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `gujarati_name` VARCHAR(191) NULL,
    `code` VARCHAR(191) NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `districts_state_id_idx`(`state_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `talukas` (
    `id` VARCHAR(191) NOT NULL,
    `district_id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `gujarati_name` VARCHAR(191) NULL,
    `code` VARCHAR(191) NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `talukas_district_id_idx`(`district_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `parganas` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `gujarati_name` VARCHAR(191) NULL,
    `code` VARCHAR(191) NULL,
    `description` VARCHAR(191) NULL,
    `village_count` VARCHAR(191) NULL,
    `district_region` VARCHAR(191) NULL,
    `leader_name` VARCHAR(191) NULL,
    `contact_phone` VARCHAR(191) NULL,
    `manual_count` INTEGER NULL,
    `total_count` INTEGER NOT NULL DEFAULT 0,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    UNIQUE INDEX `parganas_code_key`(`code`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `pargana_talukas` (
    `pargana_id` VARCHAR(191) NOT NULL,
    `taluka_id` VARCHAR(191) NOT NULL,

    PRIMARY KEY (`pargana_id`, `taluka_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `villages` (
    `id` VARCHAR(191) NOT NULL,
    `pargana_id` VARCHAR(191) NULL,
    `taluka_id` VARCHAR(191) NULL,
    `name` VARCHAR(191) NOT NULL,
    `gujarati_name` VARCHAR(191) NULL,
    `code` VARCHAR(191) NULL,
    `pincode` VARCHAR(191) NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `villages_pargana_id_idx`(`pargana_id`),
    INDEX `villages_taluka_id_idx`(`taluka_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `verification_requests` (
    `id` VARCHAR(191) NOT NULL,
    `profile_id` VARCHAR(191) NOT NULL,
    `document_type` VARCHAR(191) NOT NULL,
    `document_url` VARCHAR(191) NOT NULL,
    `status` ENUM('PENDING', 'VERIFIED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
    `rejection_reason` VARCHAR(191) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `match_interests` (
    `id` VARCHAR(191) NOT NULL,
    `sender_profile_id` VARCHAR(191) NOT NULL,
    `receiver_profile_id` VARCHAR(191) NOT NULL,
    `status` ENUM('PENDING', 'ACCEPTED', 'DECLINED') NOT NULL DEFAULT 'PENDING',
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `reports` (
    `id` VARCHAR(191) NOT NULL,
    `reporter_user_id` VARCHAR(191) NOT NULL,
    `target_profile_id` VARCHAR(191) NOT NULL,
    `reason` VARCHAR(191) NOT NULL,
    `details` VARCHAR(191) NULL,
    `status` ENUM('OPEN', 'RESOLVED', 'DISMISSED') NOT NULL DEFAULT 'OPEN',
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `success_stories` (
    `id` VARCHAR(191) NOT NULL,
    `bride_name` VARCHAR(191) NOT NULL,
    `groom_name` VARCHAR(191) NOT NULL,
    `wedding_date` VARCHAR(191) NULL,
    `story` VARCHAR(191) NOT NULL,
    `image_url` VARCHAR(191) NULL,
    `is_published` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `samaj_services` (
    `id` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `slug` VARCHAR(191) NOT NULL,
    `category` VARCHAR(191) NOT NULL DEFAULT 'General',
    `icon` VARCHAR(191) NOT NULL DEFAULT '🤝',
    `contact_phone` VARCHAR(191) NULL,
    `contact_person` VARCHAR(191) NULL,
    `description` VARCHAR(191) NULL,
    `sort_order` INTEGER NOT NULL DEFAULT 0,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    UNIQUE INDEX `samaj_services_slug_key`(`slug`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `samaj_service_persons` (
    `id` VARCHAR(191) NOT NULL,
    `service_id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `gujarati_name` VARCHAR(191) NULL,
    `photo_url` VARCHAR(191) NULL,
    `phone` VARCHAR(191) NOT NULL,
    `address` VARCHAR(191) NULL,
    `city` VARCHAR(191) NULL,
    `description` VARCHAR(191) NULL,
    `experience` VARCHAR(191) NULL,
    `district_id` VARCHAR(191) NULL,
    `taluka_id` VARCHAR(191) NULL,
    `village_id` VARCHAR(191) NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `samaj_service_persons_service_id_idx`(`service_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `govt_departments` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `gujarati_name` VARCHAR(191) NULL,
    `code` VARCHAR(191) NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    UNIQUE INDEX `govt_departments_code_key`(`code`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `govt_designations` (
    `id` VARCHAR(191) NOT NULL,
    `department_id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `gujarati_name` VARCHAR(191) NULL,
    `code` VARCHAR(191) NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `govt_designations_department_id_idx`(`department_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `government_employments` (
    `id` VARCHAR(191) NOT NULL,
    `profile_id` VARCHAR(191) NOT NULL,
    `employment_type` ENUM('CENTRAL_GOVT', 'STATE_GOVT', 'PSU', 'SEMI_GOVT', 'DEFENSE', 'BANKING', 'RAILWAYS') NOT NULL DEFAULT 'STATE_GOVT',
    `department_id` VARCHAR(191) NULL,
    `designation_id` VARCHAR(191) NULL,
    `office_location` VARCHAR(191) NULL,
    `joining_year` INTEGER NULL,
    `verification_status` ENUM('PENDING', 'VERIFIED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
    `verification_submitted_at` DATETIME(3) NULL,
    `verified_at` DATETIME(3) NULL,
    `verified_by` VARCHAR(191) NULL,
    `rejection_reason` VARCHAR(191) NULL,
    `is_featured` BOOLEAN NOT NULL DEFAULT false,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    UNIQUE INDEX `government_employments_profile_id_key`(`profile_id`),
    INDEX `government_employments_department_id_idx`(`department_id`),
    INDEX `government_employments_designation_id_idx`(`designation_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `government_employment_verifications` (
    `id` VARCHAR(191) NOT NULL,
    `employment_id` VARCHAR(191) NOT NULL,
    `document_type` VARCHAR(191) NOT NULL DEFAULT 'GOVT_ID_CARD',
    `document_url` VARCHAR(191) NOT NULL,
    `status` ENUM('PENDING', 'VERIFIED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
    `reviewed_by` VARCHAR(191) NULL,
    `reviewed_at` DATETIME(3) NULL,
    `rejection_reason` VARCHAR(191) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `government_employment_verifications_employment_id_idx`(`employment_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `admin_audit_logs` (
    `id` VARCHAR(191) NOT NULL,
    `admin_id` VARCHAR(191) NOT NULL,
    `action` VARCHAR(191) NOT NULL,
    `entity_type` VARCHAR(191) NOT NULL,
    `entity_id` VARCHAR(191) NOT NULL,
    `old_value` VARCHAR(191) NULL,
    `new_value` VARCHAR(191) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `advertisements` (
    `id` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `image_url` VARCHAR(191) NOT NULL,
    `target_url` VARCHAR(191) NULL,
    `placement` ENUM('HOME_BANNER', 'DIRECTORY_BANNER', 'POPUP') NOT NULL DEFAULT 'HOME_BANNER',
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `start_at` DATETIME(3) NULL,
    `end_at` DATETIME(3) NULL,
    `sort_order` INTEGER NOT NULL DEFAULT 0,
    `created_by` VARCHAR(191) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `matrimonial_profiles` ADD CONSTRAINT `matrimonial_profiles_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `matrimonial_profiles` ADD CONSTRAINT `matrimonial_profiles_state_id_fkey` FOREIGN KEY (`state_id`) REFERENCES `states`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `matrimonial_profiles` ADD CONSTRAINT `matrimonial_profiles_district_id_fkey` FOREIGN KEY (`district_id`) REFERENCES `districts`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `matrimonial_profiles` ADD CONSTRAINT `matrimonial_profiles_taluka_id_fkey` FOREIGN KEY (`taluka_id`) REFERENCES `talukas`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `matrimonial_profiles` ADD CONSTRAINT `matrimonial_profiles_pargana_id_fkey` FOREIGN KEY (`pargana_id`) REFERENCES `parganas`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `matrimonial_profiles` ADD CONSTRAINT `matrimonial_profiles_village_id_fkey` FOREIGN KEY (`village_id`) REFERENCES `villages`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `districts` ADD CONSTRAINT `districts_state_id_fkey` FOREIGN KEY (`state_id`) REFERENCES `states`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `talukas` ADD CONSTRAINT `talukas_district_id_fkey` FOREIGN KEY (`district_id`) REFERENCES `districts`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `pargana_talukas` ADD CONSTRAINT `pargana_talukas_pargana_id_fkey` FOREIGN KEY (`pargana_id`) REFERENCES `parganas`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `pargana_talukas` ADD CONSTRAINT `pargana_talukas_taluka_id_fkey` FOREIGN KEY (`taluka_id`) REFERENCES `talukas`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `villages` ADD CONSTRAINT `villages_pargana_id_fkey` FOREIGN KEY (`pargana_id`) REFERENCES `parganas`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `villages` ADD CONSTRAINT `villages_taluka_id_fkey` FOREIGN KEY (`taluka_id`) REFERENCES `talukas`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `verification_requests` ADD CONSTRAINT `verification_requests_profile_id_fkey` FOREIGN KEY (`profile_id`) REFERENCES `matrimonial_profiles`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `samaj_service_persons` ADD CONSTRAINT `samaj_service_persons_service_id_fkey` FOREIGN KEY (`service_id`) REFERENCES `samaj_services`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `samaj_service_persons` ADD CONSTRAINT `samaj_service_persons_district_id_fkey` FOREIGN KEY (`district_id`) REFERENCES `districts`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `samaj_service_persons` ADD CONSTRAINT `samaj_service_persons_taluka_id_fkey` FOREIGN KEY (`taluka_id`) REFERENCES `talukas`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `samaj_service_persons` ADD CONSTRAINT `samaj_service_persons_village_id_fkey` FOREIGN KEY (`village_id`) REFERENCES `villages`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `govt_designations` ADD CONSTRAINT `govt_designations_department_id_fkey` FOREIGN KEY (`department_id`) REFERENCES `govt_departments`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `government_employments` ADD CONSTRAINT `government_employments_profile_id_fkey` FOREIGN KEY (`profile_id`) REFERENCES `matrimonial_profiles`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `government_employments` ADD CONSTRAINT `government_employments_department_id_fkey` FOREIGN KEY (`department_id`) REFERENCES `govt_departments`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `government_employments` ADD CONSTRAINT `government_employments_designation_id_fkey` FOREIGN KEY (`designation_id`) REFERENCES `govt_designations`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `government_employment_verifications` ADD CONSTRAINT `government_employment_verifications_employment_id_fkey` FOREIGN KEY (`employment_id`) REFERENCES `government_employments`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
