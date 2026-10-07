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
exports.GovernmentEmployeesController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const government_employees_service_1 = require("./government-employees.service");
const government_employees_dto_1 = require("./dto/government-employees.dto");
let GovernmentEmployeesController = class GovernmentEmployeesController {
    constructor(govtEmployeesService) {
        this.govtEmployeesService = govtEmployeesService;
    }
    getDepartments() {
        return this.govtEmployeesService.getMasterDepartments();
    }
    searchPublic(query) {
        return this.govtEmployeesService.searchPublicGovtEmployees(query);
    }
    getFeatured() {
        return this.govtEmployeesService.getFeaturedGovtEmployees();
    }
    getMyEmployment(req) {
        return this.govtEmployeesService.getMyEmployment(req.user.id);
    }
    createMyEmployment(req, dto) {
        return this.govtEmployeesService.createMyEmployment(req.user.id, dto);
    }
    updateMyEmployment(req, dto) {
        return this.govtEmployeesService.updateMyEmployment(req.user.id, dto);
    }
    submitVerification(req, dto) {
        return this.govtEmployeesService.submitMyVerification(req.user.id, dto);
    }
    getPublicById(id) {
        return this.govtEmployeesService.getPublicGovtProfileById(id);
    }
    getAdminStats() {
        return this.govtEmployeesService.getAdminStats();
    }
    getAdminProfiles(page, limit, status) {
        return this.govtEmployeesService.getAdminGovtEmployees(Number(page) || 1, Number(limit) || 20, status);
    }
    verifyProfile(req, id, dto) {
        return this.govtEmployeesService.verifyGovtEmployee(id, dto, req.user.id);
    }
    setFeatured(req, id, dto) {
        return this.govtEmployeesService.setGovtEmployeeFeatured(id, dto, req.user.id);
    }
    setStatus(req, id, dto) {
        return this.govtEmployeesService.setGovtEmployeeStatus(id, dto, req.user.id);
    }
    createDepartment(req, dto) {
        return this.govtEmployeesService.createDepartment(dto, req.user.id);
    }
    updateDepartment(req, id, dto) {
        return this.govtEmployeesService.updateDepartment(id, dto, req.user.id);
    }
    deleteDepartment(req, id) {
        return this.govtEmployeesService.softDeleteDepartment(id, req.user.id);
    }
    createDesignation(req, dto) {
        return this.govtEmployeesService.createDesignation(dto, req.user.id);
    }
    updateDesignation(req, id, dto) {
        return this.govtEmployeesService.updateDesignation(id, dto, req.user.id);
    }
    deleteDesignation(req, id) {
        return this.govtEmployeesService.softDeleteDesignation(id, req.user.id);
    }
};
exports.GovernmentEmployeesController = GovernmentEmployeesController;
__decorate([
    (0, common_1.Get)("government-employees/departments"),
    (0, swagger_1.ApiOperation)({ summary: "Get active government departments & designations" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "getDepartments", null);
__decorate([
    (0, common_1.Get)("government-employees"),
    (0, swagger_1.ApiOperation)({
        summary: "Search & filter verified government employee profiles",
    }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [government_employees_dto_1.GovtEmployeeSearchQueryDto]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "searchPublic", null);
__decorate([
    (0, common_1.Get)("government-employees/featured"),
    (0, swagger_1.ApiOperation)({ summary: "Get featured government employee profiles" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "getFeatured", null);
__decorate([
    (0, common_1.Get)("government-employees/me"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: "Get current user government employment profile" }),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "getMyEmployment", null);
__decorate([
    (0, common_1.Post)("government-employees/me"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({
        summary: "Create current user government employment profile",
    }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, government_employees_dto_1.CreateGovtEmploymentDto]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "createMyEmployment", null);
__decorate([
    (0, common_1.Patch)("government-employees/me"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({
        summary: "Update current user government employment profile",
    }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, government_employees_dto_1.UpdateGovtEmploymentDto]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "updateMyEmployment", null);
__decorate([
    (0, common_1.Post)("government-employees/me/verification"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({
        summary: "Submit verification proof document for government employment",
    }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, government_employees_dto_1.SubmitVerificationDto]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "submitVerification", null);
__decorate([
    (0, common_1.Get)("government-employees/:id"),
    (0, swagger_1.ApiOperation)({
        summary: "Get public details of a verified government employee",
    }),
    __param(0, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "getPublicById", null);
__decorate([
    (0, common_1.Get)("admin/government-employees/stats"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({
        summary: "Get Admin dashboard government employee statistics",
    }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "getAdminStats", null);
__decorate([
    (0, common_1.Get)("admin/government-employees"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({
        summary: "Get all government employee profiles for Admin review",
    }),
    __param(0, (0, common_1.Query)("page")),
    __param(1, (0, common_1.Query)("limit")),
    __param(2, (0, common_1.Query)("status")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, String]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "getAdminProfiles", null);
__decorate([
    (0, common_1.Patch)("admin/government-employees/:id/verify"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({
        summary: "Approve or Reject government employment verification",
    }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)("id")),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, government_employees_dto_1.AdminVerifyGovtEmpDto]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "verifyProfile", null);
__decorate([
    (0, common_1.Patch)("admin/government-employees/:id/feature"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: "Set government employment featured status" }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)("id")),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, government_employees_dto_1.AdminFeatureGovtEmpDto]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "setFeatured", null);
__decorate([
    (0, common_1.Patch)("admin/government-employees/:id/status"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: "Set government employment active status" }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)("id")),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, government_employees_dto_1.AdminStatusGovtEmpDto]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "setStatus", null);
__decorate([
    (0, common_1.Post)("admin/government-departments"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, government_employees_dto_1.CreateDepartmentDto]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "createDepartment", null);
__decorate([
    (0, common_1.Patch)("admin/government-departments/:id"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)("id")),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "updateDepartment", null);
__decorate([
    (0, common_1.Delete)("admin/government-departments/:id"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "deleteDepartment", null);
__decorate([
    (0, common_1.Post)("admin/government-designations"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, government_employees_dto_1.CreateDesignationDto]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "createDesignation", null);
__decorate([
    (0, common_1.Patch)("admin/government-designations/:id"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)("id")),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "updateDesignation", null);
__decorate([
    (0, common_1.Delete)("admin/government-designations/:id"),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], GovernmentEmployeesController.prototype, "deleteDesignation", null);
exports.GovernmentEmployeesController = GovernmentEmployeesController = __decorate([
    (0, swagger_1.ApiTags)("Government Employees"),
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [government_employees_service_1.GovernmentEmployeesService])
], GovernmentEmployeesController);
//# sourceMappingURL=government-employees.controller.js.map