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
import { PavanPrernadataService } from "./pavan-prernadata.service";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { Public } from "../auth/decorators/public.decorator";

@Controller()
export class PavanPrernadataController {
  constructor(private readonly pavanService: PavanPrernadataService) {}

  @Public()
  @Get("pavan-prernadata")
  findAllPublic() {
    return this.pavanService.findAllPublic();
  }

  // @UseGuards(JwtAuthGuard)
  @Get("admin/pavan-prernadata")
  findAllAdmin() {
    return this.pavanService.findAllAdmin();
  }

  // @UseGuards(JwtAuthGuard)
  @Post("admin/pavan-prernadata")
  create(@Body() createDto: any) {
    return this.pavanService.create(createDto);
  }

  // @UseGuards(JwtAuthGuard)
  @Patch("admin/pavan-prernadata/:id")
  update(@Param("id") id: string, @Body() updateDto: any) {
    return this.pavanService.update(id, updateDto);
  }

  // @UseGuards(JwtAuthGuard)
  @Delete("admin/pavan-prernadata/:id")
  remove(@Param("id") id: string) {
    return this.pavanService.remove(id);
  }
}
