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
exports.ParganasController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const parganas_service_1 = require("./parganas.service");
const public_decorator_1 = require("../auth/decorators/public.decorator");
let ParganasController = class ParganasController {
    constructor(parganasService) {
        this.parganasService = parganasService;
    }
    async getPublicParganas() {
        return this.parganasService.getPublicParganas();
    }
    async getAdminParganas() {
        return this.parganasService.getAllAdminParganas();
    }
    async createPargana(body) {
        return this.parganasService.createPargana(body);
    }
    async updatePargana(id, body) {
        return this.parganasService.updatePargana(id, body);
    }
    async deletePargana(id) {
        return this.parganasService.deletePargana(id);
    }
};
exports.ParganasController = ParganasController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("parganas"),
    (0, swagger_1.ApiOperation)({
        summary: "Get list of active parganas for Flutter & public website",
    }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], ParganasController.prototype, "getPublicParganas", null);
__decorate([
    (0, common_1.Get)("admin/parganas"),
    (0, swagger_1.ApiOperation)({ summary: "Get all parganas for Admin Panel" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], ParganasController.prototype, "getAdminParganas", null);
__decorate([
    (0, common_1.Post)("admin/parganas"),
    (0, swagger_1.ApiOperation)({ summary: "Create a new pargana region from Admin Panel" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], ParganasController.prototype, "createPargana", null);
__decorate([
    (0, common_1.Patch)("admin/parganas/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Update pargana region details from Admin Panel" }),
    __param(0, (0, common_1.Param)("id")),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ParganasController.prototype, "updatePargana", null);
__decorate([
    (0, common_1.Delete)("admin/parganas/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Delete pargana region from Admin Panel" }),
    __param(0, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ParganasController.prototype, "deletePargana", null);
exports.ParganasController = ParganasController = __decorate([
    (0, swagger_1.ApiTags)("Parganas"),
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [parganas_service_1.ParganasService])
], ParganasController);
//# sourceMappingURL=parganas.controller.js.map