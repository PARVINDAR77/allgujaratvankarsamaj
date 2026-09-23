import { Test, TestingModule } from '@nestjs/testing';
import { SuccessStoriesController } from './success-stories.controller';

describe('SuccessStoriesController', () => {
  let controller: SuccessStoriesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [SuccessStoriesController],
    }).compile();

    controller = module.get<SuccessStoriesController>(SuccessStoriesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
