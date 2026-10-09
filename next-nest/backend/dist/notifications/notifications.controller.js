"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const notifications_service_1 = require("./notifications.service");
const create_notification_dto_1 = require("./dto/create-notification.dto");
const public_decorator_1 = require("../auth/decorators/public.decorator");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
let NotificationsController = class NotificationsController {
    constructor(notificationsService) {
        this.notificationsService = notificationsService;
    }
    async findAllPublic() {
        return this.notificationsService.findAllPublic();
    }
    async findUserNotifications(req) {
        return this.notificationsService.getUserNotifications(req.user.id);
    }
    async getUnreadCount(req) {
        return this.notificationsService.getUnreadCount(req.user.id);
    }
    async markAsRead(req, id) {
        return this.notificationsService.markAsRead(req.user.id, id);
    }
    async markAllAsRead(req) {
        return this.notificationsService.markAllAsRead(req.user.id);
    }
    async findAllAdmin() {
        return this.notificationsService.findAllAdmin();
    }
    async create(dto) {
        return this.notificationsService.create(dto);
    }
    async remove(id) {
        return this.notificationsService.remove(id);
    }
};
exports.NotificationsController = NotificationsController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("notifications"),
    (0, swagger_1.ApiOperation)({ summary: "Get all broadcast notifications for the app" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "findAllPublic", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Get)("user/notifications"),
    (0, swagger_1.ApiOperation)({ summary: "Get personal notifications for authenticated user" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "findUserNotifications", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Get)("user/notifications/unread-count"),
    (0, swagger_1.ApiOperation)({ summary: "Get unread count of personal notifications" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "getUnreadCount", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Patch)("user/notifications/:id/read"),
    (0, swagger_1.ApiOperation)({ summary: "Mark a personal notification as read" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "markAsRead", null);
__decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)("user/notifications/read-all"),
    (0, swagger_1.ApiOperation)({ summary: "Mark all personal notifications as read" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "markAllAsRead", null);
__decorate([
    (0, common_1.Get)("admin/notifications"),
    (0, swagger_1.ApiOperation)({ summary: "Get all notifications for admin management" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "findAllAdmin", null);
__decorate([
    (0, common_1.Post)("admin/notifications"),
    (0, swagger_1.ApiOperation)({ summary: "Broadcast a new notification from admin panel" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_notification_dto_1.CreateNotificationDto]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "create", null);
__decorate([
    (0, common_1.Delete)("admin/notifications/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Delete a broadcast notification" }),
    __param(0, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], NotificationsController.prototype, "remove", null);
exports.NotificationsController = NotificationsController = __decorate([
    (0, swagger_1.ApiTags)("Notifications"),
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [notifications_service_1.NotificationsService])
], NotificationsController);
//# sourceMappingURL=notifications.controller.js.map