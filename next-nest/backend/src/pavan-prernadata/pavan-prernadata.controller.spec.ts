import { Test, TestingModule } from '@nestjs/testing';
import { PavanPrernadataController } from './pavan-prernadata.controller';

describe('PavanPrernadataController', () => {
  let controller: PavanPrernadataController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PavanPrernadataController],
    }).compile();

    controller = module.get<PavanPrernadataController>(PavanPrernadataController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
