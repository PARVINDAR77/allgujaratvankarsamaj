import { Module } from "@nestjs/common";
import {
  VerificationsController,
  AdminVerificationsController,
} from "./verifications.controller";
import { VerificationsService } from "./verifications.service";
import { AiVerificationService } from "./ai-verification.service";
import { PrismaModule } from "../prisma/prisma.module";
import { StorageModule } from "../storage/storage.module";

@Module({
  imports: [PrismaModule, StorageModule],
  controllers: [VerificationsController, AdminVerificationsController],
  providers: [VerificationsService, AiVerificationService],
  exports: [VerificationsService, AiVerificationService],
})
export class VerificationsModule {}
