"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ProfileVisibilityPolicy = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const capabilities_1 = require("../../auth/constants/capabilities");
let ProfileVisibilityPolicy = class ProfileVisibilityPolicy {
    isProfilePubliclyVisible(profile, viewer) {
        if (!profile) {
            return false;
        }
        if (profile.status !== client_1.ProfileStatus.APPROVED) {
            if (viewer && viewer.id === profile.userId) {
                return true;
            }
            if (viewer && viewer.role) {
                const capabilities = capabilities_1.RoleCapabilities[viewer.role] || [];
                if (capabilities.includes(capabilities_1.Capability.PROFILES_READ_PRIVATE)) {
                    return true;
                }
            }
            return false;
        }
        if (profile.user && profile.user.status !== client_1.Status.ACTIVE) {
            return false;
        }
        return true;
    }
};
exports.ProfileVisibilityPolicy = ProfileVisibilityPolicy;
exports.ProfileVisibilityPolicy = ProfileVisibilityPolicy = __decorate([
    (0, common_1.Injectable)()
], ProfileVisibilityPolicy);
//# sourceMappingURL=profile-visibility.policy.js.map