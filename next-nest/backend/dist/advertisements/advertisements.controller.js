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
exports.AdvertisementsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const advertisements_service_1 = require("./advertisements.service");
const create_advertisement_dto_1 = require("./dto/create-advertisement.dto");
const update_advertisement_dto_1 = require("./dto/update-advertisement.dto");
const public_decorator_1 = require("../auth/decorators/public.decorator");
let AdvertisementsController = class AdvertisementsController {
    constructor(advertisementsService) {
        this.advertisementsService = advertisementsService;
    }
    async findAllPublic() {
        return this.advertisementsService.findAllPublic();
    }
    async findAllAdmin() {
        return this.advertisementsService.findAllAdmin();
    }
    async findOne(id) {
        return this.advertisementsService.findOne(id);
    }
    async create(req, createAdvertisementDto) {
        return this.advertisementsService.create(createAdvertisementDto, "admin-user");
    }
    async update(req, id, updateAdvertisementDto) {
        return this.advertisementsService.update(id, updateAdvertisementDto, "admin-user");
    }
    async remove(req, id) {
        return this.advertisementsService.remove(id, "admin-user");
    }
};
exports.AdvertisementsController = AdvertisementsController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("advertisements"),
    (0, swagger_1.ApiOperation)({ summary: "Get all active advertisements for the public app" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AdvertisementsController.prototype, "findAllPublic", null);
__decorate([
    (0, common_1.Get)("admin/advertisements"),
    (0, swagger_1.ApiOperation)({ summary: "Get all advertisements (Admin)" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AdvertisementsController.prototype, "findAllAdmin", null);
__decorate([
    (0, common_1.Get)("admin/advertisements/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Get a specific advertisement by ID (Admin)" }),
    __param(0, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AdvertisementsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Post)("admin/advertisements"),
    (0, swagger_1.ApiOperation)({ summary: "Create a new advertisement (Admin)" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_advertisement_dto_1.CreateAdvertisementDto]),
    __metadata("design:returntype", Promise)
], AdvertisementsController.prototype, "create", null);
__decorate([
    (0, common_1.Patch)("admin/advertisements/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Update an advertisement (Admin)" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, update_advertisement_dto_1.UpdateAdvertisementDto]),
    __metadata("design:returntype", Promise)
], AdvertisementsController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)("admin/advertisements/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Delete an advertisement (Admin)" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], AdvertisementsController.prototype, "remove", null);
exports.AdvertisementsController = AdvertisementsController = __decorate([
    (0, swagger_1.ApiTags)("Advertisements"),
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [advertisements_service_1.AdvertisementsService])
], AdvertisementsController);
//# sourceMappingURL=advertisements.controller.js.map