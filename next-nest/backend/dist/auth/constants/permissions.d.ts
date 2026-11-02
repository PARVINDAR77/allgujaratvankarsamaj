export declare enum Permission {
    MEMBERS_READ = "members.read",
    MEMBERS_UPDATE = "members.update",
    MEMBERS_BLOCK = "members.block",
    MEMBERS_DELETE = "members.delete",
    VERIFICATION_READ = "verification.read",
    VERIFICATION_REVIEW = "verification.review",
    GOVERNMENT_READ = "government.read",
    GOVERNMENT_MANAGE = "government.manage",
    GOVERNMENT_FEATURE = "government.feature",
    CONTENT_READ = "content.read",
    CONTENT_MANAGE = "content.manage",
    AUDIT_READ = "audit.read",
    STATISTICS_VIEW = "statistics.view"
}
export declare enum AdminSection {
    DASHBOARD = "dashboard",
    USERS = "users",
    PROFILES = "profiles",
    GOVERNMENT_EMPLOYEES = "government_employees",
    VERIFICATIONS = "verifications",
    MATCHES = "matches",
    EDUCATION = "education",
    LOCATIONS = "locations",
    SERVICES = "services",
    PAVAN_PRERNADATA = "pavan_prernadata",
    SAMAJ_SUPER_STARS = "samaj_super_stars",
    SAMAJ_RATNA = "samaj_ratna",
    HOME_SCREEN = "home_screen",
    ADVERTISEMENTS = "advertisements",
    NOTIFICATIONS = "notifications",
    REPORTS = "reports",
    OTP_ANALYTICS = "otp_analytics",
    SETTINGS = "settings"
}
export declare enum AdminRole {
    SUPER_ADMIN = "SUPER_ADMIN",
    ADMIN = "ADMIN",
    VERIFICATION_ADMIN = "VERIFICATION_ADMIN",
    CONTENT_ADMIN = "CONTENT_ADMIN"
}
export declare const PermissionToSectionMap: Record<Permission, AdminSection[]>;
export declare const RolePermissions: Record<AdminRole, Permission[]>;
