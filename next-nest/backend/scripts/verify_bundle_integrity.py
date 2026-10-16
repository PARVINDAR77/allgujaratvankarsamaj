#!/usr/bin/env python3
import zipfile
import tarfile
import hashlib
import os

repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))

zip_path = os.path.join(repo_root, "audit_review_source_bundle.zip")
tar_path = os.path.join(repo_root, "staging-backend-patch.tar.gz")
sha_path = os.path.join(repo_root, "staging-backend-patch.tar.gz.sha256")

print("=== 1. Verifying audit_review_source_bundle.zip ===")
with zipfile.ZipFile(zip_path, 'r') as z:
    corrupt = z.testzip()
    print("testzip result (None means 0 CRC errors):", corrupt)
    print("Member count:", len(z.namelist()))
    for info in z.infolist():
        print(f"  {info.filename:42} {info.file_size:7} bytes")

print("\n=== 2. Verifying staging-backend-patch.tar.gz ===")
with tarfile.open(tar_path, 'r:gz') as t:
    members = t.getmembers()
    print("Total members:", len(members))
    dirs = sum(1 for m in members if m.isdir())
    files = sum(1 for m in members if m.isreg())
    print(f"  Directories: {dirs}")
    print(f"  Files:       {files}")

print("\n=== 3. SHA-256 Verification ===")
def get_sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()

tar_sha = get_sha256(tar_path)
zip_sha = get_sha256(zip_path)
with open(sha_path, "r") as f:
    sha_file_content = f.read().strip()

print(f"staging-backend-patch.tar.gz:     {tar_sha} ({os.path.getsize(tar_path)} bytes)")
print(f"audit_review_source_bundle.zip:    {zip_sha} ({os.path.getsize(zip_path)} bytes)")
print(f"staging-backend-patch.tar.gz.sha256: {sha_file_content}")
assert sha_file_content.startswith(tar_sha), "Companion SHA file does not match actual tarball SHA!"
print("All integrity assertions passed!")
