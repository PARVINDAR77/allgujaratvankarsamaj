import { Test, TestingModule } from '@nestjs/testing';
import { SamajSuperStarsService } from './samaj-super-stars.service';

describe('SamajSuperStarsService', () => {
  let service: SamajSuperStarsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [SamajSuperStarsService],
    }).compile();

    service = module.get<SamajSuperStarsService>(SamajSuperStarsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
