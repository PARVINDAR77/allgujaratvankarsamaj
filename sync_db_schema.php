<?php
// Automatic database schema synchronization script for Hostinger MySQL
$rootDir = __DIR__;
$envFiles = [
    $rootDir . '/.env.production',
    $rootDir . '/next-nest/backend/.env',
    $rootDir . '/.env'
];

$envContent = '';
foreach ($envFiles as $ef) {
    if (file_exists($ef)) {
        $envContent .= "\n" . file_get_contents($ef);
    }
}

$dbUrl = '';
foreach (explode("\n", $envContent) as $line) {
    $line = trim($line);
    if (strpos($line, 'DATABASE_URL=') === 0) {
        $dbUrl = trim(substr($line, 13), "\"'");
    }
}

if (empty($dbUrl)) {
    echo "[sync_db_schema] DATABASE_URL not found.\n";
    exit(0);
}

$p = parse_url($dbUrl);
$host = $p['host'] ?? 'localhost';
$user = $p['user'] ?? '';
$pass = $p['pass'] ?? '';
$name = ltrim($p['path'] ?? '', '/');

try {
    $pdo = new PDO("mysql:host=$host;dbname=$name;charset=utf8mb4", $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
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

