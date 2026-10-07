export declare enum Permission {
    MEMBERS_READ = "members.read",
    MEMBERS_UPDATE = "members.update",
    MEMBERS_BLOCK = "members.block",
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
export declare enum AdminRole {
    SUPER_ADMIN = "SUPER_ADMIN",
    ADMIN = "ADMIN",
    VERIFICATION_ADMIN = "VERIFICATION_ADMIN",
    CONTENT_ADMIN = "CONTENT_ADMIN"
}
export declare const RolePermissions: Record<AdminRole, Permission[]>;
