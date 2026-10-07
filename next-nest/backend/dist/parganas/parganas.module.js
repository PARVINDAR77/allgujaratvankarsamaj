"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ParganasModule = void 0;
const common_1 = require("@nestjs/common");
const parganas_service_1 = require("./parganas.service");
const parganas_controller_1 = require("./parganas.controller");
const prisma_module_1 = require("../prisma/prisma.module");
let ParganasModule = class ParganasModule {
};
exports.ParganasModule = ParganasModule;
exports.ParganasModule = ParganasModule = __decorate([
    (0, common_1.Module)({
        imports: [prisma_module_1.PrismaModule],
        controllers: [parganas_controller_1.ParganasController],
        providers: [parganas_service_1.ParganasService],
        exports: [parganas_service_1.ParganasService],
    })
], ParganasModule);
//# sourceMappingURL=parganas.module.js.map