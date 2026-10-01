import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Request,
  UseGuards,
} from "@nestjs/common";
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from "@nestjs/swagger";
import { AdvertisementsService } from "./advertisements.service";
import { CreateAdvertisementDto } from "./dto/create-advertisement.dto";
import { UpdateAdvertisementDto } from "./dto/update-advertisement.dto";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { CapabilitiesGuard } from "../auth/guards/capabilities.guard";
import { Capabilities } from "../auth/decorators/capabilities.decorator";
import { Capability } from "../auth/constants/capabilities";
import { Public } from "../auth/decorators/public.decorator";

@ApiTags("Advertisements")
@Controller()
export class AdvertisementsController {
  constructor(private readonly advertisementsService: AdvertisementsService) {}

  @Public()
  @Get("advertisements")
  @ApiOperation({ summary: "Get all active advertisements for the public app" })
  async findAllPublic() {
    return this.advertisementsService.findAllPublic();
  }

  @Get("admin/advertisements")
  @ApiOperation({ summary: "Get all advertisements (Admin)" })
  async findAllAdmin() {
    return this.advertisementsService.findAllAdmin();
  }

  @Get("admin/advertisements/:id")
  @ApiOperation({ summary: "Get a specific advertisement by ID (Admin)" })
  async findOne(@Param("id") id: string) {
    return this.advertisementsService.findOne(id);
  }

  @Post("admin/advertisements")
  @ApiOperation({ summary: "Create a new advertisement (Admin)" })
  async create(
    @Request() req: any,
    @Body() createAdvertisementDto: CreateAdvertisementDto,
  ) {
    // Pass a dummy user id since Auth is bypassed right now to match other controllers
    return this.advertisementsService.create(
      createAdvertisementDto,
      "admin-user",
    );
  }

  @Patch("admin/advertisements/:id")
  @ApiOperation({ summary: "Update an advertisement (Admin)" })
  async update(
    @Request() req: any,
    @Param("id") id: string,
    @Body() updateAdvertisementDto: UpdateAdvertisementDto,
  ) {
    return this.advertisementsService.update(
      id,
      updateAdvertisementDto,
      "admin-user",
    );
  }

  @Delete("admin/advertisements/:id")
  @ApiOperation({ summary: "Delete an advertisement (Admin)" })
  async remove(@Request() req: any, @Param("id") id: string) {
    return this.advertisementsService.remove(id, "admin-user");
  }
}
