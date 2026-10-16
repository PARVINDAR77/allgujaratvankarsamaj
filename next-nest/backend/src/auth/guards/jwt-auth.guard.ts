import {
  Injectable,
  ExecutionContext,
  UnauthorizedException,
} from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { AuthGuard } from "@nestjs/passport";
import { IS_PUBLIC_KEY } from "../decorators/public.decorator";

@Injectable()
export class JwtAuthGuard extends AuthGuard("jwt") {
  constructor(private reflector: Reflector) {
    super();
  }

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) {
      const req = context.switchToHttp().getRequest();
      if (req) {
        req.user = null;
      }
      try {
        const hasAuth =
          req?.headers?.authorization || req?.cookies?.["admin_token"];
        if (hasAuth) {
          const result = super.canActivate(context);
          if (result instanceof Promise) {
            await result;
          }
        }
      } catch (_) {
        if (req) {
          req.user = null;
        }
      }
      if (req && !req.user) {
        req.user = null;
      }
      return true;
    }
    return super.canActivate(context) as Promise<boolean>;
  }

  handleRequest(err: any, user: any, info: any, context?: ExecutionContext) {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context?.getHandler(),
      context?.getClass(),
    ]);
    if (isPublic) {
      if (err || !user) {
        return null;
      }
      return user;
    }
    if (err || !user) {
      throw err || new UnauthorizedException("Unauthorized access");
    }
    return user;
  }
}
