import { MiddlewareConsumer, Module, NestModule } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { validate } from "./config/env.validation";
import { PrismaModule } from "./prisma/prisma.module";
import { HealthModule } from "./health/health.module";
import { UsersModule } from "./users/users.module";
import { AuthModule } from "./auth/auth.module";
import { ProfilesModule } from "./profiles/profiles.module";
import { AdminModule } from "./admin/admin.module";
import { SettingsModule } from "./settings/settings.module";
import { ParganasModule } from "./parganas/parganas.module";
import { SamajServicesModule } from "./samaj-services/samaj-services.module";
import { LocationsModule } from "./locations/locations.module";
import { GovernmentEmployeesModule } from "./government-employees/government-employees.module";
import { StatisticsModule } from "./statistics/statistics.module";
import { RequestIdMiddleware } from "./common/middleware/request-id.middleware";
import { InterestsModule } from './interests/interests.module';
import { ReportsModule } from './reports/reports.module';
import { ShortlistsModule } from './shortlists/shortlists.module';
import { StorageModule } from './storage/storage.module';
import { VerificationsModule } from './verifications/verifications.module';
import { AdvertisementsModule } from './advertisements/advertisements.module';
import { SuccessStoriesModule } from './success-stories/success-stories.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validate,
    }),
    PrismaModule,
    HealthModule,
    UsersModule,
    AuthModule,
    ProfilesModule,
    AdminModule,
    SettingsModule,
    ParganasModule,
    SamajServicesModule,
    LocationsModule,
    GovernmentEmployeesModule,
    StatisticsModule,
    InterestsModule,
    ReportsModule,
    ShortlistsModule,
    StorageModule,
    VerificationsModule,
    AdvertisementsModule,
    SuccessStoriesModule,
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(RequestIdMiddleware).forRoutes("*");
  }
}
