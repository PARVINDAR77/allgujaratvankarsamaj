import { Body, Controller, Delete, Get, Param, Patch, Post, Query } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import { LocationsService } from "./locations.service";
import { Public } from "../auth/decorators/public.decorator";

@ApiTags("Locations")
@Controller("locations")
export class LocationsController {
  constructor(private readonly locationsService: LocationsService) {}

  // ==================== PUBLIC ENDPOINTS ====================
  @Public()
  @Get("states")
  @ApiOperation({ summary: "Get public active states" })
  async getPublicStates() {
    return this.locationsService.getPublicStates();
  }

  @Public()
  @Get("districts")
  @ApiOperation({ summary: "Get public active districts by stateId" })
  async getPublicDistricts(@Query("stateId") stateId?: string) {
    return this.locationsService.getPublicDistricts(stateId);
  }

  @Public()
  @Get("talukas")
  @ApiOperation({ summary: "Get public active talukas by districtId" })
  async getPublicTalukas(@Query("districtId") districtId?: string) {
    return this.locationsService.getPublicTalukas(districtId);
  }

  @Public()
  @Get("parganas")
  @ApiOperation({ summary: "Get public active parganas by talukaId" })
  async getPublicParganas(@Query("talukaId") talukaId?: string) {
    return this.locationsService.getPublicParganas(talukaId);
  }

  @Public()
  @Get("villages")
  @ApiOperation({ summary: "Get public active villages (searchable & paginated)" })
  async getPublicVillages(
    @Query("parganaId") parganaId?: string,
    @Query("talukaId") talukaId?: string,
    @Query("search") search?: string
  ) {
    return this.locationsService.getPublicVillages({ parganaId, talukaId, search });
  }

  // ==================== ADMIN ENDPOINTS ====================
  @Get("admin/states")
  @ApiOperation({ summary: "Get all states for Admin Panel" })
  async getAdminStates() {
    return this.locationsService.getAdminStates();
  }

  @Post("admin/states")
  @ApiOperation({ summary: "Create state from Admin Panel" })
  async createState(@Body() body: any) {
    return this.locationsService.createState(body);
  }

  @Patch("admin/states/:id")
  @ApiOperation({ summary: "Update state from Admin Panel" })
  async updateState(@Param("id") id: string, @Body() body: any) {
    return this.locationsService.updateState(id, body);
  }

  @Delete("admin/states/:id")
  @ApiOperation({ summary: "Deactivate state from Admin Panel" })
  async deleteState(@Param("id") id: string) {
    return this.locationsService.deleteState(id);
  }

  // Districts Admin
  @Get("admin/districts")
  @ApiOperation({ summary: "Get all districts for Admin Panel" })
  async getAdminDistricts(@Query("stateId") stateId?: string) {
    return this.locationsService.getAdminDistricts(stateId);
  }

  @Post("admin/districts")
  @ApiOperation({ summary: "Create district from Admin Panel" })
  async createDistrict(@Body() body: any) {
    return this.locationsService.createDistrict(body);
  }

  @Patch("admin/districts/:id")
  @ApiOperation({ summary: "Update district from Admin Panel" })
  async updateDistrict(@Param("id") id: string, @Body() body: any) {
    return this.locationsService.updateDistrict(id, body);
  }

  @Delete("admin/districts/:id")
  @ApiOperation({ summary: "Deactivate district from Admin Panel" })
  async deleteDistrict(@Param("id") id: string) {
    return this.locationsService.deleteDistrict(id);
  }

  // Talukas Admin
  @Get("admin/talukas")
  @ApiOperation({ summary: "Get all talukas for Admin Panel" })
  async getAdminTalukas(@Query("districtId") districtId?: string) {
    return this.locationsService.getAdminTalukas(districtId);
  }

  @Post("admin/talukas")
  @ApiOperation({ summary: "Create taluka from Admin Panel" })
  async createTaluka(@Body() body: any) {
    return this.locationsService.createTaluka(body);
  }

  @Patch("admin/talukas/:id")
  @ApiOperation({ summary: "Update taluka from Admin Panel" })
  async updateTaluka(@Param("id") id: string, @Body() body: any) {
    return this.locationsService.updateTaluka(id, body);
  }

  @Delete("admin/talukas/:id")
  @ApiOperation({ summary: "Deactivate taluka from Admin Panel" })
  async deleteTaluka(@Param("id") id: string) {
    return this.locationsService.deleteTaluka(id);
  }

  // Villages Admin
  @Get("admin/villages")
  @ApiOperation({ summary: "Get all villages for Admin Panel" })
  async getAdminVillages(
    @Query("parganaId") parganaId?: string,
    @Query("talukaId") talukaId?: string,
    @Query("search") search?: string
  ) {
    return this.locationsService.getAdminVillages({ parganaId, talukaId, search });
  }

  @Post("admin/villages")
  @ApiOperation({ summary: "Create village from Admin Panel" })
  async createVillage(@Body() body: any) {
    return this.locationsService.createVillage(body);
  }

  @Patch("admin/villages/:id")
  @ApiOperation({ summary: "Update village from Admin Panel" })
  async updateVillage(@Param("id") id: string, @Body() body: any) {
    return this.locationsService.updateVillage(id, body);
  }

  @Delete("admin/villages/:id")
  @ApiOperation({ summary: "Deactivate village from Admin Panel" })
  async deleteVillage(@Param("id") id: string) {
    return this.locationsService.deleteVillage(id);
  }
}
