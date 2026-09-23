import { Role } from '@prisma/client';

export enum Capability {
  // Profiles
  PROFILES_READ = 'profiles.read',
  PROFILES_READ_PRIVATE = 'profiles.read_private',
  PROFILES_CREATE = 'profiles.create',
  PROFILES_UPDATE_OWN = 'profiles.update_own',
  PROFILES_UPDATE_ANY = 'profiles.update_any',
  PROFILES_DELETE_OWN = 'profiles.delete_own',
  PROFILES_DELETE_ANY = 'profiles.delete_any',

  // Verification
  VERIFICATION_READ = 'verification.read',
  VERIFICATION_APPROVE = 'verification.approve',
  VERIFICATION_REJECT = 'verification.reject',

  // Users
  USERS_READ = 'users.read',
  USERS_UPDATE = 'users.update',
  USERS_SUSPEND = 'users.suspend',

  // Samaj Services
  SAMAJ_SERVICES_READ = 'samaj-services.read',
  SAMAJ_SERVICES_MANAGE = 'samaj-services.manage',

  // Advertisements
  ADVERTISEMENTS_READ = 'advertisements.read',
  ADVERTISEMENTS_MANAGE = 'advertisements.manage',

  // Success Stories
  SUCCESS_STORIES_READ = 'success-stories.read',
  SUCCESS_STORIES_MANAGE = 'success-stories.manage',

  // Government Employees
  GOVERNMENT_EMPLOYEES_READ = 'government-employees.read',
  GOVERNMENT_EMPLOYEES_MANAGE = 'government-employees.manage',

  // Reports
  REPORTS_CREATE = 'reports.create',
  REPORTS_READ = 'reports.read',
  REPORTS_RESOLVE = 'reports.resolve',

  // Shortlists
  SHORTLISTS_CREATE = 'shortlists.create',
  SHORTLISTS_DELETE = 'shortlists.delete',

  // Interests
  INTERESTS_CREATE = 'interests.create',
  INTERESTS_READ = 'interests.read',
  INTERESTS_MANAGE = 'interests.manage',

  // Locations
  LOCATIONS_READ = 'locations.read',
  LOCATIONS_MANAGE = 'locations.manage',

  // Statistics
  STATISTICS_READ = 'statistics.read',

  // Audit
  ADMIN_AUDIT_READ = 'admin.audit.read',
}

export const RoleCapabilities: Record<Role, Capability[]> = {
  [Role.USER]: [
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
  [Role.VERIFICATION_ADMIN]: [
    Capability.PROFILES_READ,
    Capability.PROFILES_READ_PRIVATE,
    Capability.VERIFICATION_READ,
    Capability.VERIFICATION_APPROVE,
    Capability.VERIFICATION_REJECT,
    Capability.GOVERNMENT_EMPLOYEES_READ,
    Capability.LOCATIONS_READ,
  ],
  [Role.CONTENT_ADMIN]: [
    Capability.PROFILES_READ,
    Capability.SAMAJ_SERVICES_READ,
    Capability.SAMAJ_SERVICES_MANAGE,
    Capability.ADVERTISEMENTS_READ,
    Capability.ADVERTISEMENTS_MANAGE,
    Capability.SUCCESS_STORIES_READ,
    Capability.SUCCESS_STORIES_MANAGE,
    Capability.LOCATIONS_READ,
  ],
  [Role.ADMIN]: [
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
  [Role.SUPER_ADMIN]: Object.values(Capability),
};
