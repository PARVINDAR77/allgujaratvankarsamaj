import { Test, TestingModule } from '@nestjs/testing';
import { SuccessStoriesService } from './success-stories.service';

describe('SuccessStoriesService', () => {
  let service: SuccessStoriesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [SuccessStoriesService],
    }).compile();

    service = module.get<SuccessStoriesService>(SuccessStoriesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
