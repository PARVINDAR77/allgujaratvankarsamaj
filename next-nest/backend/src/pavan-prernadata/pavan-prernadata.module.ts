import { Module } from '@nestjs/common';
import { PavanPrernadataService } from './pavan-prernadata.service';
import { PavanPrernadataController } from './pavan-prernadata.controller';

@Module({
  providers: [PavanPrernadataService],
  controllers: [PavanPrernadataController]
})
export class PavanPrernadataModule {}
