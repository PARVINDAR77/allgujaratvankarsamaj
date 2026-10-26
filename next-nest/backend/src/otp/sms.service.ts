import { Injectable, Logger } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { OtpChannel, OtpPurpose, OtpStatus } from "@prisma/client";

export interface SendSmsResult {
  success: boolean;
  messageId?: string;
  gatewayResponse?: any;
  error?: string;
}

@Injectable()
export class SmsService {
  private readonly logger = new Logger(SmsService.name);

  // Default credentials pre-configured from DLT portal
  private readonly gatewayUrl =
    process.env.SMS_GATEWAY_URL ||
    "https://allsmssolution.in/sms-panel/api/http/index.php";
  private readonly username = process.env.SMS_USERNAME || "EMPEROR";
  private readonly apiKey = process.env.SMS_APIKEY || "62CEF-9A446";
  private readonly senderId = process.env.SMS_SENDER_ID || "TXXTOO";
  private readonly templateId =
    process.env.SMS_TEMPLATE_ID || "1607100000000313742";
  private readonly entityId =
    process.env.SMS_ENTITY_ID || "1401805350000060162";
  private readonly route = process.env.SMS_ROUTE || "TRANS";

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Builds the TRAI DLT approved template text
   */
  private formatDltMessage(name: string, otp: string, signOff: string = "All Gujarat Vankar Samaj"): string {
    const cleanName = (name || "Member").trim().slice(0, 30);
    const cleanSignOff = signOff.trim().slice(0, 30);
    return `Dear ${cleanName} Your OTP for verification is ${otp}. Please enter this code to complete the process.\nRegards ${cleanSignOff}\nTEXT2`;
  }

  /**
   * Clean and normalize a 10-digit Indian phone number
   */
  public cleanPhoneNumber(phone: string): string {
    const digits = phone.replace(/\D/g, "");
    if (digits.length === 12 && digits.startsWith("91")) {
      return digits.slice(2);
    }
    if (digits.length === 11 && digits.startsWith("0")) {
      return digits.slice(1);
    }
    return digits;
  }

  /**
   * Dispatch SMS via allsmssolution HTTP Gateway
   */
  async sendOtpSms(params: {
    phone: string;
    otp: string;
    recipientName?: string;
    purpose: OtpPurpose;
    ipAddress?: string;
  }): Promise<SendSmsResult> {
    const cleanPhone = this.cleanPhoneNumber(params.phone);
    const recipientName = params.recipientName || "Member";
    const finalMessage = this.formatDltMessage(recipientName, params.otp);

    this.logger.log(`Dispatching DLT SMS to ${cleanPhone} (Purpose: ${params.purpose})`);

    const postParams = new URLSearchParams();
    postParams.append("username", this.username);
    postParams.append("apikey", this.apiKey);
    postParams.append("apirequest", "Text");
    postParams.append("sender", this.senderId);
    postParams.append("route", this.route);
    postParams.append("format", "JSON");
    postParams.append("message", finalMessage);
    postParams.append("mobile", cleanPhone);
    postParams.append("TemplateID", this.templateId);
    postParams.append("EntityID", this.entityId);
    postParams.append("PE_ID", this.entityId);

    let status: OtpStatus = OtpStatus.SENT;
    let gatewayId: string | undefined;
    let rawResponseText = "";
    let isSuccess = false;

    try {
      const response = await fetch(this.gatewayUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: postParams.toString(),
      });

      rawResponseText = await response.text();
      this.logger.log(`DLT Gateway HTTP ${response.status} Response: ${rawResponseText}`);

      let parsed: any;
      try {
        parsed = JSON.parse(rawResponseText);
      } catch {
        parsed = { raw: rawResponseText };
      }

      // Check success response criteria from allsmssolution
      if (
        response.ok &&
        (parsed?.status?.toLowerCase() === "success" ||
          parsed?.status?.toLowerCase() === "submitted" ||
          parsed?.status?.toLowerCase() === "queued" ||
          parsed?.status === "1" ||
          (parsed?.message && !parsed.message.toLowerCase().includes("error")))
      ) {
        isSuccess = true;
        status = OtpStatus.DELIVERED;
        gatewayId =
          parsed?.message_id ||
          parsed?.msgid ||
          parsed?.batch_id ||
          (Array.isArray(parsed?.data) ? parsed.data[0]?.id : undefined);
      } else if (response.ok && rawResponseText.toLowerCase().includes("success")) {
        isSuccess = true;
        status = OtpStatus.DELIVERED;
      } else {
        status = OtpStatus.FAILED;
      }

      // Record in OtpLog
      await this.prisma.otpLog.create({
        data: {
          channel: OtpChannel.SMS,
          purpose: params.purpose,
          recipient: cleanPhone,
          ipAddress: params.ipAddress,
          status,
          gatewayId,
          gatewayResp: rawResponseText.slice(0, 1000),
        },
      });

      return {
        success: isSuccess,
        messageId: gatewayId,
        gatewayResponse: parsed,
      };
    } catch (error: any) {
      this.logger.error(`Failed to send SMS to ${cleanPhone}: ${error.message}`, error.stack);

      try {
        await this.prisma.otpLog.create({
          data: {
            channel: OtpChannel.SMS,
            purpose: params.purpose,
            recipient: cleanPhone,
            ipAddress: params.ipAddress,
            status: OtpStatus.FAILED,
            gatewayResp: `Error: ${error.message}`,
          },
        });
      } catch (logErr: any) {
        this.logger.warn(`Failed to create failed OtpLog: ${logErr.message}`);
      }

      return {
        success: false,
        error: error.message,
      };
    }
  }
}
