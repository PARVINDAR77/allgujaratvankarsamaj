import { validateAndNormalizeAllowedOrigins } from "./cors.validator";

describe("CORS Allowed Origins Validator", () => {
  describe("Staging & Production Environments (Strict Enforcement)", () => {
    it("should accept a valid HTTPS origin", () => {
      const result = validateAndNormalizeAllowedOrigins(
        "https://staging.allgujaratvankarsamaj.com",
        "staging",
      );
      expect(result).toEqual(["https://staging.allgujaratvankarsamaj.com"]);
    });

    it("should strip trailing slash and normalize uppercase characters", () => {
      const result = validateAndNormalizeAllowedOrigins(
        "HTTPS://STAGING.ALLGUJARATVANKARSAMAJ.COM/",
        "staging",
      );
      expect(result).toEqual(["https://staging.allgujaratvankarsamaj.com"]);
    });

    it("should accept multiple comma-separated valid HTTPS origins", () => {
      const result = validateAndNormalizeAllowedOrigins(
        "https://allgujaratvankarsamaj.com, https://www.allgujaratvankarsamaj.com",
        "production",
      );
      expect(result).toEqual([
        "https://allgujaratvankarsamaj.com",
        "https://www.allgujaratvankarsamaj.com",
      ]);
    });

    it("should deduplicate duplicate origins", () => {
      const result = validateAndNormalizeAllowedOrigins(
        "https://staging.allgujaratvankarsamaj.com, https://staging.allgujaratvankarsamaj.com/",
        "staging",
      );
      expect(result).toEqual(["https://staging.allgujaratvankarsamaj.com"]);
    });

    it("should fallback to default production domains when ALLOWED_ORIGINS is empty or undefined in staging", () => {
      expect(validateAndNormalizeAllowedOrigins("", "staging")).toEqual([
        "https://allgujaratvankarsamaj.com",
        "https://www.allgujaratvankarsamaj.com",
      ]);
      expect(validateAndNormalizeAllowedOrigins(undefined, "staging")).toEqual([
        "https://allgujaratvankarsamaj.com",
        "https://www.allgujaratvankarsamaj.com",
      ]);
      expect(() => validateAndNormalizeAllowedOrigins("   ,   ", "staging")).toThrow(
        /No valid origins parsed/,
      );
    });

    it("should reject wildcard '*'", () => {
      expect(() => validateAndNormalizeAllowedOrigins("*", "staging")).toThrow(
        /Wildcard origin '\*' is strictly prohibited/,
      );
      expect(() =>
        validateAndNormalizeAllowedOrigins("https://*.example.com", "staging"),
      ).toThrow(/Wildcard origin/);
    });

    it("should reject insecure HTTP origins in staging and production", () => {
      expect(() =>
        validateAndNormalizeAllowedOrigins(
          "http://staging.allgujaratvankarsamaj.com",
          "staging",
        ),
      ).toThrow(/Insecure protocol 'http:' in origin/);
      expect(() =>
        validateAndNormalizeAllowedOrigins(
          "http://allgujaratvankarsamaj.com",
          "production",
        ),
      ).toThrow(/Insecure protocol 'http:' in origin/);
    });

    it("should reject origins with path components", () => {
      expect(() =>
        validateAndNormalizeAllowedOrigins(
          "https://staging.allgujaratvankarsamaj.com/api",
          "staging",
        ),
      ).toThrow(/contains prohibited URL path/);
    });

    it("should reject origins with embedded credentials", () => {
      expect(() =>
        validateAndNormalizeAllowedOrigins(
          "https://user:pass@staging.allgujaratvankarsamaj.com",
          "staging",
        ),
      ).toThrow(/contains prohibited embedded userinfo/);
    });

    it("should reject origins with query parameters", () => {
      expect(() =>
        validateAndNormalizeAllowedOrigins(
          "https://staging.allgujaratvankarsamaj.com?foo=bar",
          "staging",
        ),
      ).toThrow(/contains prohibited query parameters/);
    });

    it("should reject origins with URL fragments", () => {
      expect(() =>
        validateAndNormalizeAllowedOrigins(
          "https://staging.allgujaratvankarsamaj.com#section",
          "staging",
        ),
      ).toThrow(/contains prohibited URL fragment/);
    });

    it("should reject invalid URL strings", () => {
      expect(() =>
        validateAndNormalizeAllowedOrigins("not-a-valid-url", "staging"),
      ).toThrow(/Invalid URL format/);
    });
  });

  describe("Development Environment", () => {
    it("should allow HTTP localhost for local development", () => {
      const result = validateAndNormalizeAllowedOrigins(
        "http://localhost:3000, http://127.0.0.1:3000",
        "development",
      );
      expect(result).toEqual([
        "http://localhost:3000",
        "http://127.0.0.1:3000",
      ]);
    });

    it("should return empty array when ALLOWED_ORIGINS is empty in development", () => {
      const result = validateAndNormalizeAllowedOrigins("", "development");
      expect(result).toEqual([]);
    });
  });
});
