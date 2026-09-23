import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSuccessStoryDto } from './dto/create-success-story.dto';
import { UpdateSuccessStoryDto } from './dto/update-success-story.dto';

@Injectable()
export class SuccessStoriesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createSuccessStoryDto: CreateSuccessStoryDto, adminId: string) {
    const story = await this.prisma.successStory.create({
      data: createSuccessStoryDto,
    });
    
    await this.prisma.adminAuditLog.create({
      data: {
        adminId,
        action: 'CREATE_SUCCESS_STORY',
        entityType: 'SuccessStory',
        entityId: story.id,
        newValue: JSON.stringify(story),
      }
    });
    return story;
  }

  async findAllPublic() {
    return this.prisma.successStory.findMany({
      where: {
        isPublished: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findAllAdmin() {
    return this.prisma.successStory.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const story = await this.prisma.successStory.findUnique({
      where: { id },
    });
    if (!story) {
      throw new NotFoundException('Success story not found');
    }
    return story;
  }

  async update(id: string, updateSuccessStoryDto: UpdateSuccessStoryDto, adminId: string) {
    const oldStory = await this.findOne(id);
    const updated = await this.prisma.successStory.update({
      where: { id },
      data: updateSuccessStoryDto,
    });
    
    await this.prisma.adminAuditLog.create({
      data: {
        adminId,
        action: 'UPDATE_SUCCESS_STORY',
        entityType: 'SuccessStory',
        entityId: id,
        oldValue: JSON.stringify(oldStory),
        newValue: JSON.stringify(updated),
      }
    });

    return updated;
  }

  async remove(id: string, adminId: string) {
    const oldStory = await this.findOne(id);
    const deleted = await this.prisma.successStory.delete({
      where: { id },
    });
    
    await this.prisma.adminAuditLog.create({
      data: {
        adminId,
        action: 'DELETE_SUCCESS_STORY',
        entityType: 'SuccessStory',
        entityId: id,
        oldValue: JSON.stringify(oldStory),
      }
    });
    
    return deleted;
  }
}
