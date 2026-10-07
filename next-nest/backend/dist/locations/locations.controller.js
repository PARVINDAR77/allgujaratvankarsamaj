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
exports.LocationsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const locations_service_1 = require("./locations.service");
const public_decorator_1 = require("../auth/decorators/public.decorator");
let LocationsController = class LocationsController {
    constructor(locationsService) {
        this.locationsService = locationsService;
    }
    async getPublicStates() {
        return this.locationsService.getPublicStates();
    }
    async getPublicDistricts(stateId) {
        return this.locationsService.getPublicDistricts(stateId);
    }
    async getPublicTalukas(districtId) {
        return this.locationsService.getPublicTalukas(districtId);
    }
    async getPublicParganas(talukaId) {
        return this.locationsService.getPublicParganas(talukaId);
    }
    async getPublicVillages(parganaId, talukaId, search) {
        return this.locationsService.getPublicVillages({
            parganaId,
            talukaId,
            search,
        });
    }
    async getAdminStates() {
        return this.locationsService.getAdminStates();
    }
    async createState(body) {
        return this.locationsService.createState(body);
    }
    async updateState(id, body) {
        return this.locationsService.updateState(id, body);
    }
    async deleteState(id) {
        return this.locationsService.deleteState(id);
    }
    async getAdminDistricts(stateId) {
        return this.locationsService.getAdminDistricts(stateId);
    }
    async createDistrict(body) {
        return this.locationsService.createDistrict(body);
    }
    async updateDistrict(id, body) {
        return this.locationsService.updateDistrict(id, body);
    }
    async deleteDistrict(id) {
        return this.locationsService.deleteDistrict(id);
    }
    async getAdminTalukas(districtId) {
        return this.locationsService.getAdminTalukas(districtId);
    }
    async createTaluka(body) {
        return this.locationsService.createTaluka(body);
    }
    async updateTaluka(id, body) {
        return this.locationsService.updateTaluka(id, body);
    }
    async deleteTaluka(id) {
        return this.locationsService.deleteTaluka(id);
    }
    async getAdminVillages(parganaId, talukaId, search) {
        return this.locationsService.getAdminVillages({
            parganaId,
            talukaId,
            search,
        });
    }
    async createVillage(body) {
        return this.locationsService.createVillage(body);
    }
    async updateVillage(id, body) {
        return this.locationsService.updateVillage(id, body);
    }
    async deleteVillage(id) {
        return this.locationsService.deleteVillage(id);
    }
};
exports.LocationsController = LocationsController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("states"),
    (0, swagger_1.ApiOperation)({ summary: "Get public active states" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "getPublicStates", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("districts"),
    (0, swagger_1.ApiOperation)({ summary: "Get public active districts by stateId" }),
    __param(0, (0, common_1.Query)("stateId")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "getPublicDistricts", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("talukas"),
    (0, swagger_1.ApiOperation)({ summary: "Get public active talukas by districtId" }),
    __param(0, (0, common_1.Query)("districtId")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "getPublicTalukas", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("parganas"),
    (0, swagger_1.ApiOperation)({ summary: "Get public active parganas by talukaId" }),
    __param(0, (0, common_1.Query)("talukaId")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "getPublicParganas", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("villages"),
    (0, swagger_1.ApiOperation)({
        summary: "Get public active villages (searchable & paginated)",
    }),
    __param(0, (0, common_1.Query)("parganaId")),
    __param(1, (0, common_1.Query)("talukaId")),
    __param(2, (0, common_1.Query)("search")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "getPublicVillages", null);
__decorate([
    (0, common_1.Get)("admin/states"),
    (0, swagger_1.ApiOperation)({ summary: "Get all states for Admin Panel" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "getAdminStates", null);
__decorate([
    (0, common_1.Post)("admin/states"),
    (0, swagger_1.ApiOperation)({ summary: "Create state from Admin Panel" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "createState", null);
__decorate([
    (0, common_1.Patch)("admin/states/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Update state from Admin Panel" }),
    __param(0, (0, common_1.Param)("id")),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "updateState", null);
__decorate([
    (0, common_1.Delete)("admin/states/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Deactivate state from Admin Panel" }),
    __param(0, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "deleteState", null);
__decorate([
    (0, common_1.Get)("admin/districts"),
    (0, swagger_1.ApiOperation)({ summary: "Get all districts for Admin Panel" }),
    __param(0, (0, common_1.Query)("stateId")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "getAdminDistricts", null);
__decorate([
    (0, common_1.Post)("admin/districts"),
    (0, swagger_1.ApiOperation)({ summary: "Create district from Admin Panel" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "createDistrict", null);
__decorate([
    (0, common_1.Patch)("admin/districts/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Update district from Admin Panel" }),
    __param(0, (0, common_1.Param)("id")),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "updateDistrict", null);
__decorate([
    (0, common_1.Delete)("admin/districts/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Deactivate district from Admin Panel" }),
    __param(0, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "deleteDistrict", null);
__decorate([
    (0, common_1.Get)("admin/talukas"),
    (0, swagger_1.ApiOperation)({ summary: "Get all talukas for Admin Panel" }),
    __param(0, (0, common_1.Query)("districtId")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "getAdminTalukas", null);
__decorate([
    (0, common_1.Post)("admin/talukas"),
    (0, swagger_1.ApiOperation)({ summary: "Create taluka from Admin Panel" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "createTaluka", null);
__decorate([
    (0, common_1.Patch)("admin/talukas/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Update taluka from Admin Panel" }),
    __param(0, (0, common_1.Param)("id")),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "updateTaluka", null);
__decorate([
    (0, common_1.Delete)("admin/talukas/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Deactivate taluka from Admin Panel" }),
    __param(0, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "deleteTaluka", null);
__decorate([
    (0, common_1.Get)("admin/villages"),
    (0, swagger_1.ApiOperation)({ summary: "Get all villages for Admin Panel" }),
    __param(0, (0, common_1.Query)("parganaId")),
    __param(1, (0, common_1.Query)("talukaId")),
    __param(2, (0, common_1.Query)("search")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "getAdminVillages", null);
__decorate([
    (0, common_1.Post)("admin/villages"),
    (0, swagger_1.ApiOperation)({ summary: "Create village from Admin Panel" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "createVillage", null);
__decorate([
    (0, common_1.Patch)("admin/villages/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Update village from Admin Panel" }),
    __param(0, (0, common_1.Param)("id")),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "updateVillage", null);
__decorate([
    (0, common_1.Delete)("admin/villages/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Deactivate village from Admin Panel" }),
    __param(0, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LocationsController.prototype, "deleteVillage", null);
exports.LocationsController = LocationsController = __decorate([
    (0, swagger_1.ApiTags)("Locations"),
    (0, common_1.Controller)("locations"),
    __metadata("design:paramtypes", [locations_service_1.LocationsService])
], LocationsController);
//# sourceMappingURL=locations.controller.js.map