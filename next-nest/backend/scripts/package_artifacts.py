#!/usr/bin/env python3
"""
Authoritative artifact packaging and verification script.
Builds:
1. staging-backend-patch.tar.gz (canonical layout backend/...)
2. audit_review_source_bundle.zip (authoritative source and test files)
Computes SHA-256 digests and file sizes.
Verifies with verify_archive_ast.py.
"""

import os
import sys
import tarfile
import zipfile
import hashlib
import gzip
import subprocess

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
BACKEND_DIR = os.path.join(REPO_ROOT, "next-nest", "backend")

EXCLUDE_DIRS = {
    "node_modules",
    ".git",
    "__pycache__",
    ".idea",
    ".vscode",
    ".cache",
    "coverage",
}

EXCLUDE_EXTS = {
    ".log",
    ".tmp",
    ".swp",
}

EXCLUDE_FILENAMES = {
    ".DS_Store",
    "Thumbs.db",
    "staging-backend-patch.tar.gz",
    "audit_review_source_bundle.zip",
    "staging-backend-patch.tar.gz.sha256",
    "audit_review_source_bundle.zip.sha256",
    "package_artifacts.py",
    "verify_bundle_integrity.py",
    "BUNDLE_README.md",
}

def is_excluded(rel_path: str) -> bool:
    parts = rel_path.replace("\\", "/").split("/")
    for p in parts:
        if p in EXCLUDE_DIRS:
            return True
        if p.startswith(".env"):
            return True
    fname = parts[-1]
    if fname in EXCLUDE_FILENAMES:
        return True
    _, ext = os.path.splitext(fname)
    if ext in EXCLUDE_EXTS:
        return True
    return False

def build_staging_archive(out_tar_path: str):
    print(f"Building staging archive: {out_tar_path}")
    # Collect files
    members = []
    for root, dirs, files in os.walk(BACKEND_DIR):
        dirs.sort()
        files.sort()
        rel_root = os.path.relpath(root, BACKEND_DIR)
        if rel_root != "." and is_excluded(rel_root):
            dirs[:] = []
            continue
        
        # Filter dirs in place
        dirs[:] = [d for d in dirs if not is_excluded(os.path.join(rel_root, d) if rel_root != "." else d)]
        
        # Add directory member
        if rel_root == ".":
            arc_dir = "backend"
        else:
            arc_dir = "backend/" + rel_root.replace("\\", "/")
        members.append((root, arc_dir, True))
        
        for f in files:
            rel_file = os.path.join(rel_root, f) if rel_root != "." else f
            if is_excluded(rel_file):
                continue
            arc_name = "backend/" + rel_file.replace("\\", "/")
            full_path = os.path.join(root, f)
            members.append((full_path, arc_name, False))
            
    with open(out_tar_path, "wb") as f_out:
        with gzip.GzipFile(filename="", mode="wb", fileobj=f_out, mtime=1728900000) as gz_out:
            with tarfile.open(mode="w", fileobj=gz_out) as tar:
                for full_path, arc_name, is_dir in members:
                    ti = tar.gettarinfo(full_path, arcname=arc_name)
                    ti.uid = 1000
                    ti.gid = 1000
                    ti.uname = "node"
                    ti.gname = "node"
                    ti.mtime = 1728900000
                    if is_dir:
                        ti.mode = 0o755
                        tar.addfile(ti)
                    else:
                        ti.mode = 0o644
                        with open(full_path, "rb") as f:
                            tar.addfile(ti, f)
    print(f"Added {len(members)} members to {out_tar_path}")

def build_source_bundle(out_zip_path: str):
    print(f"Building audit source bundle: {out_zip_path}")
    source_files = [
        # Scripts
        ("next-nest/backend/scripts/preflight_staging_readonly.sh", "preflight_staging_readonly.sh"),
        ("next-nest/backend/scripts/permission_checker_core.py", "permission_checker_core.py"),
        ("next-nest/backend/scripts/test_permission_checker.py", "test_permission_checker.py"),
        ("next-nest/backend/scripts/verify_archive_ast.py", "verify_archive_ast.py"),
        ("next-nest/backend/scripts/test_archive_verifier_adversarial.py", "test_archive_verifier_adversarial.py"),
        ("next-nest/backend/scripts/test_pm2_registry_parser.py", "test_pm2_registry_parser.py"),
        # Source & Typescript
        ("next-nest/backend/src/common/validators/static-media.validator.ts", "static-media.validator.ts"),
        ("next-nest/backend/src/common/middleware/static-media.middleware.ts", "static-media.middleware.ts"),
        ("next-nest/backend/src/verifications/verifications.service.ts", "verifications.service.ts"),
        # Specifications
        ("next-nest/backend/src/common/validators/static-media.validator.spec.ts", "static-media.validator.spec.ts"),
        ("next-nest/backend/src/common/validators/static-media-serving.integration.spec.ts", "static-media-serving.integration.spec.ts"),
        # Auditor Guidance & Evidence
        ("next-nest/backend/scripts/BUNDLE_README.md", "README.md"),
        ("FINAL_SECURITY_REMEDIATION_AND_AUDIT_REPORT.md", "FINAL_SECURITY_REMEDIATION_AND_AUDIT_REPORT.md"),
        ("staging-backend-patch.tar.gz.sha256", "staging-backend-patch.tar.gz.sha256"),
    ]
    with zipfile.ZipFile(out_zip_path, "w", compression=zipfile.ZIP_DEFLATED) as z:
        for rel_src, arc_name in source_files:
            full_src = os.path.join(REPO_ROOT, rel_src)
            if not os.path.exists(full_src):
                raise FileNotFoundError(f"Missing bundle source file: {full_src}")
            zinfo = zipfile.ZipInfo(arc_name, (2026, 10, 15, 10, 0, 0))
            zinfo.compress_type = zipfile.ZIP_DEFLATED
            zinfo.external_attr = 0o644 << 16
            with open(full_src, "rb") as f:
                z.writestr(zinfo, f.read())
            print(f"  + {arc_name} (from {rel_src})")
    print(f"Built source bundle with {len(source_files)} files.")

def compute_sha256(filepath: str) -> str:
    h = hashlib.sha256()
    with open(filepath, "rb") as f:
        while True:
            chunk = f.read(65536)
            if not chunk:
                break
            h.update(chunk)
    return h.hexdigest()

def main():
    tar_path = os.path.join(REPO_ROOT, "staging-backend-patch.tar.gz")
    zip_path = os.path.join(REPO_ROOT, "audit_review_source_bundle.zip")
    sha_file = os.path.join(REPO_ROOT, "staging-backend-patch.tar.gz.sha256")
    
    build_staging_archive(tar_path)
    
    tar_sha = compute_sha256(tar_path)
    tar_size = os.path.getsize(tar_path)
    
    # Write companion sha file
    with open(sha_file, "w") as f:
        f.write(f"{tar_sha}  staging-backend-patch.tar.gz\n")
        
    build_source_bundle(zip_path)
    
    zip_sha = compute_sha256(zip_path)
    zip_size = os.path.getsize(zip_path)
    
    zip_sha_file = os.path.join(REPO_ROOT, "audit_review_source_bundle.zip.sha256")
    with open(zip_sha_file, "w") as f:
        f.write(f"{zip_sha}  audit_review_source_bundle.zip\n")
        
    print("\n=== Artifact Verification Metrics ===")
    print(f"1. staging-backend-patch.tar.gz:")
    print(f"   Size:   {tar_size} bytes")
    print(f"   SHA256: {tar_sha}")
    print(f"2. audit_review_source_bundle.zip:")
    print(f"   Size:   {zip_size} bytes")
    print(f"   SHA256: {zip_sha}")
    print(f"3. staging-backend-patch.tar.gz.sha256:")
    print(f"   Content: {tar_sha}  staging-backend-patch.tar.gz")
    print(f"4. audit_review_source_bundle.zip.sha256:")
    print(f"   Content: {zip_sha}  audit_review_source_bundle.zip")
    
    # Run verify_archive_ast.py
    print("\n=== Running verify_archive_ast.py on rebuilt staging archive ===")
    verifier_script = os.path.join(BACKEND_DIR, "scripts", "verify_archive_ast.py")
    ret = subprocess.run([sys.executable, verifier_script, tar_path], capture_output=True, text=True)
    print(f"Verifier Exit Code: {ret.returncode}")
    print(ret.stdout)
    if ret.stderr:
        print("Verifier Stderr:", ret.stderr)
        
    if ret.returncode != 0:
        print("ERROR: Verifier failed on rebuilt archive!")
        sys.exit(1)
    else:
        print("SUCCESS: Verifier passed on rebuilt archive!")

if __name__ == "__main__":
    main()
