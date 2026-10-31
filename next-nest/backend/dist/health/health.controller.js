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
exports.HealthController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const health_service_1 = require("./health.service");
let HealthController = class HealthController {
    constructor(healthService) {
        this.healthService = healthService;
    }
    getLiveness() {
        return this.healthService.checkLiveness();
    }
    async getHealth() {
        return this.healthService.checkHealth();
    }
    async cookieTest(res) {
        if (process.env.NODE_ENV !== "staging" || process.env.ENABLE_STAGING_TEST_ROUTES !== "true") {
            throw new common_1.NotFoundException("Endpoint available only in staging environment with explicit test flag");
        }
        res.cookie("stg_test_a", "val_alpha", {
            httpOnly: true,
            secure: true,
            sameSite: "lax",
            path: "/",
        });
        res.cookie("stg_test_b", "val_beta", {
            httpOnly: true,
            secure: true,
            sameSite: "lax",
            path: "/",
        });
        return { status: "ok", cookieTest: true };
    }
};
exports.HealthController = HealthController;
__decorate([
    (0, common_1.Get)("liveness"),
    (0, swagger_1.ApiOperation)({ summary: "Ultra-fast process liveness check (no DB dependency)" }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: "Process liveness status",
        schema: {
            example: {
                status: "ok",
                service: "backend",
                timestamp: "2026-10-29T11:30:00.000Z",
            },
        },
    }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Object)
], HealthController.prototype, "getLiveness", null);
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: "Backend and Database Health Check" }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: "System health status and database connectivity indicator",
        schema: {
            example: {
                status: "ok",
                service: "backend",
                timestamp: "2026-09-09T11:30:00.000Z",
                database: "connected",
            },
        },
    }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], HealthController.prototype, "getHealth", null);
__decorate([
    (0, common_1.Get)("cookie-test"),
    (0, swagger_1.ApiOperation)({ summary: "Staging-only multi-cookie verification endpoint" }),
    __param(0, (0, common_1.Res)({ passthrough: true })),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], HealthController.prototype, "cookieTest", null);
exports.HealthController = HealthController = __decorate([
    (0, swagger_1.ApiTags)("Health"),
    (0, common_1.Controller)("health"),
    __metadata("design:paramtypes", [health_service_1.HealthService])
], HealthController);
//# sourceMappingURL=health.controller.js.map