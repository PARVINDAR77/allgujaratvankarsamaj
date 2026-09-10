import { validate } from "class-validator";
import { IsMinAge } from "./is-min-age.validator";

class TestAgeDto {
  @IsMinAge(18)
  dateOfBirth: string;

  constructor(dob: string) {
    this.dateOfBirth = dob;
  }
}

describe("IsMinAge Validator", () => {
  it("should pass for a valid adult birth date (e.g. 25 years old)", async () => {
    const dto = new TestAgeDto("1999-01-15");
    const errors = await validate(dto);
    expect(errors.length).toBe(0);
  });

  it("should fail for an underage birth date (e.g. 15 years old)", async () => {
    const today = new Date();
    const underageYear = today.getFullYear() - 15;
    const dto = new TestAgeDto(`${underageYear}-05-10`);
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].constraints).toHaveProperty("isMinAge");
  });

  it("should fail for a future date of birth", async () => {
    const dto = new TestAgeDto("2050-01-01");
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
  });

  it("should fail for an invalid date string", async () => {
    const dto = new TestAgeDto("invalid-date");
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
  });
});
