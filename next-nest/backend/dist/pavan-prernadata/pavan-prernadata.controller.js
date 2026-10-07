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
exports.PavanPrernadataController = void 0;
const common_1 = require("@nestjs/common");
const pavan_prernadata_service_1 = require("./pavan-prernadata.service");
const public_decorator_1 = require("../auth/decorators/public.decorator");
let PavanPrernadataController = class PavanPrernadataController {
    constructor(pavanService) {
        this.pavanService = pavanService;
    }
    findAllPublic() {
        return this.pavanService.findAllPublic();
    }
    findAllAdmin() {
        return this.pavanService.findAllAdmin();
    }
    create(createDto) {
        return this.pavanService.create(createDto);
    }
    update(id, updateDto) {
        return this.pavanService.update(id, updateDto);
    }
    remove(id) {
        return this.pavanService.remove(id);
    }
};
exports.PavanPrernadataController = PavanPrernadataController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("pavan-prernadata"),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], PavanPrernadataController.prototype, "findAllPublic", null);
__decorate([
    (0, common_1.Get)("admin/pavan-prernadata"),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], PavanPrernadataController.prototype, "findAllAdmin", null);
__decorate([
    (0, common_1.Post)("admin/pavan-prernadata"),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], PavanPrernadataController.prototype, "create", null);
__decorate([
    (0, common_1.Patch)("admin/pavan-prernadata/:id"),
    __param(0, (0, common_1.Param)("id")),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], PavanPrernadataController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)("admin/pavan-prernadata/:id"),
    __param(0, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], PavanPrernadataController.prototype, "remove", null);
exports.PavanPrernadataController = PavanPrernadataController = __decorate([
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [pavan_prernadata_service_1.PavanPrernadataService])
], PavanPrernadataController);
//# sourceMappingURL=pavan-prernadata.controller.js.map