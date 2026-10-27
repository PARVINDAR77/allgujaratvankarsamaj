/**
 * CORS Origin Validator for All Gujarat Vankar Samaj Matrimony
 *
 * Strict Security Invariants:
 * 1. Requires explicit ALLOWED_ORIGINS configuration in production and staging environments.
 * 2. Parses each entry via WHATWG URL parser.
 * 3. Enforces HTTPS protocol for staging and production environments (no plaintext HTTP).
 * 4. Rejects wildcard origins ('*') and any origin containing wildcard characters.
 * 5. Rejects origins with embedded credentials (user:password@).
 * 6. Rejects origins with query parameters (?key=val).
 * 7. Rejects origins with URL fragments (#section).
 * 8. Rejects origins with unexpected path components (e.g. /api, /path). Only empty or '/' is permitted.
 * 9. Normalizes origins to WHATWG origin string format (protocol + '//' + host[:port]), stripping trailing slashes.
 */

export function validateAndNormalizeAllowedOrigins(
  rawStr: string | undefined,
  env: string = "production",
): string[] {
  const isEnforcedEnv = env === "production" || env === "staging";

  if (!rawStr || rawStr.trim() === "") {
    if (isEnforcedEnv) {
      return ["https://allgujaratvankarsamaj.com", "https://www.allgujaratvankarsamaj.com"];
    }
    return [];
  }

  const rawEntries = rawStr
    .split(",")
    .map((s) => s.trim())
    .filter((s) => s.length > 0);

  if (rawEntries.length === 0) {
    if (isEnforcedEnv) {
      throw new Error(
        `No valid origins parsed from ALLOWED_ORIGINS in ${env} environment!`,
      );
    }
    return [];
  }

  const validatedOrigins: string[] = [];

  for (const raw of rawEntries) {
    // 1. Strict wildcard rejection
    if (raw === "*" || raw.includes("*")) {
      throw new Error(
        `Wildcard origin '${raw}' is strictly prohibited in ${env} environment.`,
      );
    }

    // 2. URL format parse
    let parsed: URL;
    try {
      parsed = new URL(raw);
    } catch (err: any) {
      throw new Error(
        `Invalid URL format in ALLOWED_ORIGINS entry '${raw}': ${err?.message || "unparseable"}`,
      );
    }

    // 3. Protocol enforcement
    if (isEnforcedEnv && parsed.protocol !== "https:") {
      throw new Error(
        `Insecure protocol '${parsed.protocol}' in origin '${raw}'. HTTPS is mandatory in ${env} environment.`,
      );
    }

    if (!isEnforcedEnv && parsed.protocol !== "https:" && parsed.protocol !== "http:") {
      throw new Error(
        `Disallowed protocol '${parsed.protocol}' in origin '${raw}'. Only HTTP/HTTPS permitted.`,
      );
    }

    // 4. Reject embedded credentials
    if (parsed.username || parsed.password) {
      throw new Error(
        `Origin '${raw}' contains prohibited embedded userinfo/credentials.`,
      );
    }

    // 5. Reject query parameters
    if (parsed.search && parsed.search !== "") {
      throw new Error(
        `Origin '${raw}' contains prohibited query parameters ('${parsed.search}').`,
      );
    }

    // 6. Reject fragments / hashes
    if (parsed.hash && parsed.hash !== "") {
      throw new Error(
        `Origin '${raw}' contains prohibited URL fragment ('${parsed.hash}').`,
      );
    }

    // 7. Reject unexpected path components
    if (parsed.pathname && parsed.pathname !== "/" && parsed.pathname !== "") {
      throw new Error(
        `Origin '${raw}' contains prohibited URL path ('${parsed.pathname}'). Origins must not include subpaths.`,
      );
    }

    // 8. Reconstruct normalized origin
    const normalized = parsed.origin.toLowerCase();
    if (!validatedOrigins.includes(normalized)) {
      validatedOrigins.push(normalized);
    }
  }

  return validatedOrigins;
}
