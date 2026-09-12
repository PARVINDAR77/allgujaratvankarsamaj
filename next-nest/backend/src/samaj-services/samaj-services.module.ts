import { Module } from "@nestjs/common";
import { SamajServicesController } from "./samaj-services.controller";
import { SamajServicesService } from "./samaj-services.service";
import { PrismaModule } from "../prisma/prisma.module";

@Module({
  imports: [PrismaModule],
  controllers: [SamajServicesController],
  providers: [SamajServicesService],
  exports: [SamajServicesService],
})
export class SamajServicesModule {}
