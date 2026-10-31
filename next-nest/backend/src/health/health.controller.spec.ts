import { Test, TestingModule } from "@nestjs/testing";
import { NotFoundException } from "@nestjs/common";
import { HealthController } from "./health.controller";
import { HealthService } from "./health.service";
import { Response } from "express";

describe("HealthController - Staging Test Route Gating", () => {
  let controller: HealthController;
  const originalEnv = process.env;

  beforeEach(async () => {
    process.env = { ...originalEnv };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [
        {
          provide: HealthService,
          useValue: {
            checkHealth: jest.fn().mockResolvedValue({ status: "ok", service: "backend" }),
            checkLiveness: jest.fn().mockReturnValue({ status: "ok", service: "backend", timestamp: "2026-10-29T11:30:00.000Z" }),
          },
        },
      ],
    }).compile();

    controller = module.get<HealthController>(HealthController);
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  const createMockResponse = (): Partial<Response> => ({
    cookie: jest.fn(),
  });

  it("should throw NotFoundException (404) in production environment", async () => {
    process.env.NODE_ENV = "production";
    process.env.ENABLE_STAGING_TEST_ROUTES = "true";

    const res = createMockResponse() as Response;
    await expect(controller.cookieTest(res)).rejects.toThrow(NotFoundException);
    expect(res.cookie).not.toHaveBeenCalled();
  });

  it("should throw NotFoundException (404) when ENABLE_STAGING_TEST_ROUTES is not 'true'", async () => {
    process.env.NODE_ENV = "staging";
    process.env.ENABLE_STAGING_TEST_ROUTES = "false";

    const res = createMockResponse() as Response;
    await expect(controller.cookieTest(res)).rejects.toThrow(NotFoundException);
    expect(res.cookie).not.toHaveBeenCalled();
  });

  it("should throw NotFoundException (404) when NODE_ENV is unset or development", async () => {
    process.env.NODE_ENV = "development";
    process.env.ENABLE_STAGING_TEST_ROUTES = "true";

    const res = createMockResponse() as Response;
    await expect(controller.cookieTest(res)).rejects.toThrow(NotFoundException);
    expect(res.cookie).not.toHaveBeenCalled();
  });

  it("should succeed and set both cookies only when NODE_ENV=staging AND ENABLE_STAGING_TEST_ROUTES=true", async () => {
    process.env.NODE_ENV = "staging";
    process.env.ENABLE_STAGING_TEST_ROUTES = "true";

    const res = createMockResponse() as Response;
    const result = await controller.cookieTest(res);

    expect(result).toEqual({ status: "ok", cookieTest: true });
    expect(res.cookie).toHaveBeenCalledTimes(2);
    expect(res.cookie).toHaveBeenCalledWith(
      "stg_test_a",
      "val_alpha",
      expect.objectContaining({ httpOnly: true, secure: true, sameSite: "lax", path: "/" }),
    );
    expect(res.cookie).toHaveBeenCalledWith(
      "stg_test_b",
      "val_beta",
      expect.objectContaining({ httpOnly: true, secure: true, sameSite: "lax", path: "/" }),
    );
  });

  it("should return liveness status successfully without DB access", () => {
    const result = controller.getLiveness();
    expect(result).toEqual(
      expect.objectContaining({
        status: "ok",
        service: "backend",
      }),
    );
  });
});
