<?php
// All Gujarat Vankar Samaj - Internal Mail Delivery Bridge
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$shared_secret = 'VANKAR_INTERNAL_MAIL_SECRET_2026';
$provided_secret = $_POST['secret'] ?? $_GET['secret'] ?? '';

// Check header as well
if (empty($provided_secret) && isset($_SERVER['HTTP_X_MAIL_SECRET'])) {
    $provided_secret = $_SERVER['HTTP_X_MAIL_SECRET'];
}

$input = json_decode(file_get_contents('php://input'), true);
if (is_array($input)) {
    if (empty($provided_secret) && isset($input['secret'])) {
        $provided_secret = $input['secret'];
    }
}

if ($provided_secret !== $shared_secret) {
    http_response_code(403);
    echo json_encode(['success' => false, 'error' => 'Unauthorized mail bridge access']);
    exit;
}

$to = trim($input['to'] ?? $_POST['to'] ?? '');
$subject = trim($input['subject'] ?? $_POST['subject'] ?? 'All Gujarat Vankar Samaj - Verification Code');
$html = $input['html'] ?? $_POST['html'] ?? '';
$otp = $input['otp'] ?? $_POST['otp'] ?? '';

if (empty($to) || !filter_var($to, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid recipient email']);
    exit;
}

if (empty($html)) {
    $html = "<h2>Your Verification Code is: <b>$otp</b></h2><p>Valid for 10 minutes.</p>";
}

$headers = "MIME-Version: 1.0\r\n" .
           "From: All Gujarat Vankar Samaj <noreply@allgujaratvankarsamaj.com>\r\n" .
           "Reply-To: noreply@allgujaratvankarsamaj.com\r\n" .
           "X-Mailer: PHP/" . phpversion() . "\r\n" .
           "Content-Type: text/html; charset=UTF-8\r\n";

$sent = @mail($to, $subject, $html, $headers);

if ($sent) {
    echo json_encode([
        'success' => true,
        'message' => 'Email delivered successfully via Hostinger mail gateway',
        'recipient' => $to,
        'timestamp' => date('c'),
    ]);
} else {
    $err = error_get_last();
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $err['message'] ?? 'Failed to dispatch email via mail()',
    ]);
}
