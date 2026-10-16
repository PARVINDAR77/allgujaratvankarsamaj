#!/usr/bin/env bash
# ==============================================================================
# All Gujarat Vankar Samaj Matrimony — Staging Reverse Proxy Verification Suite
# Execution Context: Tests public proxy endpoint with explicit assertions
# Safety Guarantees:
# 1. Fails immediately on transport errors.
# 2. Asserts status codes and CORS headers independently.
# 3. Tests OPTIONS, allowed-origin GET, untrusted-origin GET, 4xx/5xx handling,
#    genuine multi-cookie preservation, and oversized request rejection.
# ==============================================================================

set -Eeuo pipefail
set +x

PROXY_URL="https://staging.allgujaratvankarsamaj.com/api/v1"
ALLOWED_ORIGIN="https://staging.allgujaratvankarsamaj.com"
UNTRUSTED_ORIGIN="https://malicious-attacker-domain.com"

echo "=== Testing Staging Public Reverse Proxy ($PROXY_URL) ==="

TMP_HEADER=$(mktemp)
TMP_BODY=$(mktemp)
trap 'rm -f "$TMP_HEADER" "$TMP_BODY"' EXIT

# --- Test 1: OPTIONS Preflight with Allowed Origin ---
echo "[Test 1/8] OPTIONS Preflight with Allowed Origin..."
HTTP_STATUS=$(curl -sS -o "$TMP_BODY" -D "$TMP_HEADER" -X OPTIONS \
  -H "Origin: $ALLOWED_ORIGIN" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Authorization, Content-Type" \
  "$PROXY_URL/health" -w "%{http_code}")

if [ "$HTTP_STATUS" != "204" ]; then
  echo "FATAL: Preflight failed with status $HTTP_STATUS (expected 204)!"
  cat "$TMP_HEADER"
  exit 1
fi

grep -iq "^access-control-allow-origin: $ALLOWED_ORIGIN" "$TMP_HEADER" || {
  echo "FATAL: Preflight missing expected Access-Control-Allow-Origin!"
  cat "$TMP_HEADER"
  exit 1
}

grep -iq "^access-control-allow-credentials: true" "$TMP_HEADER" || {
  echo "FATAL: Preflight missing Access-Control-Allow-Credentials: true!"
  cat "$TMP_HEADER"
  exit 1
}
echo "  [PASS] Preflight returned HTTP 204 with allowed origin and credentials."

# --- Test 2: OPTIONS Preflight with Untrusted Origin ---
echo "[Test 2/8] OPTIONS Preflight with Untrusted Origin..."
HTTP_STATUS=$(curl -sS -o "$TMP_BODY" -D "$TMP_HEADER" -X OPTIONS \
  -H "Origin: $UNTRUSTED_ORIGIN" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Authorization, Content-Type" \
  "$PROXY_URL/health" -w "%{http_code}")

if grep -iq "^access-control-allow-credentials: true" "$TMP_HEADER"; then
  echo "FATAL SECURITY FLAW: Untrusted preflight granted Access-Control-Allow-Credentials: true!"
  cat "$TMP_HEADER"
  exit 1
fi

if grep -iq "^access-control-allow-origin:" "$TMP_HEADER"; then
  echo "FATAL SECURITY FLAW: Untrusted preflight reflected Access-Control-Allow-Origin!"
  cat "$TMP_HEADER"
  exit 1
fi
echo "  [PASS] Untrusted origin preflight strictly denied credentials and reflection."

# --- Test 3: GET with Allowed Origin ---
echo "[Test 3/8] GET with Allowed Origin..."
HTTP_STATUS=$(curl -sS -o "$TMP_BODY" -D "$TMP_HEADER" \
  -H "Origin: $ALLOWED_ORIGIN" \
  "$PROXY_URL/health" -w "%{http_code}")

if [ "$HTTP_STATUS" != "200" ]; then
  echo "FATAL: Health check failed with status $HTTP_STATUS (expected 200)!"
  cat "$TMP_HEADER"
  cat "$TMP_BODY"
  exit 1
fi

grep -iq "^access-control-allow-origin: $ALLOWED_ORIGIN" "$TMP_HEADER" || {
  echo "FATAL: Expected Access-Control-Allow-Origin header missing or mismatched!"
  cat "$TMP_HEADER"
  exit 1
}

grep -iq "^access-control-allow-credentials: true" "$TMP_HEADER" || {
  echo "FATAL: Access-Control-Allow-Credentials header missing for allowed origin!"
  cat "$TMP_HEADER"
  exit 1
}
echo "  [PASS] Allowed origin received HTTP 200, matched origin, and credentials."

# --- Test 4: GET with Untrusted Origin ---
echo "[Test 4/8] GET with Untrusted Origin..."
HTTP_STATUS=$(curl -sS -o "$TMP_BODY" -D "$TMP_HEADER" \
  -H "Origin: $UNTRUSTED_ORIGIN" \
  "$PROXY_URL/health" -w "%{http_code}")

if [ "$HTTP_STATUS" != "200" ]; then
  echo "FATAL: Request failed with status $HTTP_STATUS!"
  cat "$TMP_HEADER"
  exit 1
fi

if grep -iq "^access-control-allow-credentials: true" "$TMP_HEADER"; then
  echo "FATAL SECURITY FLAW: Untrusted origin granted Access-Control-Allow-Credentials: true!"
  cat "$TMP_HEADER"
  exit 1
fi

if grep -iq "^access-control-allow-origin:" "$TMP_HEADER"; then
  echo "FATAL SECURITY FLAW: Untrusted origin was emitted Access-Control-Allow-Origin!"
  cat "$TMP_HEADER"
  exit 1
fi
echo "  [PASS] Untrusted origin strictly denied credentials and reflection."

# --- Test 5: Protected Endpoint Authentication Assertion (401 Response) ---
echo "[Test 5/8] Protected Endpoint Authentication Assertion (401)..."
HTTP_STATUS=$(curl -sS -o "$TMP_BODY" -D "$TMP_HEADER" \
  -H "Origin: $ALLOWED_ORIGIN" \
  "$PROXY_URL/profiles/me" -w "%{http_code}")

if [ "$HTTP_STATUS" != "401" ]; then
  echo "FATAL: Protected route did not return 401 Unauthorized (got $HTTP_STATUS)!"
  cat "$TMP_HEADER"
  cat "$TMP_BODY"
  exit 1
fi
echo "  [PASS] Protected endpoint correctly returned HTTP 401 Unauthorized."

# --- Test 6: Genuine Multi-Cookie Response Preservation Assertion ---
echo "[Test 6/8] Genuine Multi-Cookie Response Preservation Assertion..."
HTTP_STATUS=$(curl -sS -o "$TMP_BODY" -D "$TMP_HEADER" \
  -H "Origin: $ALLOWED_ORIGIN" \
  "$PROXY_URL/health/cookie-test" -w "%{http_code}")

if [ "$HTTP_STATUS" != "200" ]; then
  echo "FATAL: Staging cookie-test route returned $HTTP_STATUS (expected 200)!"
  cat "$TMP_HEADER"
  cat "$TMP_BODY"
  exit 1
fi

grep -iq "^set-cookie:.*stg_test_a=val_alpha" "$TMP_HEADER" || {
  echo "FATAL: First Set-Cookie header (stg_test_a) missing from proxy response!"
  cat "$TMP_HEADER"
  exit 1
}

grep -iq "^set-cookie:.*stg_test_b=val_beta" "$TMP_HEADER" || {
  echo "FATAL: Second Set-Cookie header (stg_test_b) missing from proxy response!"
  cat "$TMP_HEADER"
  exit 1
}

COOKIE_COUNT=$(grep -ci "^set-cookie:" "$TMP_HEADER" || true)
if [ "$COOKIE_COUNT" -lt 2 ]; then
  echo "FATAL: Expected at least 2 distinct Set-Cookie headers; found $COOKIE_COUNT!"
  cat "$TMP_HEADER"
  exit 1
fi
echo "  [PASS] Genuine multi-cookie response verified: $COOKIE_COUNT distinct Set-Cookie headers preserved."

# --- Test 7: Upstream 404 Response Propagation ---
echo "[Test 7/8] Non-existent Route 404 Propagation..."
HTTP_STATUS=$(curl -sS -o "$TMP_BODY" -D "$TMP_HEADER" \
  -H "Origin: $ALLOWED_ORIGIN" \
  "$PROXY_URL/health/non-existent-route-for-testing-xyz" -w "%{http_code}")

if [ "$HTTP_STATUS" != "404" ]; then
  echo "FATAL: Non-existent route did not return 404 (got $HTTP_STATUS)!"
  cat "$TMP_HEADER"
  exit 1
fi
echo "  [PASS] Upstream 404 status correctly propagated."

# --- Test 8: Oversized Request Body Rejection (413 Payload Too Large) ---
echo "[Test 8/8] Oversized Request Body Rejection (11MB payload)..."
OVERSIZED_TMP=$(mktemp)

# Generate 11MB binary payload reliably
if ! dd if=/dev/zero of="$OVERSIZED_TMP" bs=1048576 count=11 2>/dev/null; then
  head -c 11534336 /dev/zero > "$OVERSIZED_TMP" 2>/dev/null || true
fi

OVERSIZED_BYTES=$(wc -c < "$OVERSIZED_TMP" 2>/dev/null || echo "0")
if [ "$OVERSIZED_BYTES" -lt 11534336 ]; then
  rm -f "$OVERSIZED_TMP"
  echo "FATAL: Failed to generate 11MB test fixture (got $OVERSIZED_BYTES bytes). Cannot verify size limit."
  exit 1
fi

HTTP_STATUS=$(curl -sS -o "$TMP_BODY" -D "$TMP_HEADER" -X POST \
  -H "Origin: $ALLOWED_ORIGIN" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @"$OVERSIZED_TMP" \
  "$PROXY_URL/auth/login" -w "%{http_code}")
rm -f "$OVERSIZED_TMP"

if [ "$HTTP_STATUS" != "413" ]; then
  echo "FATAL: Oversized request was not rejected with HTTP 413 (got $HTTP_STATUS)!"
  cat "$TMP_HEADER"
  cat "$TMP_BODY"
  exit 1
fi
echo "  [PASS] Oversized request body correctly rejected with HTTP 413 Payload Too Large."

echo "=== All Staging Reverse Proxy Security Tests Completed Successfully ==="
