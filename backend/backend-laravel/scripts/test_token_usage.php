<?php

$base = 'http://127.0.0.1:8000';

function request($method, $url, $data = null, $token = null) {
    $headers = [];
    if ($token) $headers[] = "Authorization: Bearer $token";
    if ($data !== null) $headers[] = 'Content-Type: application/json';

    $opts = ['http' => [
        'method' => $method,
        'header' => implode("\r\n", $headers),
        'ignore_errors' => true,
    ]];

    if ($data !== null) $opts['http']['content'] = json_encode($data);

    $context = stream_context_create($opts);
    $body = @file_get_contents($url, false, $context);
    $status = 0;
    if (!empty($http_response_header)) {
        foreach ($http_response_header as $h) {
            if (preg_match('#HTTP/\d+\.\d+\s+(\d+)#', $h, $m)) {
                $status = (int)$m[1];
                break;
            }
        }
    }
    return [$status, $body];
}

echo "-- Test 1: Unauthorized (no token) GET /api/auth/me --\n";
list($status1, $body1) = request('GET', $base . '/api/auth/me');
echo "Status: $status1\n";
echo "Body: $body1\n\n";

// Login
echo "-- Login to obtain token --\n";
list($sLogin, $bLogin) = request('POST', $base . '/api/auth/login', [
    'username' => 'superadmin',
    'password' => 'ChangeMe123!',
    'device_name' => 'test-client'
]);
echo "Login status: $sLogin\n";
echo "Login body: $bLogin\n\n";

$parsed = json_decode($bLogin, true);
$token = $parsed['data']['token'] ?? null;
if (! $token) {
    echo "ERROR: no token returned, aborting tests.\n";
    exit(1);
}

// Authorized
echo "-- Test 2: Authorized GET /api/auth/me with token --\n";
list($status2, $body2) = request('GET', $base . '/api/auth/me', null, $token);
echo "Status: $status2\n";
echo "Body: $body2\n\n";

// Logout (with token)
echo "-- Logout (revoke current token) --\n";
list($sLogout, $bLogout) = request('POST', $base . '/api/auth/logout', [], $token);
echo "Logout status: $sLogout\n";
echo "Logout body: $bLogout\n\n";

// After logout, token should be invalid
echo "-- Test 3: After logout, GET /api/auth/me with same token (should be 401) --\n";
list($status3, $body3) = request('GET', $base . '/api/auth/me', null, $token);
echo "Status: $status3\n";
echo "Body: $body3\n\n";

// Summary
$pass = ($status1 === 401 || $status1 === 403) && $status2 === 200 && ($status3 === 401 || $status3 === 403);
echo "Summary: ";
echo $pass ? "PASS" : "FAIL";
echo "\n";
