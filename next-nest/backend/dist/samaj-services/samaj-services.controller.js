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
exports.SamajServicesController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const samaj_services_service_1 = require("./samaj-services.service");
const public_decorator_1 = require("../auth/decorators/public.decorator");
const create_service_person_dto_1 = require("./dto/create-service-person.dto");
const update_service_person_dto_1 = require("./dto/update-service-person.dto");
let SamajServicesController = class SamajServicesController {
    constructor(samajServicesService) {
        this.samajServicesService = samajServicesService;
    }
    async getPublicServices(search, category) {
        return this.samajServicesService.getPublicServices(search, category);
    }
    async getPublicServiceById(id) {
        return this.samajServicesService.getPublicServiceById(id);
    }
    async getPublicPersonsByServiceId(serviceId, district, taluka, village, search) {
        return this.samajServicesService.getPublicPersonsByServiceId(serviceId, {
            district,
            taluka,
            village,
            search,
        });
    }
    async getAdminServices() {
        return this.samajServicesService.getAllAdminServices();
    }
    async createService(body) {
        return this.samajServicesService.createService(body);
    }
    async updateService(id, body) {
        return this.samajServicesService.updateService(id, body);
    }
    async deleteService(id) {
        return this.samajServicesService.deleteService(id);
    }
    async getAdminServicePersons(serviceId) {
        return this.samajServicesService.getAllAdminServicePersons(serviceId);
    }
    async createServicePerson(dto) {
        return this.samajServicesService.createServicePerson(dto);
    }
    async updateServicePerson(id, dto) {
        return this.samajServicesService.updateServicePerson(id, dto);
    }
    async deleteServicePerson(id) {
        return this.samajServicesService.deleteServicePerson(id);
    }
};
exports.SamajServicesController = SamajServicesController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("samaj-services"),
    (0, swagger_1.ApiOperation)({
        summary: "Get active Samaj Services for Flutter App & Public Web",
    }),
    __param(0, (0, common_1.Query)("search")),
    __param(1, (0, common_1.Query)("category")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", Promise)
], SamajServicesController.prototype, "getPublicServices", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("samaj-services/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Get active Samaj Service detail by ID" }),
    __param(0, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], SamajServicesController.prototype, "getPublicServiceById", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("samaj-services/:serviceId/persons"),
    (0, swagger_1.ApiOperation)({
        summary: "Get active service persons belonging to selected service ID",
    }),
    __param(0, (0, common_1.Param)("serviceId")),
    __param(1, (0, common_1.Query)("district")),
    __param(2, (0, common_1.Query)("taluka")),
    __param(3, (0, common_1.Query)("village")),
    __param(4, (0, common_1.Query)("search")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, String, String]),
    __metadata("design:returntype", Promise)
], SamajServicesController.prototype, "getPublicPersonsByServiceId", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Get)("admin/samaj-services"),
    (0, swagger_1.ApiOperation)({
        summary: "Get all Samaj Services for Admin Panel management",
    }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SamajServicesController.prototype, "getAdminServices", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)("admin/samaj-services"),
    (0, swagger_1.ApiOperation)({ summary: "Create a new Samaj Service from Admin Panel" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], SamajServicesController.prototype, "createService", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Patch)("admin/samaj-services/:id"),
    (0, swagger_1.ApiOperation)({
        summary: "Update Samaj Service details or status from Admin Panel",
    }),
    __param(0, (0, common_1.Param)("id")),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], SamajServicesController.prototype, "updateService", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Delete)("admin/samaj-services/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Delete Samaj Service from Admin Panel" }),
    __param(0, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], SamajServicesController.prototype, "deleteService", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Get)("admin/samaj-services/persons"),
    (0, swagger_1.ApiOperation)({
        summary: "Get all service persons for Admin Panel management",
    }),
    __param(0, (0, common_1.Query)("serviceId")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], SamajServicesController.prototype, "getAdminServicePersons", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Post)("admin/samaj-services/persons"),
    (0, swagger_1.ApiOperation)({ summary: "Create a new service person from Admin Panel" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_service_person_dto_1.CreateServicePersonDto]),
    __metadata("design:returntype", Promise)
], SamajServicesController.prototype, "createServicePerson", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Patch)("admin/samaj-services/persons/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Update service person details from Admin Panel" }),
    __param(0, (0, common_1.Param)("id")),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_service_person_dto_1.UpdateServicePersonDto]),
    __metadata("design:returntype", Promise)
], SamajServicesController.prototype, "updateServicePerson", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.Delete)("admin/samaj-services/persons/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Delete service person from Admin Panel" }),
    __param(0, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], SamajServicesController.prototype, "deleteServicePerson", null);
exports.SamajServicesController = SamajServicesController = __decorate([
    (0, swagger_1.ApiTags)("Samaj Services"),
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [samaj_services_service_1.SamajServicesService])
], SamajServicesController);
//# sourceMappingURL=samaj-services.controller.js.map