<?php
// Enhanced Self-Healing Reverse Proxy to NestJS Backend on Hostinger Unix Domain Socket
error_reporting(0);
ini_set('display_errors', '0');
@set_time_limit(30);

$socket_file = '/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock';
$backend_dir = '/home/u796269890/domains/allgujaratvankarsamaj.com/project_source/next-nest/backend';
$project_dir = '/home/u796269890/domains/allgujaratvankarsamaj.com/project_source';
$log_file = $backend_dir . '/backend.log';
$lock_file = sys_get_temp_dir() . '/vankar_backend_spawn.lock';
$trigger_file = '/home/u796269890/domains/allgujaratvankarsamaj.com/restart_trigger.txt';
$restart_state_file = '/home/u796269890/domains/allgujaratvankarsamaj.com/last_restart.time';

define('MAX_REQUEST_BYTES', 10 * 1024 * 1024);   // 10 MB limit on request body
define('MAX_RESPONSE_BYTES', 10 * 1024 * 1024);  // 10 MB limit on response body
define('CONNECT_TIMEOUT_SECS', 3);
define('TRANSFER_TIMEOUT_SECS', 15);
define('WATCHDOG_COOLDOWN_SECS', 45);

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$uri = $_SERVER['REQUEST_URI'] ?? '/api/v1';

// Strict Origin & CORS validation (Exact scheme, hostname, and port)
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$allowedOrigins = [
    'https://allgujaratvankarsamaj.com',
    'https://www.allgujaratvankarsamaj.com',
    'https://staging.allgujaratvankarsamaj.com'
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
} elseif (empty($origin)) {
    // Non-browser or native mobile clients
    header("Access-Control-Allow-Origin: *");
} else {
    // Untrusted web origin - strictly do not grant credentials or reflection
    header("Vary: Origin");
}

$reqHeaders = $_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS'] ?? 'Authorization, Content-Type, Accept, Origin, X-Requested-With, X-Request-ID, Cache-Control, Pragma';
header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
header("Access-Control-Allow-Headers: $reqHeaders");
header('Access-Control-Max-Age: 86400');

// 1. Immediate CORS Preflight response
if ($method === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// 2. Direct handling for file upload if PHP received a multipart form file
if ((preg_match('#^/api/v1/storage/upload#', $uri) || preg_match('#^/storage/upload#', $uri)) && !empty($_FILES['file'])) {
    $file = $_FILES['file'];
    if ($file['error'] === UPLOAD_ERR_OK && is_uploaded_file($file['tmp_name'])) {
        $uploadDir = '/home/u796269890/domains/allgujaratvankarsamaj.com/uploads';
        if (!is_dir($uploadDir)) {
            @mkdir($uploadDir, 0755, true);
        }
        $origName = basename($file['name']);
        $ext = strtolower(pathinfo($origName, PATHINFO_EXTENSION) ?: 'jpg');
        $allowedExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'pdf'];
        // Chat video attachments: only for authenticated (Bearer token) requests, max 25 MB
        $videoExts = ['mp4', 'm4v', 'mov', 'webm'];
        $reqHeadersAll = function_exists('getallheaders') ? array_change_key_case(getallheaders(), CASE_LOWER) : [];
        $authHeader = $reqHeadersAll['authorization'] ?? ($_SERVER['HTTP_AUTHORIZATION'] ?? '');
        if (in_array($ext, $videoExts) && stripos($authHeader, 'Bearer ') === 0 && $file['size'] <= 25 * 1024 * 1024) {
            $allowedExts = array_merge($allowedExts, $videoExts);
        }
        if (in_array($ext, $allowedExts)) {
            $uniqueFilename = bin2hex(random_bytes(16)) . '.' . $ext;
            $destPath = $uploadDir . '/' . $uniqueFilename;
            if (move_uploaded_file($file['tmp_name'], $destPath)) {
                header('Content-Type: application/json');
                http_response_code(201);
                echo json_encode([
                    'success' => true,
                    'url' => '/uploads/' . $uniqueFilename
                ]);
                exit;
            }
        }
    }
}

// 3. Read & enforce request body limit during streaming (prevents memory exhaustion)
$body = '';
$inputStream = fopen('php://input', 'rb');
$bytesRead = 0;
$requestOversized = false;

if ($inputStream) {
    while (!feof($inputStream)) {
        $chunk = fread($inputStream, 8192);
        if ($chunk === false) break;
        $bytesRead += strlen($chunk);
        if ($bytesRead > MAX_REQUEST_BYTES) {
            $requestOversized = true;
            break;
        }
        $body .= $chunk;
    }
    fclose($inputStream);
}

if ($requestOversized) {
    http_response_code(413);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'statusCode' => 413,
        'message' => 'Payload Too Large: Request body exceeds maximum limit of 10MB.'
    ]);
    exit;
}

// 4. Build forwarded request headers
if (!function_exists('getallheaders')) {
    function getallheaders() {
        $headers = [];
        foreach ($_SERVER as $name => $value) {
            if (substr($name, 0, 5) === 'HTTP_') {
                $hdrName = str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))));
                $headers[$hdrName] = $value;
            } elseif ($name === 'CONTENT_TYPE') {
                $headers['Content-Type'] = $value;
            } elseif ($name === 'CONTENT_LENGTH') {
                $headers['Content-Length'] = $value;
            }
        }
        return $headers;
    }
}

$hopByHopHeaders = [
    'connection',
    'keep-alive',
    'proxy-authenticate',
    'proxy-authorization',
    'te',
    'trailers',
    'upgrade',
    'content-length',
    'host'
];

$forwardHeaders = [];
$incomingHeaders = getallheaders();
foreach ($incomingHeaders as $name => $value) {
    $lower = strtolower($name);
    if (!in_array($lower, $hopByHopHeaders, true)) {
        $forwardHeaders[] = "$name: $value";
    }
}
$forwardHeaders[] = 'Host: localhost';
$forwardHeaders[] = 'Connection: close';
if (strlen($body) > 0) {
    $forwardHeaders[] = 'Content-Length: ' . strlen($body);
}

// 5. Watchdog Cooldown & Auto-Recovery Trigger (Non-blocking)
function trigger_watchdog_restart_if_needed($trigger_file, $restart_state_file, $lock_file, $project_dir) {
    $cooldown = WATCHDOG_COOLDOWN_SECS;
    $now = time();
    
    if (file_exists($restart_state_file)) {
        $lastRestart = (int)@file_get_contents($restart_state_file);
        if (($now - $lastRestart) < $cooldown) {
            return false;
        }
    }
    
    if (file_exists($lock_file)) {
        $lockMtime = (int)@filemtime($lock_file);
        if (($now - $lockMtime) < $cooldown) {
            return false;
        }
    }
    
    @touch($lock_file);
    @touch($trigger_file);
    
    $watchdog_script = $project_dir . '/keep_backend_alive.sh';
    if (file_exists($watchdog_script)) {
        $cmd = "/bin/bash " . escapeshellarg($watchdog_script) . " </dev/null >/dev/null 2>&1 &";
        if (function_exists('shell_exec')) {
            @shell_exec($cmd);
        } elseif (function_exists('exec')) {
            @exec($cmd);
        }
    }
    return true;
}

// 6. Upstream transport implementations
function proxy_via_stream($socket_file, $method, $uri, $forwardHeaders, $body, $trigger_file, $restart_state_file, $lock_file, $project_dir) {
    $socket_path = 'unix://' . $socket_file;
    $errno = 0;
    $errstr = '';
    
    $fp = @stream_socket_client($socket_path, $errno, $errstr, CONNECT_TIMEOUT_SECS);
    if (!$fp) {
        $fp = @stream_socket_client('tcp://127.0.0.1:3000', $errno, $errstr, 1);
    }
    
    if (!$fp) {
        trigger_watchdog_restart_if_needed($trigger_file, $restart_state_file, $lock_file, $project_dir);
        http_response_code(502);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'statusCode' => 502,
            'message' => 'Bad Gateway: Backend socket is unreachable. Auto-recovery in progress.',
            'restartUrl' => 'https://allgujaratvankarsamaj.com/restart_backend.php'
        ]);
        exit;
    }
    
    stream_set_timeout($fp, TRANSFER_TIMEOUT_SECS);
    
    $request = "$method $uri HTTP/1.1\r\n" . implode("\r\n", $forwardHeaders) . "\r\n\r\n" . $body;
    $written = @fwrite($fp, $request);
    if ($written === false) {
        fclose($fp);
        http_response_code(502);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'statusCode' => 502,
            'message' => 'Bad Gateway: Failed writing request to backend socket.'
        ]);
        exit;
    }
    
    $rawResponse = '';
    $respBytes = 0;
    $timedOut = false;
    $respOversized = false;
    
    while (!feof($fp)) {
        $chunk = fread($fp, 8192);
        if ($chunk === false) {
            break;
        }
        $meta = stream_get_meta_data($fp);
        if (!empty($meta['timed_out'])) {
            $timedOut = true;
            break;
        }
        $chunkLen = strlen($chunk);
        if ($chunkLen === 0) {
            break;
        }
        $respBytes += $chunkLen;
        if ($respBytes > MAX_RESPONSE_BYTES) {
            $respOversized = true;
            break;
        }
        $rawResponse .= $chunk;
    }
    fclose($fp);
    
    if ($timedOut) {
        http_response_code(504);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'statusCode' => 504,
            'message' => 'Gateway Timeout: Backend request timed out after 15 seconds.'
        ]);
        exit;
    }
    
    if ($respOversized) {
        http_response_code(502);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'statusCode' => 502,
            'message' => 'Bad Gateway: Upstream response exceeded maximum buffer limit of 10MB.'
        ]);
        exit;
    }
    
    if (empty($rawResponse)) {
        http_response_code(502);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'statusCode' => 502,
            'message' => 'Bad Gateway: Backend returned empty response.'
        ]);
        exit;
    }
    
    while (preg_match('/^HTTP\/\d\.\d\s+100\s+Continue/i', $rawResponse)) {
        $parts = explode("\r\n\r\n", $rawResponse, 2);
        $rawResponse = $parts[1] ?? '';
    }
    
    $parts = explode("\r\n\r\n", $rawResponse, 2);
    $headerText = $parts[0] ?? '';
    $bodyText = $parts[1] ?? '';
    
    $headerLines = explode("\r\n", $headerText);
    $finalStatus = 200;
    $parsedHeaders = [];
    
    foreach ($headerLines as $line) {
        $trimmed = trim($line);
        if (empty($trimmed)) continue;
        if (preg_match('/^HTTP\/\d\.\d\s+(\d+)/i', $trimmed, $m)) {
            $finalStatus = (int)$m[1];
            continue;
        }
        $colonPos = strpos($trimmed, ':');
        if ($colonPos !== false) {
            $hdrName = strtolower(substr($trimmed, 0, $colonPos));
            if (in_array($hdrName, ['transfer-encoding', 'connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization', 'te', 'trailers', 'upgrade'], true)) {
                continue;
            }
            if (strpos($hdrName, 'access-control-') === 0) {
                continue;
            }
            $parsedHeaders[] = $trimmed;
        }
    }
    
    http_response_code($finalStatus);
    foreach ($parsedHeaders as $headerLine) {
        $colonPos = strpos($headerLine, ':');
        if ($colonPos !== false) {
            $hdrName = strtolower(substr($headerLine, 0, $colonPos));
            $isCookie = ($hdrName === 'set-cookie');
            header($headerLine, !$isCookie);
        }
    }
    echo $bodyText;
    exit;
}

function proxy_via_curl($socket_file, $method, $uri, $forwardHeaders, $body, $trigger_file, $restart_state_file, $lock_file, $project_dir) {
    $hasSocket = file_exists($socket_file);
    $upstreamUrl = $hasSocket ? ('http://localhost' . $uri) : ('http://127.0.0.1:3000' . $uri);
    
    $ch = curl_init();
    if ($hasSocket) {
        curl_setopt($ch, CURLOPT_UNIX_SOCKET_PATH, $socket_file);
    }
    curl_setopt($ch, CURLOPT_URL, $upstreamUrl);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, CONNECT_TIMEOUT_SECS);
    curl_setopt($ch, CURLOPT_TIMEOUT, TRANSFER_TIMEOUT_SECS);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, false);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $forwardHeaders);
    
    if (in_array($method, ['POST', 'PUT', 'PATCH'], true) || strlen($body) > 0) {
        curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
    }
    
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
            $hdrName = strtolower(substr($trimmed, 0, $colonPos));
            if (in_array($hdrName, ['transfer-encoding', 'connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization', 'te', 'trailers', 'upgrade'], true)) {
                return $len;
            }
            if (strpos($hdrName, 'access-control-') === 0) {
                return $len;
            }
            $capturedHeaders[] = $trimmed;
        }
        return $len;
    });
    
    $responseBody = '';
    $responseSize = 0;
    $responseOversized = false;
    
    curl_setopt($ch, CURLOPT_WRITEFUNCTION, function($curlHandle, $chunk) use (&$responseBody, &$responseSize, &$responseOversized) {
        $chunkLen = strlen($chunk);
        $responseSize += $chunkLen;
        if ($responseSize > MAX_RESPONSE_BYTES) {
            $responseOversized = true;
            return 0; // Aborts transfer
        }
        $responseBody .= $chunk;
        return $chunkLen;
    });
    
    $execResult = curl_exec($ch);
    $curlErrno  = curl_errno($ch);
    $curlError  = curl_error($ch);
    curl_close($ch);
    
    if ($responseOversized) {
        http_response_code(502);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'statusCode' => 502,
            'message' => 'Bad Gateway: Upstream response exceeded maximum buffer limit of 10MB.'
        ]);
        exit;
    }
    
    if ($execResult === false) {
        if ($curlErrno === CURLE_OPERATION_TIMEDOUT || $curlErrno === 28) {
            http_response_code(504);
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode([
                'statusCode' => 504,
                'message' => 'Gateway Timeout: Backend request timed out after 15 seconds.'
            ]);
            exit;
        }
        
        // If Unix socket failed and socket file was present, fallback to stream check
        if ($hasSocket) {
            return proxy_via_stream($socket_file, $method, $uri, $forwardHeaders, $body, $trigger_file, $restart_state_file, $lock_file, $project_dir);
        }
        
        trigger_watchdog_restart_if_needed($trigger_file, $restart_state_file, $lock_file, $project_dir);
        http_response_code(502);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'statusCode' => 502,
            'message' => 'Bad Gateway: Backend service is unreachable. Auto-recovery in progress.',
            'restartUrl' => 'https://allgujaratvankarsamaj.com/restart_backend.php'
        ]);
        exit;
    }
    
    http_response_code($finalStatusCode);
    foreach ($capturedHeaders as $headerLine) {
        $colonPos = strpos($headerLine, ':');
        if ($colonPos !== false) {
            $hdrName = strtolower(substr($headerLine, 0, $colonPos));
            $isCookie = ($hdrName === 'set-cookie');
            header($headerLine, !$isCookie);
        }
    }
    echo $responseBody;
    exit;
}

// 7. Execute proxying via cURL if available, else stream fallback
if (function_exists('curl_init') && defined('CURLOPT_UNIX_SOCKET_PATH')) {
    proxy_via_curl($socket_file, $method, $uri, $forwardHeaders, $body, $trigger_file, $restart_state_file, $lock_file, $project_dir);
} else {
    proxy_via_stream($socket_file, $method, $uri, $forwardHeaders, $body, $trigger_file, $restart_state_file, $lock_file, $project_dir);
}
