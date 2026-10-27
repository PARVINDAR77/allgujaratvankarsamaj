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
var SmsService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.SmsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
const https = require("https");
const http = require("http");
const url_1 = require("url");
let SmsService = SmsService_1 = class SmsService {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger(SmsService_1.name);
        this.gatewayUrl = process.env.SMS_GATEWAY_URL ||
            "https://allsmssolution.in/sms-panel/api/http/index.php";
        this.username = process.env.SMS_USERNAME || "EMPEROR";
        this.apiKey = process.env.SMS_APIKEY || "62CEF-9A446";
        this.senderId = process.env.SMS_SENDER_ID || "TXXTOO";
        this.templateId = process.env.SMS_TEMPLATE_ID || "1607100000000313742";
        this.entityId = process.env.SMS_ENTITY_ID || "1401805350000060162";
        this.route = process.env.SMS_ROUTE || "TRANS";
    }
    formatDltMessage(name, otp, signOff = process.env.SMS_SIGNOFF || "Team Emperor") {
        const cleanName = (name || "Member").trim().slice(0, 30);
        const cleanSignOff = signOff.trim().slice(0, 30);
        return `Dear ${cleanName} Your OTP for verification is ${otp}. Please enter this code to complete the process.\nRegards ${cleanSignOff}\nTEXT2`;
    }
    cleanPhoneNumber(phone) {
        const digits = phone.replace(/\D/g, "");
        if (digits.length === 12 && digits.startsWith("91")) {
            return digits.slice(2);
        }
        if (digits.length === 11 && digits.startsWith("0")) {
            return digits.slice(1);
        }
        return digits;
    }
    async sendOtpSms(params) {
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
        let status = client_1.OtpStatus.SENT;
        let gatewayId;
        let rawResponseText = "";
        let isSuccess = false;
        const postBody = postParams.toString();
        try {
            const response = await this.executeHttpRequest(this.gatewayUrl, postBody, {
                "Content-Type": "application/x-www-form-urlencoded",
                "Content-Length": Buffer.byteLength(postBody).toString(),
            });
            rawResponseText = response.text;
            this.logger.log(`DLT Gateway HTTP ${response.status} Response: ${rawResponseText}`);
            let parsed;
            try {
                parsed = JSON.parse(rawResponseText);
            }
            catch {
                parsed = { raw: rawResponseText };
            }
            if (response.ok &&
                (parsed?.status?.toLowerCase() === "success" ||
                    parsed?.status?.toLowerCase() === "submitted" ||
                    parsed?.status?.toLowerCase() === "queued" ||
                    parsed?.status === "1" ||
                    (parsed?.message && !parsed.message.toLowerCase().includes("error")))) {
                isSuccess = true;
                status = client_1.OtpStatus.DELIVERED;
                gatewayId =
                    parsed?.message_id ||
                        parsed?.msgid ||
                        parsed?.batch_id ||
                        (Array.isArray(parsed?.data) ? parsed.data[0]?.id : undefined);
            }
            else if (response.ok && rawResponseText.toLowerCase().includes("success")) {
                isSuccess = true;
                status = client_1.OtpStatus.DELIVERED;
            }
            else {
                status = client_1.OtpStatus.FAILED;
            }
            await this.prisma.otpLog.create({
                data: {
                    channel: client_1.OtpChannel.SMS,
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
        }
        catch (error) {
            this.logger.error(`Failed to send SMS to ${cleanPhone}: ${error.message}`, error.stack);
            try {
                await this.prisma.otpLog.create({
                    data: {
                        channel: client_1.OtpChannel.SMS,
                        purpose: params.purpose,
                        recipient: cleanPhone,
                        ipAddress: params.ipAddress,
                        status: client_1.OtpStatus.FAILED,
                        gatewayResp: `Error: ${error.message}`,
                    },
                });
            }
            catch (logErr) {
                this.logger.warn(`Failed to create failed OtpLog: ${logErr.message}`);
            }
            return {
                success: false,
                error: error.message,
            };
        }
    }
    executeHttpRequest(urlStr, body, headers) {
        return new Promise((resolve, reject) => {
            try {
                const parsedUrl = new url_1.URL(urlStr);
                const isHttps = parsedUrl.protocol === "https:";
                const client = isHttps ? https : http;
                const req = client.request({
                    protocol: parsedUrl.protocol,
                    hostname: parsedUrl.hostname,
                    port: parsedUrl.port || (isHttps ? 443 : 80),
                    path: `${parsedUrl.pathname}${parsedUrl.search}`,
                    method: "POST",
                    headers,
                    timeout: 10000,
                }, (res) => {
                    let data = "";
                    res.setEncoding("utf8");
                    res.on("data", (chunk) => {
                        data += chunk;
                    });
                    res.on("end", () => {
                        const status = res.statusCode || 200;
                        resolve({
                            status,
                            text: data,
                            ok: status >= 200 && status < 300,
                        });
                    });
                });
                req.on("timeout", () => {
                    req.destroy(new Error("SMS gateway request timed out after 10000ms"));
                });
                req.on("error", (err) => {
                    reject(err);
                });
                req.write(body);
                req.end();
            }
            catch (err) {
                reject(err);
            }
        });
    }
};
exports.SmsService = SmsService;
exports.SmsService = SmsService = SmsService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], SmsService);
//# sourceMappingURL=sms.service.js.map