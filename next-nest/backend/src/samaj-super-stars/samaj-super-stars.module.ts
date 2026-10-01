import { Module } from '@nestjs/common';
import { SamajSuperStarsService } from './samaj-super-stars.service';
import { SamajSuperStarsController } from './samaj-super-stars.controller';

@Module({
  providers: [SamajSuperStarsService],
  controllers: [SamajSuperStarsController]
})
export class SamajSuperStarsModule {}
