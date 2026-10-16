import { Test, TestingModule } from '@nestjs/testing';
import { SamajSuperStarsController } from './samaj-super-stars.controller';
import { SamajSuperStarsService } from './samaj-super-stars.service';

describe('SamajSuperStarsController', () => {
  let controller: SamajSuperStarsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [SamajSuperStarsController],
      providers: [
        {
          provide: SamajSuperStarsService,
          useValue: {
            findAll: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<SamajSuperStarsController>(SamajSuperStarsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
