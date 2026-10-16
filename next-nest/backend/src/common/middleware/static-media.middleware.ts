import { Request, Response, NextFunction } from "express";
import * as fs from "fs";
import * as fsPromises from "fs/promises";
import * as path from "path";
import { isAllowedStaticMediaPath } from "../validators/static-media.validator";

/**
 * Public static media handler: serves public profile photos and media.
 *
 * Security Invariants:
 * 1. Strictly enforces an allowlist of public image extensions (.jpg, .jpeg, .png, .webp, .gif).
 * 2. Rejects document formats (.pdf, .doc, .docx, etc.) to prevent unauthenticated retrieval of ID proofs.
 * 3. Rejects ambiguous encodings, malformed percent escapes, encoded separators (%2f, %5c), and encoded dots (%2e).
 * 4. Verifies exact equivalence between raw URL and routed path before and after mount point stripping.
 * 5. Verifies every intermediate directory component from root to leaf contains zero symlinks and maintains strict containment.
 * 6. Opens file descriptor with O_NOFOLLOW (failing closed on POSIX if unsupported) to prevent kernel symlink following.
 * 7. Compares open file handle (dev, ino) with canonical path (dev, ino) to guarantee descriptor-path consistency and defeat TOCTOU races.
 * 8. Enforces complete streaming lifecycle management (res.on('close'), stream.on('error'), stream.on('end')) to guarantee zero handle leaks.
 */
export const servePublicStaticMedia = async (req: Request, res: Response, next?: NextFunction) => {
  if (req.method !== "GET" && req.method !== "HEAD" && req.method !== "OPTIONS") {
    return res.status(405).json({ statusCode: 405, message: "Method Not Allowed" });
  }

  if (req.method === "OPTIONS") {
    res.set({
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, HEAD, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
    });
    return res.status(204).end();
  }

  // Step 1: Pre-decode & Raw Request Validation (Finding B Remediation)
  const rawOrigUrl = req.originalUrl || req.url || "";
  const [rawOrigUrlPath] = rawOrigUrl.split("?");

  // Reject malformed percent escapes
  if (/%(?![0-9a-fA-F]{2})/.test(rawOrigUrlPath)) {
    return res.status(403).json({ statusCode: 403, error: "Forbidden", message: "Malformed percent-encoding in request" });
  }
  // Reject double encoding
  if (/%25/i.test(rawOrigUrlPath)) {
    return res.status(403).json({ statusCode: 403, error: "Forbidden", message: "Double percent-encoding is forbidden" });
  }
  // Reject encoded path separators
  if (/%2f|%5c/i.test(rawOrigUrlPath)) {
    return res.status(403).json({ statusCode: 403, error: "Forbidden", message: "Encoded path separators are forbidden" });
  }
  // Reject encoded dots (%2e)
  if (/%2e/i.test(rawOrigUrlPath)) {
    return res.status(403).json({ statusCode: 403, error: "Forbidden", message: "Encoded dots are forbidden" });
  }
  if (/[\\:]/.test(rawOrigUrlPath)) {
    return res.status(403).json({ statusCode: 403, error: "Forbidden", message: "Backslashes and drive colons are forbidden" });
  }
  if (/\/{2,}/.test(rawOrigUrlPath)) {
    return res.status(403).json({ statusCode: 403, error: "Forbidden", message: "Consecutive slashes are forbidden" });
  }
  if (/[\x00-\x1f\x7f]/.test(rawOrigUrlPath)) {
    return res.status(403).json({ statusCode: 403, error: "Forbidden", message: "Control characters are forbidden" });
  }

  // Strict equivalence between raw URL and routed path
  const rawReqPath = (req.path || "").split("?")[0];
  const rawUrlPath = (req.url || "").split("?")[0];
  if (rawReqPath !== rawUrlPath || (req.baseUrl && rawOrigUrlPath !== `${req.baseUrl}${rawReqPath}`)) {
    return res.status(403).json({
      statusCode: 403,
      error: "Forbidden",
      message: "Ambiguous request URL and routed path discrepancy detected.",
    });
  }

  const check = isAllowedStaticMediaPath(rawReqPath);
  if (!check.allowed || !check.sanitizedPath) {
    return res.status(403).json({
      statusCode: 403,
      error: "Forbidden",
      message: check.reason || "Direct static access is forbidden.",
    });
  }

  const uploadsRoot = path.resolve(process.cwd(), "uploads");
  const relativeClean = check.sanitizedPath.replace(/^\/+/, "");
  const targetFilePath = path.resolve(uploadsRoot, relativeClean);

  // Containment assertion: target path must be strictly within uploads root
  if (!targetFilePath.startsWith(uploadsRoot + path.sep)) {
    return res.status(403).json({
      statusCode: 403,
      error: "Forbidden",
      message: "Path traversal outside public media directory is forbidden.",
    });
  }

  let fileHandle: fsPromises.FileHandle | null = null;
  try {
    const canonicalUploadsRoot = await fsPromises.realpath(uploadsRoot);

    // Step 2: Intermediate Directory Containment Verification (Finding C Remediation)
    const segments = relativeClean.split("/").filter(Boolean);
    if (segments.length === 0) {
      return res.status(403).json({ statusCode: 403, error: "Forbidden", message: "Missing file path." });
    }

    let currentStep = uploadsRoot;
    for (let i = 0; i < segments.length - 1; i++) {
      currentStep = path.join(currentStep, segments[i]);
      const stepLstat = await fsPromises.lstat(currentStep);
      if (stepLstat.isSymbolicLink() || !stepLstat.isDirectory()) {
        return res.status(403).json({
          statusCode: 403,
          error: "Forbidden",
          message: "Intermediate path component is not a regular directory or is a symbolic link.",
        });
      }
      const stepReal = await fsPromises.realpath(currentStep);
      if (!stepReal.startsWith(canonicalUploadsRoot + path.sep)) {
        return res.status(403).json({
          statusCode: 403,
          error: "Forbidden",
          message: "Intermediate directory escapes public media tree.",
        });
      }
    }

    // Verify leaf is not a symlink before opening
    const targetLstat = await fsPromises.lstat(targetFilePath);
    if (targetLstat.isSymbolicLink() || !targetLstat.isFile()) {
      return res.status(403).json({
        statusCode: 403,
        error: "Forbidden",
        message: "Target is a symbolic link or non-regular file.",
      });
    }

    // Step 3: Platform O_NOFOLLOW validation (Fail closed on POSIX if unsupported)
    if (process.platform !== "win32") {
      if (typeof fs.constants.O_NOFOLLOW !== "number" || fs.constants.O_NOFOLLOW === 0) {
        throw new Error("Security invariant violated: O_NOFOLLOW is required on POSIX platform");
      }
    }
    const openFlags = fs.constants.O_RDONLY | (fs.constants.O_NOFOLLOW || 0);
    fileHandle = await fsPromises.open(targetFilePath, openFlags);
    const handleStat = await fileHandle.stat();

    if (!handleStat.isFile()) {
      await fileHandle.close();
      return res.status(403).json({
        statusCode: 403,
        error: "Forbidden",
        message: "Only regular files may be served from public static media.",
      });
    }

    // Step 4: Descriptor / Path Consistency Check (Device and Inode verification)
    const canonicalTarget = await fsPromises.realpath(targetFilePath);
    if (!canonicalTarget.startsWith(canonicalUploadsRoot + path.sep)) {
      await fileHandle.close();
      return res.status(403).json({
        statusCode: 403,
        error: "Forbidden",
        message: "Canonical file target escapes public media directory.",
      });
    }

    const canonicalStat = await fsPromises.stat(canonicalTarget);
    if (handleStat.dev !== canonicalStat.dev || handleStat.ino !== canonicalStat.ino) {
      await fileHandle.close();
      return res.status(403).json({
        statusCode: 403,
        error: "Forbidden",
        message: "File descriptor device/inode does not match canonical target.",
      });
    }

    const ext = path.extname(targetFilePath).toLowerCase();
    const mimeTypes: Record<string, string> = {
      ".jpg": "image/jpeg",
      ".jpeg": "image/jpeg",
      ".png": "image/png",
      ".webp": "image/webp",
      ".gif": "image/gif",
    };
    const contentType = mimeTypes[ext] || "application/octet-stream";

    res.set({
      "Content-Type": contentType,
      "Content-Length": handleStat.size.toString(),
      "X-Content-Type-Options": "nosniff",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, HEAD, OPTIONS",
      "Cross-Origin-Resource-Policy": "cross-origin",
      "Cache-Control": "public, max-age=86400",
    });

    // Step 5: Streaming Lifecycle & Cleanup Management
    let isCleanedUp = false;
    const cleanupHandle = async () => {
      if (!isCleanedUp && fileHandle) {
        isCleanedUp = true;
        await fileHandle.close().catch(() => {});
      }
    };

    if (req.method === "HEAD") {
      await cleanupHandle();
      return res.status(200).end();
    }

    const stream = fileHandle.createReadStream();

    res.on("close", () => {
      if (!stream.destroyed) {
        stream.destroy();
      }
      cleanupHandle();
    });

    stream.on("error", () => {
      cleanupHandle();
      if (!res.headersSent) {
        res.status(500).json({ statusCode: 500, error: "Internal Server Error", message: "Failed to stream media safely." });
      }
    });

    stream.on("end", () => {
      cleanupHandle();
    });

    stream.pipe(res);
  } catch (err: any) {
    if (fileHandle) {
      await fileHandle.close().catch(() => {});
    }
    if (err.code === "ENOENT") {
      return res.status(404).json({ statusCode: 404, message: "File Not Found" });
    }
    if (err.code === "ELOOP" || err.code === "EACCES" || err.code === "EPERM") {
      return res.status(403).json({
        statusCode: 403,
        error: "Forbidden",
        message: "Symbolic links and unauthorized access are forbidden.",
      });
    }
    return res.status(403).json({
      statusCode: 403,
      error: "Forbidden",
      message: "Failed to access public media safely.",
    });
  }
};
