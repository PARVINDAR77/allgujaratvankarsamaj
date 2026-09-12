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
import { RequestIdMiddleware } from "./common/middleware/request-id.middleware";

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
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(RequestIdMiddleware).forRoutes("*");
  }
}
