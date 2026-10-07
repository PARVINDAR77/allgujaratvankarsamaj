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
exports.SamajRatnaController = void 0;
const common_1 = require("@nestjs/common");
const samaj_ratna_service_1 = require("./samaj-ratna.service");
const public_decorator_1 = require("../auth/decorators/public.decorator");
let SamajRatnaController = class SamajRatnaController {
    constructor(samajRatnaService) {
        this.samajRatnaService = samajRatnaService;
    }
    findAllPublic() {
        return this.samajRatnaService.findAllPublic();
    }
    findAllAdmin() {
        return this.samajRatnaService.findAllAdmin();
    }
    create(createDto) {
        return this.samajRatnaService.create(createDto);
    }
    update(id, updateDto) {
        return this.samajRatnaService.update(id, updateDto);
    }
    remove(id) {
        return this.samajRatnaService.remove(id);
    }
};
exports.SamajRatnaController = SamajRatnaController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("samaj-ratna"),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], SamajRatnaController.prototype, "findAllPublic", null);
__decorate([
    (0, common_1.Get)("admin/samaj-ratna"),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], SamajRatnaController.prototype, "findAllAdmin", null);
__decorate([
    (0, common_1.Post)("admin/samaj-ratna"),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], SamajRatnaController.prototype, "create", null);
__decorate([
    (0, common_1.Patch)("admin/samaj-ratna/:id"),
    __param(0, (0, common_1.Param)("id")),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", void 0)
], SamajRatnaController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)("admin/samaj-ratna/:id"),
    __param(0, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], SamajRatnaController.prototype, "remove", null);
exports.SamajRatnaController = SamajRatnaController = __decorate([
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [samaj_ratna_service_1.SamajRatnaService])
], SamajRatnaController);
//# sourceMappingURL=samaj-ratna.controller.js.map