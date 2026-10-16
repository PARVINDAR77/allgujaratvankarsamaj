"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.servePublicStaticMedia = void 0;
const fs = require("fs");
const fsPromises = require("fs/promises");
const path = require("path");
const static_media_validator_1 = require("../validators/static-media.validator");
const servePublicStaticMedia = async (req, res, next) => {
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
    const rawOrigUrl = req.originalUrl || req.url || "";
    const [rawOrigUrlPath] = rawOrigUrl.split("?");
    if (/%(?![0-9a-fA-F]{2})/.test(rawOrigUrlPath)) {
        return res.status(403).json({ statusCode: 403, error: "Forbidden", message: "Malformed percent-encoding in request" });
    }
    if (/%25/i.test(rawOrigUrlPath)) {
        return res.status(403).json({ statusCode: 403, error: "Forbidden", message: "Double percent-encoding is forbidden" });
    }
    if (/%2f|%5c/i.test(rawOrigUrlPath)) {
        return res.status(403).json({ statusCode: 403, error: "Forbidden", message: "Encoded path separators are forbidden" });
    }
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
    const rawReqPath = (req.path || "").split("?")[0];
    const rawUrlPath = (req.url || "").split("?")[0];
    if (rawReqPath !== rawUrlPath || (req.baseUrl && rawOrigUrlPath !== `${req.baseUrl}${rawReqPath}`)) {
        return res.status(403).json({
            statusCode: 403,
            error: "Forbidden",
            message: "Ambiguous request URL and routed path discrepancy detected.",
        });
    }
    const check = (0, static_media_validator_1.isAllowedStaticMediaPath)(rawReqPath);
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
    if (!targetFilePath.startsWith(uploadsRoot + path.sep)) {
        return res.status(403).json({
            statusCode: 403,
            error: "Forbidden",
            message: "Path traversal outside public media directory is forbidden.",
        });
    }
    let fileHandle = null;
    try {
        const canonicalUploadsRoot = await fsPromises.realpath(uploadsRoot);
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
        const targetLstat = await fsPromises.lstat(targetFilePath);
        if (targetLstat.isSymbolicLink() || !targetLstat.isFile()) {
            return res.status(403).json({
                statusCode: 403,
                error: "Forbidden",
                message: "Target is a symbolic link or non-regular file.",
            });
        }
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
        const mimeTypes = {
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
        let isCleanedUp = false;
        const cleanupHandle = async () => {
            if (!isCleanedUp && fileHandle) {
                isCleanedUp = true;
                await fileHandle.close().catch(() => { });
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
    }
    catch (err) {
        if (fileHandle) {
            await fileHandle.close().catch(() => { });
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
exports.servePublicStaticMedia = servePublicStaticMedia;
//# sourceMappingURL=static-media.middleware.js.map