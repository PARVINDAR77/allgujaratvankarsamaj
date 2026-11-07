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
define('CONNECT_TIMEOUT_SECS', 4);
define('TRANSFER_TIMEOUT_SECS', 25);
define('WATCHDOG_COOLDOWN_SECS', 60);

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
        $col2 = $pdo->query("SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'verification_requests' AND COLUMN_NAME = 'document_back_url'")->fetch();
        if (!$col2) {
            $pdo->exec("ALTER TABLE verification_requests ADD COLUMN document_back_url VARCHAR(255) NULL");
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

// 1.3 High-Efficiency Image Compression Helper using PHP GD
function compress_and_save_image($tmpFile, $destPath, $ext) {
    if (!extension_loaded('gd') || !in_array($ext, ['jpg', 'jpeg', 'png', 'webp'], true)) {
        return move_uploaded_file($tmpFile, $destPath);
    }
    
    $info = @getimagesize($tmpFile);
    if (!$info) {
        return move_uploaded_file($tmpFile, $destPath);
    }
    
    $origWidth = $info[0];
    $origHeight = $info[1];
    $imageType = $info[2];
    
    $maxDim = 1280;
    $width = $origWidth;
    $height = $origHeight;
    
    if ($width > $maxDim || $height > $maxDim) {
        if ($width > $height) {
            $height = (int)round(($height * $maxDim) / $width);
            $width = $maxDim;
        } else {
            $width = (int)round(($width * $maxDim) / $height);
            $height = $maxDim;
        }
    }
    
    $srcImg = null;
    switch ($imageType) {
        case IMAGETYPE_JPEG:
            $srcImg = @imagecreatefromjpeg($tmpFile);
            break;
        case IMAGETYPE_PNG:
            $srcImg = @imagecreatefrompng($tmpFile);
            break;
        case IMAGETYPE_WEBP:
            if (function_exists('imagecreatefromwebp')) {
                $srcImg = @imagecreatefromwebp($tmpFile);
            }
            break;
    }
    
    if (!$srcImg) {
        return move_uploaded_file($tmpFile, $destPath);
    }
    
    $dstImg = imagecreatetruecolor($width, $height);
    if ($imageType === IMAGETYPE_PNG || $imageType === IMAGETYPE_WEBP) {
        imagealphablending($dstImg, false);
        imagesavealpha($dstImg, true);
    }
    
    imagecopyresampled($dstImg, $srcImg, 0, 0, 0, 0, $width, $height, $origWidth, $origHeight);
    
    $saved = false;
    if ($ext === 'jpg' || $ext === 'jpeg') {
        $saved = @imagejpeg($dstImg, $destPath, 82);
    } elseif ($ext === 'png') {
        $saved = @imagepng($dstImg, $destPath, 7);
    } elseif ($ext === 'webp' && function_exists('imagewebp')) {
        $saved = @imagewebp($dstImg, $destPath, 82);
    }
    
    @imagedestroy($srcImg);
    @imagedestroy($dstImg);
    
    return $saved ?: move_uploaded_file($tmpFile, $destPath);
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
            if (compress_and_save_image($file['tmp_name'], $destPath, $ext)) {
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

// 5. Watchdog Cooldown & Auto-Recovery Trigger (Self-Healing On-Demand)
function trigger_watchdog_restart_if_needed($trigger_file, $restart_state_file, $lock_file, $project_dir) {
    $now = time();
    $spawnLock = sys_get_temp_dir() . '/vankar_backend_spawn.lock';
    
    // Rate limit respawn attempts to at most once per 15 seconds
    if (file_exists($spawnLock)) {
        $lockAge = $now - (int)@filemtime($spawnLock);
        if ($lockAge < 15) {
            return false;
        }
    }
    @touch($spawnLock);
    @touch($trigger_file);

    // Clean up any stale lock or dead socket
    @unlink('/home/u796269890/domains/allgujaratvankarsamaj.com/keep_alive.lock');
    @unlink($project_dir . '/backend_daemon.lock');

    // Asynchronously launch supervisor in the background detached
    if (function_exists('shell_exec')) {
        $log_file = $project_dir . '/next-nest/backend/backend.log';
        @shell_exec("nohup bash " . escapeshellarg($project_dir . "/start_backend_daemon.sh") . " </dev/null >> " . escapeshellarg($log_file) . " 2>&1 &");
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
        
        // Wait up to 3.5 seconds (14 iterations * 250ms) for socket readiness
        for ($retry = 0; $retry < 14; $retry++) {
            usleep(250000); // 250ms
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
        for ($retry = 0; $retry < 14; $retry++) {
            usleep(250000); // 250ms
            if (file_exists($socket_file)) {
                usleep(200000); // 200ms grace for socket bind
                break;
            }
        }
    }
    
    $hasSocket = file_exists($socket_file);
    if (!$hasSocket) {
        $tcpTest = null;
        for ($retry = 0; $retry < 8; $retry++) {
            if (file_exists($socket_file)) {
                $hasSocket = true;
                break;
            }
            $tcpTest = @stream_socket_client('tcp://127.0.0.1:3000', $errno, $errstr, 0.4);
            if ($tcpTest) {
                fclose($tcpTest);
                break;
            }
            usleep(250000);
        }
        if (!$hasSocket && !$tcpTest) {
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
    
    // Automatic Seamless Failover: If Unix Socket failed, immediately retry over TCP port 3000
    if ($execResult === false && $hasSocket) {
        $ch2 = curl_init();
        curl_setopt($ch2, CURLOPT_URL, 'http://127.0.0.1:3000' . $uri);
        curl_setopt($ch2, CURLOPT_CUSTOMREQUEST, $method);
        curl_setopt($ch2, CURLOPT_CONNECTTIMEOUT, 2);
        curl_setopt($ch2, CURLOPT_TIMEOUT, TRANSFER_TIMEOUT_SECS);
        curl_setopt($ch2, CURLOPT_FOLLOWLOCATION, false);
        curl_setopt($ch2, CURLOPT_HTTPHEADER, $forwardHeaders);
        if (in_array($method, ['POST', 'PUT', 'PATCH'], true) || strlen($body) > 0) {
            curl_setopt($ch2, CURLOPT_POSTFIELDS, $body);
        }
        $capturedHeaders = [];
        $finalStatusCode = 200;
        curl_setopt($ch2, CURLOPT_HEADERFUNCTION, function($curlHandle, $headerLine) use (&$capturedHeaders, &$finalStatusCode) {
            $len = strlen($headerLine);
            $trimmed = trim($headerLine);
            if (empty($trimmed)) return $len;
            if (preg_match('/^HTTP\/\d\.\d\s+(\d+)/i', $trimmed, $matches)) {
                $status = (int)$matches[1];
                if ($status !== 100) $finalStatusCode = $status;
                return $len;
            }
            $colonPos = strpos($trimmed, ':');
            if ($colonPos !== false) {
                $hdrName = strtolower(substr($trimmed, 0, $colonPos));
                if (in_array($hdrName, ['transfer-encoding', 'connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization', 'te', 'trailers', 'upgrade'], true)) return $len;
                if (strpos($hdrName, 'access-control-') === 0) return $len;
                $capturedHeaders[] = $trimmed;
            }
            return $len;
        });
        $responseBody = '';
        $responseSize = 0;
        $responseOversized = false;
        curl_setopt($ch2, CURLOPT_WRITEFUNCTION, function($curlHandle, $chunk) use (&$responseBody, &$responseSize, &$responseOversized) {
            $chunkLen = strlen($chunk);
            $responseSize += $chunkLen;
            if ($responseSize > MAX_RESPONSE_BYTES) {
                $responseOversized = true;
                return 0;
            }
            $responseBody .= $chunk;
            return $chunkLen;
        });
        $execResult = curl_exec($ch2);
        $curlErrno  = curl_errno($ch2);
        $curlError  = curl_error($ch2);
        curl_close($ch2);
    }
    
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

        // Resilience loop: wait and retry up to 2 times (500ms delay) before failing
        for ($r = 0; $r < 2; $r++) {
            usleep(500000); // 500ms
            $hasSockNow = file_exists($socket_file);
            $retryUrl = $hasSockNow ? ('http://localhost' . $uri) : ('http://127.0.0.1:3000' . $uri);
            $chRetry = curl_init();
            if ($hasSockNow) {
                curl_setopt($chRetry, CURLOPT_UNIX_SOCKET_PATH, $socket_file);
            }
            curl_setopt($chRetry, CURLOPT_URL, $retryUrl);
            curl_setopt($chRetry, CURLOPT_CUSTOMREQUEST, $method);
            curl_setopt($chRetry, CURLOPT_CONNECTTIMEOUT, 2);
            curl_setopt($chRetry, CURLOPT_TIMEOUT, TRANSFER_TIMEOUT_SECS);
            curl_setopt($chRetry, CURLOPT_FOLLOWLOCATION, false);
            curl_setopt($chRetry, CURLOPT_HTTPHEADER, $forwardHeaders);
            if (in_array($method, ['POST', 'PUT', 'PATCH'], true) || strlen($body) > 0) {
                curl_setopt($chRetry, CURLOPT_POSTFIELDS, $body);
            }
            $capturedHeaders = [];
            $finalStatusCode = 200;
            curl_setopt($chRetry, CURLOPT_HEADERFUNCTION, function($curlHandle, $headerLine) use (&$capturedHeaders, &$finalStatusCode) {
                $len = strlen($headerLine);
                $trimmed = trim($headerLine);
                if (empty($trimmed)) return $len;
                if (preg_match('/^HTTP\/\d\.\d\s+(\d+)/i', $trimmed, $matches)) {
                    $status = (int)$matches[1];
                    if ($status !== 100) $finalStatusCode = $status;
                    return $len;
                }
                $colonPos = strpos($trimmed, ':');
                if ($colonPos !== false) {
                    $hdrName = strtolower(substr($trimmed, 0, $colonPos));
                    if (in_array($hdrName, ['transfer-encoding', 'connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization', 'te', 'trailers', 'upgrade'], true)) return $len;
                    if (strpos($hdrName, 'access-control-') === 0) return $len;
                    $capturedHeaders[] = $trimmed;
                }
                return $len;
            });
            $responseBody = '';
            $responseSize = 0;
            $responseOversized = false;
            curl_setopt($chRetry, CURLOPT_WRITEFUNCTION, function($curlHandle, $chunk) use (&$responseBody, &$responseSize, &$responseOversized) {
                $chunkLen = strlen($chunk);
                $responseSize += $chunkLen;
                if ($responseSize > MAX_RESPONSE_BYTES) {
                    $responseOversized = true;
                    return 0;
                }
                $responseBody .= $chunk;
                return $chunkLen;
            });
            $execResult = curl_exec($chRetry);
            $curlErrno  = curl_errno($chRetry);
            $curlError  = curl_error($chRetry);
            curl_close($chRetry);
            if ($execResult !== false) {
                break;
            }
        }
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
