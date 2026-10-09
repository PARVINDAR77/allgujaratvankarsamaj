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
exports.ChatController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const chat_service_1 = require("./chat.service");
const send_message_dto_1 = require("./dto/send-message.dto");
let ChatController = class ChatController {
    constructor(chatService) {
        this.chatService = chatService;
    }
    async getUserConversations(req) {
        return this.chatService.getUserConversations(req.user.id);
    }
    async getOrCreateConversationWithPartner(req, partnerProfileId) {
        return this.chatService.getOrCreateConversationWithPartner(req.user.id, partnerProfileId);
    }
    async getConversationMessages(req, conversationId) {
        return this.chatService.getConversationMessages(req.user.id, conversationId);
    }
    async sendMessage(req, dto) {
        return this.chatService.sendMessage(req.user.id, dto);
    }
    async markAsRead(req, conversationId) {
        return this.chatService.markAsRead(req.user.id, conversationId);
    }
};
exports.ChatController = ChatController;
__decorate([
    (0, common_1.Get)("conversations"),
    (0, swagger_1.ApiOperation)({ summary: "List all active conversations for the authenticated user" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], ChatController.prototype, "getUserConversations", null);
__decorate([
    (0, common_1.Get)("conversation-with/:partnerProfileId"),
    (0, swagger_1.ApiOperation)({ summary: "Get or create conversation room with an accepted partner" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("partnerProfileId")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], ChatController.prototype, "getOrCreateConversationWithPartner", null);
__decorate([
    (0, common_1.Get)("conversations/:id/messages"),
    (0, swagger_1.ApiOperation)({ summary: "Get messages for a conversation and mark as read" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], ChatController.prototype, "getConversationMessages", null);
__decorate([
    (0, common_1.Post)("messages"),
    (0, swagger_1.ApiOperation)({ summary: "Send a chat message" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, send_message_dto_1.SendMessageDto]),
    __metadata("design:returntype", Promise)
], ChatController.prototype, "sendMessage", null);
__decorate([
    (0, common_1.Patch)("conversations/:id/read"),
    (0, swagger_1.ApiOperation)({ summary: "Mark conversation as read" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], ChatController.prototype, "markAsRead", null);
exports.ChatController = ChatController = __decorate([
    (0, swagger_1.ApiTags)("Chat"),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)("chat"),
    __metadata("design:paramtypes", [chat_service_1.ChatService])
], ChatController);
//# sourceMappingURL=chat.controller.js.map