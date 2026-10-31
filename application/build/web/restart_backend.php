<?php
// All Gujarat Vankar Samaj - Backend Health & Auto-Restart Controller
error_reporting(0);
ini_set('display_errors', '0');

header('Access-Control-Allow-Origin: https://allgujaratvankarsamaj.com');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Authorization, Content-Type, X-Admin-Key, X-Requested-With, X-Admin-Action');

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$socket_file = '/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock';
$socket_stream = 'unix://' . $socket_file;
$backend_dir = '/home/u796269890/domains/allgujaratvankarsamaj.com/project_source/next-nest/backend';
$project_dir = '/home/u796269890/domains/allgujaratvankarsamaj.com/project_source';
$main_script = $backend_dir . '/dist/main.js';
$log_file = $backend_dir . '/backend.log';
$trigger_file = '/home/u796269890/domains/allgujaratvankarsamaj.com/restart_trigger.txt';
$audit_file = $backend_dir . '/maintenance_audit.log';

$action = strtolower(trim($_GET['action'] ?? ($_POST['action'] ?? 'status')));
$format = $_GET['format'] ?? (isset($_SERVER['HTTP_ACCEPT']) && strpos($_SERVER['HTTP_ACCEPT'], 'application/json') !== false ? 'json' : 'html');
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

function check_socket($socket_stream, $timeout = 2) {
    $errno = 0;
    $errstr = '';
    $fp = @stream_socket_client($socket_stream, $errno, $errstr, $timeout);
    $type = 'unix';
    if (!$fp) {
        $fp = @stream_socket_client('tcp://127.0.0.1:3000', $errno, $errstr, $timeout);
        $type = 'tcp';
    }
    if (!$fp) {
        return ['connected' => false, 'error' => "$errstr ($errno)"];
    }
    
    // CRITICAL: 2-second stream read timeout to prevent probe hanging
    stream_set_timeout($fp, 2);
    
    // Test HTTP zero-DB liveness probe
    $req = "GET /api/v1/health/liveness HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n";
    @fwrite($fp, $req);
    $response = '';
    $timedOut = false;
    while (!feof($fp)) {
        $chunk = fread($fp, 4096);
        if ($chunk === false) {
            break;
        }
        $meta = stream_get_meta_data($fp);
        if (!empty($meta['timed_out'])) {
            $timedOut = true;
            break;
        }
        $response .= $chunk;
    }
    fclose($fp);
    
    if ($timedOut) {
        return [
            'connected' => true,
            'channel' => $type,
            'http_status' => 504,
            'error' => 'Liveness probe timed out after 2 seconds',
            'body' => ''
        ];
    }
    
    $parts = explode("\r\n\r\n", $response, 2);
    $status = 0;
    if (isset($parts[0]) && preg_match('/^HTTP\/\d\.\d\s+(\d+)/', $parts[0], $m)) {
        $status = (int)$m[1];
    }
    return [
        'connected' => true,
        'channel' => $type,
        'http_status' => $status,
        'body' => isset($parts[1]) ? trim($parts[1]) : ''
    ];
}

function verify_admin_authorization($project_dir, $requireHeaderOnly = false) {
    $env_file = $project_dir . '/.env.production';
    if (!file_exists($env_file)) {
        $env_file = $project_dir . '/next-nest/backend/.env';
    }
    
    // Fail-Closed: Return unauthorized immediately if configuration file is absent
    if (!file_exists($env_file)) {
        return ['authorized' => false, 'error' => 'Security configuration unavailable (fail-closed)'];
    }

    $jwtSecret = '';
    $adminRestartKey = '';
    $jwtIssuer = '';
    $jwtAudience = '';
    
    $lines = @file($env_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
    foreach ($lines as $line) {
        $line = trim($line);
        if (strpos($line, '#') === 0) continue;
        if (strpos($line, '=') !== false) {
            list($k, $v) = explode('=', $line, 2);
            $k = trim($k);
            $v = trim(trim($v), '"\'');
            if ($k === 'JWT_SECRET') $jwtSecret = $v;
            if ($k === 'ADMIN_RESTART_KEY') $adminRestartKey = $v;
            if ($k === 'JWT_ISSUER') $jwtIssuer = $v;
            if ($k === 'JWT_AUDIENCE') $jwtAudience = $v;
        }
    }

    // Fail-Closed: Secret must be non-empty and at least 16 bytes
    if (empty($jwtSecret) || strlen($jwtSecret) < 16) {
        return ['authorized' => false, 'error' => 'JWT secret is not securely configured (fail-closed)'];
    }

    // 1. Check optional static admin key strictly via HTTP header (never from query parameters)
    $reqKey = $_SERVER['HTTP_X_ADMIN_KEY'] ?? '';
    if (!empty($adminRestartKey) && strlen($adminRestartKey) >= 16 && !empty($reqKey) && hash_equals($adminRestartKey, $reqKey)) {
        return [
            'authorized' => true,
            'user' => 'admin_key_holder',
            'role' => 'SUPER_ADMIN',
            'auth_method' => 'static_header'
        ];
    }

    // 2. Extract JWT token: For mutating actions, strictly enforce Authorization header (no ambient cookies)
    $token = '';
    $tokenSource = '';
    $authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? ($_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '');
    if (preg_match('/Bearer\s+(\S+)/i', $authHeader, $m)) {
        $token = $m[1];
        $tokenSource = 'bearer_header';
    } elseif (!$requireHeaderOnly) {
        // Read-only maintenance diagnostic inspection may optionally read cookie
        if (!empty($_COOKIE['admin_token'])) {
            $token = $_COOKIE['admin_token'];
            $tokenSource = 'cookie';
        } elseif (!empty($_COOKIE['token'])) {
            $token = $_COOKIE['token'];
            $tokenSource = 'cookie';
        } elseif (!empty($_COOKIE['accessToken'])) {
            $token = $_COOKIE['accessToken'];
            $tokenSource = 'cookie';
        }
    }

    if (empty($token)) {
        return ['authorized' => false, 'error' => 'Missing administrator Authorization: Bearer header'];
    }

    // 3. Verify HS256 JWT structure & claims
    $parts = explode('.', $token);
    if (count($parts) !== 3) {
        return ['authorized' => false, 'error' => 'Malformed JWT structure'];
    }
    list($header64, $payload64, $sig64) = $parts;

    // Strict algorithm validation
    $headerJson = base64_decode(strtr($header64, '-_', '+/'));
    $header = json_decode($headerJson, true);
    if (!is_array($header) || empty($header['alg']) || $header['alg'] !== 'HS256') {
        return ['authorized' => false, 'error' => 'Invalid JWT algorithm: Only HS256 is accepted'];
    }

    // Cryptographic signature check
    $sigExpected = hash_hmac('sha256', "$header64.$payload64", $jwtSecret, true);
    $sigProvided = base64_decode(strtr($sig64, '-_', '+/'));
    if (!hash_equals($sigExpected, $sigProvided)) {
        return ['authorized' => false, 'error' => 'Invalid JWT cryptographic signature'];
    }

    $payloadJson = base64_decode(strtr($payload64, '-_', '+/'));
    $payload = json_decode($payloadJson, true);
    if (!is_array($payload)) {
        return ['authorized' => false, 'error' => 'Invalid JWT payload'];
    }

    $now = time();
    // Verify exp claim
    if (!isset($payload['exp']) || !is_numeric($payload['exp']) || $payload['exp'] < $now) {
        return ['authorized' => false, 'error' => 'Administrator token expired'];
    }

    // Verify nbf claim if present
    if (isset($payload['nbf']) && is_numeric($payload['nbf']) && $payload['nbf'] > ($now + 60)) {
        return ['authorized' => false, 'error' => 'Administrator token not active yet'];
    }

    // Verify iat claim if present
    if (isset($payload['iat']) && is_numeric($payload['iat']) && $payload['iat'] > ($now + 300)) {
        return ['authorized' => false, 'error' => 'Administrator token issued in future'];
    }

    // Verify iss if configured (only if present in payload, since NestJS tokens do not emit iss by default)
    if (isset($payload['iss']) && !empty($jwtIssuer) && $payload['iss'] !== $jwtIssuer) {
        return ['authorized' => false, 'error' => 'Invalid token issuer (iss)'];
    }

    // Verify aud if configured (only if present in payload, since NestJS tokens do not emit aud by default)
    if (isset($payload['aud']) && !empty($jwtAudience) && $payload['aud'] !== $jwtAudience) {
        return ['authorized' => false, 'error' => 'Invalid token audience (aud)'];
    }

    // Strict role validation
    $role = isset($payload['role']) && is_string($payload['role']) ? strtoupper(trim($payload['role'])) : '';
    $allowedRoles = ['SUPER_ADMIN', 'ADMIN'];
    if (!in_array($role, $allowedRoles, true)) {
        return ['authorized' => false, 'error' => "Forbidden: Role '$role' is not an administrator"];
    }

    // Strict subject validation
    $sub = isset($payload['sub']) && is_string($payload['sub']) ? trim($payload['sub']) : '';
    if (empty($sub)) {
        return ['authorized' => false, 'error' => 'Invalid JWT: Missing subject claim'];
    }

    return [
        'authorized' => true,
        'user' => $payload['email'] ?? $sub,
        'role' => $role,
        'auth_method' => $tokenSource
    ];
}

function verify_csrf_protection($auth_info) {
    // If request used Bearer token or static admin key header, cross-origin web forms cannot forge it
    if (($auth_info['auth_method'] ?? '') === 'bearer_header' || ($auth_info['auth_method'] ?? '') === 'static_header') {
        return true;
    }

    // For cookie-based authentication, enforce anti-CSRF custom headers
    $hasCustomHeader = !empty($_SERVER['HTTP_X_REQUESTED_WITH']) || !empty($_SERVER['HTTP_X_ADMIN_ACTION']);
    if ($hasCustomHeader) {
        return true;
    }

    // Strict Origin / Referer validation against exact scheme, hostname, and port
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    $referer = $_SERVER['HTTP_REFERER'] ?? '';
    $targetUrl = !empty($origin) ? $origin : $referer;
    
    if (!empty($targetUrl)) {
        $parsed = parse_url($targetUrl);
        $scheme = strtolower($parsed['scheme'] ?? '');
        $host = strtolower($parsed['host'] ?? '');
        $port = $parsed['port'] ?? ($scheme === 'https' ? 443 : 80);
        
        $allowedOrigins = [
            'https://allgujaratvankarsamaj.com:443',
            'https://allgujaratvankarsamaj.com',
            'https://staging.allgujaratvankarsamaj.com:443',
            'https://staging.allgujaratvankarsamaj.com'
        ];
        
        $constructed = $scheme . '://' . $host . ($port !== 443 && $port !== 80 ? ":$port" : '');
        if (in_array($constructed, $allowedOrigins, true) || in_array($scheme . '://' . $host, $allowedOrigins, true)) {
            return true;
        }
    }

    return false;
}

function write_maintenance_audit_log($audit_file, $user, $role, $action, $details) {
    $timestamp = date('Y-m-d H:i:s T');
    $ip = $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';
    $entry = sprintf("[%s] USER: %s (%s) IP: %s ACTION: %s DETAILS: %s\n",
        $timestamp, $user, $role, $ip, $action, $details
    );
    @file_put_contents($audit_file, $entry, FILE_APPEND | LOCK_EX);
}

function terminate_verified_backend_processes($project_dir, $socket_file, &$actions) {
    $nodePidFile = $project_dir . '/backend_node.pid';
    $daemonPidFile = $project_dir . '/backend_daemon.pid';
    
    // 1. Terminate verified daemon supervisor if running
    if (file_exists($daemonPidFile)) {
        $dpid = trim(@file_get_contents($daemonPidFile) ?: '');
        if (ctype_digit($dpid)) {
            $cmd = @file_get_contents("/proc/$dpid/cmdline") ?: (function_exists('shell_exec') ? @shell_exec("ps -p $dpid -o args= 2>/dev/null") : '');
            if (strpos($cmd, 'start_backend_daemon') !== false) {
                if (function_exists('posix_kill')) {
                    @posix_kill((int)$dpid, 15); // SIGTERM
                } elseif (function_exists('shell_exec')) {
                    @shell_exec("kill -TERM $dpid 2>/dev/null");
                }
                $actions[] = "Sent SIGTERM to verified daemon supervisor (PID: $dpid)";
            }
        }
        @unlink($daemonPidFile);
    }
    
    // 2. Terminate verified backend Node.js process
    if (file_exists($nodePidFile)) {
        $npid = trim(@file_get_contents($nodePidFile) ?: '');
        if (ctype_digit($npid)) {
            $cmd = @file_get_contents("/proc/$npid/cmdline") ?: (function_exists('shell_exec') ? @shell_exec("ps -p $npid -o args= 2>/dev/null") : '');
            if (strpos($cmd, 'dist/main.js') !== false) {
                if (function_exists('posix_kill')) {
                    @posix_kill((int)$npid, 15); // SIGTERM
                    usleep(500000); // 500ms
                    if (@posix_kill((int)$npid, 0)) {
                        @posix_kill((int)$npid, 9); // SIGKILL
                    }
                } elseif (function_exists('shell_exec')) {
                    @shell_exec("kill -TERM $npid 2>/dev/null; sleep 1; kill -9 $npid 2>/dev/null");
                }
                $actions[] = "Terminated verified backend Node process (PID: $npid)";
            }
        }
        @unlink($nodePidFile);
    }
    
    // 3. Fallback: check if process is bound to the Unix socket
    if (file_exists($socket_file)) {
        if (function_exists('shell_exec')) {
            $sockPid = trim(@shell_exec("lsof -t " . escapeshellarg($socket_file) . " 2>/dev/null | head -n 1") ?: '');
            if (!ctype_digit($sockPid)) {
                $sockPid = trim(@shell_exec("fuser " . escapeshellarg($socket_file) . " 2>/dev/null | tr -d ' '") ?: '');
            }
            if (ctype_digit($sockPid)) {
                $cmd = @file_get_contents("/proc/$sockPid/cmdline") ?: @shell_exec("ps -p $sockPid -o args= 2>/dev/null");
                if (strpos($cmd, 'dist/main.js') !== false) {
                    @shell_exec("kill -TERM $sockPid 2>/dev/null; sleep 1; kill -9 $sockPid 2>/dev/null");
                    $actions[] = "Terminated verified process bound to socket (PID: $sockPid)";
                }
            }
        }
        @unlink($socket_file);
        $actions[] = "Removed socket file";
    }
}

function fix_database_genders_transactional($project_dir, &$results) {
    $env_file = $project_dir . '/.env.production';
    if (!file_exists($env_file)) {
        $env_file = $project_dir . '/next-nest/backend/.env';
    }
    if (!file_exists($env_file)) {
        $results['db_fix'] = 'No env file found at ' . $env_file;
        return;
    }
    $lines = file($env_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    $conf = [];
    foreach ($lines as $line) {
        $line = trim($line);
        if (strpos($line, '#') === 0) continue;
        if (strpos($line, '=') !== false) {
            list($k, $v) = explode('=', $line, 2);
            $conf[trim($k)] = trim(trim($v), '"\'');
        }
    }
    $host = $conf['DB_HOST'] ?? 'localhost';
    $user = $conf['DB_USER'] ?? '';
    $pass = $conf['DB_PASSWORD'] ?? '';
    $name = $conf['DB_NAME'] ?? '';
    if (empty($user) && !empty($conf['DATABASE_URL'])) {
        $p = parse_url($conf['DATABASE_URL']);
        $host = $p['host'] ?? 'localhost';
        $user = $p['user'] ?? '';
        $pass = $p['pass'] ?? '';
        $name = ltrim($p['path'] ?? '', '/');
    }
    if (empty($name)) {
        $results['db_fix'] = 'DB credentials missing';
        return;
    }

    $pdo = null;
    try {
        $pdo = new PDO("mysql:host=$host;dbname=$name;charset=utf8mb4", $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
        ]);
        
        // Transactional execution to guarantee atomicity
        $pdo->beginTransaction();

        $q1 = "UPDATE matrimonial_profiles 
               SET gender = 'FEMALE' 
               WHERE LOWER(first_name) LIKE '%ben%' 
                  OR LOWER(first_name) LIKE '%bahen%' 
                  OR first_name LIKE '%બેન%' 
                  OR first_name LIKE '%બહેન%'
                  OR LOWER(first_name) IN ('dipika', 'sakshi', 'pooja', 'priya', 'neha', 'dula', 'dulaben', 'heena', 'kinjal', 'payal', 'kiran', 'sheetal', 'rekha')";
        $s1 = $pdo->prepare($q1);
        $s1->execute();
        $c1 = $s1->rowCount();

        $q2 = "UPDATE users 
               SET gender = 'FEMALE' 
               WHERE id IN (SELECT user_id FROM matrimonial_profiles WHERE gender = 'FEMALE')";
        $s2 = $pdo->prepare($q2);
        $s2->execute();
        $c2 = $s2->rowCount();

        // Synchronize contact phones and mark verified for registered users
        $q3 = "UPDATE users 
               SET is_phone_verified = 1, is_email_verified = 1 
               WHERE (phone IS NOT NULL AND phone != '') OR (email IS NOT NULL AND email != '')";
        $s3 = $pdo->prepare($q3);
        $s3->execute();

        // Sync contact_email to matrimonial_profiles from users if null
        $q4 = "UPDATE matrimonial_profiles mp 
               JOIN users u ON mp.user_id = u.id 
               SET mp.contact_email = u.email 
               WHERE mp.contact_email IS NULL AND u.email IS NOT NULL";
        $s4 = $pdo->prepare($q4);
        $s4->execute();

        $pdo->commit();

        $results['db_fix'] = "Transactional update complete: $c1 candidate profiles and $c2 users set to FEMALE. Verification flags synchronized.";
        $results['actions_taken'][] = "Database Gender Fix: Updated $c1 profiles and $c2 users to FEMALE, synced verification flags.";
    } catch (Exception $e) {
        if ($pdo && $pdo->inTransaction()) {
            $pdo->rollBack();
        }
        $results['db_fix_error'] = 'Transaction rolled back: ' . $e->getMessage();
    }
}

// -------------------------------------------------------------
// Route Access Control & Authorization Enforcement
// -------------------------------------------------------------
$mutatingActions = [
    'restart',
    'start',
    'clean_restart',
    'kill_stale',
    'deploy',
    'fix_db_manual'
];

$sensitiveActions = [
    'restart',
    'start',
    'clean_restart',
    'kill_stale',
    'deploy',
    'install_pkg',
    'fix_db_manual',
    'fix_db',
    'tail_log',
    'check_verif',
    'check_user',
    'test_mail'
];

$callerAuth = null;
if (in_array($action, $sensitiveActions, true)) {
    // For mutating actions, require strictly HTTP Header (no cookies)
    $isMutating = in_array($action, $mutatingActions, true);
    $callerAuth = verify_admin_authorization($project_dir, $isMutating);
    
    if (!$callerAuth['authorized']) {
        http_response_code(403);
        if ($format === 'json') {
            header('Content-Type: application/json; charset=utf-8');
            echo json_encode([
                'statusCode' => 403,
                'message' => 'Forbidden: Administrator authentication required for action: ' . htmlspecialchars($action),
                'error' => $callerAuth['error'] ?? 'Unauthorized'
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
        } else {
            echo '<!DOCTYPE html><html><head><title>403 Forbidden</title></head><body style="font-family:sans-serif;background:#0f172a;color:#f87171;padding:40px;">' .
                 '<h1>403 Forbidden</h1><p>Administrative authentication required: ' . htmlspecialchars($callerAuth['error'] ?? 'Unauthorized') . '</p>' .
                 '<p>Please provide valid Bearer token or X-Admin-Key header.</p></body></html>';
        }
        exit;
    }

    // Enforce POST method and anti-CSRF check for mutating actions
    if ($isMutating) {
        if ($method !== 'POST') {
            http_response_code(405);
            header('Allow: POST');
            if ($format === 'json') {
                header('Content-Type: application/json; charset=utf-8');
                echo json_encode([
                    'statusCode' => 405,
                    'message' => 'Method Not Allowed: Action ' . htmlspecialchars($action) . ' must be requested via HTTP POST.'
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
            } else {
                echo '<!DOCTYPE html><html><body style="font-family:sans-serif;padding:40px;"><h1>405 Method Not Allowed</h1><p>Mutating actions must be executed via POST.</p></body></html>';
            }
            exit;
        }

        if (!verify_csrf_protection($callerAuth)) {
            http_response_code(403);
            if ($format === 'json') {
                header('Content-Type: application/json; charset=utf-8');
                echo json_encode([
                    'statusCode' => 403,
                    'message' => 'Forbidden: Cross-Site Request Forgery (CSRF) validation failed.'
                ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
            } else {
                echo '<!DOCTYPE html><html><body style="font-family:sans-serif;padding:40px;"><h1>403 Forbidden</h1><p>CSRF validation failed.</p></body></html>';
            }
            exit;
        }
    }
}

// Minimal public response structure (Zero sensitive diagnostic disclosure)
$probe = check_socket($socket_stream, 2);
$isHealthy = !empty($probe['connected']) && ($probe['http_status'] ?? 0) === 200;

if (!$callerAuth || empty($callerAuth['authorized'])) {
    if ($format === 'json') {
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode([
            'status' => $isHealthy ? 'UP' : 'DOWN',
            'timestamp' => date('c')
        ]);
        exit;
    } else {
        // Minimal public status HTML badge (zero internal leaks)
        ?>
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <title>Service Status | All Gujarat Vankar Samaj</title>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0b1120; color: #f1f5f9; padding: 24px; margin: 0; display: flex; align-items: center; justify-content: center; min-height: 80vh; }
            .card { max-width: 450px; width: 100%; background: #1e293b; border-radius: 12px; padding: 32px; box-shadow: 0 10px 25px rgba(0,0,0,0.5); text-align: center; }
            .badge { display: inline-block; padding: 6px 16px; border-radius: 9999px; font-weight: bold; font-size: 15px; margin-top: 10px; }
            .badge-success { background: #10b981; color: #022c22; }
            .badge-error { background: #ef4444; color: #450a0a; }
          </style>
        </head>
        <body>
          <div class="card">
            <h2>All Gujarat Vankar Samaj</h2>
            <p>Platform Core System Status:</p>
            <?php if ($isHealthy): ?>
              <span class="badge badge-success">SYSTEM OPERATIONAL</span>
            <?php else: ?>
              <span class="badge badge-error">SYSTEM DEGRADED</span>
            <?php endif; ?>
            <p style="color: #94a3b8; font-size: 13px; margin-top: 20px;">Last checked: <?= htmlspecialchars(date('Y-m-d H:i:s T')) ?></p>
          </div>
        </body>
        </html>
        <?php
        exit;
    }
}

// -------------------------------------------------------------
// Authenticated Administrator View & Action Execution
// -------------------------------------------------------------
$results = [
    'status' => $isHealthy ? 'UP' : 'DOWN',
    'timestamp' => date('Y-m-d H:i:s T'),
    'ready' => $isHealthy,
    'socket_file_exists' => file_exists($socket_file),
    'probe' => $probe,
    'authenticated_admin' => $callerAuth['user'],
    'authenticated_role' => $callerAuth['role'],
    'php_user' => get_current_user(),
    'disabled_functions' => ini_get('disable_functions') ?: 'none',
    'actions_taken' => [],
];

if (file_exists($socket_file)) {
    $results['socket_perms'] = substr(sprintf('%o', fileperms($socket_file)), -4);
}

if ($action === 'deploy') {
    if (function_exists('shell_exec')) {
        $cmd = "cd " . escapeshellarg($project_dir) . " 2>&1; " .
               "git checkout -- keep_backend_alive.sh start_backend_daemon.sh 2>&1; " .
               "git pull origin main 2>&1; " .
               "cp -rf next-nest/frontend/out/_next /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>&1; " .
               "cp -rf next-nest/frontend/out/admin /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>&1; " .
               "cp -rf next-nest/frontend/out/login /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>&1; " .
               "cp -rf next-nest/frontend/out/profile /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>&1; " .
               "cp -rf next-nest/frontend/out/register /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>&1; " .
               "cp -rf next-nest/frontend/out/search /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>&1; " .
               "cp -rf next-nest/frontend/out/matrimony /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>&1; " .
               "cp -rf next-nest/frontend/out/services /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>&1; " .
               "cp -rf next-nest/frontend/out/verified-profile /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>&1; " .
               "cp -rf application/build/web/* /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>&1; " .
               "echo 'DEPLOY_COMPLETE'";
        $deployLog = shell_exec($cmd);
        $results['deploy_log'] = $deployLog;
        terminate_verified_backend_processes($project_dir, $socket_file, $results['actions_taken']);
        $results['actions_taken'][] = 'Pulled origin main, copied web assets and static routes, and gracefully signaled backend';
        write_maintenance_audit_log($audit_file, $callerAuth['user'], $callerAuth['role'], 'deploy', 'Deployed git assets and restarted backend');
    }
    @touch($trigger_file);
}

if ($action === 'clean_restart' || $action === 'kill_stale') {
    terminate_verified_backend_processes($project_dir, $socket_file, $results['actions_taken']);
    if (function_exists('shell_exec')) {
        $cleanLog = @shell_exec("nohup bash " . escapeshellarg($project_dir . "/start_backend_daemon.sh") . " </dev/null > /dev/null 2>&1 &");
        $results['clean_log'] = $cleanLog;
        $results['actions_taken'][] = 'Launched start_backend_daemon.sh via nohup (fully detached)';
        write_maintenance_audit_log($audit_file, $callerAuth['user'], $callerAuth['role'], $action, 'Terminated stale processes and launched start_backend_daemon.sh');
    }
}

if ($action === 'install_pkg') {
    if (function_exists('shell_exec')) {
        $installLog = shell_exec("cd " . escapeshellarg($backend_dir) . " 2>&1; export PATH='/home/u796269890/.nvm/versions/node/v20.20.2/bin:/usr/local/bin:/usr/bin:/bin:$HOME/bin:$PATH'; npm install --no-audit --no-fund --omit=dev @google/generative-ai 2>&1");
        $results['install_log'] = $installLog;
        $results['actions_taken'][] = 'Executed npm install @google/generative-ai';
        write_maintenance_audit_log($audit_file, $callerAuth['user'], $callerAuth['role'], 'install_pkg', 'Installed npm package @google/generative-ai');
    }
}

// Explicit manual database repair: Requires POST, authenticated admin, and confirm=yes
if ($action === 'fix_db_manual') {
    $confirm = $_POST['confirm'] ?? '';
    if ($confirm === 'yes') {
        fix_database_genders_transactional($project_dir, $results);
        write_maintenance_audit_log($audit_file, $callerAuth['user'], $callerAuth['role'], 'fix_db_manual', $results['db_fix'] ?? 'Executed transactional gender fix');
    } else {
        $results['db_fix'] = 'Safety check: Manual DB repair requires confirm=yes body parameter.';
    }
} elseif ($action === 'fix_db') {
    $results['db_fix'] = 'Deprecated action: Use POST action=fix_db_manual with confirm=yes and admin authorization.';
}

if ($action === 'check_verif') {
    $env_file = $project_dir . '/.env.production';
    if (!file_exists($env_file)) $env_file = $project_dir . '/next-nest/backend/.env';
    $lines = @file($env_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
    $conf = [];
    foreach ($lines as $line) {
        if (strpos($line, '=') !== false) {
            list($k, $v) = explode('=', $line, 2);
            $conf[trim($k)] = trim(trim($v), '"\'');
        }
    }
    $host = $conf['DB_HOST'] ?? 'localhost';
    $user = $conf['DB_USER'] ?? '';
    $pass = $conf['DB_PASSWORD'] ?? '';
    $name = $conf['DB_NAME'] ?? '';
    if (empty($user) && !empty($conf['DATABASE_URL'])) {
        $p = parse_url($conf['DATABASE_URL']);
        $host = $p['host'] ?? 'localhost';
        $user = $p['user'] ?? '';
        $pass = $p['pass'] ?? '';
        $name = ltrim($p['path'] ?? '', '/');
    }
    try {
        $pdo = new PDO("mysql:host=$host;dbname=$name;charset=utf8mb4", $user, $pass);
        $stmt = $pdo->query("SELECT vr.id, vr.document_type, vr.document_url, vr.document_back_url, vr.status, mp.first_name, mp.last_name, mp.photos FROM verification_requests vr LEFT JOIN matrimonial_profiles mp ON vr.profile_id = mp.id ORDER BY vr.created_at DESC LIMIT 15");
        $results['verifications'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        $results['verif_err'] = $e->getMessage();
    }
}

if ($action === 'check_user') {
    $env_file = $project_dir . '/.env.production';
    if (!file_exists($env_file)) $env_file = $project_dir . '/next-nest/backend/.env';
    $lines = @file($env_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [];
    $conf = [];
    foreach ($lines as $line) {
        if (strpos($line, '=') !== false) {
            list($k, $v) = explode('=', $line, 2);
            $conf[trim($k)] = trim(trim($v), '"\'');
        }
    }
    $host = $conf['DB_HOST'] ?? 'localhost';
    $user = $conf['DB_USER'] ?? '';
    $pass = $conf['DB_PASSWORD'] ?? '';
    $name = $conf['DB_NAME'] ?? '';
    if (empty($user) && !empty($conf['DATABASE_URL'])) {
        $p = parse_url($conf['DATABASE_URL']);
        $host = $p['host'] ?? 'localhost';
        $user = $p['user'] ?? '';
        $pass = $p['pass'] ?? '';
        $name = ltrim($p['path'] ?? '', '/');
    }
    $results['smtp_status'] = [
        'has_host' => !empty($conf['SMTP_HOST']),
        'host' => $conf['SMTP_HOST'] ?? null,
        'has_user' => !empty($conf['SMTP_USER']),
        'user' => $conf['SMTP_USER'] ?? null,
        'has_pass' => !empty($conf['SMTP_PASS']),
        'port' => $conf['SMTP_PORT'] ?? null,
    ];
    try {
        $pdo = new PDO("mysql:host=$host;dbname=$name;charset=utf8mb4", $user, $pass);
        $search = $_GET['search'] ?? '9234567890';
        $st = $pdo->prepare("SELECT id, email, phone, name, role, status, is_email_verified, is_phone_verified, created_at FROM users WHERE phone LIKE :s1 OR email LIKE :s2 LIMIT 10");
        $st->execute([':s1' => "%$search%", ':s2' => "%$search%"]);
        $results['matched_users'] = $st->fetchAll(PDO::FETCH_ASSOC);

        $st2 = $pdo->query("SELECT * FROM otp_sessions ORDER BY created_at DESC LIMIT 10");
        $results['recent_otp_sessions'] = $st2->fetchAll(PDO::FETCH_ASSOC);

        $st3 = $pdo->query("SELECT * FROM otp_logs ORDER BY created_at DESC LIMIT 10");
        $results['recent_otp_logs'] = $st3->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        $results['db_error'] = $e->getMessage();
    }
}

if ($action === 'test_mail') {
    $to = $_GET['to'] ?? 'parvindarpanjabi18@gmail.com';
    $subject = "All Gujarat Vankar Samaj - Verification Code Test";
    $otp = rand(100000, 999999);
    $headers = "From: noreply@allgujaratvankarsamaj.com\r\n" .
               "Reply-To: noreply@allgujaratvankarsamaj.com\r\n" .
               "X-Mailer: PHP/" . phpversion() . "\r\n" .
               "Content-Type: text/html; charset=UTF-8\r\n";
    $body = "<h2>Your Verification Code is: <b>$otp</b></h2><p>Valid for 10 minutes.</p>";
    $mailSent = @mail($to, $subject, $body, $headers);
    $results['test_mail'] = [
        'to' => $to,
        'otp' => $otp,
        'sent' => $mailSent,
        'last_error' => error_get_last()
    ];
}

if ($action === 'restart' || $action === 'start') {
    // 1. Touch trigger file for the background watchdog
    @touch($trigger_file);
    $results['actions_taken'][] = 'Created restart trigger file for background watchdog';
    write_maintenance_audit_log($audit_file, $callerAuth['user'], $callerAuth['role'], $action, 'Requested backend restart via watchdog trigger');

    // 2. Remove stale socket if connection is refused
    if (file_exists($socket_file)) {
        $t_fp = @stream_socket_client($socket_stream, $t_err, $t_msg, 1);
        if (!$t_fp) {
            @unlink($socket_file);
            $results['actions_taken'][] = 'Removed stale unix socket file';
        } else {
            @fclose($t_fp);
        }
    }

    // 3. If CLI execution is allowed, invoke watchdog directly (strictly non-blocking with stdin closed)
    if (function_exists('shell_exec')) {
        @shell_exec("bash " . escapeshellarg($project_dir . "/keep_backend_alive.sh") . " --force </dev/null > /dev/null 2>&1 &");
        $results['actions_taken'][] = 'Triggered keep_backend_alive.sh via shell_exec (non-blocking)';
    } elseif (function_exists('exec')) {
        @exec("bash " . escapeshellarg($project_dir . "/keep_backend_alive.sh") . " --force </dev/null > /dev/null 2>&1 &");
        $results['actions_taken'][] = 'Triggered keep_backend_alive.sh via exec (non-blocking)';
    }

    // 4. Poll for socket ready with zero-DB liveness probe (up to 4 seconds)
    $ready = false;
    for ($i = 0; $i < 16; $i++) {
        usleep(250000); // 250ms
        $probe = check_socket($socket_stream, 1);
        if (!empty($probe['connected']) && ($probe['http_status'] ?? 0) === 200) {
            $ready = true;
            $results['probe'] = $probe;
            break;
        }
    }
    $results['ready'] = $ready;
    $results['status'] = $ready ? 'UP' : 'DOWN';
}

if ($action === 'tail_log') {
    header('Content-Type: text/plain; charset=utf-8');
    if (file_exists($log_file)) {
        $lines = @file($log_file);
        $num = isset($_GET['lines']) ? min(500, max(25, intval($_GET['lines']))) : 150;
        echo implode('', array_slice($lines, -$num));
    } else {
        echo "Log file not found at " . $log_file;
    }
    exit;
}

// Running node processes (Exposed only if authenticated administrator)
if (function_exists('shell_exec')) {
    $pids = trim(@shell_exec('pgrep -fa "node" 2>/dev/null') ?? '');
    $results['node_processes'] = $pids ?: 'None running';
    if (file_exists($log_file)) {
        $lines = @file($log_file);
        if ($lines) {
            $num = isset($_GET['lines']) ? min(500, max(25, intval($_GET['lines']))) : 100;
            $results['recent_logs'] = array_slice($lines, -$num);
        }
    }
}

if ($format === 'json') {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($results, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

// HTML Dashboard output for authenticated administrators
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Backend Server Admin Dashboard | All Gujarat Vankar Samaj</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0b1120; color: #f1f5f9; padding: 24px; margin: 0; }
    .card { max-width: 800px; margin: 0 auto; background: #1e293b; border-radius: 12px; padding: 28px; box-shadow: 0 10px 25px rgba(0,0,0,0.5); }
    h1 { margin-top: 0; font-size: 24px; display: flex; align-items: center; gap: 12px; }
    .badge { display: inline-block; padding: 6px 14px; border-radius: 9999px; font-weight: bold; font-size: 14px; }
    .badge-success { background: #10b981; color: #022c22; }
    .badge-error { background: #ef4444; color: #450a0a; }
    .btn { display: inline-block; background: #3b82f6; color: white; padding: 10px 20px; border-radius: 8px; text-decoration: none; font-weight: 600; transition: background 0.2s; margin-right: 10px; margin-top: 15px; border: none; cursor: pointer; }
    .btn:hover { background: #2563eb; }
    .btn-green { background: #10b981; }
    .btn-green:hover { background: #059669; }
    pre { background: #0f172a; padding: 14px; border-radius: 8px; overflow-x: auto; color: #38bdf8; font-size: 13px; max-height: 250px; }
    table { width: 100%; border-collapse: collapse; margin-top: 16px; margin-bottom: 20px; }
    td, th { padding: 8px 12px; border-bottom: 1px solid #334155; text-align: left; }
    th { color: #94a3b8; font-size: 13px; text-transform: uppercase; }
  </style>
</head>
<body>
  <div class="card">
    <h1>
      Backend Server Administration
      <?php if (!empty($results['ready'])): ?>
        <span class="badge badge-success">ONLINE</span>
      <?php else: ?>
        <span class="badge badge-error">OFFLINE</span>
      <?php endif; ?>
    </h1>

    <p>Last checked: <strong><?= htmlspecialchars($results['timestamp']) ?></strong></p>

    <table>
      <tr>
        <th>Check</th>
        <th>Result</th>
      </tr>
      <tr>
        <td>Unix Socket File</td>
        <td><?= $results['socket_file_exists'] ? '✅ Present (' . htmlspecialchars($results['socket_perms'] ?? '') . ')' : '❌ Not Found' ?></td>
      </tr>
      <tr>
        <td>Socket Liveness Probe (/api/v1/health/liveness)</td>
        <td><?= !empty($results['ready']) ? '✅ Responsive (HTTP ' . ($results['probe']['http_status'] ?? 200) . ' OK)' : '❌ Unreachable / Timed Out' ?></td>
      </tr>
      <tr>
        <td>Authenticated Administrator</td>
        <td><code><?= htmlspecialchars($callerAuth['user'] . ' (' . $callerAuth['role'] . ')') ?></code></td>
      </tr>
      <tr>
        <td>Active Node Processes</td>
        <td><code><?= htmlspecialchars($results['node_processes'] ?? 'None') ?></code></td>
      </tr>
    </table>

    <div style="display: flex; gap: 10px; flex-wrap: wrap; margin-top: 15px;">
      <a href="?action=status" class="btn">🔍 Refresh Status</a>
      <a href="/" class="btn" style="background: #475569;">🏠 Go to App</a>
      <form method="POST" action="?action=restart" style="display: inline;">
        <input type="hidden" name="action" value="restart">
        <input type="hidden" name="X-Admin-Action" value="1">
        <button type="submit" class="btn btn-green">🔄 Restart Backend (POST)</button>
      </form>
      <a href="?action=tail_log" class="btn" style="background: #0284c7;">📜 View Logs</a>
    </div>

    <?php if (!empty($results['recent_logs'])): ?>
      <h3>Recent Backend Logs</h3>
      <pre><?= htmlspecialchars(implode('', $results['recent_logs'])) ?></pre>
    <?php endif; ?>
  </div>
</body>
</html>
