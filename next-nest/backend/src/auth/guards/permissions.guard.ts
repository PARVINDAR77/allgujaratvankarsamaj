import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PERMISSIONS_KEY } from '../decorators/permissions.decorator';
import { Permission, RolePermissions, AdminRole } from '../constants/permissions';

@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredPermissions = this.reflector.getAllAndOverride<Permission[]>(PERMISSIONS_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    
    if (!requiredPermissions || requiredPermissions.length === 0) {
      return true;
    }
    
    const { user } = context.switchToHttp().getRequest();
    
    if (!user || !user.role) {
      return false;
    }
    
    // Convert DB role string to AdminRole enum (if it's a valid admin role)
    const userRole = user.role as AdminRole;
    
    // Check if the user's role is defined in our RolePermissions map
    const userPermissions = RolePermissions[userRole] || [];
    
    // The user must have ALL required permissions for the endpoint
    return requiredPermissions.every((permission) => userPermissions.includes(permission));
  }
}
