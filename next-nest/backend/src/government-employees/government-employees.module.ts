import { Module } from '@nestjs/common';
import { GovernmentEmployeesService } from './government-employees.service';
import { GovernmentEmployeesController } from './government-employees.controller';

@Module({
  controllers: [GovernmentEmployeesController],
  providers: [GovernmentEmployeesService],
  exports: [GovernmentEmployeesService],
})
export class GovernmentEmployeesModule {}
