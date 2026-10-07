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
Object.defineProperty(exports, "__esModule", { value: true });
exports.CapabilitiesGuard = void 0;
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
const capabilities_1 = require("../constants/capabilities");
const capabilities_decorator_1 = require("../decorators/capabilities.decorator");
let CapabilitiesGuard = class CapabilitiesGuard {
    constructor(reflector) {
        this.reflector = reflector;
    }
    canActivate(context) {
        const requiredCapabilities = this.reflector.getAllAndOverride(capabilities_decorator_1.CAPABILITIES_KEY, [context.getHandler(), context.getClass()]);
        if (!requiredCapabilities || requiredCapabilities.length === 0) {
            return true;
        }
        const { user } = context.switchToHttp().getRequest();
        if (!user || !user.role) {
            return false;
        }
        const userRole = user.role;
        const userCapabilities = capabilities_1.RoleCapabilities[userRole];
        if (!userCapabilities) {
            return false;
        }
        const hasCapabilities = requiredCapabilities.every((capability) => userCapabilities.includes(capability));
        if (!hasCapabilities) {
            throw new common_1.ForbiddenException("Insufficient capabilities");
        }
        return true;
    }
};
exports.CapabilitiesGuard = CapabilitiesGuard;
exports.CapabilitiesGuard = CapabilitiesGuard = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [core_1.Reflector])
], CapabilitiesGuard);
//# sourceMappingURL=capabilities.guard.js.map