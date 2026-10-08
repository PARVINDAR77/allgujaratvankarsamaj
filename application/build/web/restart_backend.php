<?php
// All Gujarat Vankar Samaj - Backend Health & Auto-Restart Controller
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');

$socket_file = '/home/u796269890/domains/allgujaratvankarsamaj.com/backend.sock';
$socket_stream = 'unix://' . $socket_file;
$backend_dir = '/home/u796269890/domains/allgujaratvankarsamaj.com/project_source/next-nest/backend';
$project_dir = '/home/u796269890/domains/allgujaratvankarsamaj.com/project_source';
$main_script = $backend_dir . '/dist/main.js';
$log_file = $backend_dir . '/backend.log';
$trigger_file = '/home/u796269890/domains/allgujaratvankarsamaj.com/restart_trigger.txt';

$action = $_GET['action'] ?? 'status'; // default to status check (safe, does not kill running socket)
$format = $_GET['format'] ?? (isset($_SERVER['HTTP_ACCEPT']) && strpos($_SERVER['HTTP_ACCEPT'], 'application/json') !== false ? 'json' : 'html');

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
    
    // Test HTTP health probe
    $req = "GET /api/v1/health HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n";
    fwrite($fp, $req);
    $response = '';
    while (!feof($fp)) {
        $response .= fread($fp, 4096);
    }
    fclose($fp);
    
    $parts = explode("\r\n\r\n", $response, 2);
    $status = 0;
    if (preg_match('/^HTTP\/\d\.\d\s+(\d+)/', $parts[0], $m)) {
        $status = (int)$m[1];
    }
    return [
        'connected' => true,
        'channel' => $type,
        'http_status' => $status,
        'body' => isset($parts[1]) ? trim($parts[1]) : ''
    ];
}

function fix_database_genders($project_dir, &$results) {
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
    try {
        $pdo = new PDO("mysql:host=$host;dbname=$name;charset=utf8mb4", $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
        ]);
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

        $results['db_fix'] = "Updated $c1 candidate profiles and $c2 users to FEMALE";
        $results['actions_taken'][] = "Database Gender Fix: Updated $c1 profiles and $c2 users to FEMALE";
    } catch (Exception $e) {
        $results['db_fix_error'] = $e->getMessage();
    }
}

$results = [
    'timestamp' => date('Y-m-d H:i:s T'),
    'php_user' => get_current_user(),
    'disabled_functions' => ini_get('disable_functions') ?: 'none',
    'actions_taken' => [],
];

if ($action === 'deploy') {
    if (function_exists('shell_exec')) {
        $deployLog = shell_exec("cd " . escapeshellarg($project_dir) . " && git checkout -- keep_backend_alive.sh start_backend_daemon.sh 2>&1 && git pull origin main 2>&1 && cp -r application/build/web/* /home/u796269890/domains/allgujaratvankarsamaj.com/public_html/ 2>&1 && cp -r next-nest/backend/dist/* " . escapeshellarg($backend_dir . "/dist/") . " 2>&1");
        $results['deploy_log'] = $deployLog;
        $results['actions_taken'][] = 'Pulled origin main and deployed web + backend dist';
    }
    @touch($trigger_file);
}

if ($action === 'fix_db') {
    fix_database_genders($project_dir, $results);
}

if ($action === 'restart' || $action === 'start') {
    fix_database_genders($project_dir, $results);
    // 1. Touch trigger file for the watchdog script
    @touch($trigger_file);
    $results['actions_taken'][] = 'Created restart trigger file for background watchdog';

    // Remove stale socket if connection is refused
    if (file_exists($socket_file)) {
        $t_fp = @stream_socket_client($socket_stream, $t_err, $t_msg, 1);
        if (!$t_fp) {
            @unlink($socket_file);
            $results['actions_taken'][] = 'Removed stale unix socket file';
        } else {
            @fclose($t_fp);
        }
    }

    // 2. If CLI execution is allowed, invoke watchdog or restart directly
    if (function_exists('shell_exec')) {
        @shell_exec("bash " . escapeshellarg($project_dir . "/keep_backend_alive.sh") . " > /dev/null 2>&1 &");
        $results['actions_taken'][] = 'Triggered keep_backend_alive.sh via shell_exec';
    } elseif (function_exists('exec')) {
        @exec("bash " . escapeshellarg($project_dir . "/keep_backend_alive.sh") . " > /dev/null 2>&1 &");
        $results['actions_taken'][] = 'Triggered keep_backend_alive.sh via exec';
    }

    // 3. Poll for socket ready (up to 4 seconds)
    $ready = false;
    for ($i = 0; $i < 16; $i++) {
        usleep(250000); // 250ms
        $probe = check_socket($socket_stream, 1);
        if ($probe['connected']) {
            $ready = true;
            $results['probe'] = $probe;
            break;
        }
    }
    $results['ready'] = $ready;
} else {
    // Just check status
    $results['probe'] = check_socket($socket_stream, 2);
    $results['ready'] = !empty($results['probe']['connected']);
}

// Running node processes
if (function_exists('shell_exec')) {
    $pids = trim(@shell_exec('pgrep -fa "node" 2>/dev/null') ?? '');
    $results['node_processes'] = $pids ?: 'None running';
}

// Socket file status
$results['socket_file_exists'] = file_exists($socket_file);
if (file_exists($socket_file)) {
    $results['socket_perms'] = substr(sprintf('%o', fileperms($socket_file)), -4);
}

// Last log lines
if (file_exists($log_file)) {
    $lines = @file($log_file);
    if ($lines) {
        $results['recent_logs'] = array_slice($lines, -25);
    }
}

if ($format === 'json') {
    header('Content-Type: application/json');
    echo json_encode($results, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

// HTML Dashboard output
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Backend Server Status | All Gujarat Vankar Samaj</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0b1120; color: #f1f5f9; padding: 24px; margin: 0; }
    .card { max-width: 800px; margin: 0 auto; background: #1e293b; border-radius: 12px; padding: 28px; box-shadow: 0 10px 25px rgba(0,0,0,0.5); }
    h1 { margin-top: 0; font-size: 24px; display: flex; align-items: center; gap: 12px; }
    .badge { display: inline-block; padding: 6px 14px; border-radius: 9999px; font-weight: bold; font-size: 14px; }
    .badge-success { background: #10b981; color: #022c22; }
    .badge-error { background: #ef4444; color: #450a0a; }
    .btn { display: inline-block; background: #3b82f6; color: white; padding: 10px 20px; border-radius: 8px; text-decoration: none; font-weight: 600; transition: background 0.2s; margin-right: 10px; margin-top: 15px; }
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
      Backend Server Status
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
        <td><?= $results['socket_file_exists'] ? '✅ Exists (' . htmlspecialchars($results['socket_perms'] ?? '') . ')' : '❌ Not Found' ?></td>
      </tr>
      <tr>
        <td>Socket Connection</td>
        <td><?= !empty($results['ready']) ? '✅ Connected (HTTP ' . ($results['probe']['http_status'] ?? 200) . ' OK)' : '❌ Unreachable' ?></td>
      </tr>
      <tr>
        <td>Active Processes</td>
        <td><code><?= htmlspecialchars($results['node_processes'] ?? 'None') ?></code></td>
      </tr>
    </table>

    <a href="?action=restart" class="btn btn-green">🔄 Restart Backend Now</a>
    <a href="?action=status" class="btn">🔍 Refresh Status</a>
    <a href="/" class="btn" style="background: #475569;">🏠 Go to App</a>

    <h3>Recent Backend Logs</h3>
    <pre><?= htmlspecialchars(implode('', $results['recent_logs'] ?? ['No logs found'])) ?></pre>
  </div>
</body>
</html>
