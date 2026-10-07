import { Controller, Get, Put, Body } from "@nestjs/common";
import { ApiTags, ApiOperation } from "@nestjs/swagger";
import { EducationService } from "./education.service";
import { UpdateEducationDto } from "./dto/update-education.dto";
import { Public } from "../auth/decorators/public.decorator";

@ApiTags("education")
@Controller()
export class EducationController {
  constructor(private readonly educationService: EducationService) {}

  @Public()
  @Get("education")
  @ApiOperation({
    summary: "Get Education for Better Tomorrow 4-box content for Flutter App",
  })
  async getEducation() {
    return this.educationService.getEducationContent();
  }

  @Public()
  @Get("admin/education")
  @ApiOperation({
    summary: "Get Education content for Admin Panel",
  })
  async getAdminEducation() {
    return this.educationService.getEducationContent();
  }

  @Public()
  @Put("admin/education")
  @ApiOperation({
    summary: "Update Education content from Admin Panel",
  })
  async updateEducation(@Body() dto: UpdateEducationDto) {
    return this.educationService.updateEducationContent(dto);
  }
}
