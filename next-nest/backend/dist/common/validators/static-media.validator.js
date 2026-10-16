"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MAX_STATIC_MEDIA_PATH_LENGTH = void 0;
exports.isAllowedStaticMediaPath = isAllowedStaticMediaPath;
exports.MAX_STATIC_MEDIA_PATH_LENGTH = 512;
function isAllowedStaticMediaPath(rawPath) {
    if (!rawPath || typeof rawPath !== "string") {
        return { allowed: false, reason: "Empty or invalid path" };
    }
    if (rawPath.length > exports.MAX_STATIC_MEDIA_PATH_LENGTH) {
        return { allowed: false, reason: `Path exceeds maximum allowed length of ${exports.MAX_STATIC_MEDIA_PATH_LENGTH} characters` };
    }
    const rawPathOnly = rawPath.split("?")[0];
    if (/[\x00-\x1f\x7f]/.test(rawPathOnly)) {
        return { allowed: false, reason: "Prohibited control characters in path" };
    }
    if (/^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(rawPathOnly) || rawPathOnly.startsWith("//")) {
        return { allowed: false, reason: "URI schemes and network protocol paths are strictly forbidden" };
    }
    if (/%(?![0-9a-fA-F]{2})/.test(rawPathOnly)) {
        return { allowed: false, reason: "Malformed URI percent-encoding" };
    }
    if (/%25/i.test(rawPathOnly)) {
        return { allowed: false, reason: "Double percent-encoding is strictly forbidden" };
    }
    if (/%2f|%5c/i.test(rawPathOnly)) {
        return { allowed: false, reason: "Encoded path separators are strictly forbidden" };
    }
    if (/%2e/i.test(rawPathOnly)) {
        return { allowed: false, reason: "Encoded dots are strictly forbidden" };
    }
    if (/[\\:]/.test(rawPathOnly)) {
        return { allowed: false, reason: "Backslashes and colons are forbidden in path" };
    }
    if (/\/{2,}/.test(rawPathOnly)) {
        return { allowed: false, reason: "Consecutive slashes in path are forbidden" };
    }
    const rawSegments = rawPathOnly.split("/").filter(Boolean);
    for (const rawSeg of rawSegments) {
        if (rawSeg === "." || rawSeg === "..") {
            return { allowed: false, reason: "Directory traversal or dot segment detected in raw path" };
        }
        if (rawSeg.startsWith(".") || rawSeg.endsWith(".")) {
            return { allowed: false, reason: "Dotfiles and trailing dot segments are forbidden" };
        }
    }
    const MAX_DECODE_ITERATIONS = 5;
    let decoded = rawPathOnly;
    try {
        let iterations = 0;
        while (decoded.includes("%") && iterations < MAX_DECODE_ITERATIONS) {
            const prev = decoded;
            decoded = decodeURIComponent(decoded);
            iterations++;
            if (prev === decoded)
                break;
        }
    }
    catch (_) {
        return { allowed: false, reason: "Malformed URI percent-encoding" };
    }
    if (decoded.includes("%")) {
        return {
            allowed: false,
            reason: "Exceeded maximum URL percent-decoding depth; input remains encoded",
        };
    }
    if (/[\x00-\x1f\x7f]/.test(decoded)) {
        return { allowed: false, reason: "Prohibited control characters in decoded path" };
    }
    const normalized = decoded.replace(/\\/g, "/");
    const segments = normalized.split("/").filter(Boolean);
    if (segments.length === 0) {
        return { allowed: false, reason: "Missing file path; empty or root path not permitted" };
    }
    for (const seg of segments) {
        if (seg === ".." || seg === "." || seg.startsWith(".") || seg.endsWith(".") || seg.endsWith(" ")) {
            return { allowed: false, reason: "Prohibited path traversal, hidden dotfile, or trailing character" };
        }
        if (/[\x00-\x1f\x7f\\:\s]/.test(seg)) {
            return { allowed: false, reason: "Invalid characters in path segment" };
        }
    }
    const FORBIDDEN_DIRECTORY_SEGMENTS = new Set([
        "private_uploads",
        "documents",
        "id_proofs",
        "secure",
        "evidence",
        "node_modules",
        ".git",
        "prisma",
        "dist",
    ]);
    for (const seg of segments) {
        if (FORBIDDEN_DIRECTORY_SEGMENTS.has(seg.toLowerCase())) {
            return { allowed: false, reason: `Access to restricted directory '${seg}' is strictly forbidden via static media route` };
        }
    }
    const ALLOWED_IMAGE_EXTENSIONS = new Set([
        ".jpg",
        ".jpeg",
        ".png",
        ".webp",
        ".gif",
    ]);
    const extMatch = normalized.match(/\.([a-zA-Z0-9]+)$/);
    if (!extMatch) {
        return { allowed: false, reason: "Missing file extension; directories not permitted" };
    }
    const ext = `.${extMatch[1].toLowerCase()}`;
    if (!ALLOWED_IMAGE_EXTENSIONS.has(ext)) {
        return {
            allowed: false,
            reason: `Disallowed extension '${ext}'. Direct static access is restricted to public images only. Private documents require authenticated endpoints.`,
        };
    }
    const sanitized = "/" + segments.join("/");
    return { allowed: true, sanitizedPath: sanitized };
}
//# sourceMappingURL=static-media.validator.js.map