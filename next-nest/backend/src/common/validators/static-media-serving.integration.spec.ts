import * as express from "express";
import * as http from "http";
import * as fs from "fs";
import * as fsPromises from "fs/promises";
import * as path from "path";
import { servePublicStaticMedia } from "../middleware/static-media.middleware";

describe("Static Media Serving Integration Tests (Express & TOCTOU-safe handler)", () => {
  let app: express.Express;
  let server: http.Server;
  let baseUrl: string;
  const testUploadsDir = path.resolve(process.cwd(), "uploads");
  const testPrivateDir = path.resolve(process.cwd(), "private_uploads");

  const sampleImageName = "test_sample_avatar.png";
  const samplePdfName = "test_verification_proof.pdf";
  const sampleDocxName = "test_contract.docx";
  const symlinkImageName = "test_symlink_photo.png";

  const nestedDirPath = path.join(testUploadsDir, "profiles", "2026");
  const nestedImageName = "valid_nested.png";
  const nestedImagePath = path.join(nestedDirPath, nestedImageName);

  const symlinkDirPath = path.join(testUploadsDir, "symlink_dir");

  const sampleImagePath = path.join(testUploadsDir, sampleImageName);
  const samplePdfPath = path.join(testUploadsDir, samplePdfName);
  const sampleDocxPath = path.join(testUploadsDir, sampleDocxName);
  const symlinkPath = path.join(testUploadsDir, symlinkImageName);

  beforeAll(async () => {
    await fsPromises.mkdir(testUploadsDir, { recursive: true });
    await fsPromises.mkdir(testPrivateDir, { recursive: true, mode: 0o700 });
    await fsPromises.mkdir(nestedDirPath, { recursive: true });

    // Create real files in uploads
    await fsPromises.writeFile(sampleImagePath, Buffer.from("FAKE_PNG_BINARY_CONTENT"));
    await fsPromises.writeFile(samplePdfPath, Buffer.from("%PDF-1.4 FAKE_PDF_CONTENT"));
    await fsPromises.writeFile(sampleDocxPath, Buffer.from("PK FAKE_DOCX_CONTENT"));
    await fsPromises.writeFile(nestedImagePath, Buffer.from("FAKE_NESTED_PNG_CONTENT"));

    // Create symlink pointing outside uploads (e.g. to package.json)
    try {
      if (fs.existsSync(symlinkPath)) {
        await fsPromises.unlink(symlinkPath);
      }
      await fsPromises.symlink(path.resolve(process.cwd(), "package.json"), symlinkPath);
    } catch (_) {
      // Symlink creation might require elevated privileges on Windows, handle gracefully
    }

    // Create directory symlink pointing outside uploads
    try {
      if (fs.existsSync(symlinkDirPath)) {
        await fsPromises.unlink(symlinkDirPath).catch(() => fsPromises.rmdir(symlinkDirPath));
      }
      await fsPromises.symlink(testPrivateDir, symlinkDirPath, "junction");
    } catch (_) {
      // Symlink or junction creation might require elevated privileges on Windows, handle gracefully
    }

    // Initialize express app with exact production middleware
    app = express();

    app.use("/uploads", servePublicStaticMedia);
    app.use("/api/v1/uploads", servePublicStaticMedia);

    // Start server on random available port
    await new Promise<void>((resolve) => {
      server = app.listen(0, () => {
        const addr = server.address() as any;
        baseUrl = `http://127.0.0.1:${addr.port}`;
        resolve();
      });
    });
  });

  afterAll(async () => {
    if (server) {
      await new Promise<void>((resolve) => server.close(() => resolve()));
    }
    // Clean up test files
    await fsPromises.unlink(sampleImagePath).catch(() => {});
    await fsPromises.unlink(samplePdfPath).catch(() => {});
    await fsPromises.unlink(sampleDocxPath).catch(() => {});
    await fsPromises.unlink(nestedImagePath).catch(() => {});
    await fsPromises.unlink(symlinkPath).catch(() => {});
    if (fs.existsSync(symlinkDirPath)) {
      await fsPromises.unlink(symlinkDirPath).catch(() => fsPromises.rmdir(symlinkDirPath)).catch(() => {});
    }
  });

  describe("Normal Image Serving Under Both Mount Prefixes", () => {
    it("should serve valid PNG under /uploads with correct headers", async () => {
      const res = await fetch(`${baseUrl}/uploads/${sampleImageName}`);
      expect(res.status).toBe(200);
      expect(res.headers.get("content-type")).toBe("image/png");
      expect(res.headers.get("x-content-type-options")).toBe("nosniff");
      const text = await res.text();
      expect(text).toBe("FAKE_PNG_BINARY_CONTENT");
    });

    it("should serve valid PNG under /api/v1/uploads identically", async () => {
      const res = await fetch(`${baseUrl}/api/v1/uploads/${sampleImageName}`);
      expect(res.status).toBe(200);
      expect(res.headers.get("content-type")).toBe("image/png");
      expect(res.headers.get("x-content-type-options")).toBe("nosniff");
      const text = await res.text();
      expect(text).toBe("FAKE_PNG_BINARY_CONTENT");
    });

    it("should serve legitimate image inside nested genuine directory", async () => {
      const res = await fetch(`${baseUrl}/uploads/profiles/2026/${nestedImageName}`);
      expect(res.status).toBe(200);
      expect(res.headers.get("content-type")).toBe("image/png");
      const text = await res.text();
      expect(text).toBe("FAKE_NESTED_PNG_CONTENT");
    });

    it("should handle HEAD requests properly", async () => {
      const res = await fetch(`${baseUrl}/uploads/${sampleImageName}`, { method: "HEAD" });
      expect(res.status).toBe(200);
      expect(res.headers.get("content-type")).toBe("image/png");
      const text = await res.text();
      expect(text).toBe("");
    });

    it("should handle OPTIONS requests for CORS preflight", async () => {
      const res = await fetch(`${baseUrl}/uploads/${sampleImageName}`, { method: "OPTIONS" });
      expect(res.status).toBe(204);
      expect(res.headers.get("access-control-allow-origin")).toBe("*");
    });

    it("should reject disallowed HTTP methods (POST, PUT, DELETE)", async () => {
      const res = await fetch(`${baseUrl}/uploads/${sampleImageName}`, { method: "POST" });
      expect(res.status).toBe(405);
    });

    it("should serve normal image when query string is appended under /uploads", async () => {
      const res = await fetch(`${baseUrl}/uploads/${sampleImageName}?v=1.2.3&token=abc`);
      expect(res.status).toBe(200);
      const text = await res.text();
      expect(text).toBe("FAKE_PNG_BINARY_CONTENT");
    });

    it("should serve normal image when query string is appended under /api/v1/uploads", async () => {
      const res = await fetch(`${baseUrl}/api/v1/uploads/${sampleImageName}?v=1.2.3&token=abc`);
      expect(res.status).toBe(200);
      const text = await res.text();
      expect(text).toBe("FAKE_PNG_BINARY_CONTENT");
    });

    it("should return 404 for non-existent image", async () => {
      const res = await fetch(`${baseUrl}/uploads/non_existent_file.png`);
      expect(res.status).toBe(404);
    });
  });

  describe("Rejection of Private Identity Documents", () => {
    it("should return 403 Forbidden when requesting PDF under /uploads", async () => {
      const res = await fetch(`${baseUrl}/uploads/${samplePdfName}`);
      expect(res.status).toBe(403);
      const data = await res.json();
      expect(data.error).toBe("Forbidden");
      expect(data.message).toMatch(/Disallowed extension '\.pdf'/);
    });

    it("should return 403 Forbidden when requesting PDF under /api/v1/uploads", async () => {
      const res = await fetch(`${baseUrl}/api/v1/uploads/${samplePdfName}`);
      expect(res.status).toBe(403);
      const data = await res.json();
      expect(data.error).toBe("Forbidden");
      expect(data.message).toMatch(/Disallowed extension '\.pdf'/);
    });

    it("should return 403 Forbidden for DOCX and Word files under /uploads", async () => {
      const res = await fetch(`${baseUrl}/uploads/${sampleDocxName}`);
      expect(res.status).toBe(403);
    });

    it("should return 403 Forbidden for DOCX and Word files under /api/v1/uploads", async () => {
      const res = await fetch(`${baseUrl}/api/v1/uploads/${sampleDocxName}`);
      expect(res.status).toBe(403);
    });
  });

  describe("Traversal and Encoding Security Invariants (Finding B)", () => {
    it("should reject standard directory traversal (..)", async () => {
      const res = await fetch(`${baseUrl}/uploads/sub/../../package.json`);
      expect([403, 404]).toContain(res.status);

      const resSub = await fetch(`${baseUrl}/uploads/images/../photo.png`);
      expect([403, 404]).toContain(resSub.status);
    });

    it("should reject single URL-encoded traversal (%2e%2e)", async () => {
      const res = await fetch(`${baseUrl}/uploads/images/%2e%2e/secret.png`);
      expect([403, 404]).toContain(res.status);
    });

    it("should reject double URL-encoded traversal (%252e%252e)", async () => {
      const res = await fetch(`${baseUrl}/uploads/%252e%252e/package.json`);
      expect(res.status).toBe(403);
    });

    it("should reject deep nested percent-encoding exceeding 5 rounds", async () => {
      const deep = "/%25252525252e%25252525252e/photo.png";
      const res = await fetch(`${baseUrl}/uploads${deep}`);
      expect(res.status).toBe(403);
      const data = await res.json();
      expect(data.message).toMatch(/Double percent-encoding|Exceeded maximum URL percent-decoding depth/);
    });

    it("should reject encoded forward slashes (%2f)", async () => {
      const res = await fetch(`${baseUrl}/uploads/sub%2f${sampleImageName}`);
      expect(res.status).toBe(403);
      const data = await res.json();
      expect(data.message).toMatch(/Encoded path separators are forbidden|Encoded path separators are strictly forbidden/);
    });

    it("should reject encoded backslashes (%5c)", async () => {
      const res = await fetch(`${baseUrl}/uploads/sub%5c${sampleImageName}`);
      expect(res.status).toBe(403);
    });

    it("should reject control characters and NUL bytes (%00, %08, %1f)", async () => {
      const resNull = await fetch(`${baseUrl}/uploads/photo%00.png`);
      expect(resNull.status).toBe(403);

      const resCtrl = await fetch(`${baseUrl}/uploads/photo%08.png`);
      expect(resCtrl.status).toBe(403);

      const resLf = await fetch(`${baseUrl}/uploads/photo%0a.png`);
      expect(resLf.status).toBe(403);
    });

    it("should reject malformed percent escapes (%999, %zz, %2)", async () => {
      const resMalformed1 = await fetch(`${baseUrl}/uploads/photo%999.png`);
      expect([400, 403, 404]).toContain(resMalformed1.status);

      const resMalformed2 = await fetch(`${baseUrl}/uploads/photo%zz.png`);
      expect([400, 403, 404]).toContain(resMalformed2.status);
    });

    it("should reject unusual path representations (trailing dots, spaces, hidden files)", async () => {
      const resTrailingDot = await fetch(`${baseUrl}/uploads/${sampleImageName}.`);
      expect(resTrailingDot.status).toBe(403);

      const resTrailingSpace = await fetch(`${baseUrl}/uploads/${sampleImageName}%20`);
      expect(resTrailingSpace.status).toBe(403);

      const resHidden = await fetch(`${baseUrl}/uploads/.hidden_photo.png`);
      expect(resHidden.status).toBe(403);
    });

    it("should reject consecutive slashes", async () => {
      const res = await fetch(`${baseUrl}/uploads//${sampleImageName}`);
      expect(res.status).toBe(403);
    });

    it("should reject directory access without file", async () => {
      const res = await fetch(`${baseUrl}/uploads/`);
      expect(res.status).toBe(403);
    });
  });

  describe("Symlink Protection, Intermediate Containment & Lifecycle (Finding C)", () => {
    it("should reject serving symlinked files pointing outside uploads", async () => {
      if (fs.existsSync(symlinkPath)) {
        const res = await fetch(`${baseUrl}/uploads/${symlinkImageName}`);
        expect(res.status).toBe(403);
      }
    });

    it("should reject serving symlinked files under /api/v1/uploads", async () => {
      if (fs.existsSync(symlinkPath)) {
        const res = await fetch(`${baseUrl}/api/v1/uploads/${symlinkImageName}`);
        expect(res.status).toBe(403);
      }
    });

    it("should reject requests through intermediate directory symlinks (Finding C)", async () => {
      if (fs.existsSync(symlinkDirPath)) {
        const res = await fetch(`${baseUrl}/uploads/symlink_dir/${nestedImageName}`);
        expect(res.status).toBe(403);
        const data = await res.json();
        expect(data.error).toBe("Forbidden");
      }
    });

    it("should safely close file handle and return 404 when file is unlinked", async () => {
      const tempPhotoName = "temp_race_photo.png";
      const tempPhotoPath = path.join(testUploadsDir, tempPhotoName);
      await fsPromises.writeFile(tempPhotoPath, Buffer.from("TEMP_PHOTO_CONTENT"));

      const resOk = await fetch(`${baseUrl}/uploads/${tempPhotoName}`);
      expect(resOk.status).toBe(200);

      await fsPromises.unlink(tempPhotoPath);
      const resAfterUnlink = await fetch(`${baseUrl}/uploads/${tempPhotoName}`);
      expect(resAfterUnlink.status).toBe(404);
    });

    it("should handle client disconnect (res close event) without resource leak", async () => {
      const controller = new AbortController();
      const fetchPromise = fetch(`${baseUrl}/uploads/${sampleImageName}`, {
        signal: controller.signal,
      });
      // Abort connection immediately
      controller.abort();
      await expect(fetchPromise).rejects.toThrow();
    });
  });
});
