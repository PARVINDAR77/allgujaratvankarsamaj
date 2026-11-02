<?php
// Automatic database schema synchronization script for Hostinger MySQL
$rootDir = __DIR__;
$envFiles = [
    $rootDir . '/.env.production',
    $rootDir . '/next-nest/backend/.env',
    $rootDir . '/.env'
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
                // The first file that defines a non-empty key wins (so .env.production takes precedence)
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

if (empty($name) || empty($user)) {
    echo "[sync_db_schema] Incomplete DB config (name=$name, user=$user)\n";
    exit(0);
}

try {
    $pdo = new PDO("mysql:host=$host;dbname=$name;charset=utf8mb4", $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_TIMEOUT => 3
    ]);
    
    // 1. Ensure permissions column exists on users table
    $col = $pdo->query("SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND COLUMN_NAME = 'permissions'")->fetch();
    if (!$col) {
        $pdo->exec("ALTER TABLE users ADD COLUMN permissions TEXT NULL");
        echo "[sync_db_schema] Added missing 'permissions' column to users table.\n";
    } else {
        echo "[sync_db_schema] 'permissions' column is already present on users table.\n";
    }
} catch (Exception $e) {
    echo "[sync_db_schema] Error: " . $e->getMessage() . "\n";
}
