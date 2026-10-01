import { Test, TestingModule } from '@nestjs/testing';
import { PavanPrernadataService } from './pavan-prernadata.service';

describe('PavanPrernadataService', () => {
  let service: PavanPrernadataService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PavanPrernadataService],
    }).compile();

    service = module.get<PavanPrernadataService>(PavanPrernadataService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
