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
        'http_status' => $status,
        'body' => isset($parts[1]) ? trim($parts[1]) : ''
    ];
}

$results = [
    'timestamp' => date('Y-m-d H:i:s T'),
    'php_user' => get_current_user(),
    'disabled_functions' => ini_get('disable_functions') ?: 'none',
    'actions_taken' => [],
];

if ($action === 'restart' || $action === 'start') {
    // 1. Touch trigger file for the watchdog script
    @touch($trigger_file);
    $results['actions_taken'][] = 'Created restart trigger file for background watchdog';

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
