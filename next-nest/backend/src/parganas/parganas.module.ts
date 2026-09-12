import { Module } from "@nestjs/common";
import { ParganasService } from "./parganas.service";
import { ParganasController } from "./parganas.controller";
import { PrismaModule } from "../prisma/prisma.module";

@Module({
  imports: [PrismaModule],
  controllers: [ParganasController],
  providers: [ParganasService],
  exports: [ParganasService],
})
export class ParganasModule {}
