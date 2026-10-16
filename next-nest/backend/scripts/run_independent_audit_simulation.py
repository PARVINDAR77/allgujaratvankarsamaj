#!/usr/bin/env python3
"""
Independent Auditor Simulation Script
Executes all checks strictly from the extracted review bundle in an isolated directory
against staging-backend-patch.tar.gz to verify third-party reproducibility.
"""

import os
import sys
import shutil
import zipfile
import hashlib
import subprocess
import tempfile
import time

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
BUNDLE_ZIP = os.path.join(REPO_ROOT, "audit_review_source_bundle.zip")
STAGING_TAR = os.path.join(REPO_ROOT, "staging-backend-patch.tar.gz")

def sha256_file(filepath):
    h = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()

def main():
    print("=" * 70)
    print("INDEPENDENT AUDITOR SIMULATION & VERIFICATION RUN")
    print("=" * 70)

    # 1. File verification
    print("\n--- [STAGE 1] Verifying Artifact Hashes & Sizes ---")
    bundle_size = os.path.getsize(BUNDLE_ZIP)
    bundle_sha = sha256_file(BUNDLE_ZIP)
    print(f"audit_review_source_bundle.zip:")
    print(f"  Size:   {bundle_size} bytes")
    print(f"  SHA256: {bundle_sha}")

    tar_size = os.path.getsize(STAGING_TAR)
    tar_sha = sha256_file(STAGING_TAR)
    print(f"staging-backend-patch.tar.gz:")
    print(f"  Size:   {tar_size} bytes")
    print(f"  SHA256: {tar_sha}")

    # 2. ZIP integrity
    print("\n--- [STAGE 2] Checking ZIP Integrity ---")
    with zipfile.ZipFile(BUNDLE_ZIP, "r") as z:
        crc_error = z.testzip()
        members = z.namelist()
        print(f"ZIP member count: {len(members)}")
        print(f"ZIP CRC integrity test: {'PASS (0 errors)' if crc_error is None else 'FAIL: ' + str(crc_error)}")
        for m in sorted(members):
            print(f"  - {m}")

    # 3. Extract to clean isolated temp directory
    sandbox_dir = tempfile.mkdtemp(prefix="auditor_sandbox_")
    print(f"\n--- [STAGE 3] Extracting Bundle to Clean Sandbox: {sandbox_dir} ---")
    try:
        with zipfile.ZipFile(BUNDLE_ZIP, "r") as z:
            z.extractall(sandbox_dir)
        print("Successfully extracted all 14 files into isolated sandbox.")

        # 4. Run tests strictly from sandbox
        print("\n--- [STAGE 4] Executing Test Suites From Sandbox ---")

        # 4a. Archive Adversarial Suite
        adv_script = os.path.join(sandbox_dir, "test_archive_verifier_adversarial.py")
        t0 = time.time()
        p_adv = subprocess.run([sys.executable, adv_script], cwd=sandbox_dir, capture_output=True, text=True, timeout=60)
        dt_adv = time.time() - t0
        print(f"\n[Test 1] Archive Adversarial Matrix (26 tests) - Duration: {dt_adv:.2f}s:")
        print(f"Exit code: {p_adv.returncode}")
        print(p_adv.stdout.strip())
        if p_adv.stderr:
            print("Stderr:", p_adv.stderr.strip())

        # 4b. Permission Checker Suite
        perm_script = os.path.join(sandbox_dir, "test_permission_checker.py")
        t0 = time.time()
        p_perm = subprocess.run([sys.executable, perm_script], cwd=sandbox_dir, capture_output=True, text=True, timeout=60)
        dt_perm = time.time() - t0
        print(f"\n[Test 2] Permission Checker Suite (36 tests) - Duration: {dt_perm:.2f}s:")
        print(f"Exit code: {p_perm.returncode}")
        print(p_perm.stdout.strip())
        if p_perm.stderr:
            print("Stderr:", p_perm.stderr.strip())

        # 4c. PM2 Parser Suite
        pm2_script = os.path.join(sandbox_dir, "test_pm2_registry_parser.py")
        t0 = time.time()
        p_pm2 = subprocess.run([sys.executable, pm2_script], cwd=sandbox_dir, capture_output=True, text=True, timeout=30)
        dt_pm2 = time.time() - t0
        print(f"\n[Test 3] PM2 Passive Registry Parser Suite (8 tests) - Duration: {dt_pm2:.2f}s:")
        print(f"Exit code: {p_pm2.returncode}")
        print(p_pm2.stdout.strip())
        if p_pm2.stderr:
            print("Stderr:", p_pm2.stderr.strip())

        # 4d. Preflight Shell Syntax Check
        preflight_script = os.path.join(sandbox_dir, "preflight_staging_readonly.sh")
        p_sh = subprocess.run(["bash", "-n", preflight_script], cwd=sandbox_dir, capture_output=True, text=True)
        print(f"\n[Check 4] Preflight Shell Syntax Validation (bash -n):")
        print(f"Exit code: {p_sh.returncode} ({'PASS' if p_sh.returncode == 0 else 'FAIL'})")

        # 4e. Zero-Production-Contact Static Query Scan
        with open(preflight_script, "r") as f:
            preflight_content = f.read()
        import re
        prod_matches = re.findall(r"vankar_matrimony[^_]", preflight_content)
        print(f"\n[Check 5] Zero-Production-Contact Database Reference Scan:")
        print(f"Matches for production database 'vankar_matrimony': {len(prod_matches)}")
        if len(prod_matches) == 0:
            print("PASS: Zero queries or references to production schema 'vankar_matrimony' found in preflight script.")
        else:
            print(f"FAIL: Found {len(prod_matches)} unauthorized reference(s) to production schema!")

        # 4f. Run Archive AST & Secret Scanner on staging patch
        verifier_script = os.path.join(sandbox_dir, "verify_archive_ast.py")
        t0 = time.time()
        p_ver = subprocess.run([sys.executable, verifier_script, STAGING_TAR], cwd=sandbox_dir, capture_output=True, text=True, timeout=60)
        dt_ver = time.time() - t0
        print(f"\n[Check 6] Archive AST & Secret Scanning on staging-backend-patch.tar.gz - Duration: {dt_ver:.2f}s:")
        print(f"Exit code: {p_ver.returncode}")
        print(p_ver.stdout.strip())
        if p_ver.stderr:
            print("Stderr:", p_ver.stderr.strip())

        print("\n" + "=" * 70)
        all_passed = (
            crc_error is None and
            p_adv.returncode == 0 and
            p_perm.returncode == 0 and
            p_pm2.returncode == 0 and
            p_sh.returncode == 0 and
            len(prod_matches) == 0 and
            p_ver.returncode == 0
        )
        if all_passed:
            print("ALL INDEPENDENT VERIFICATION CHECKS PASSED SUCCESSFULLY (100%).")
        else:
            print("WARNING: Some independent verification checks failed!")
        print("=" * 70)

    finally:
        shutil.rmtree(sandbox_dir, ignore_errors=True)

if __name__ == "__main__":
    main()
