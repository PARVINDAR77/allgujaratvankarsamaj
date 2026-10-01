import { Test, TestingModule } from '@nestjs/testing';
import { SamajSuperStarsController } from './samaj-super-stars.controller';

describe('SamajSuperStarsController', () => {
  let controller: SamajSuperStarsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [SamajSuperStarsController],
    }).compile();

    controller = module.get<SamajSuperStarsController>(SamajSuperStarsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
