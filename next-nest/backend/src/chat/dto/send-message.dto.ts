import { ApiProperty } from "@nestjs/swagger";
import { IsNotEmpty, IsOptional, IsString } from "class-validator";

export class SendMessageDto {
  @ApiProperty({
    description: "Conversation ID if already initiated",
    required: false,
  })
  @IsOptional()
  @IsString()
  conversationId?: string;

  @ApiProperty({
    description: "Recipient candidate profile ID",
    required: false,
  })
  @IsOptional()
  @IsString()
  receiverProfileId?: string;

  @ApiProperty({
    description: "Message content text",
  })
  @IsNotEmpty()
  @IsString()
  content: string;
}
