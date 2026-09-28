import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
import { SamajRatnaService } from './samaj-ratna.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { Public } from '../auth/decorators/public.decorator';

@Controller()
export class SamajRatnaController {
  constructor(private readonly samajRatnaService: SamajRatnaService) {}

  @Public()
  @Get('samaj-ratna')
  findAllPublic() {
    return this.samajRatnaService.findAllPublic();
  }

  // @UseGuards(JwtAuthGuard)
  @Get('admin/samaj-ratna')
  findAllAdmin() {
    return this.samajRatnaService.findAllAdmin();
  }

  // @UseGuards(JwtAuthGuard)
  @Post('admin/samaj-ratna')
  create(@Body() createDto: any) {
    return this.samajRatnaService.create(createDto);
  }

  // @UseGuards(JwtAuthGuard)
  @Patch('admin/samaj-ratna/:id')
  update(@Param('id') id: string, @Body() updateDto: any) {
    return this.samajRatnaService.update(id, updateDto);
  }

  // @UseGuards(JwtAuthGuard)
  @Delete('admin/samaj-ratna/:id')
  remove(@Param('id') id: string) {
    return this.samajRatnaService.remove(id);
  }
}
