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
exports.EducationController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const education_service_1 = require("./education.service");
const update_education_dto_1 = require("./dto/update-education.dto");
const public_decorator_1 = require("../auth/decorators/public.decorator");
let EducationController = class EducationController {
    constructor(educationService) {
        this.educationService = educationService;
    }
    async getEducation() {
        return this.educationService.getEducationContent();
    }
    async getAdminEducation() {
        return this.educationService.getEducationContent();
    }
    async updateEducation(dto) {
        return this.educationService.updateEducationContent(dto);
    }
};
exports.EducationController = EducationController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("education"),
    (0, swagger_1.ApiOperation)({
        summary: "Get Education for Better Tomorrow 4-box content for Flutter App",
    }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], EducationController.prototype, "getEducation", null);
__decorate([
    (0, common_1.Get)("admin/education"),
    (0, swagger_1.ApiOperation)({
        summary: "Get Education content for Admin Panel",
    }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], EducationController.prototype, "getAdminEducation", null);
__decorate([
    (0, common_1.Put)("admin/education"),
    (0, swagger_1.ApiOperation)({
        summary: "Update Education content from Admin Panel",
    }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [update_education_dto_1.UpdateEducationDto]),
    __metadata("design:returntype", Promise)
], EducationController.prototype, "updateEducation", null);
exports.EducationController = EducationController = __decorate([
    (0, swagger_1.ApiTags)("education"),
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [education_service_1.EducationService])
], EducationController);
//# sourceMappingURL=education.controller.js.map