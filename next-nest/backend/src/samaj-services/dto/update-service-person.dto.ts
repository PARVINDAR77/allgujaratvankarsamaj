import { PartialType } from '@nestjs/swagger';
import { CreateServicePersonDto } from './create-service-person.dto';

export class UpdateServicePersonDto extends PartialType(CreateServicePersonDto) {}
