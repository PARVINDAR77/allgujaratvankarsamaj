<?php
// Enhanced Self-Healing API Proxy to NestJS Backend on Hostinger Unix Domain Socket
error_reporting(0);
ini_set('display_errors', 0);

$socket_file = '/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock';
$socket_path = 'unix://' . $socket_file;
$backend_dir = '/home/u796269890/domains/allgujaratvankarsamaj.com/project_source/next-nest/backend';
$main_script = $backend_dir . '/dist/main.js';
$log_file = $backend_dir . '/backend.log';
$lock_file = sys_get_temp_dir() . '/vankar_backend_spawn.lock';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$uri = $_SERVER['REQUEST_URI'] ?? '/api/v1';

// Dynamic CORS handling compatible with withCredentials=true
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$reqHeaders = $_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS'] ?? 'Authorization, Content-Type, Accept, Origin, X-Requested-With, X-Request-ID, Cache-Control, Pragma';

if (!empty($origin)) {
    header("Access-Control-Allow-Origin: $origin");
    header("Access-Control-Allow-Credentials: true");
    header("Vary: Origin");
} else {
    header("Access-Control-Allow-Origin: *");
}

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

// 3. Connect to backend socket with self-healing auto-restart
function try_connect_socket($path, $timeout = 2) {
    $errno = 0;
    $errstr = '';
    $fp = @stream_socket_client($path, $errno, $errstr, $timeout);
    return [$fp, $errno, $errstr];
}

list($fp, $errno, $errstr) = try_connect_socket($socket_path, 2);
if (!$fp) {
    // Fallback: check if backend is listening on localhost TCP port 3000
    list($tcp_fp, $tcp_errno, $tcp_errstr) = try_connect_socket('tcp://127.0.0.1:3000', 1);
    if ($tcp_fp) {
        $fp = $tcp_fp;
    }
}

// If socket connection failed, attempt automatic self-healing restart
if (!$fp) {
    $can_restart = true;
    if (file_exists($lock_file)) {
        // Prevent race conditions: check if another request attempted restart in the last 8 seconds
        if ((time() - filemtime($lock_file)) < 8) {
            $can_restart = false;
        }
    }

    if ($can_restart) {
        @touch($lock_file);
        
        // Signal watchdog to restart via trigger file
        $trigger_file = '/home/u796269890/domains/allgujaratvankarsamaj.com/restart_trigger.txt';
        @touch($trigger_file);

        // Try direct script invocation via keep_backend_alive.sh
        $watchdog_script = '/home/u796269890/domains/allgujaratvankarsamaj.com/project_source/keep_backend_alive.sh';
        if (function_exists('shell_exec') || function_exists('exec')) {
            $start_cmd = "/bin/bash " . escapeshellarg($watchdog_script) . " >> " . escapeshellarg($log_file) . " 2>&1 &";
            if (function_exists('shell_exec')) {
                @shell_exec($start_cmd);
            } else {
                @exec($start_cmd);
            }
        }

        // Poll for socket readiness up to 3.5 seconds
        for ($i = 0; $i < 14; $i++) {
            usleep(250000); // 250ms
            list($retry_fp, $retry_errno, $retry_errstr) = try_connect_socket($socket_path, 1);
            if (!$retry_fp) {
                list($retry_fp, $retry_errno, $retry_errstr) = try_connect_socket('tcp://127.0.0.1:3000', 1);
            }
            if ($retry_fp) {
                $fp = $retry_fp;
                break;
            }
        }
    }

    // Final fallback check
    if (!$fp) {
        list($tcp_fp, $tcp_errno, $tcp_errstr) = try_connect_socket('tcp://127.0.0.1:3000', 1);
        if ($tcp_fp) {
            $fp = $tcp_fp;
        }
    }
}

// If STILL unreachable after auto-restart attempt
if (!$fp) {
    http_response_code(502);
    header('Content-Type: application/json');
    echo json_encode([
        "statusCode" => 502,
        "message" => "Bad Gateway: Backend socket is unreachable ($errstr). Backend auto-recovery in progress.",
        "restartUrl" => "https://allgujaratvankarsamaj.com/restart_backend.php"
    ]);
    exit;
}

// 4. Build HTTP request to send over Unix socket
$headers = [];
foreach (getallheaders() as $name => $value) {
    $lowerName = strtolower($name);
    if ($lowerName !== 'host' && $lowerName !== 'connection' && $lowerName !== 'content-length') {
        $headers[] = "$name: $value";
    }
}
$headers[] = "Host: localhost";
$headers[] = "Connection: close";

$body = file_get_contents('php://input');
if ($body !== false && strlen($body) > 0) {
    $headers[] = "Content-Length: " . strlen($body);
}

$request = "$method $uri HTTP/1.1\r\n" . implode("\r\n", $headers) . "\r\n\r\n" . ($body !== false ? $body : '');

fwrite($fp, $request);

$response = '';
while (!feof($fp)) {
    $response .= fread($fp, 8192);
}
fclose($fp);

if (empty($response)) {
    http_response_code(502);
    header('Content-Type: application/json');
    echo json_encode(["statusCode" => 502, "message" => "Bad Gateway: Backend returned empty response"]);
    exit;
}

// 5. Parse response and send to client
$parts = explode("\r\n\r\n", $response, 2);
$header_text = $parts[0];
$body_text = isset($parts[1]) ? $parts[1] : '';

$header_lines = explode("\r\n", $header_text);
foreach ($header_lines as $line) {
    if (empty(trim($line))) continue;
    
    if (preg_match('/^HTTP\/\d\.\d\s+(\d+)/', $line, $matches)) {
        http_response_code((int)$matches[1]);
    } else {
        $trimLine = trim($line);
        if (stripos($trimLine, 'Transfer-Encoding:') === 0) continue;
        if (stripos($trimLine, 'Access-Control-') === 0) continue;
        header($line, true);
    }
}

echo $body_text;
?>
