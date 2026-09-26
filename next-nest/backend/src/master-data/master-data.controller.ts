import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { MasterDataService } from './master-data.service';

@ApiTags('Master Data')
@Controller('master-data')
export class MasterDataController {
  constructor(private readonly masterDataService: MasterDataService) {}

  @Get()
  @ApiOperation({ summary: 'Get all master data (districts, talukas, options)' })
  getAllMasterData() {
    return this.masterDataService.getAllMasterData();
  }
}
