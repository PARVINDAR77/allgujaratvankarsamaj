/**
 * Static Media Access Validator for All Gujarat Vankar Samaj Matrimony
 *
 * Security Invariants:
 * 1. Strictly enforces an allowlist of public image extensions (.jpg, .jpeg, .png, .webp, .gif).
 * 2. Rejects document formats (.pdf, .doc, .docx, .txt, .zip, etc.) to prevent unauthenticated retrieval of ID proofs.
 * 3. Handles recursive URL decoding to defeat single, double, and multi-level percent-encoding bypasses.
 * 4. Normalizes path separators and rejects directory traversal sequences (..) and NUL bytes.
 * 5. Prohibits dotfiles and hidden directories (/. or starting with .).
 */

export interface StaticMediaValidationResult {
  allowed: boolean;
  reason?: string;
  sanitizedPath?: string;
}

export const MAX_STATIC_MEDIA_PATH_LENGTH = 512;

export function isAllowedStaticMediaPath(rawPath: string): StaticMediaValidationResult {
  if (!rawPath || typeof rawPath !== "string") {
    return { allowed: false, reason: "Empty or invalid path" };
  }

  // 1. Raw original path validation BEFORE any decoding or normalization (Finding 1 & Finding A Remediation)
  // Input length limit defense against ReDoS or memory abuse
  if (rawPath.length > MAX_STATIC_MEDIA_PATH_LENGTH) {
    return { allowed: false, reason: `Path exceeds maximum allowed length of ${MAX_STATIC_MEDIA_PATH_LENGTH} characters` };
  }

  // Strip query string if present
  const rawPathOnly = rawPath.split("?")[0];

  // 1.1 Reject control characters and NUL bytes in raw input
  if (/[\x00-\x1f\x7f]/.test(rawPathOnly)) {
    return { allowed: false, reason: "Prohibited control characters in path" };
  }

  // 1.1b Reject URI schemes (e.g. http://, file://, javascript:) and network paths (//)
  if (/^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(rawPathOnly) || rawPathOnly.startsWith("//")) {
    return { allowed: false, reason: "URI schemes and network protocol paths are strictly forbidden" };
  }

  // 1.2 Reject malformed percent escapes in raw input
  if (/%(?![0-9a-fA-F]{2})/.test(rawPathOnly)) {
    return { allowed: false, reason: "Malformed URI percent-encoding" };
  }

  // 1.3 Reject double encoding (%25), encoded separators (%2f, %5c), and encoded dots (%2e)
  if (/%25/i.test(rawPathOnly)) {
    return { allowed: false, reason: "Double percent-encoding is strictly forbidden" };
  }
  if (/%2f|%5c/i.test(rawPathOnly)) {
    return { allowed: false, reason: "Encoded path separators are strictly forbidden" };
  }
  if (/%2e/i.test(rawPathOnly)) {
    return { allowed: false, reason: "Encoded dots are strictly forbidden" };
  }

  // 1.4 Reject backslashes and drive colons
  if (/[\\:]/.test(rawPathOnly)) {
    return { allowed: false, reason: "Backslashes and colons are forbidden in path" };
  }

  // 1.5 Reject consecutive slashes
  if (/\/{2,}/.test(rawPathOnly)) {
    return { allowed: false, reason: "Consecutive slashes in path are forbidden" };
  }

  // 1.6 Reject literal '.' and '..' segments in raw input BEFORE normalization
  // Splitting on '/' ensures paths like 'a/../b.jpg' or 'a/./b.jpg' are rejected immediately
  const rawSegments = rawPathOnly.split("/").filter(Boolean);
  for (const rawSeg of rawSegments) {
    if (rawSeg === "." || rawSeg === "..") {
      return { allowed: false, reason: "Directory traversal or dot segment detected in raw path" };
    }
    if (rawSeg.startsWith(".") || rawSeg.endsWith(".")) {
      return { allowed: false, reason: "Dotfiles and trailing dot segments are forbidden" };
    }
  }

  // 2. Recursive percent-decoding (defends against multi-level percent-encoding bypasses)
  const MAX_DECODE_ITERATIONS = 5;
  let decoded = rawPathOnly;
  try {
    let iterations = 0;
    while (decoded.includes("%") && iterations < MAX_DECODE_ITERATIONS) {
      const prev = decoded;
      decoded = decodeURIComponent(decoded);
      iterations++;
      if (prev === decoded) break;
    }
  } catch (_) {
    return { allowed: false, reason: "Malformed URI percent-encoding" };
  }

  // Finding B Remediation: Reject inputs that remain percent-encoded after reaching the decoding limit.
  // This prevents attackers from hiding traversal sequences or prohibited extensions under deep encoding.
  if (decoded.includes("%")) {
    return {
      allowed: false,
      reason: "Exceeded maximum URL percent-decoding depth; input remains encoded",
    };
  }

  // Check for control characters that might have emerged after decoding
  if (/[\x00-\x1f\x7f]/.test(decoded)) {
    return { allowed: false, reason: "Prohibited control characters in decoded path" };
  }

  // 3. Normalize path separators to forward slash
  const normalized = decoded.replace(/\\/g, "/");

  // 4. Reject directory traversal sequences and hidden files
  const segments = normalized.split("/").filter(Boolean);
  if (segments.length === 0) {
    return { allowed: false, reason: "Missing file path; empty or root path not permitted" };
  }

  for (const seg of segments) {
    if (seg === ".." || seg === "." || seg.startsWith(".") || seg.endsWith(".") || seg.endsWith(" ")) {
      return { allowed: false, reason: "Prohibited path traversal, hidden dotfile, or trailing character" };
    }
    // Reject any segment containing null, slash, whitespace, or invalid path characters
    if (/[\x00-\x1f\x7f\\:\s]/.test(seg)) {
      return { allowed: false, reason: "Invalid characters in path segment" };
    }
  }

  // 4.1 Reject restricted and private directory segments (Defense-in-depth against private data leakage)
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

  // 5. Strict allowlist for public media extensions (case-insensitive)
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

  // Canonical sanitized path leading with forward slash
  const sanitized = "/" + segments.join("/");
  return { allowed: true, sanitizedPath: sanitized };
}

