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
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { NotificationsService } from "./notifications.service";
import { CreateNotificationDto } from "./dto/create-notification.dto";
import { Public } from "../auth/decorators/public.decorator";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";

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

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Get("user/notifications")
  @ApiOperation({ summary: "Get personal notifications for authenticated user" })
  async findUserNotifications(@Request() req: any) {
    return this.notificationsService.getUserNotifications(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Get("user/notifications/unread-count")
  @ApiOperation({ summary: "Get unread count of personal notifications" })
  async getUnreadCount(@Request() req: any) {
    return this.notificationsService.getUnreadCount(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Patch("user/notifications/:id/read")
  @ApiOperation({ summary: "Mark a personal notification as read" })
  async markAsRead(@Request() req: any, @Param("id") id: string) {
    return this.notificationsService.markAsRead(req.user.id, id);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post("user/notifications/read-all")
  @ApiOperation({ summary: "Mark all personal notifications as read" })
  async markAllAsRead(@Request() req: any) {
    return this.notificationsService.markAllAsRead(req.user.id);
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
