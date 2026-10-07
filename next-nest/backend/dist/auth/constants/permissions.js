"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RolePermissions = exports.AdminRole = exports.Permission = void 0;
var Permission;
(function (Permission) {
    Permission["MEMBERS_READ"] = "members.read";
    Permission["MEMBERS_UPDATE"] = "members.update";
    Permission["MEMBERS_BLOCK"] = "members.block";
    Permission["VERIFICATION_READ"] = "verification.read";
    Permission["VERIFICATION_REVIEW"] = "verification.review";
    Permission["GOVERNMENT_READ"] = "government.read";
    Permission["GOVERNMENT_MANAGE"] = "government.manage";
    Permission["GOVERNMENT_FEATURE"] = "government.feature";
    Permission["CONTENT_READ"] = "content.read";
    Permission["CONTENT_MANAGE"] = "content.manage";
    Permission["AUDIT_READ"] = "audit.read";
    Permission["STATISTICS_VIEW"] = "statistics.view";
})(Permission || (exports.Permission = Permission = {}));
var AdminRole;
(function (AdminRole) {
    AdminRole["SUPER_ADMIN"] = "SUPER_ADMIN";
    AdminRole["ADMIN"] = "ADMIN";
    AdminRole["VERIFICATION_ADMIN"] = "VERIFICATION_ADMIN";
    AdminRole["CONTENT_ADMIN"] = "CONTENT_ADMIN";
})(AdminRole || (exports.AdminRole = AdminRole = {}));
exports.RolePermissions = {
    [AdminRole.SUPER_ADMIN]: Object.values(Permission),
    [AdminRole.ADMIN]: [
        Permission.MEMBERS_READ,
        Permission.MEMBERS_UPDATE,
        Permission.MEMBERS_BLOCK,
        Permission.GOVERNMENT_READ,
        Permission.CONTENT_READ,
        Permission.STATISTICS_VIEW,
    ],
    [AdminRole.VERIFICATION_ADMIN]: [
        Permission.MEMBERS_READ,
        Permission.VERIFICATION_READ,
        Permission.VERIFICATION_REVIEW,
        Permission.GOVERNMENT_READ,
    ],
    [AdminRole.CONTENT_ADMIN]: [
        Permission.CONTENT_READ,
        Permission.CONTENT_MANAGE,
    ],
};
//# sourceMappingURL=permissions.js.map