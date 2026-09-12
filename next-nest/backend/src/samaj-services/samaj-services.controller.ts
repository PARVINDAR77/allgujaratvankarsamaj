import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { SamajServicesService } from "./samaj-services.service";
import { Public } from "../auth/decorators/public.decorator";
import { CreateServicePersonDto } from "./dto/create-service-person.dto";
import { UpdateServicePersonDto } from "./dto/update-service-person.dto";

@ApiTags("Samaj Services")
@Controller()
export class SamajServicesController {
  constructor(private readonly samajServicesService: SamajServicesService) {}

  // ==========================================
  // PUBLIC FLUTTER APP ENDPOINTS
  // ==========================================

  @Public()
  @Get("samaj-services")
  @ApiOperation({ summary: "Get active Samaj Services for Flutter App & Public Web" })
  async getPublicServices() {
    return this.samajServicesService.getPublicServices();
  }

  @Public()
  @Get("samaj-services/:id")
  @ApiOperation({ summary: "Get active Samaj Service detail by ID" })
  async getPublicServiceById(@Param("id") id: string) {
    return this.samajServicesService.getPublicServiceById(id);
  }

  @Public()
  @Get("samaj-services/:serviceId/persons")
  @ApiOperation({ summary: "Get active service persons belonging to selected service ID" })
  async getPublicPersonsByServiceId(@Param("serviceId") serviceId: string) {
    return this.samajServicesService.getPublicPersonsByServiceId(serviceId);
  }

  // ==========================================
  // PROTECTED ADMIN PANEL ENDPOINTS (JWT Required)
  // ==========================================

  @ApiBearerAuth()
  @Get("admin/samaj-services")
  @ApiOperation({ summary: "Get all Samaj Services for Admin Panel management" })
  async getAdminServices() {
    return this.samajServicesService.getAllAdminServices();
  }

  @ApiBearerAuth()
  @Post("admin/samaj-services")
  @ApiOperation({ summary: "Create a new Samaj Service from Admin Panel" })
  async createService(@Body() body: any) {
    return this.samajServicesService.createService(body);
  }

  @ApiBearerAuth()
  @Patch("admin/samaj-services/:id")
  @ApiOperation({ summary: "Update Samaj Service details or status from Admin Panel" })
  async updateService(@Param("id") id: string, @Body() body: any) {
    return this.samajServicesService.updateService(id, body);
  }

  @ApiBearerAuth()
  @Delete("admin/samaj-services/:id")
  @ApiOperation({ summary: "Delete Samaj Service from Admin Panel" })
  async deleteService(@Param("id") id: string) {
    return this.samajServicesService.deleteService(id);
  }

  @ApiBearerAuth()
  @Get("admin/samaj-services/persons")
  @ApiOperation({ summary: "Get all service persons for Admin Panel management" })
  async getAdminServicePersons(@Query("serviceId") serviceId?: string) {
    return this.samajServicesService.getAllAdminServicePersons(serviceId);
  }

  @ApiBearerAuth()
  @Post("admin/samaj-services/persons")
  @ApiOperation({ summary: "Create a new service person from Admin Panel" })
  async createServicePerson(@Body() dto: CreateServicePersonDto) {
    return this.samajServicesService.createServicePerson(dto);
  }

  @ApiBearerAuth()
  @Patch("admin/samaj-services/persons/:id")
  @ApiOperation({ summary: "Update service person details from Admin Panel" })
  async updateServicePerson(
    @Param("id") id: string,
    @Body() dto: UpdateServicePersonDto
  ) {
    return this.samajServicesService.updateServicePerson(id, dto);
  }

  @ApiBearerAuth()
  @Delete("admin/samaj-services/persons/:id")
  @ApiOperation({ summary: "Delete service person from Admin Panel" })
  async deleteServicePerson(@Param("id") id: string) {
    return this.samajServicesService.deleteServicePerson(id);
  }
}
