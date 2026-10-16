"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateAndNormalizeAllowedOrigins = validateAndNormalizeAllowedOrigins;
function validateAndNormalizeAllowedOrigins(rawStr, env = "production") {
    const isEnforcedEnv = env === "production" || env === "staging";
    if (!rawStr || rawStr.trim() === "") {
        if (isEnforcedEnv) {
            throw new Error(`ALLOWED_ORIGINS must be explicitly configured in ${env} environment!`);
        }
        return [];
    }
    const rawEntries = rawStr
        .split(",")
        .map((s) => s.trim())
        .filter((s) => s.length > 0);
    if (rawEntries.length === 0) {
        if (isEnforcedEnv) {
            throw new Error(`No valid origins parsed from ALLOWED_ORIGINS in ${env} environment!`);
        }
        return [];
    }
    const validatedOrigins = [];
    for (const raw of rawEntries) {
        if (raw === "*" || raw.includes("*")) {
            throw new Error(`Wildcard origin '${raw}' is strictly prohibited in ${env} environment.`);
        }
        let parsed;
        try {
            parsed = new URL(raw);
        }
        catch (err) {
            throw new Error(`Invalid URL format in ALLOWED_ORIGINS entry '${raw}': ${err?.message || "unparseable"}`);
        }
        if (isEnforcedEnv && parsed.protocol !== "https:") {
            throw new Error(`Insecure protocol '${parsed.protocol}' in origin '${raw}'. HTTPS is mandatory in ${env} environment.`);
        }
        if (!isEnforcedEnv && parsed.protocol !== "https:" && parsed.protocol !== "http:") {
            throw new Error(`Disallowed protocol '${parsed.protocol}' in origin '${raw}'. Only HTTP/HTTPS permitted.`);
        }
        if (parsed.username || parsed.password) {
            throw new Error(`Origin '${raw}' contains prohibited embedded userinfo/credentials.`);
        }
        if (parsed.search && parsed.search !== "") {
            throw new Error(`Origin '${raw}' contains prohibited query parameters ('${parsed.search}').`);
        }
        if (parsed.hash && parsed.hash !== "") {
            throw new Error(`Origin '${raw}' contains prohibited URL fragment ('${parsed.hash}').`);
        }
        if (parsed.pathname && parsed.pathname !== "/" && parsed.pathname !== "") {
            throw new Error(`Origin '${raw}' contains prohibited URL path ('${parsed.pathname}'). Origins must not include subpaths.`);
        }
        const normalized = parsed.origin.toLowerCase();
        if (!validatedOrigins.includes(normalized)) {
            validatedOrigins.push(normalized);
        }
    }
    return validatedOrigins;
}
//# sourceMappingURL=cors.validator.js.map