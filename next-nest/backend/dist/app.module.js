"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const env_validation_1 = require("./config/env.validation");
const prisma_module_1 = require("./prisma/prisma.module");
const health_module_1 = require("./health/health.module");
const users_module_1 = require("./users/users.module");
const auth_module_1 = require("./auth/auth.module");
const profiles_module_1 = require("./profiles/profiles.module");
const admin_module_1 = require("./admin/admin.module");
const settings_module_1 = require("./settings/settings.module");
const parganas_module_1 = require("./parganas/parganas.module");
const samaj_services_module_1 = require("./samaj-services/samaj-services.module");
const locations_module_1 = require("./locations/locations.module");
const government_employees_module_1 = require("./government-employees/government-employees.module");
const statistics_module_1 = require("./statistics/statistics.module");
const request_id_middleware_1 = require("./common/middleware/request-id.middleware");
const interests_module_1 = require("./interests/interests.module");
const reports_module_1 = require("./reports/reports.module");
const shortlists_module_1 = require("./shortlists/shortlists.module");
const storage_module_1 = require("./storage/storage.module");
const verifications_module_1 = require("./verifications/verifications.module");
const advertisements_module_1 = require("./advertisements/advertisements.module");
const success_stories_module_1 = require("./success-stories/success-stories.module");
const master_data_module_1 = require("./master-data/master-data.module");
const samaj_ratna_module_1 = require("./samaj-ratna/samaj-ratna.module");
const pavan_prernadata_module_1 = require("./pavan-prernadata/pavan-prernadata.module");
const samaj_super_stars_module_1 = require("./samaj-super-stars/samaj-super-stars.module");
const notifications_module_1 = require("./notifications/notifications.module");
const education_module_1 = require("./education/education.module");
const chat_module_1 = require("./chat/chat.module");
let AppModule = class AppModule {
    configure(consumer) {
        consumer.apply(request_id_middleware_1.RequestIdMiddleware).forRoutes("*");
    }
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                validate: env_validation_1.validate,
            }),
            prisma_module_1.PrismaModule,
            health_module_1.HealthModule,
            users_module_1.UsersModule,
            auth_module_1.AuthModule,
            profiles_module_1.ProfilesModule,
            admin_module_1.AdminModule,
            settings_module_1.SettingsModule,
            parganas_module_1.ParganasModule,
            samaj_services_module_1.SamajServicesModule,
            locations_module_1.LocationsModule,
            government_employees_module_1.GovernmentEmployeesModule,
            statistics_module_1.StatisticsModule,
            interests_module_1.InterestsModule,
            reports_module_1.ReportsModule,
            shortlists_module_1.ShortlistsModule,
            storage_module_1.StorageModule,
            verifications_module_1.VerificationsModule,
            advertisements_module_1.AdvertisementsModule,
            success_stories_module_1.SuccessStoriesModule,
            master_data_module_1.MasterDataModule,
            samaj_ratna_module_1.SamajRatnaModule,
            pavan_prernadata_module_1.PavanPrernadataModule,
            samaj_super_stars_module_1.SamajSuperStarsModule,
            notifications_module_1.NotificationsModule,
            education_module_1.EducationModule,
            chat_module_1.ChatModule,
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map