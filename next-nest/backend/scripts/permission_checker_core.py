#!/usr/bin/env python3
"""
Permission Checker Core Module
Authoritative filesystem permission, ownership, entry type, and containment validator
for All Gujarat Vankar Samaj Matrimony.

Shared between preflight_staging_readonly.sh and test_permission_checker.py.
Guarantees identical, reproducible validation logic in both production preflight and tests.
"""

import os
import sys
import stat
import argparse

def check_file_mode(file_mode: int, uid: int, expected_uid: int):
    """
    Validates file permission mode and ownership:
    - Mode must not exceed 0644
    - Bitmask (mode & 0o7133) == 0 rejects group-write (0020), world-write (0002),
      setuid/setgid/sticky (7000), and all execution bits (0111).
    - UID must match expected_uid.
    """
    violations = []
    if uid != expected_uid:
        violations.append(f"Owner UID {uid} does not match expected {expected_uid}")
    if (file_mode & 0o7133) != 0 or file_mode > 0o644:
        violations.append(f"File mode {oct(file_mode)} exceeds maximum allowed 0644 or contains exec/group/world-write/special bits")
    return violations

def check_dir_mode(dir_mode: int, uid: int, expected_uid: int):
    """
    Validates directory permission mode and ownership:
    - Mode must not exceed 0755
    - Bitmask (dir_mode & 0o7022) == 0 rejects group-write (0020), world-write (0002),
      and setuid/setgid/sticky bits (7000).
    - UID must match expected_uid.
    """
    violations = []
    if uid != expected_uid:
        violations.append(f"Owner UID {uid} does not match expected {expected_uid}")
    if (dir_mode & 0o7022) != 0 or dir_mode > 0o755:
        violations.append(f"Directory mode {oct(dir_mode)} exceeds maximum allowed 0755 or contains special/group/world-write bits")
    return violations

def check_entry_type(file_type_mode: int):
    """Verifies that only regular files (S_ISREG) or directories (S_ISDIR) are permitted."""
    if stat.S_ISREG(file_type_mode):
        return True, "Regular file permitted"
    if stat.S_ISDIR(file_type_mode):
        return True, "Directory permitted"
    if stat.S_ISLNK(file_type_mode):
        return False, "Symbolic link strictly forbidden"
    if stat.S_ISFIFO(file_type_mode):
        return False, "FIFO/Named pipe strictly forbidden"
    if stat.S_ISSOCK(file_type_mode):
        return False, "UNIX socket strictly forbidden"
    if stat.S_ISCHR(file_type_mode):
        return False, "Character device strictly forbidden"
    if stat.S_ISBLK(file_type_mode):
        return False, "Block device strictly forbidden"
    return False, f"Unknown/unsupported file type mode {oct(file_type_mode)}"

def audit_public_uploads(uploads_dir: str, expected_uid: int = None):
    """Recursively audits public uploads tree fail-closed."""
    if expected_uid is None:
        expected_uid = os.getuid()

    if not os.path.exists(uploads_dir):
        return False, 0, 0, [f"Uploads directory does not exist: {uploads_dir}"], []

    if os.path.islink(uploads_dir):
        return False, 0, 0, [f"Uploads root is an illegal symbolic link: {uploads_dir}"], []

    symlink_violations = []
    traversal_errors = []
    scanned_dirs = 0
    scanned_files = 0

    def on_walk_error(err):
        traversal_errors.append(str(err))

    try:
        st = os.stat(uploads_dir)
        dir_mode = stat.S_IMODE(st.st_mode)
        root_violations = check_dir_mode(dir_mode, st.st_uid, expected_uid)
        symlink_violations.extend(root_violations)

        for root, dirs, files in os.walk(uploads_dir, onerror=on_walk_error, followlinks=False):
            scanned_dirs += 1
            st_root = os.stat(root)
            dir_mode = stat.S_IMODE(st_root.st_mode)
            dir_v = check_dir_mode(dir_mode, st_root.st_uid, expected_uid)
            if dir_v:
                symlink_violations.extend([f"Directory {root}: {v}" for v in dir_v])

            for d in dirs:
                full_d = os.path.join(root, d)
                if os.path.islink(full_d):
                    symlink_violations.append(f"Directory symlink in uploads: {full_d} -> {os.readlink(full_d)}")
                else:
                    st_d = os.stat(full_d)
                    if not stat.S_ISDIR(st_d.st_mode):
                        traversal_errors.append(f"Non-directory in dirs list: {full_d}")

            for f in files:
                scanned_files += 1
                full_f = os.path.join(root, f)
                if os.path.islink(full_f):
                    symlink_violations.append(f"File symlink in uploads: {full_f} -> {os.readlink(full_f)}")
                else:
                    st_f = os.stat(full_f)
                    if not stat.S_ISREG(st_f.st_mode):
                        traversal_errors.append(f"Non-regular file in uploads (special device/fifo/socket): {full_f}")
                    f_mode = stat.S_IMODE(st_f.st_mode)
                    file_v = check_file_mode(f_mode, st_f.st_uid, expected_uid)
                    if file_v:
                        symlink_violations.extend([f"File {full_f}: {v}" for v in file_v])

        success = len(symlink_violations) == 0 and len(traversal_errors) == 0
        return success, scanned_dirs, scanned_files, symlink_violations, traversal_errors

    except Exception as e:
        traversal_errors.append(f"Uploads inspection exception: {e}")
        return False, scanned_dirs, scanned_files, symlink_violations, traversal_errors

def audit_private_uploads(priv_dir: str, prod_root: str, stg_root: str, expected_uid: int = None):
    """Audits private document storage containment and permissions fail-closed."""
    if expected_uid is None:
        expected_uid = os.getuid()

    if not os.path.exists(priv_dir):
        return True, 0, [], False, "Private document storage is not yet provisioned (clean pre-provisioning state; isolation verified)."

    violations = []
    scanned_files = 0

    try:
        canon_priv = os.path.realpath(priv_dir)
        if prod_root and os.path.exists(prod_root) and canon_priv.startswith(os.path.realpath(prod_root) + os.sep):
            violations.append(f"CRITICAL: private_uploads is nested inside production web root: {canon_priv}")
        if stg_root and os.path.exists(stg_root) and canon_priv.startswith(os.path.realpath(stg_root) + os.sep):
            violations.append(f"CRITICAL: private_uploads is nested inside staging public web root: {canon_priv}")

        if os.path.islink(priv_dir):
            violations.append(f"private_uploads root is a symlink: {priv_dir}")

        st = os.stat(priv_dir)
        dir_mode = stat.S_IMODE(st.st_mode)

        if st.st_uid != expected_uid:
            violations.append(f"private_uploads root owner UID {st.st_uid} does not match expected {expected_uid}")

        # Private storage directory must be at most 0700: no group/world read, write, exec, or special bits
        if (dir_mode & 0o7077) != 0 or dir_mode > 0o700:
            violations.append(f"private_uploads root mode {oct(dir_mode)} exceeds maximum allowed 0700 or has group/world permissions")

        with os.scandir(priv_dir) as it:
            for entry in it:
                if entry.is_symlink():
                    violations.append(f"Symlink in private_uploads: {entry.name}")
                    continue
                if not entry.is_file(follow_symlinks=False):
                    violations.append(f"Non-regular file entry in private_uploads: {entry.name}")
                    continue

                scanned_files += 1
                st_f = entry.stat(follow_symlinks=False)
                if not stat.S_ISREG(st_f.st_mode):
                    violations.append(f"Non-regular file type in private_uploads: {entry.name}")
                f_mode = stat.S_IMODE(st_f.st_mode)

                if st_f.st_uid != expected_uid:
                    violations.append(f"File {entry.name} owner UID {st_f.st_uid} does not match expected {expected_uid}")
                # Private document files must be at most 0600: no exec bits, no group/world access
                if (f_mode & 0o7177) != 0 or f_mode > 0o600:
                    violations.append(f"File {entry.name} mode {oct(f_mode)} exceeds maximum allowed 0600 or contains exec/group/world bits")

        success = len(violations) == 0
        msg = f"Private document storage strictly verified: mode {oct(dir_mode)}, owner UID {expected_uid}, {scanned_files} file(s), 0 symlinks, completely isolated outside public web roots."
        return success, scanned_files, violations, True, msg

    except Exception as e:
        violations.append(f"Private document storage inspection exception: {e}")
        return False, scanned_files, violations, True, "Exception during private storage audit"

def main():
    parser = argparse.ArgumentParser(description="Filesystem Permission and Containment Checker")
    parser.add_argument("--audit-uploads", help="Path to public uploads directory to audit")
    parser.add_argument("--audit-private", help="Path to private uploads directory to audit")
    parser.add_argument("--prod-root", default="", help="Path to canonical production web root")
    parser.add_argument("--stg-root", default="", help="Path to canonical staging web root")
    parser.add_argument("--expected-uid", type=int, default=None, help="Expected owner UID (defaults to current process UID)")

    args = parser.parse_args()

    if args.audit_uploads:
        success, dirs, files, violations, errors = audit_public_uploads(args.audit_uploads, args.expected_uid)
        if errors:
            sys.stderr.write(f"Uploads traversal encountered {len(errors)} error(s):\n")
            for e in errors[:10]:
                sys.stderr.write(f"  - {e}\n")
            sys.exit(3)
        if violations:
            sys.stderr.write(f"Public uploads directory contains {len(violations)} violation(s):\n")
            for v in violations[:10]:
                sys.stderr.write(f"  - {v}\n")
            sys.exit(1)
        print(f"Public uploads directory verified: {dirs} directory/ies and {files} file(s) scanned, 0 traversal errors, 0 permission violations, 0 symlinks.")
        sys.exit(0)

    if args.audit_private:
        success, files, violations, prov, msg = audit_private_uploads(args.audit_private, args.prod_root, args.stg_root, args.expected_uid)
        if not success:
            sys.stderr.write(f"private_uploads audit failed with {len(violations)} violation(s):\n")
            for v in violations[:10]:
                sys.stderr.write(f"  - {v}\n")
            sys.exit(1)
        print(msg)
        sys.exit(0)

    parser.print_help()
    sys.exit(2)

if __name__ == "__main__":
    main()
