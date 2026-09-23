import { Module } from '@nestjs/common';
import { ShortlistsController } from './shortlists.controller';
import { ShortlistsService } from './shortlists.service';

import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [ShortlistsController],
  providers: [ShortlistsService],
})
export class ShortlistsModule {}
