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
exports.InterestsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const interests_service_1 = require("./interests.service");
const create_interest_dto_1 = require("./dto/create-interest.dto");
let InterestsController = class InterestsController {
    constructor(interestsService) {
        this.interestsService = interestsService;
    }
    async sendInterestRoot(req, dto) {
        return this.interestsService.sendInterest(req.user.id, dto);
    }
    async sendInterest(req, dto) {
        return this.interestsService.sendInterest(req.user.id, dto);
    }
    async getInterestStatus(req, targetProfileId) {
        return this.interestsService.getInterestStatus(req.user.id, targetProfileId);
    }
    async acceptInterest(req, interestId) {
        return this.interestsService.acceptInterest(req.user.id, interestId);
    }
    async declineInterest(req, interestId) {
        return this.interestsService.declineInterest(req.user.id, interestId);
    }
    async getSentInterests(req) {
        return this.interestsService.getSentInterests(req.user.id);
    }
    async getReceivedInterests(req) {
        return this.interestsService.getReceivedInterests(req.user.id);
    }
};
exports.InterestsController = InterestsController;
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: "Send an interest to another profile" }),
    (0, swagger_1.ApiResponse)({ status: 201, description: "Interest sent successfully" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_interest_dto_1.CreateInterestDto]),
    __metadata("design:returntype", Promise)
], InterestsController.prototype, "sendInterestRoot", null);
__decorate([
    (0, common_1.Post)("send"),
    (0, swagger_1.ApiOperation)({ summary: "Send an interest to another profile" }),
    (0, swagger_1.ApiResponse)({ status: 201, description: "Interest sent successfully" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_interest_dto_1.CreateInterestDto]),
    __metadata("design:returntype", Promise)
], InterestsController.prototype, "sendInterest", null);
__decorate([
    (0, common_1.Get)("status/:targetProfileId"),
    (0, swagger_1.ApiOperation)({ summary: "Check connection/interest status with a target profile" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("targetProfileId")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], InterestsController.prototype, "getInterestStatus", null);
__decorate([
    (0, common_1.Patch)(":id/accept"),
    (0, swagger_1.ApiOperation)({ summary: "Accept a received interest" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Interest accepted" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], InterestsController.prototype, "acceptInterest", null);
__decorate([
    (0, common_1.Patch)(":id/decline"),
    (0, swagger_1.ApiOperation)({ summary: "Decline a received interest" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Interest declined" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], InterestsController.prototype, "declineInterest", null);
__decorate([
    (0, common_1.Get)("sent"),
    (0, swagger_1.ApiOperation)({ summary: "Get all interests sent by the user" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "List of sent interests" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], InterestsController.prototype, "getSentInterests", null);
__decorate([
    (0, common_1.Get)("received"),
    (0, swagger_1.ApiOperation)({ summary: "Get all interests received by the user" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "List of received interests" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], InterestsController.prototype, "getReceivedInterests", null);
exports.InterestsController = InterestsController = __decorate([
    (0, swagger_1.ApiTags)("Interests"),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)("interests"),
    __metadata("design:paramtypes", [interests_service_1.InterestsService])
], InterestsController);
//# sourceMappingURL=interests.controller.js.map