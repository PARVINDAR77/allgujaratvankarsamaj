import { Test, TestingModule } from '@nestjs/testing';
import { PavanPrernadataController } from './pavan-prernadata.controller';
import { PavanPrernadataService } from './pavan-prernadata.service';

describe('PavanPrernadataController', () => {
  let controller: PavanPrernadataController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PavanPrernadataController],
      providers: [
        {
          provide: PavanPrernadataService,
          useValue: {
            findAll: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<PavanPrernadataController>(PavanPrernadataController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
