import { Injectable, CanActivate, ExecutionContext } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { PERMISSIONS_KEY } from "../decorators/permissions.decorator";
import {
  Permission,
  RolePermissions,
  AdminRole,
  PermissionToSectionMap,
  AdminSection,
} from "../constants/permissions";

@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredPermissions = this.reflector.getAllAndOverride<Permission[]>(
      PERMISSIONS_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!requiredPermissions || requiredPermissions.length === 0) {
      return true;
    }

    const { user } = context.switchToHttp().getRequest();

    if (!user || !user.role) {
      return false;
    }

    // Super Admin has unrestricted access to everything
    if (user.role === "SUPER_ADMIN") {
      return true;
    }

    // Extract user permissions
    let userPermissions: string[] = [];
    if (Array.isArray(user.permissions)) {
      userPermissions = user.permissions;
    } else if (typeof user.permissions === "string") {
      try {
        userPermissions = JSON.parse(user.permissions);
      } catch (_) {}
    }

    // Also include legacy role permissions if configured
    const userRole = user.role as AdminRole;
    const legacyPerms = RolePermissions[userRole] || [];

    // The user must satisfy the required permissions
    return requiredPermissions.every((perm) => {
      // Direct permission match
      if (userPermissions.includes(perm) || legacyPerms.includes(perm)) {
        return true;
      }
      // Section-level match
      const mappedSections = PermissionToSectionMap[perm] || [];
      return mappedSections.some((sec) => userPermissions.includes(sec));
    });
  }
}
