import { Module } from "@nestjs/common";
import { UsersService } from "./users.service";
import { AdminUsersController } from "./admin-users.controller";
import { PrismaModule } from "../prisma/prisma.module";

@Module({
  imports: [PrismaModule],
  controllers: [AdminUsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
