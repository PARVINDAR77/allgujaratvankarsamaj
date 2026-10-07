"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var PrismaService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.PrismaService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
let PrismaService = PrismaService_1 = class PrismaService extends client_1.PrismaClient {
    constructor() {
        super(...arguments);
        this.logger = new common_1.Logger(PrismaService_1.name);
    }
    async onModuleInit() {
        try {
            await this.$connect();
            this.logger.log("Successfully connected to MySQL database via Prisma");
            await this.syncSchema();
        }
        catch (error) {
            this.logger.warn(`MySQL database not yet reachable at DATABASE_URL (${error.message || error}). Backend will retry on demand.`);
        }
    }
    async syncSchema() {
        try {
            await this.$executeRawUnsafe(`
        CREATE TABLE IF NOT EXISTS \`section_view_counts\` (
          \`id\` varchar(191) NOT NULL,
          \`section_name\` varchar(191) NOT NULL,
          \`view_count\` int NOT NULL DEFAULT 0,
          \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
          \`updated_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
          PRIMARY KEY (\`id\`),
          UNIQUE KEY \`section_view_counts_section_name_key\` (\`section_name\`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      `);
            await this.$executeRawUnsafe(`
        CREATE TABLE IF NOT EXISTS \`home_button_configs\` (
          \`id\` varchar(191) NOT NULL,
          \`button_id\` int NOT NULL,
          \`title\` varchar(191) DEFAULT NULL,
          \`subtitle\` varchar(191) DEFAULT NULL,
          \`icon\` varchar(191) DEFAULT NULL,
          \`route\` varchar(191) NOT NULL,
          \`is_active\` tinyint(1) NOT NULL DEFAULT 1,
          \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
          \`updated_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
          PRIMARY KEY (\`id\`),
          UNIQUE KEY \`home_button_configs_button_id_key\` (\`button_id\`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      `);
            await this.$executeRawUnsafe(`
        CREATE TABLE IF NOT EXISTS \`samaj_service_persons\` (
          \`id\` varchar(191) NOT NULL,
          \`service_id\` varchar(191) NOT NULL,
          \`user_id\` varchar(191) DEFAULT NULL,
          \`name\` varchar(191) NOT NULL,
          \`gujarati_name\` varchar(191) DEFAULT NULL,
          \`photo_url\` text DEFAULT NULL,
          \`phone\` varchar(191) NOT NULL,
          \`address\` text DEFAULT NULL,
          \`city\` varchar(191) DEFAULT NULL,
          \`description\` text DEFAULT NULL,
          \`experience\` varchar(191) DEFAULT NULL,
          \`district_id\` varchar(191) DEFAULT NULL,
          \`taluka_id\` varchar(191) DEFAULT NULL,
          \`village_id\` varchar(191) DEFAULT NULL,
          \`is_active\` tinyint(1) NOT NULL DEFAULT 1,
          \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
          \`updated_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
          PRIMARY KEY (\`id\`),
          KEY \`samaj_service_persons_service_id_idx\` (\`service_id\`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      `);
            await this.$executeRawUnsafe(`
        CREATE TABLE IF NOT EXISTS \`system_notifications\` (
          \`id\` varchar(191) NOT NULL,
          \`title\` varchar(191) NOT NULL,
          \`message\` text NOT NULL,
          \`target\` varchar(191) NOT NULL DEFAULT 'ALL',
          \`route\` varchar(191) DEFAULT NULL,
          \`created_at\` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
          PRIMARY KEY (\`id\`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      `);
            await this.$executeRawUnsafe(`
        ALTER TABLE \`advertisements\` MODIFY COLUMN \`placement\` ENUM('HOME_BANNER', 'DIRECTORY_BANNER', 'POPUP', 'BUTTON_1', 'BUTTON_2', 'BUTTON_3', 'BUTTON_4', 'BUTTON_5', 'PAVAN_PRERNADATA', 'SAMAJ_SUPER_STARS', 'SAMAJ_RATNA') NOT NULL DEFAULT 'HOME_BANNER';
      `);
            await this.$executeRawUnsafe(`
        UPDATE \`users\` SET \`role\` = 'SUPER_ADMIN', \`status\` = 'ACTIVE' 
        WHERE \`email\` IN ('admin@vankarsamaj.org', 'admin@vankarsamaj.com', 'panjabiparvindar77@gmail.com');
      `);
            await this.syncGovernmentEmployeesFromProfiles();
            this.logger.log("Schema auto-migration check completed successfully");
        }
        catch (migrationErr) {
            this.logger.warn(`Schema auto-migration notice: ${migrationErr.message}`);
        }
    }
    async syncGovernmentEmployeesFromProfiles() {
        try {
            const govtProfiles = await this.$queryRawUnsafe(`
        SELECT p.id, p.first_name, p.last_name, p.occupation, p.organization_name, p.designation, p.city, p.state, p.native_place, p.is_featured, p.is_verified, p.status, g.id AS govt_id
        FROM matrimonial_profiles p
        LEFT JOIN government_employments g ON g.profile_id = p.id
        WHERE (
          LOWER(COALESCE(p.occupation, '')) LIKE '%gov%' OR COALESCE(p.occupation, '') LIKE '%સરકારી%'
          OR LOWER(COALESCE(p.organization_name, '')) LIKE '%gov%' OR COALESCE(p.organization_name, '') LIKE '%સરકારી%'
          OR LOWER(COALESCE(p.occupation, '')) LIKE '%central%' OR COALESCE(p.occupation, '') LIKE '%કેન્દ્ર%'
          OR LOWER(COALESCE(p.organization_name, '')) LIKE '%central%' OR COALESCE(p.organization_name, '') LIKE '%કેન્દ્ર%'
          OR LOWER(COALESCE(p.occupation, '')) LIKE '%state%' OR COALESCE(p.occupation, '') LIKE '%રાજ્ય%'
          OR LOWER(COALESCE(p.organization_name, '')) LIKE '%state%' OR COALESCE(p.organization_name, '') LIKE '%રાજ્ય%'
        );
      `);
            if (govtProfiles && govtProfiles.length > 0) {
                for (const p of govtProfiles) {
                    const occ = (p.occupation || "").toLowerCase();
                    const org = (p.organization_name || "").toLowerCase();
                    let empType = "STATE_GOVT";
                    if (org.includes("central") ||
                        org.includes("કેન્દ્ર") ||
                        occ.includes("central") ||
                        occ.includes("કેન્દ્ર")) {
                        empType = "CENTRAL_GOVT";
                    }
                    else if (org.includes("psu") ||
                        org.includes("public") ||
                        org.includes("જાહેર") ||
                        occ.includes("psu")) {
                        empType = "PSU";
                    }
                    const officeLoc = p.city || p.state || p.native_place || p.organization_name || "Gujarat";
                    const isFeatured = p.is_featured ? 1 : 0;
                    if (!p.govt_id) {
                        const newId = `gov-${p.id}`;
                        await this.$executeRawUnsafe(`
              INSERT INTO government_employments (
                id, profile_id, employment_type, office_location, verification_status, is_active, is_featured, created_at, updated_at
              ) VALUES (?, ?, ?, ?, 'VERIFIED', 1, ?, NOW(), NOW());
            `, newId, p.id, empType, officeLoc, isFeatured);
                        this.logger.log(`Created government_employments record for profile: ${p.first_name} ${p.last_name} (${p.id})`);
                    }
                    else {
                        await this.$executeRawUnsafe(`
              UPDATE government_employments
              SET verification_status = 'VERIFIED', is_active = 1, employment_type = ?, office_location = ?
              WHERE profile_id = ?;
            `, empType, officeLoc, p.id);
                    }
                }
            }
        }
        catch (err) {
            this.logger.warn(`Government employee profile sync warning: ${err?.message || err}`);
        }
    }
    async onModuleDestroy() {
        await this.$disconnect();
        this.logger.log("Disconnected from MySQL database");
    }
};
exports.PrismaService = PrismaService;
exports.PrismaService = PrismaService = PrismaService_1 = __decorate([
    (0, common_1.Injectable)()
], PrismaService);
//# sourceMappingURL=prisma.service.js.map