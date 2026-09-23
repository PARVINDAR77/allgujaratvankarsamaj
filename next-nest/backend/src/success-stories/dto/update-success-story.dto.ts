import { PartialType } from '@nestjs/swagger';
import { CreateSuccessStoryDto } from './create-success-story.dto';

export class UpdateSuccessStoryDto extends PartialType(CreateSuccessStoryDto) {}
