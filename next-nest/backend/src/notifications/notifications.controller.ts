import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
} from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import { NotificationsService } from "./notifications.service";
import { CreateNotificationDto } from "./dto/create-notification.dto";
import { Public } from "../auth/decorators/public.decorator";

@ApiTags("Notifications")
@Controller()
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Public()
  @Get("notifications")
  @ApiOperation({ summary: "Get all broadcast notifications for the app" })
  async findAllPublic() {
    return this.notificationsService.findAllPublic();
  }

  @Get("admin/notifications")
  @ApiOperation({ summary: "Get all notifications for admin management" })
  async findAllAdmin() {
    return this.notificationsService.findAllAdmin();
  }

  @Post("admin/notifications")
  @ApiOperation({ summary: "Broadcast a new notification from admin panel" })
  async create(@Body() dto: CreateNotificationDto) {
    return this.notificationsService.create(dto);
  }

  @Delete("admin/notifications/:id")
  @ApiOperation({ summary: "Delete a broadcast notification" })
  async remove(@Param("id") id: string) {
    return this.notificationsService.remove(id);
  }
}
