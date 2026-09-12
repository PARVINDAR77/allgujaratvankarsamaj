import { Body, Controller, Delete, Get, Param, Patch, Post } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import { ParganasService } from "./parganas.service";
import { Public } from "../auth/decorators/public.decorator";

@ApiTags("Parganas")
@Controller()
export class ParganasController {
  constructor(private readonly parganasService: ParganasService) {}

  @Public()
  @Get("parganas")
  @ApiOperation({ summary: "Get list of active parganas for Flutter & public website" })
  async getPublicParganas() {
    return this.parganasService.getPublicParganas();
  }

  @Get("admin/parganas")
  @ApiOperation({ summary: "Get all parganas for Admin Panel" })
  async getAdminParganas() {
    return this.parganasService.getAllAdminParganas();
  }

  @Post("admin/parganas")
  @ApiOperation({ summary: "Create a new pargana region from Admin Panel" })
  async createPargana(@Body() body: any) {
    return this.parganasService.createPargana(body);
  }

  @Patch("admin/parganas/:id")
  @ApiOperation({ summary: "Update pargana region details from Admin Panel" })
  async updatePargana(@Param("id") id: string, @Body() body: any) {
    return this.parganasService.updatePargana(id, body);
  }

  @Delete("admin/parganas/:id")
  @ApiOperation({ summary: "Delete pargana region from Admin Panel" })
  async deletePargana(@Param("id") id: string) {
    return this.parganasService.deletePargana(id);
  }
}
