"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RolePermissions = exports.PermissionToSectionMap = exports.AdminRole = exports.AdminSection = exports.Permission = void 0;
var Permission;
(function (Permission) {
    Permission["MEMBERS_READ"] = "members.read";
    Permission["MEMBERS_UPDATE"] = "members.update";
    Permission["MEMBERS_BLOCK"] = "members.block";
    Permission["MEMBERS_DELETE"] = "members.delete";
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
var AdminSection;
(function (AdminSection) {
    AdminSection["DASHBOARD"] = "dashboard";
    AdminSection["USERS"] = "users";
    AdminSection["PROFILES"] = "profiles";
    AdminSection["GOVERNMENT_EMPLOYEES"] = "government_employees";
    AdminSection["VERIFICATIONS"] = "verifications";
    AdminSection["MATCHES"] = "matches";
    AdminSection["EDUCATION"] = "education";
    AdminSection["LOCATIONS"] = "locations";
    AdminSection["SERVICES"] = "services";
    AdminSection["PAVAN_PRERNADATA"] = "pavan_prernadata";
    AdminSection["SAMAJ_SUPER_STARS"] = "samaj_super_stars";
    AdminSection["SAMAJ_RATNA"] = "samaj_ratna";
    AdminSection["HOME_SCREEN"] = "home_screen";
    AdminSection["ADVERTISEMENTS"] = "advertisements";
    AdminSection["NOTIFICATIONS"] = "notifications";
    AdminSection["REPORTS"] = "reports";
    AdminSection["OTP_ANALYTICS"] = "otp_analytics";
    AdminSection["SETTINGS"] = "settings";
})(AdminSection || (exports.AdminSection = AdminSection = {}));
var AdminRole;
(function (AdminRole) {
    AdminRole["SUPER_ADMIN"] = "SUPER_ADMIN";
    AdminRole["ADMIN"] = "ADMIN";
    AdminRole["VERIFICATION_ADMIN"] = "VERIFICATION_ADMIN";
    AdminRole["CONTENT_ADMIN"] = "CONTENT_ADMIN";
})(AdminRole || (exports.AdminRole = AdminRole = {}));
exports.PermissionToSectionMap = {
    [Permission.MEMBERS_READ]: [AdminSection.USERS, AdminSection.PROFILES],
    [Permission.MEMBERS_UPDATE]: [AdminSection.USERS, AdminSection.PROFILES],
    [Permission.MEMBERS_BLOCK]: [AdminSection.USERS],
    [Permission.MEMBERS_DELETE]: [AdminSection.USERS, AdminSection.PROFILES],
    [Permission.VERIFICATION_READ]: [AdminSection.VERIFICATIONS],
    [Permission.VERIFICATION_REVIEW]: [AdminSection.VERIFICATIONS],
    [Permission.GOVERNMENT_READ]: [AdminSection.GOVERNMENT_EMPLOYEES],
    [Permission.GOVERNMENT_MANAGE]: [AdminSection.GOVERNMENT_EMPLOYEES],
    [Permission.GOVERNMENT_FEATURE]: [AdminSection.GOVERNMENT_EMPLOYEES],
    [Permission.CONTENT_READ]: [
        AdminSection.ADVERTISEMENTS,
        AdminSection.SERVICES,
        AdminSection.HOME_SCREEN,
        AdminSection.EDUCATION,
        AdminSection.PAVAN_PRERNADATA,
        AdminSection.SAMAJ_SUPER_STARS,
        AdminSection.SAMAJ_RATNA,
    ],
    [Permission.CONTENT_MANAGE]: [
        AdminSection.ADVERTISEMENTS,
        AdminSection.SERVICES,
        AdminSection.HOME_SCREEN,
        AdminSection.EDUCATION,
        AdminSection.PAVAN_PRERNADATA,
        AdminSection.SAMAJ_SUPER_STARS,
        AdminSection.SAMAJ_RATNA,
    ],
    [Permission.AUDIT_READ]: [AdminSection.DASHBOARD, AdminSection.OTP_ANALYTICS],
    [Permission.STATISTICS_VIEW]: [AdminSection.DASHBOARD],
};
exports.RolePermissions = {
    [AdminRole.SUPER_ADMIN]: Object.values(Permission),
    [AdminRole.ADMIN]: [
        Permission.MEMBERS_READ,
        Permission.MEMBERS_UPDATE,
        Permission.MEMBERS_BLOCK,
        Permission.MEMBERS_DELETE,
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