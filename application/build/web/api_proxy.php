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
define('CONNECT_TIMEOUT_SECS', 1);
define('TRANSFER_TIMEOUT_SECS', 8);
define('WATCHDOG_COOLDOWN_SECS', 45);

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$uri = $_SERVER['REQUEST_URI'] ?? '/api/v1';

// Normalize endpoint paths so un-prefixed requests reach NestJS /api/v1 routes
$known_prefixes = [
    'verifications', 'advertisements', 'auth', 'profiles', 'storage',
    'interests', 'chat', 'notifications', 'master-data', 'parganas',
    'locations', 'education', 'government-employees', 'samaj-services',
    'samaj-super-stars', 'samaj-ratna', 'pavan-prernadata', 'shortlists',
    'reports', 'settings', 'health', 'admin'
];
$prefix_regex = implode('|', $known_prefixes);
if (preg_match('#^/(' . $prefix_regex . ')(?:[/?].*)?$#i', $uri)) {
    $uri = '/api/v1' . $uri;
} elseif (preg_match('#^/api/(?!v1/)(.*)$#i', $uri, $m)) {
    $uri = '/api/v1/' . $m[1];
}

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

// 1.1 Direct MySQL schema validation via PHP PDO (Non-blocking, cached for 1 hour)
function ensure_direct_schema_sync($project_dir) {
    $flag = sys_get_temp_dir() . '/vankar_schema_synced_v4.flag';
    if (file_exists($flag) && (time() - (int)@filemtime($flag)) < 3600) {
        return;
    }
    $envFiles = [
        $project_dir . '/.env.production',
        $project_dir . '/next-nest/backend/.env',
        $project_dir . '/.env'
    ];
    $conf = [];
    foreach ($envFiles as $ef) {
        if (file_exists($ef)) {
            $lines = @file($ef, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
            foreach ($lines as $line) {
                $line = trim($line);
                if (empty($line) || strpos($line, '#') === 0) continue;
                if (strpos($line, '=') !== false) {
                    list($k, $v) = explode('=', $line, 2);
                    $k = trim($k);
                    $v = trim(trim($v), "\"'");
                    if (!isset($conf[$k]) && strlen($v) > 0) {
                        $conf[$k] = $v;
                    }
                }
            }
        }
    }
    $user = $conf['MYSQL_USER'] ?? ($conf['DB_USER'] ?? '');
    $pass = $conf['MYSQL_PASSWORD'] ?? ($conf['DB_PASSWORD'] ?? '');
    $host = $conf['DB_HOST'] ?? '127.0.0.1';
    $name = $conf['MYSQL_DB'] ?? ($conf['DB_NAME'] ?? '');
    $dbUrl = $conf['DATABASE_URL'] ?? '';
    if (!empty($dbUrl)) {
        $p = parse_url($dbUrl);
        if (!empty($p['user'])) $user = urldecode($p['user']);
        if (!empty($p['pass'])) $pass = urldecode($p['pass']);
        if (!empty($p['host'])) $host = $p['host'];
        if (!empty($p['path'])) $name = ltrim($p['path'], '/');
    }
    if (empty($name) || empty($user)) return;
    try {
        $pdo = new PDO("mysql:host=$host;dbname=$name;charset=utf8mb4", $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_TIMEOUT => 3
        ]);
        $col = $pdo->query("SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND COLUMN_NAME = 'permissions'")->fetch();
        if (!$col) {
            $pdo->exec("ALTER TABLE users ADD COLUMN permissions TEXT NULL");
        }
        @touch($flag);
    } catch (Exception $e) {
        // Silently continue
    }
}
ensure_direct_schema_sync($project_dir);

// 1.2 Direct static media serving for /uploads/ (Bypasses backend socket for maximum speed & reliability)
$cleanPath = parse_url($uri, PHP_URL_PATH) ?? $uri;
if (preg_match('#^/(?:api/v1/)?uploads/([a-zA-Z0-9_\-\.]+)$#i', $cleanPath, $uploadMatch)) {
    $requestedFilename = basename($uploadMatch[1]);
    $possibleUploadDirs = [
        '/home/u796269890/domains/allgujaratvankarsamaj.com/uploads',
        $project_dir . '/uploads',
        $backend_dir . '/uploads',
        dirname(__DIR__) . '/uploads'
    ];
    
    // Ensure public_html/uploads symlink exists
    $pubUploads = '/home/u796269890/domains/allgujaratvankarsamaj.com/public_html/uploads';
    if (!file_exists($pubUploads) && !is_link($pubUploads)) {
        @symlink('/home/u796269890/domains/allgujaratvankarsamaj.com/uploads', $pubUploads);
    }
    
    foreach ($possibleUploadDirs as $candDir) {
        $fullPath = $candDir . '/' . $requestedFilename;
        if (file_exists($fullPath) && is_file($fullPath)) {
            $ext = strtolower(pathinfo($fullPath, PATHINFO_EXTENSION));
            $mimeMap = [
                'jpg'  => 'image/jpeg',
                'jpeg' => 'image/jpeg',
                'png'  => 'image/png',
                'webp' => 'image/webp',
                'gif'  => 'image/gif',
                'svg'  => 'image/svg+xml',
                'pdf'  => 'application/pdf',
                'mp4'  => 'video/mp4',
                'webm' => 'video/webm'
            ];
            $cType = $mimeMap[$ext] ?? 'application/octet-stream';
            header("Content-Type: $cType");
            header("Content-Length: " . filesize($fullPath));
            header("Cache-Control: public, max-age=86400, stale-while-revalidate=604800");
            header("Access-Control-Allow-Origin: *");
            header("Access-Control-Allow-Methods: GET, HEAD, OPTIONS");
            header("X-Content-Type-Options: nosniff");
            if ($method === 'HEAD') {
                exit;
            }
            readfile($fullPath);
            exit;
        }
    }
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
    $now = time();
    
    // Prevent multiple requests within 8s from concurrently spawning watchdogs
    if (file_exists($lock_file)) {
        $lockMtime = (int)@filemtime($lock_file);
        if (($now - $lockMtime) < 15) {
            return false;
        }
    }
    
    @touch($lock_file);
    @touch($trigger_file);
    
    $watchdog_script = $project_dir . '/keep_backend_alive.sh';
    if (file_exists($watchdog_script)) {
        $cmd = "nohup /bin/bash " . escapeshellarg($watchdog_script) . " --force </dev/null >/dev/null 2>&1 &";
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
    
    // Auto-recovery polling loop if backend is starting up or recovering
    if (!$fp) {
        trigger_watchdog_restart_if_needed($trigger_file, $restart_state_file, $lock_file, $project_dir);
        
        // Wait up to 10 seconds (25 iterations * 400ms) for socket readiness
        for ($retry = 0; $retry < 3; $retry++) {
            usleep(250000); // 400ms
            $fp = @stream_socket_client($socket_path, $errno, $errstr, 1);
            if (!$fp) {
                $fp = @stream_socket_client('tcp://127.0.0.1:3000', $errno, $errstr, 1);
            }
            if ($fp) {
                break;
            }
        }
    }
    
    if (!$fp) {
        http_response_code(502);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'statusCode' => 502,
            'message' => 'Bad Gateway: Backend service is currently starting. Please retry in a few seconds.',
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
        trigger_watchdog_restart_if_needed($trigger_file, $restart_state_file, $lock_file, $project_dir);
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
    if (!file_exists($socket_file)) {
        trigger_watchdog_restart_if_needed($trigger_file, $restart_state_file, $lock_file, $project_dir);
        for ($retry = 0; $retry < 3; $retry++) {
            usleep(250000); // 400ms
            if (file_exists($socket_file)) {
                usleep(200000); // 200ms grace for socket bind
                break;
            }
        }
    }
    
    $hasSocket = file_exists($socket_file);
    if (!$hasSocket) {
        $tcpTest = @stream_socket_client('tcp://127.0.0.1:3000', $errno, $errstr, 0.5);
        if (!$tcpTest) {
            trigger_watchdog_restart_if_needed($trigger_file, $restart_state_file, $lock_file, $project_dir);
            http_response_code(502);
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode([
                'statusCode' => 502,
                'message' => 'Bad Gateway: Backend service is currently starting. Please retry in a few seconds.',
                'restartUrl' => 'https://allgujaratvankarsamaj.com/restart_backend.php'
            ]);
            exit;
        }
        fclose($tcpTest);
    }
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
        trigger_watchdog_restart_if_needed($trigger_file, $restart_state_file, $lock_file, $project_dir);
        if ($curlErrno === CURLE_OPERATION_TIMEDOUT || $curlErrno === 28) {
            http_response_code(504);
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode([
                'statusCode' => 504,
                'message' => 'Gateway Timeout: Backend request timed out after 8 seconds.'
            ]);
            exit;
        }
        
        http_response_code(502);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'statusCode' => 502,
            'message' => 'Bad Gateway: Backend connection failed. Automatic restart triggered.',
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
