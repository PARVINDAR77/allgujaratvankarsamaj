export enum Permission {
  // Members
  MEMBERS_READ = "members.read",
  MEMBERS_UPDATE = "members.update",
  MEMBERS_BLOCK = "members.block",
  MEMBERS_DELETE = "members.delete",

  // Verification
  VERIFICATION_READ = "verification.read",
  VERIFICATION_REVIEW = "verification.review",

  // Government Employees
  GOVERNMENT_READ = "government.read",
  GOVERNMENT_MANAGE = "government.manage",
  GOVERNMENT_FEATURE = "government.feature",

  // Content (Ads, Samaj, Success Stories)
  CONTENT_READ = "content.read",
  CONTENT_MANAGE = "content.manage",

  // Audit
  AUDIT_READ = "audit.read",

  // Statistics
  STATISTICS_VIEW = "statistics.view",
}

export enum AdminSection {
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
  SETTINGS = "settings",
}

export enum AdminRole {
  SUPER_ADMIN = "SUPER_ADMIN",
  ADMIN = "ADMIN",
  VERIFICATION_ADMIN = "VERIFICATION_ADMIN",
  CONTENT_ADMIN = "CONTENT_ADMIN",
}

export const PermissionToSectionMap: Record<Permission, AdminSection[]> = {
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

export const RolePermissions: Record<AdminRole, Permission[]> = {
  [AdminRole.SUPER_ADMIN]: Object.values(Permission), // Has all permissions
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
