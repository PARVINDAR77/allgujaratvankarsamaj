import { Module } from "@nestjs/common";
import { PrismaModule } from "../prisma/prisma.module";
import { SmsService } from "./sms.service";
import { MailService } from "./mail.service";
import { OtpService } from "./otp.service";

@Module({
  imports: [PrismaModule],
  providers: [SmsService, MailService, OtpService],
  exports: [SmsService, MailService, OtpService],
})
export class OtpModule {}
