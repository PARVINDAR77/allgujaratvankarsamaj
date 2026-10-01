import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
} from "@nestjs/common";
import { SamajSuperStarsService } from "./samaj-super-stars.service";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { Public } from "../auth/decorators/public.decorator";

@Controller()
export class SamajSuperStarsController {
  constructor(private readonly starsService: SamajSuperStarsService) {}

  @Public()
  @Get("samaj-super-stars")
  findAllPublic() {
    return this.starsService.findAllPublic();
  }

  // @UseGuards(JwtAuthGuard)
  @Get("admin/samaj-super-stars")
  findAllAdmin() {
    return this.starsService.findAllAdmin();
  }

  // @UseGuards(JwtAuthGuard)
  @Post("admin/samaj-super-stars")
  create(@Body() createDto: any) {
    return this.starsService.create(createDto);
  }

  // @UseGuards(JwtAuthGuard)
  @Patch("admin/samaj-super-stars/:id")
  update(@Param("id") id: string, @Body() updateDto: any) {
    return this.starsService.update(id, updateDto);
  }

  // @UseGuards(JwtAuthGuard)
  @Delete("admin/samaj-super-stars/:id")
  remove(@Param("id") id: string) {
    return this.starsService.remove(id);
  }
}
