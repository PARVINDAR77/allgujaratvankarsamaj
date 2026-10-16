import { isAllowedStaticMediaPath } from "./static-media.validator";

describe("Static Media Path Security Validator", () => {
  describe("Allowed Public Media Assets", () => {
    it("should allow valid PNG images", () => {
      const res = isAllowedStaticMediaPath("/avatar.png");
      expect(res.allowed).toBe(true);
    });

    it("should allow valid JPG / JPEG images", () => {
      expect(isAllowedStaticMediaPath("/photo.jpg").allowed).toBe(true);
      expect(isAllowedStaticMediaPath("/photo.jpeg").allowed).toBe(true);
    });

    it("should allow WebP and GIF images", () => {
      expect(isAllowedStaticMediaPath("/image.webp").allowed).toBe(true);
      expect(isAllowedStaticMediaPath("/anim.gif").allowed).toBe(true);
    });

    it("should handle mixed-case extensions properly", () => {
      expect(isAllowedStaticMediaPath("/PHOTO.JPG").allowed).toBe(true);
      expect(isAllowedStaticMediaPath("/Image.PnG").allowed).toBe(true);
      expect(isAllowedStaticMediaPath("/banner.WeBp").allowed).toBe(true);
    });

    it("should allow UUID-style filenames", () => {
      expect(
        isAllowedStaticMediaPath("/01fb4b95-5a47-4d18-9186-a27ededd6854.png").allowed,
      ).toBe(true);
    });
  });

  describe("Prohibited Private Documents & Extensions", () => {
    it("should strictly reject PDF files", () => {
      const res = isAllowedStaticMediaPath("/aadhaar_document.pdf");
      expect(res.allowed).toBe(false);
      expect(res.reason).toMatch(/Disallowed extension '\.pdf'/);
    });

    it("should strictly reject mixed-case PDF extensions", () => {
      expect(isAllowedStaticMediaPath("/id_card.PDF").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/passport.PdF").allowed).toBe(false);
    });

    it("should strictly reject Word documents and archives", () => {
      expect(isAllowedStaticMediaPath("/resume.doc").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/contract.docx").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/backup.zip").allowed).toBe(false);
    });

    it("should strictly reject scripts and executable extensions", () => {
      expect(isAllowedStaticMediaPath("/exploit.sh").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/script.js").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/page.html").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/page.php").allowed).toBe(false);
    });
  });

  describe("Defeating Encoding & Traversal Bypasses", () => {
    it("should reject standard directory traversal (..)", () => {
      expect(isAllowedStaticMediaPath("/../etc/passwd").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/sub/../../secret.png").allowed).toBe(false);
    });

    it("should reject Windows backslash directory traversal (..\\)", () => {
      expect(isAllowedStaticMediaPath("..\\..\\secret.png").allowed).toBe(false);
    });

    it("should reject single URL-encoded traversal (%2e%2e)", () => {
      expect(isAllowedStaticMediaPath("/%2e%2e/passwd").allowed).toBe(false);
    });

    it("should defeat double URL-encoded traversal (%252e%252e)", () => {
      expect(isAllowedStaticMediaPath("/%252e%252e/passwd").allowed).toBe(false);
    });

    it("should reject URL-encoded PDF extension (%2e%70%64%66)", () => {
      expect(isAllowedStaticMediaPath("/document%2epdf").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/document%2e%70%64%66").allowed).toBe(false);
    });

    it("should reject hidden dotfiles (.env, .git)", () => {
      expect(isAllowedStaticMediaPath("/.env").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/.git/config").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/sub/.secret.jpg").allowed).toBe(false);
    });

    it("should reject paths with NUL bytes or control characters", () => {
      expect(isAllowedStaticMediaPath("/photo.png\0.pdf").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/photo\x08.png").allowed).toBe(false);
    });

    it("should reject inputs exceeding the maximum percent-decoding depth or double-encoding", () => {
      // 6-level nested percent-encoding: %25252525252e -> immediately caught as double/multi-percent encoding
      const deepEncoded = "/%25252525252e%25252525252e/photo.png";
      const res = isAllowedStaticMediaPath(deepEncoded);
      expect(res.allowed).toBe(false);
      expect(res.reason).toMatch(/Double percent-encoding is strictly forbidden|Exceeded maximum URL percent-decoding depth/);
    });

    it("should reject paths with control characters emerging after decoding", () => {
      // %00 is encoded NUL byte
      const encodedNull = "/photo%00.png";
      const res = isAllowedStaticMediaPath(encodedNull);
      expect(res.allowed).toBe(false);
      expect(res.reason).toMatch(/Prohibited control characters/);
    });

    it("should reject raw traversal embedded before normalization (uploads/a/../b.jpg)", () => {
      const res = isAllowedStaticMediaPath("/uploads/a/../b.jpg");
      expect(res.allowed).toBe(false);
      expect(res.reason).toMatch(/Directory traversal or dot segment detected in raw path/);
    });

    it("should reject raw dot segments embedded before normalization (uploads/a/./b.jpg)", () => {
      const res = isAllowedStaticMediaPath("/uploads/a/./b.jpg");
      expect(res.allowed).toBe(false);
      expect(res.reason).toMatch(/Directory traversal or dot segment detected in raw path/);
    });

    it("should reject malformed percent escapes (/photo%2.jpg, /photo%zz.png)", () => {
      expect(isAllowedStaticMediaPath("/photo%2.jpg").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/photo%zz.png").allowed).toBe(false);
    });

    it("should reject encoded path separators (%2f, %5c) and encoded dots (%2e)", () => {
      expect(isAllowedStaticMediaPath("/uploads%2fphoto.jpg").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/uploads%5cphoto.jpg").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/uploads/%2e%2e/photo.jpg").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/photo%2epng").allowed).toBe(false);
    });

    it("should reject consecutive slashes (/uploads//photo.jpg)", () => {
      expect(isAllowedStaticMediaPath("/uploads//photo.jpg").allowed).toBe(false);
    });

    it("should reject paths without extensions or directories", () => {
      expect(isAllowedStaticMediaPath("/uploads/").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/uploads").allowed).toBe(false);
    });

    it("should reject overlong input exceeding MAX_STATIC_MEDIA_PATH_LENGTH (512 chars)", () => {
      const overlong = "/uploads/" + "a".repeat(510) + ".jpg";
      const res = isAllowedStaticMediaPath(overlong);
      expect(res.allowed).toBe(false);
      expect(res.reason).toMatch(/Path exceeds maximum allowed length/);
    });

    it("should reject URI schemes, protocols, and network share paths", () => {
      expect(isAllowedStaticMediaPath("http://evil.com/photo.jpg").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("https://evil.com/photo.jpg").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("file:///etc/passwd.jpg").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("//network-share/photo.jpg").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("javascript:alert(1).jpg").allowed).toBe(false);
    });

    it("should reject restricted directory segments (private_uploads, documents, id_proofs, secure, evidence)", () => {
      expect(isAllowedStaticMediaPath("/uploads/private_uploads/doc.jpg").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/uploads/documents/id.png").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/uploads/id_proofs/card.png").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/uploads/secure/secret.webp").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/uploads/evidence/dump.jpg").allowed).toBe(false);
    });

    it("should safely handle query strings on legitimate media files", () => {
      const res = isAllowedStaticMediaPath("/uploads/avatar.png?version=2&thumb=true");
      expect(res.allowed).toBe(true);
      expect(res.sanitizedPath).toBe("/uploads/avatar.png");
    });

    it("should reject trailing incomplete percent escapes (/photo%)", () => {
      expect(isAllowedStaticMediaPath("/photo%").allowed).toBe(false);
      expect(isAllowedStaticMediaPath("/photo%a").allowed).toBe(false);
    });
  });
});

