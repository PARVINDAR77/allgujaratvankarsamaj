#!/usr/bin/env python3
"""
Adversarial Test Suite for Archive AST Structural Verifier & Content Secret Scanner
Tests verify_archive_ast.py against malicious, malformed, and synthetic payloads.
"""

import os
import sys
import io
import tarfile
import tempfile
import subprocess

VERIFIER_SCRIPT = os.path.join(os.path.dirname(__file__), "verify_archive_ast.py")

def create_tar_gz(members_data: dict, member_types: dict = None) -> bytes:
    """Creates an in-memory tar.gz from a dictionary of filename -> bytes."""
    buf = io.BytesIO()
    with tarfile.open(fileobj=buf, mode="w:gz") as tar:
        for name, data in members_data.items():
            ti = tarfile.TarInfo(name=name)
            m_type = member_types.get(name, tarfile.REGTYPE) if member_types else tarfile.REGTYPE
            ti.type = m_type
            if m_type == tarfile.DIRTYPE:
                ti.size = 0
                tar.addfile(ti)
            elif m_type == tarfile.SYMTYPE or m_type == tarfile.LNKTYPE:
                ti.linkname = "backend/target"
                ti.size = 0
                tar.addfile(ti)
            else:
                ti.size = len(data)
                tar.addfile(ti, io.BytesIO(data))
    return buf.getvalue()

def run_verifier(archive_bytes: bytes) -> tuple:
    tmp = tempfile.NamedTemporaryFile(suffix=".tar.gz", delete=False)
    tmp_path = tmp.name
    try:
        tmp.write(archive_bytes)
        tmp.flush()
        tmp.close()  # Explicitly close file descriptor so child process can open without file-locking contention on Windows/containers

        proc = subprocess.run(
            [sys.executable, VERIFIER_SCRIPT, tmp_path],
            capture_output=True,
            text=True,
            timeout=15  # Bounded execution: prevents indefinite stalling
        )
        return proc.returncode, proc.stdout, proc.stderr
    except subprocess.TimeoutExpired as te:
        return 99, te.stdout or "", f"TimeoutExpired: verifier exceeded 15s on {tmp_path}"
    finally:
        try:
            if os.path.exists(tmp_path):
                os.unlink(tmp_path)
        except OSError:
            pass

def main():
    test_cases = [
        # 1. Structural tests (Expected Exit: 1)
        ("Literal parent traversal (backend/../outside)", 
         {"backend/../outside": b"exploit"}, None, 1),

        ("Literal dot component (backend/./file.ts)", 
         {"backend/./file.ts": b"data"}, None, 1),

        ("Windows backslash (backend\\file.ts)", 
         {"backend\\file.ts": b"data"}, None, 1),

        ("Drive colon (backend/C:file.ts)", 
         {"backend/C:file.ts": b"data"}, None, 1),

        ("Absolute path (/etc/passwd)", 
         {"/etc/passwd": b"root:x:0:0:..."}, None, 1),

        ("Leading slash (/backend/file.ts)", 
         {"/backend/file.ts": b"data"}, None, 1),

        ("Consecutive slashes (backend//file.ts)", 
         {"backend//file.ts": b"data"}, None, 1),

        ("Outside backend prefix (frontend/file.ts)", 
         {"frontend/file.ts": b"data"}, None, 1),

        ("Symlink member type", 
         {"backend/symlink_leaf": b""}, {"backend/symlink_leaf": tarfile.SYMTYPE}, 1),

        ("Hardlink member type", 
         {"backend/hardlink_leaf": b""}, {"backend/hardlink_leaf": tarfile.LNKTYPE}, 1),

        ("FIFO member type", 
         {"backend/fifo_leaf": b""}, {"backend/fifo_leaf": tarfile.FIFOTYPE}, 1),

        ("Sensitive environment file (backend/.env)", 
         {"backend/.env": b"SECRET=123"}, None, 1),

        # 2. Secret scanning tests (Expected Exit: 2)
        ("Synthetic RSA private key", 
         {"backend/key.txt": b"-----" + b"BEGIN RSA PRIVATE KEY" + b"-----\nMIIEowIBAAKCAQEA0..."}, None, 2),

        ("Synthetic EC private key", 
         {"backend/key.txt": b"-----" + b"BEGIN EC PRIVATE KEY" + b"-----\nMHcCAQEE..."}, None, 2),

        ("Synthetic OpenSSH private key", 
         {"backend/id_ed25519": b"-----" + b"BEGIN OPENSSH PRIVATE KEY" + b"-----\nb3BlbnNza..."}, None, 2),

        ("Synthetic AWS Access Key ID", 
         {"backend/config.json": b'{"aws_key": "' + b"AKIA" + b'IOSFODNN7EXAMPLE"}'}, None, 2),

        ("Synthetic GitHub Personal Access Token", 
         {"backend/token.txt": b"ghp_" + b"123456789012345678901234567890123456"}, None, 2),

        ("Synthetic Slack Token", 
         {"backend/slack.txt": b"xoxb-" + b"1234567890-123456789012-abcdef123456"}, None, 2),

        ("Synthetic Stripe Live Key", 
         {"backend/stripe.txt": b"sk_live_" + b"51A2B3C4D5E6F7G8H9I0J1K2L"}, None, 2),

        ("Synthetic Google API Key", 
         {"backend/gcp.txt": b" AIzaSy" + b"D-1234567890abcdefghijklmnopqrstu "}, None, 2),

        ("Prohibited key file extension (.pem)", 
         {"backend/server.pem": b"cert content"}, None, 2),

        # 3. Secret spanning 64 KiB chunk boundary (Expected Exit: 2)
        ("Secret pattern spanning chunk boundary", 
         {"backend/large.txt": b"A" * (64 * 1024 - 10) + b" " + b"AKIA" + b"IOSFODNN7EXAMPLE " + b"B" * 100}, None, 2),

        # 4. Large file (> 5 MiB) scanning (Expected Exit: 2 - proves NO 5MB skipping)
        ("Secret in file > 5 MiB (6 MiB payload)", 
         {"backend/big.txt": b"A" * (6 * 1024 * 1024) + b"-----" + b"BEGIN RSA PRIVATE KEY" + b"-----\nfake\n"}, None, 2),

        # 5. Clean benign archive (Expected Exit: 0)
        ("Benign canonical archive", 
         {"backend/src/app.ts": b"export const app = 42;\n", "backend/package.json": b'{"name": "test"}'}, None, 0),
    ]

    passed = 0
    failed = 0

    print("=== Running Archive Verifier Adversarial Test Matrix ===", flush=True)
    for desc, files, types, expected_code in test_cases:
        tar_bytes = create_tar_gz(files, types)
        code, out, err = run_verifier(tar_bytes)
        if code == expected_code:
            print(f"  [PASS] {desc} -> Exit {code} (Matches expected {expected_code})", flush=True)
            passed += 1
        else:
            print(f"  [FAIL] {desc} -> Expected {expected_code}, got {code}", flush=True)
            if err:
                print(f"         Stderr: {err.strip()}", flush=True)
            failed += 1

    # Special test: Duplicate entries
    buf = io.BytesIO()
    with tarfile.open(fileobj=buf, mode="w:gz") as tar:
        ti1 = tarfile.TarInfo(name="backend/file.ts")
        ti1.size = 4
        tar.addfile(ti1, io.BytesIO(b"data"))
        ti2 = tarfile.TarInfo(name="backend/file.ts")
        ti2.size = 5
        tar.addfile(ti2, io.BytesIO(b"data2"))
    code, out, err = run_verifier(buf.getvalue())
    if code == 1:
        print("  [PASS] Exact duplicate member names -> Exit 1 (Matches expected 1)", flush=True)
        passed += 1
    else:
        print(f"  [FAIL] Exact duplicate member names -> Expected 1, got {code}", flush=True)
        failed += 1

    # Special test: Malformed archive (not a gzip) (Expected Exit: 4)
    code, out, err = run_verifier(b"corrupt junk data not a tar.gz")
    if code == 4:
        print("  [PASS] Malformed/corrupt archive file -> Exit 4 (Matches expected 4)", flush=True)
        passed += 1
    else:
        print(f"  [FAIL] Malformed/corrupt archive file -> Expected 4, got {code}", flush=True)
        failed += 1

    print(f"\nAdversarial Results: {passed} passed, {failed} failed (Total {passed + failed} tests).", flush=True)
    if failed > 0:
        sys.exit(1)
    print("All adversarial archive verifier tests passed successfully.", flush=True)
    sys.exit(0)

if __name__ == "__main__":
    main()
