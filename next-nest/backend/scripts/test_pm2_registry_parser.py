#!/usr/bin/env python3
"""
Test PM2 Registry Parser Logic
Tests the passive PM2 registry parsing logic implemented in preflight_staging_readonly.sh.
"""

import sys
import json
import tempfile
import os

def parse_pm2_dump(dump_path: str):
    """Mirror exact logic from preflight_staging_readonly.sh Section 6."""
    try:
        with open(dump_path, "r", encoding="utf-8") as f:
            procs = json.load(f)
        if not isinstance(procs, list):
            return False, f"PM2 dump file root is not a list (got {type(procs).__name__})", None

        matching_procs = []
        for idx, entry in enumerate(procs):
            if not isinstance(entry, dict):
                return False, f"Registry entry at index {idx} is malformed (expected dict, got {type(entry).__name__})", None
            proc_name = entry.get("name")
            if isinstance(proc_name, str) and proc_name == "vankar-backend-staging":
                matching_procs.append(entry)

        if matching_procs:
            p = matching_procs[0]
            status = p.get("pm2_env", {}).get("status", "unknown") if isinstance(p.get("pm2_env"), dict) else "unknown"
            msg = f"PM2 REGISTRY STATE: \"vankar-backend-staging\" is previously registered (dump status: {status}). Note: Staging process already exists in registry; deploy_staging.sh will perform a controlled reload. Live process health cannot be inferred from passive dump data."
            return True, msg, "REGISTERED"
        else:
            msg = "PM2 REGISTRY STATE: \"vankar-backend-staging\" is NOT registered (clean pre-deployment state). Note: This confirms no prior or conflicting registration exists; deploy_staging.sh will register the application. This does not indicate a running application."
            return True, msg, "CLEAN_PRE_DEPLOYMENT"
    except Exception as e:
        return False, f"Failed to parse PM2 dump file passively: {e}", None

def main():
    test_cases = [
        # (payload, expected_success, expected_type, description)
        ([], True, "CLEAN_PRE_DEPLOYMENT", "Empty list (clean pre-deployment)"),
        ([{"name": "other-app", "pm2_env": {"status": "online"}}], True, "CLEAN_PRE_DEPLOYMENT", "List with other apps only"),
        ([{"name": "vankar-backend-staging", "pm2_env": {"status": "online"}}], True, "REGISTERED", "List with registered staging app"),
        ({}, False, None, "Invalid root: dict instead of list"),
        ("invalid json text", False, None, "Invalid JSON syntax"),
        ([{"name": "app1"}, "malformed_string_entry"], False, None, "List with non-dict element"),
        ([None], False, None, "List with None element"),
    ]

    passed = 0
    failed = 0

    print("=== Testing PM2 Passive Registry Parser ===")
    for payload, exp_succ, exp_type, desc in test_cases:
        with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False) as tmp:
            if isinstance(payload, str):
                tmp.write(payload)
            else:
                json.dump(payload, tmp)
            tmp_path = tmp.name

        try:
            succ, msg, res_type = parse_pm2_dump(tmp_path)
            if succ == exp_succ and (res_type == exp_type or not exp_succ):
                print(f"  [PASS] {desc}: success={succ}, state={res_type}")
                passed += 1
            else:
                print(f"  [FAIL] {desc}: expected (succ={exp_succ}, type={exp_type}), got (succ={succ}, type={res_type})")
                failed += 1
        finally:
            if os.path.exists(tmp_path):
                os.unlink(tmp_path)

    # Missing file test
    succ, msg, res_type = parse_pm2_dump("/nonexistent/dump.pm2")
    if not succ:
        print("  [PASS] Missing dump file fails closed: succ=False")
        passed += 1
    else:
        print("  [FAIL] Missing dump file unexpectedly succeeded")
        failed += 1

    print(f"\nResults: {passed} passed, {failed} failed (Total {passed + failed} tests).")
    if failed > 0:
        sys.exit(1)
    print("All PM2 passive registry parser tests passed successfully.")
    sys.exit(0)

if __name__ == "__main__":
    main()
