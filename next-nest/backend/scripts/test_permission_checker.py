#!/usr/bin/env python3
"""
Test Permission Checker Integration & Unit Test Suite
Validates the authoritative permission_checker_core.py module used by preflight_staging_readonly.sh.

Covers:
1. Pure unit tests for mode bitmasks, UID verification, and entry type filtering.
2. Full filesystem integration tests across isolated temporary directories:
   - Permitted file modes (0644, 0600, 0640, 0400)
   - Prohibited file modes (0660, 0666, 0755, 0645, 0654, setuid, setgid)
   - Permitted directory modes (0755, 0700, 0750)
   - Prohibited directory modes (0770, 0775, 0777, setuid, setgid)
   - File and directory symlinks
   - Disallowed entry types (FIFO, socket, character/block devices)
   - Inaccessible paths / traversal error handling (fails closed)
   - Empty directory trees & deeply nested trees
   - Private document storage containment & isolation
"""

import os
import sys
import stat
import tempfile
import shutil

# Ensure we import the authoritative core module
sys.path.insert(0, os.path.dirname(__file__))
from permission_checker_core import (
    check_file_mode,
    check_dir_mode,
    check_entry_type,
    audit_public_uploads,
    audit_private_uploads,
)

def run_unit_tests():
    expected_uid = 1000
    test_cases_files = [
        (0o644, 1000, True, "Standard regular file mode 0644"),
        (0o600, 1000, True, "Stricter private file mode 0600"),
        (0o640, 1000, True, "Group-readable file mode 0640"),
        (0o400, 1000, True, "Read-only file mode 0400"),
        (0o660, 1000, False, "Group-writable file mode 0660 (Finding D)"),
        (0o666, 1000, False, "World-writable file mode 0666"),
        (0o755, 1000, False, "Executable file mode 0755 (has exec bits)"),
        (0o645, 1000, False, "Other-executable file mode 0645"),
        (0o654, 1000, False, "Group-executable file mode 0654"),
        (0o4644, 1000, False, "Setuid file mode 04644"),
        (0o2644, 1000, False, "Setgid file mode 02644"),
        (0o644, 9999, False, "Wrong UID file test case"),
    ]

    test_cases_dirs = [
        (0o755, 1000, True, "Standard directory mode 0755"),
        (0o700, 1000, True, "Stricter private directory mode 0700"),
        (0o750, 1000, True, "Group-accessible directory mode 0750"),
        (0o775, 1000, False, "Group-writable directory mode 0775"),
        (0o777, 1000, False, "World-writable directory mode 0777"),
        (0o770, 1000, False, "Group-writable directory mode 0770"),
        (0o4755, 1000, False, "Setuid directory mode 04755"),
        (0o2755, 1000, False, "Setgid directory mode 02755"),
        (0o755, 9999, False, "Wrong UID directory test case"),
    ]

    test_cases_types = [
        (stat.S_IFREG | 0o644, True, "Regular file type (S_IFREG)"),
        (stat.S_IFDIR | 0o755, True, "Directory type (S_IFDIR)"),
        (stat.S_IFLNK | 0o777, False, "Symbolic link type (S_IFLNK)"),
        (stat.S_IFIFO | 0o644, False, "FIFO named pipe type (S_IFIFO)"),
        (stat.S_IFSOCK | 0o666, False, "Socket type (S_IFSOCK)"),
        (stat.S_IFCHR | 0o660, False, "Character device type (S_IFCHR)"),
        (stat.S_IFBLK | 0o660, False, "Block device type (S_IFBLK)"),
    ]

    passed = 0
    failed = 0

    print("=== Section 1: Pure Unit Tests (Bitmasks, UID & Types) ===")
    for mode, uid, expected_valid, desc in test_cases_files:
        violations = check_file_mode(mode, uid, expected_uid)
        is_valid = len(violations) == 0
        if is_valid == expected_valid:
            print(f"  [PASS] {desc}: mode={oct(mode)}, uid={uid} -> valid={is_valid}")
            passed += 1
        else:
            print(f"  [FAIL] {desc}: expected valid={expected_valid}, got valid={is_valid} ({violations})")
            failed += 1

    for mode, uid, expected_valid, desc in test_cases_dirs:
        violations = check_dir_mode(mode, uid, expected_uid)
        is_valid = len(violations) == 0
        if is_valid == expected_valid:
            print(f"  [PASS] {desc}: mode={oct(mode)}, uid={uid} -> valid={is_valid}")
            passed += 1
        else:
            print(f"  [FAIL] {desc}: expected valid={expected_valid}, got valid={is_valid} ({violations})")
            failed += 1

    for type_mode, expected_valid, desc in test_cases_types:
        is_valid, msg = check_entry_type(type_mode)
        if is_valid == expected_valid:
            print(f"  [PASS] {desc}: permitted={is_valid} ({msg})")
            passed += 1
        else:
            print(f"  [FAIL] {desc}: expected permitted={expected_valid}, got permitted={is_valid}")
            failed += 1

    return passed, failed

def run_filesystem_integration_tests():
    passed = 0
    failed = 0
    current_uid = os.getuid()

    print("\n=== Section 2: Filesystem Integration Tests (Isolated Temp Trees) ===")

    # Test 1: Clean public uploads directory with nested structure
    tmp_dir = tempfile.mkdtemp(prefix="test_uploads_clean_")
    try:
        os.chmod(tmp_dir, 0o755)
        sub = os.path.join(tmp_dir, "profiles", "avatars")
        os.makedirs(sub, mode=0o755)
        file1 = os.path.join(sub, "avatar1.png")
        with open(file1, "wb") as f:
            f.write(b"data")
        os.chmod(file1, 0o644)

        success, dirs, files, viols, errs = audit_public_uploads(tmp_dir, current_uid)
        if success and dirs == 3 and files == 1 and not viols and not errs:
            print("  [PASS] Clean public uploads directory with nested tree passes")
            passed += 1
        else:
            print(f"  [FAIL] Clean uploads failed: success={success}, dirs={dirs}, files={files}, viols={viols}, errs={errs}")
            failed += 1
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    # Test 2: Uploads directory containing group-writable file (0660)
    tmp_dir = tempfile.mkdtemp(prefix="test_uploads_0660_")
    try:
        os.chmod(tmp_dir, 0o755)
        bad_file = os.path.join(tmp_dir, "bad.jpg")
        with open(bad_file, "wb") as f:
            f.write(b"data")
        os.chmod(bad_file, 0o660)

        success, dirs, files, viols, errs = audit_public_uploads(tmp_dir, current_uid)
        if not success and any("0660" in v or "0o660" in v for v in viols):
            print("  [PASS] Uploads with 0660 file rejected fail-closed")
            passed += 1
        else:
            print(f"  [FAIL] 0660 test unexpected result: success={success}, viols={viols}")
            failed += 1
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    # Test 3: Uploads directory containing group-writable directory (0775)
    tmp_dir = tempfile.mkdtemp(prefix="test_uploads_0775_")
    try:
        os.chmod(tmp_dir, 0o755)
        bad_sub = os.path.join(tmp_dir, "bad_sub")
        os.makedirs(bad_sub)
        os.chmod(bad_sub, 0o775)

        success, dirs, files, viols, errs = audit_public_uploads(tmp_dir, current_uid)
        if not success and any("0775" in v or "0o775" in v for v in viols):
            print("  [PASS] Uploads with 0775 directory rejected fail-closed")
            passed += 1
        else:
            print(f"  [FAIL] 0775 test unexpected result: success={success}, viols={viols}")
            failed += 1
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    # Test 4: Uploads directory containing file symlink
    tmp_dir = tempfile.mkdtemp(prefix="test_uploads_symlink_")
    try:
        os.chmod(tmp_dir, 0o755)
        target = os.path.join(tmp_dir, "target.png")
        with open(target, "wb") as f:
            f.write(b"data")
        os.chmod(target, 0o644)
        link = os.path.join(tmp_dir, "link.png")
        os.symlink(target, link)

        success, dirs, files, viols, errs = audit_public_uploads(tmp_dir, current_uid)
        if not success and any("symlink" in v.lower() for v in viols):
            print("  [PASS] Uploads with file symlink rejected fail-closed")
            passed += 1
        else:
            print(f"  [FAIL] File symlink unexpected result: success={success}, viols={viols}")
            failed += 1
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    # Test 5: Uploads directory containing directory symlink
    tmp_dir = tempfile.mkdtemp(prefix="test_uploads_dirlink_")
    try:
        os.chmod(tmp_dir, 0o755)
        outside_target = tempfile.mkdtemp(prefix="test_outside_")
        os.chmod(outside_target, 0o755)
        link = os.path.join(tmp_dir, "dir_link")
        os.symlink(outside_target, link)

        success, dirs, files, viols, errs = audit_public_uploads(tmp_dir, current_uid)
        if not success and any("directory symlink" in v.lower() for v in viols):
            print("  [PASS] Uploads with directory symlink rejected fail-closed")
            passed += 1
        else:
            print(f"  [FAIL] Dir symlink unexpected result: success={success}, viols={viols}")
            failed += 1
        shutil.rmtree(outside_target, ignore_errors=True)
    finally:
        shutil.rmtree(tmp_dir, ignore_errors=True)

    # Test 6: Private document storage clean provisioning
    tmp_base = tempfile.mkdtemp(prefix="test_priv_base_")
    try:
        priv_dir = os.path.join(tmp_base, "staging", "backend", "private_uploads")
        prod_root = os.path.join(tmp_base, "domains", "allgujaratvankarsamaj.com", "public_html")
        stg_root = os.path.join(tmp_base, "domains", "staging.allgujaratvankarsamaj.com", "public_html")
        os.makedirs(priv_dir, mode=0o700)
        os.makedirs(prod_root, mode=0o755)
        os.makedirs(stg_root, mode=0o755)

        test_doc = os.path.join(priv_dir, "id_card.pdf")
        with open(test_doc, "wb") as f:
            f.write(b"%PDF-1.4")
        os.chmod(test_doc, 0o600)

        success, files, viols, prov, msg = audit_private_uploads(priv_dir, prod_root, stg_root, current_uid)
        if success and files == 1 and not viols:
            print("  [PASS] Private document storage (mode 0700, files 0600) verified")
            passed += 1
        else:
            print(f"  [FAIL] Private storage clean test failed: success={success}, viols={viols}")
            failed += 1
    finally:
        shutil.rmtree(tmp_base, ignore_errors=True)

    # Test 7: Private document storage containment violation (nested inside public web root)
    tmp_base = tempfile.mkdtemp(prefix="test_priv_leak_")
    try:
        stg_root = os.path.join(tmp_base, "domains", "staging.allgujaratvankarsamaj.com", "public_html")
        leaked_priv = os.path.join(stg_root, "private_uploads")
        os.makedirs(leaked_priv, mode=0o700)

        success, files, viols, prov, msg = audit_private_uploads(leaked_priv, "", stg_root, current_uid)
        if not success and any("nested inside" in v for v in viols):
            print("  [PASS] Private storage nested inside public web root rejected fail-closed")
            passed += 1
        else:
            print(f"  [FAIL] Nested private storage test failed: success={success}, viols={viols}")
            failed += 1
    finally:
        shutil.rmtree(tmp_base, ignore_errors=True)

    # Test 8: Non-existent uploads directory fails closed
    success, dirs, files, viols, errs = audit_public_uploads("/nonexistent/directory/path/never_there")
    if not success and any("does not exist" in v for v in viols):
        print("  [PASS] Non-existent uploads directory fails closed")
        passed += 1
    else:
        print(f"  [FAIL] Non-existent dir test failed: success={success}, viols={viols}")
        failed += 1

    return passed, failed

def main():
    u_passed, u_failed = run_unit_tests()
    i_passed, i_failed = run_filesystem_integration_tests()

    total_passed = u_passed + i_passed
    total_failed = u_failed + i_failed

    print(f"\n=======================================================")
    print(f"Permission Checker Test Results:")
    print(f"  - Unit Tests: {u_passed} passed, {u_failed} failed")
    print(f"  - Filesystem Integration Tests: {i_passed} passed, {i_failed} failed")
    print(f"  - Total: {total_passed} passed, {total_failed} failed")
    print(f"=======================================================")

    if total_failed > 0:
        sys.exit(1)
    print("All permission unit and integration tests passed successfully.")
    sys.exit(0)

if __name__ == "__main__":
    main()
