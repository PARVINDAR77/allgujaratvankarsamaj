import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Capability, RoleCapabilities } from '../constants/capabilities';
import { CAPABILITIES_KEY } from '../decorators/capabilities.decorator';
import { Role } from '@prisma/client';

@Injectable()
export class CapabilitiesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredCapabilities = this.reflector.getAllAndOverride<Capability[]>(CAPABILITIES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (!requiredCapabilities || requiredCapabilities.length === 0) {
      return true; // No capabilities required
    }

    const { user } = context.switchToHttp().getRequest();

    if (!user || !user.role) {
      return false; // Authentication failed or user has no role
    }

    // Get user role from Prisma Role enum
    const userRole = user.role as Role;
    const userCapabilities = RoleCapabilities[userRole];

    if (!userCapabilities) {
      return false; // Role not mapped
    }

    // Check if user has ALL required capabilities for the route (or at least one, depending on logic. Usually 'every' for strict requirements)
    // Actually, maybe we just need 'every', or maybe 'some'. The old permissions guard used 'every'.
    const hasCapabilities = requiredCapabilities.every((capability) => userCapabilities.includes(capability));

    if (!hasCapabilities) {
      throw new ForbiddenException('Insufficient capabilities');
    }

    return true;
  }
}
