"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RoleCapabilities = exports.Capability = void 0;
const client_1 = require("@prisma/client");
var Capability;
(function (Capability) {
    Capability["PROFILES_READ"] = "profiles.read";
    Capability["PROFILES_READ_PRIVATE"] = "profiles.read_private";
    Capability["PROFILES_CREATE"] = "profiles.create";
    Capability["PROFILES_UPDATE_OWN"] = "profiles.update_own";
    Capability["PROFILES_UPDATE_ANY"] = "profiles.update_any";
    Capability["PROFILES_DELETE_OWN"] = "profiles.delete_own";
    Capability["PROFILES_DELETE_ANY"] = "profiles.delete_any";
    Capability["VERIFICATION_READ"] = "verification.read";
    Capability["VERIFICATION_APPROVE"] = "verification.approve";
    Capability["VERIFICATION_REJECT"] = "verification.reject";
    Capability["USERS_READ"] = "users.read";
    Capability["USERS_UPDATE"] = "users.update";
    Capability["USERS_SUSPEND"] = "users.suspend";
    Capability["SAMAJ_SERVICES_READ"] = "samaj-services.read";
    Capability["SAMAJ_SERVICES_MANAGE"] = "samaj-services.manage";
    Capability["ADVERTISEMENTS_READ"] = "advertisements.read";
    Capability["ADVERTISEMENTS_MANAGE"] = "advertisements.manage";
    Capability["SUCCESS_STORIES_READ"] = "success-stories.read";
    Capability["SUCCESS_STORIES_MANAGE"] = "success-stories.manage";
    Capability["GOVERNMENT_EMPLOYEES_READ"] = "government-employees.read";
    Capability["GOVERNMENT_EMPLOYEES_MANAGE"] = "government-employees.manage";
    Capability["REPORTS_CREATE"] = "reports.create";
    Capability["REPORTS_READ"] = "reports.read";
    Capability["REPORTS_RESOLVE"] = "reports.resolve";
    Capability["SHORTLISTS_CREATE"] = "shortlists.create";
    Capability["SHORTLISTS_DELETE"] = "shortlists.delete";
    Capability["INTERESTS_CREATE"] = "interests.create";
    Capability["INTERESTS_READ"] = "interests.read";
    Capability["INTERESTS_MANAGE"] = "interests.manage";
    Capability["LOCATIONS_READ"] = "locations.read";
    Capability["LOCATIONS_MANAGE"] = "locations.manage";
    Capability["STATISTICS_READ"] = "statistics.read";
    Capability["ADMIN_AUDIT_READ"] = "admin.audit.read";
})(Capability || (exports.Capability = Capability = {}));
exports.RoleCapabilities = {
    [client_1.Role.USER]: [
        Capability.PROFILES_READ,
        Capability.PROFILES_CREATE,
        Capability.PROFILES_UPDATE_OWN,
        Capability.PROFILES_DELETE_OWN,
        Capability.INTERESTS_CREATE,
        Capability.INTERESTS_READ,
        Capability.SHORTLISTS_CREATE,
        Capability.SHORTLISTS_DELETE,
        Capability.REPORTS_CREATE,
        Capability.GOVERNMENT_EMPLOYEES_READ,
        Capability.SAMAJ_SERVICES_READ,
        Capability.ADVERTISEMENTS_READ,
        Capability.SUCCESS_STORIES_READ,
        Capability.LOCATIONS_READ,
    ],
    [client_1.Role.VERIFICATION_ADMIN]: [
        Capability.PROFILES_READ,
        Capability.PROFILES_READ_PRIVATE,
        Capability.VERIFICATION_READ,
        Capability.VERIFICATION_APPROVE,
        Capability.VERIFICATION_REJECT,
        Capability.GOVERNMENT_EMPLOYEES_READ,
        Capability.LOCATIONS_READ,
    ],
    [client_1.Role.CONTENT_ADMIN]: [
        Capability.PROFILES_READ,
        Capability.SAMAJ_SERVICES_READ,
        Capability.SAMAJ_SERVICES_MANAGE,
        Capability.ADVERTISEMENTS_READ,
        Capability.ADVERTISEMENTS_MANAGE,
        Capability.SUCCESS_STORIES_READ,
        Capability.SUCCESS_STORIES_MANAGE,
        Capability.LOCATIONS_READ,
    ],
    [client_1.Role.ADMIN]: [
        Capability.PROFILES_READ,
        Capability.PROFILES_READ_PRIVATE,
        Capability.PROFILES_UPDATE_ANY,
        Capability.USERS_READ,
        Capability.USERS_UPDATE,
        Capability.USERS_SUSPEND,
        Capability.GOVERNMENT_EMPLOYEES_READ,
        Capability.GOVERNMENT_EMPLOYEES_MANAGE,
        Capability.LOCATIONS_READ,
        Capability.LOCATIONS_MANAGE,
        Capability.STATISTICS_READ,
        Capability.REPORTS_READ,
        Capability.REPORTS_RESOLVE,
        Capability.VERIFICATION_READ,
        Capability.SAMAJ_SERVICES_READ,
        Capability.SUCCESS_STORIES_READ,
        Capability.ADVERTISEMENTS_READ,
        Capability.INTERESTS_READ,
        Capability.INTERESTS_MANAGE,
    ],
    [client_1.Role.SUPER_ADMIN]: Object.values(Capability),
};
//# sourceMappingURL=capabilities.js.map