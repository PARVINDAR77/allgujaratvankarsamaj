import { Module } from "@nestjs/common";
import { SamajRatnaController } from "./samaj-ratna.controller";
import { SamajRatnaService } from "./samaj-ratna.service";
import { PrismaModule } from "../prisma/prisma.module";

@Module({
  imports: [PrismaModule],
  controllers: [SamajRatnaController],
  providers: [SamajRatnaService],
})
export class SamajRatnaModule {}
