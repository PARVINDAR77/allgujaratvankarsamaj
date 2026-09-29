export enum Permission {
  // Members
  MEMBERS_READ = 'members.read',
  MEMBERS_UPDATE = 'members.update',
  MEMBERS_BLOCK = 'members.block',
  
  // Verification
  VERIFICATION_READ = 'verification.read',
  VERIFICATION_REVIEW = 'verification.review',
  
  // Government Employees
  GOVERNMENT_READ = 'government.read',
  GOVERNMENT_MANAGE = 'government.manage',
  GOVERNMENT_FEATURE = 'government.feature',
  
  // Content (Ads, Samaj, Success Stories)
  CONTENT_READ = 'content.read',
  CONTENT_MANAGE = 'content.manage',
  
  // Audit
  AUDIT_READ = 'audit.read',

  // Statistics
  STATISTICS_VIEW = 'statistics.view',
}

export enum AdminRole {
  SUPER_ADMIN = 'SUPER_ADMIN',
  ADMIN = 'ADMIN',
  VERIFICATION_ADMIN = 'VERIFICATION_ADMIN',
  CONTENT_ADMIN = 'CONTENT_ADMIN',
}

export const RolePermissions: Record<AdminRole, Permission[]> = {
  [AdminRole.SUPER_ADMIN]: Object.values(Permission), // Has all permissions
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
