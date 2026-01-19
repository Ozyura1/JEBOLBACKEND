<?php

$base = 'http://127.0.0.1:8000';

function post($url, $data) {
    $opts = ['http' => [
        'method' => 'POST',
        'header' => "Content-Type: application/json\r\n",
        'content' => json_encode($data),
        'ignore_errors' => true,
    ]];
    $context = stream_context_create($opts);
    $res = file_get_contents($url, false, $context);
    return [$res, $http_response_header ?? []];
}

function get($url, $token=null) {
    $hdr = [];
    if ($token) $hdr[] = "Authorization: Bearer $token";
    $opts = ['http' => [
        'method' => 'GET',
        'header' => implode("\r\n", $hdr),
        'ignore_errors' => true,
    ]];
    $context = stream_context_create($opts);
    $res = file_get_contents($url, false, $context);
    return [$res, $http_response_header ?? []];
}

// 1) Login
list($loginBody, $loginHdr) = post($base . '/api/auth/login', [
    'username' => 'superadmin',
    'password' => 'ChangeMe123!',
    'device_name' => 'cli-test',
]);

echo "=== LOGIN RESPONSE ===\n";
echo $loginBody . "\n\n";

$loginJson = json_decode($loginBody, true);
$token = $loginJson['data']['token'] ?? null;
if (! $token) {
    echo "Login failed or token not returned.\n";
    exit(1);
}

// 2) Me
list($meBody, $meHdr) = get($base . '/api/auth/me', $token);

echo "=== ME RESPONSE ===\n";
echo $meBody . "\n\n";

// 3) Logout
list($logoutBody, $logoutHdr) = post($base . '/api/auth/logout', []);

// We need to send Authorization header for logout via stream context; redo with header
$opts = ['http' => [
    'method' => 'POST',
    'header' => [
        "Content-Type: application/json",
        "Authorization: Bearer $token"
    ],
    'content' => json_encode([]),
    'ignore_errors' => true,
]];
$context = stream_context_create($opts);
$logoutBody = file_get_contents($base . '/api/auth/logout', false, $context);

echo "=== LOGOUT RESPONSE ===\n";
echo $logoutBody . "\n";

echo "\nDone.\n";
