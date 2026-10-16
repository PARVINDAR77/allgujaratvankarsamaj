<?php
/**
 * Hardened Reverse Proxy for Staging API
 * Target: Staging NestJS Backend (Port 3001 or Unix Socket backend_staging.sock)
 *
 * Security & Architectural Guarantees:
 * 1. Strict Origin Allowlist: Only approved staging origin receives CORS credentials.
 *    Untrusted origins receive NO Access-Control-Allow-Origin and NO credentials.
 * 2. Header Allowlists: Strict allowlists for incoming request headers and outgoing response headers.
 * 3. Bounded Request & Response Streaming: 10MB max request body enforced during ingestion;
 *    10MB max response buffer prevents memory exhaustion and partial error responses.
 * 4. Robust HTTP Framing & Error Handling: Native cURL HTTP/1.1 framing, 100 Continue handling,
 *    and clean JSON 502/504 responses without exposing internal cURL diagnostics.
 * 5. Multi-Header Preservation: Multiple Set-Cookie headers preserved via cURL header callback.
 * 6. Zero coupling to production paths, credentials, or databases.
 */

error_reporting(0);
ini_set('display_errors', '0');

define('MAX_REQUEST_BYTES', 10 * 1024 * 1024);   // 10 MB limit on request body
define('MAX_RESPONSE_BYTES', 10 * 1024 * 1024);  // 10 MB limit on response body

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$uri    = $_SERVER['REQUEST_URI'] ?? '/api/v1';

// 1. Strict Origin Allowlist (Staging public domain only)
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$allowedOrigins = [
    'https://staging.allgujaratvankarsamaj.com',
];

$matchedOrigin = null;
if (!empty($origin)) {
    $trimmedOrigin = rtrim($origin, '/');
    if (in_array($trimmedOrigin, $allowedOrigins, true)) {
        $matchedOrigin = $trimmedOrigin;
    }
}

if ($matchedOrigin !== null) {
    header("Access-Control-Allow-Origin: $matchedOrigin");
    header("Access-Control-Allow-Credentials: true");
    header("Vary: Origin");
} else if (empty($origin)) {
    // Non-browser or mobile clients without Origin header (e.g. native apps, curl)
} else {
    // Untrusted external web origin - strictly do NOT emit Allow-Origin or Allow-Credentials
    header("Vary: Origin");
}

// 2. Validate CORS Preflight Request Headers against strict allowlist (No blind reflection)
$allowedCorsHeaders = [
    'authorization',
    'content-type',
    'accept',
    'origin',
    'x-requested-with',
    'x-request-id',
    'cache-control',
    'pragma'
];

$requestedHeaders = $_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS'] ?? '';
$validatedCorsHeaders = [];
if (!empty($requestedHeaders)) {
    $parts = explode(',', $requestedHeaders);
    foreach ($parts as $p) {
        $cleaned = strtolower(trim($p));
        if (in_array($cleaned, $allowedCorsHeaders, true)) {
            $validatedCorsHeaders[] = $cleaned;
        }
    }
}
$allowedHeadersStr = !empty($validatedCorsHeaders) ? implode(', ', $validatedCorsHeaders) : 'authorization, content-type, accept';

header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
header("Access-Control-Allow-Headers: $allowedHeadersStr");
header('Access-Control-Max-Age: 86400');

// Immediate CORS Preflight response
if ($method === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// 3. Read & enforce request body limit during streaming (prevents memory exhaustion)
$body = '';
$inputStream = fopen('php://input', 'rb');
$bytesRead = 0;

if ($inputStream) {
    while (!feof($inputStream)) {
        $chunk = fread($inputStream, 8192);
        if ($chunk === false) break;
        $bytesRead += strlen($chunk);
        if ($bytesRead > MAX_REQUEST_BYTES) {
            fclose($inputStream);
            http_response_code(413);
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode([
                'statusCode' => 413,
                'message' => 'Payload Too Large: Request body exceeds staging maximum limit of 10MB.',
                'environment' => 'staging'
            ]);
            exit;
        }
        $body .= $chunk;
    }
    fclose($inputStream);
}

// 4. Build upstream request headers using strict forwarded header allowlist
$allowedForwardHeaders = [
    'authorization',
    'content-type',
    'accept',
    'accept-language',
    'user-agent',
    'x-requested-with',
    'x-request-id',
    'cookie',
    'origin'
];

$forwardHeaders = [];
$incomingHeaders = function_exists('getallheaders') ? getallheaders() : [];
foreach ($incomingHeaders as $name => $value) {
    $lower = strtolower($name);
    if (in_array($lower, $allowedForwardHeaders, true)) {
        $forwardHeaders[] = "$name: $value";
    }
}
$forwardHeaders[] = 'Host: 127.0.0.1';
$forwardHeaders[] = 'Connection: close';
if (strlen($body) > 0) {
    $forwardHeaders[] = 'Content-Length: ' . strlen($body);
}

// 5. Determine Staging Upstream Target (Socket vs TCP loopback)
$staging_socket = '/home/u796269890/staging/backend_staging.sock';
$upstreamUrl = 'http://127.0.0.1:3001' . $uri;

$ch = curl_init();

if (!empty($staging_socket) && file_exists($staging_socket)) {
    curl_setopt($ch, CURLOPT_UNIX_SOCKET_PATH, $staging_socket);
    $upstreamUrl = 'http://localhost' . $uri;
}

curl_setopt($ch, CURLOPT_URL, $upstreamUrl);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 3);
curl_setopt($ch, CURLOPT_TIMEOUT, 15);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, false);
curl_setopt($ch, CURLOPT_HTTPHEADER, $forwardHeaders);

if (strlen($body) > 0) {
    curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
}

// 6. Capture response headers with Set-Cookie preservation and 100 Continue handling
$capturedHeaders = [];
$finalStatusCode = 200;

curl_setopt($ch, CURLOPT_HEADERFUNCTION, function($curlHandle, $headerLine) use (&$capturedHeaders, &$finalStatusCode) {
    $len = strlen($headerLine);
    $trimmed = trim($headerLine);
    if (empty($trimmed)) {
        return $len;
    }

    if (preg_match('/^HTTP\/\d\.\d\s+(\d+)/i', $trimmed, $matches)) {
        $status = (int)$matches[1];
        if ($status !== 100) {
            $finalStatusCode = $status;
        }
        return $len;
    }

    $colonPos = strpos($trimmed, ':');
    if ($colonPos !== false) {
        $name = strtolower(substr($trimmed, 0, $colonPos));
        // Strip hop-by-hop headers
        if (in_array($name, ['transfer-encoding', 'connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization', 'te', 'trailers', 'upgrade'], true)) {
            return $len;
        }
        $capturedHeaders[] = $trimmed;
    }

    return $len;
});

// 7. Buffer response body with size limit (allows clean 502/504 conversion if cURL fails midway)
$responseBody = '';
$responseSize = 0;
$responseOversized = false;

curl_setopt($ch, CURLOPT_WRITEFUNCTION, function($curlHandle, $chunk) use (&$responseBody, &$responseSize, &$responseOversized) {
    $chunkLen = strlen($chunk);
    $responseSize += $chunkLen;
    if ($responseSize > MAX_RESPONSE_BYTES) {
        $responseOversized = true;
        return 0; // Aborts cURL transfer
    }
    $responseBody .= $chunk;
    return $chunkLen;
});

$execResult = curl_exec($ch);
$curlErrno  = curl_errno($ch);
$curlError  = curl_error($ch);
curl_close($ch);

// 8. Handle Failures & Timeouts (Return generic public JSON, log sanitized diagnostics privately)
if ($responseOversized) {
    http_response_code(502);
    header('Content-Type: application/json; charset=utf-8');
    error_log('[STAGING-PROXY] Response exceeded maximum limit of 10MB.');
    echo json_encode([
        'statusCode' => 502,
        'message' => 'Bad Gateway: Upstream response exceeded maximum buffer limit.',
        'environment' => 'staging'
    ]);
    exit;
}

if ($execResult === false) {
    error_log("[STAGING-PROXY] cURL error ($curlErrno): $curlError");
    if ($curlErrno === CURLE_OPERATION_TIMEDOUT || $curlErrno === 28) {
        http_response_code(504);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'statusCode' => 504,
            'message' => 'Gateway Timeout: Staging backend request timed out.',
            'environment' => 'staging'
        ]);
    } else {
        http_response_code(502);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'statusCode' => 502,
            'message' => 'Bad Gateway: Staging backend service is temporarily unavailable.',
            'environment' => 'staging'
        ]);
    }
    exit;
}

// 9. Emit final status code and response headers
http_response_code($finalStatusCode);

// Allowlist for response headers to forward to client
$allowedResponseHeaders = [
    'content-type',
    'set-cookie',
    'cache-control',
    'pragma',
    'expires',
    'etag',
    'last-modified',
    'location',
    'vary'
];

foreach ($capturedHeaders as $headerLine) {
    $colonPos = strpos($headerLine, ':');
    if ($colonPos !== false) {
        $hdrName = strtolower(substr($headerLine, 0, $colonPos));
        if (in_array($hdrName, $allowedResponseHeaders, true)) {
            // For Set-Cookie, pass false to preserve multiple cookies
            $isCookie = ($hdrName === 'set-cookie');
            header($headerLine, !$isCookie);
        }
    }
}

// 10. Output response body
echo $responseBody;
