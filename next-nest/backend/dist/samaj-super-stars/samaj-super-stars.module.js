"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SamajSuperStarsModule = void 0;
const common_1 = require("@nestjs/common");
const samaj_super_stars_service_1 = require("./samaj-super-stars.service");
const samaj_super_stars_controller_1 = require("./samaj-super-stars.controller");
let SamajSuperStarsModule = class SamajSuperStarsModule {
};
exports.SamajSuperStarsModule = SamajSuperStarsModule;
exports.SamajSuperStarsModule = SamajSuperStarsModule = __decorate([
    (0, common_1.Module)({
        providers: [samaj_super_stars_service_1.SamajSuperStarsService],
        controllers: [samaj_super_stars_controller_1.SamajSuperStarsController]
    })
], SamajSuperStarsModule);
//# sourceMappingURL=samaj-super-stars.module.js.map