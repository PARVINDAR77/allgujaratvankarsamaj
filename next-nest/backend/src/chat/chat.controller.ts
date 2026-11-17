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
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { ChatService } from "./chat.service";
import { SendMessageDto } from "./dto/send-message.dto";

@ApiTags("Chat")
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller("chat")
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Get("conversations")
  @ApiOperation({ summary: "List all active conversations for the authenticated user" })
  async getUserConversations(@Request() req: any) {
    return this.chatService.getUserConversations(req.user.id);
  }

  @Get("conversation-with/:partnerProfileId")
  @ApiOperation({ summary: "Get or create conversation room with an accepted partner" })
  async getOrCreateConversationWithPartner(
    @Request() req: any,
    @Param("partnerProfileId") partnerProfileId: string,
  ) {
    return this.chatService.getOrCreateConversationWithPartner(
      req.user.id,
      partnerProfileId,
    );
  }

  @Get("conversations/:id/messages")
  @ApiOperation({ summary: "Get messages for a conversation and mark as read" })
  async getConversationMessages(
    @Request() req: any,
    @Param("id") conversationId: string,
  ) {
    return this.chatService.getConversationMessages(req.user.id, conversationId);
  }

  @Post("messages")
  @ApiOperation({ summary: "Send a chat message" })
  async sendMessage(@Request() req: any, @Body() dto: SendMessageDto) {
    return this.chatService.sendMessage(req.user.id, dto);
  }

  @Patch("conversations/:id/read")
  @ApiOperation({ summary: "Mark conversation as read" })
  async markAsRead(@Request() req: any, @Param("id") conversationId: string) {
    return this.chatService.markAsRead(req.user.id, conversationId);
  }

  @Delete("conversations/:id")
  @ApiOperation({ summary: "Delete an entire conversation and its messages" })
  async deleteConversation(
    @Request() req: any,
    @Param("id") conversationId: string,
  ) {
    return this.chatService.deleteConversation(req.user.id, conversationId);
  }

  @Delete("conversations/:id/messages")
  @ApiOperation({ summary: "Clear all messages in a conversation" })
  async clearMessages(
    @Request() req: any,
    @Param("id") conversationId: string,
  ) {
    return this.chatService.clearMessages(req.user.id, conversationId);
  }

  @Delete("messages/:messageId")
  @ApiOperation({ summary: "Delete a specific chat message" })
  async deleteMessage(
    @Request() req: any,
    @Param("messageId") messageId: string,
  ) {
    return this.chatService.deleteMessage(req.user.id, messageId);
  }
}
