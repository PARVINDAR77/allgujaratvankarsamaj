import { Module } from '@nestjs/common';
import { VerificationsController, AdminVerificationsController } from './verifications.controller';
import { VerificationsService } from './verifications.service';

import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [VerificationsController, AdminVerificationsController],
  providers: [VerificationsService],
})
export class VerificationsModule {}
