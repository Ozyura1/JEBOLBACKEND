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

function loginUser($username) {
    global $base;
    list($s, $b) = request('POST', $base . '/api/auth/login', [
        'username' => $username,
        'password' => 'ChangeMe123!',
        'device_name' => 'test-client'
    ]);
    $token = null;
    $parsed = json_decode($b, true);
    if (is_array($parsed) && isset($parsed['data']['token'])) $token = $parsed['data']['token'];
    return [$s, $token, $b];
}

$tests = [];
$users = [
    'superadmin' => ['label'=>'SUPER_ADMIN'],
    'rt' => ['label'=>'RT'],
    'admin_ktp' => ['label'=>'ADMIN_KTP'],
    'admin_ikd' => ['label'=>'ADMIN_IKD'],
];

// Login each
foreach ($users as $u => &$info) {
    echo "Logging in $u...\n";
    list($status, $token, $body) = loginUser($u);
    $info['login_status'] = $status;
    $info['token'] = $token;
    $info['login_body'] = $body;
    echo "Login status: $status\n";
}

// Tests to run
$baseAdmin = $base . '/api/admin/super-only';
$baseKtp = $base . '/api/ktp';

// 1) SUPER_ADMIN-only with SUPER_ADMIN token
echo "\nTest A: SUPER_ADMIN-only with SUPER_ADMIN token\n";
list($sA, $bA) = request('GET', $baseAdmin, null, $users['superadmin']['token']);
echo "Status: $sA\n";
echo "Body: " . substr(trim($bA), 0, 200) . "\n";

// 2) SUPER_ADMIN-only with RT token
echo "\nTest B: SUPER_ADMIN-only with RT token\n";
list($sB, $bB) = request('GET', $baseAdmin, null, $users['rt']['token']);
echo "Status: $sB\n";
echo "Body: " . substr(trim($bB), 0, 200) . "\n";

// 3) ADMIN_KTP with ADMIN_KTP token
echo "\nTest C: KTP module with ADMIN_KTP token\n";
list($sC, $bC) = request('GET', $baseKtp, null, $users['admin_ktp']['token']);
echo "Status: $sC\n";
echo "Body: " . substr(trim($bC), 0, 200) . "\n";

// 4) ADMIN_KTP endpoint with ADMIN_IKD token
echo "\nTest D: KTP module with ADMIN_IKD token\n";
list($sD, $bD) = request('GET', $baseKtp, null, $users['admin_ikd']['token']);
echo "Status: $sD\n";
echo "Body: " . substr(trim($bD), 0, 200) . "\n";

// Print curl commands for reproducing
echo "\nCURL commands to reproduce:\n";
echo "curl -X POST -H \"Content-Type: application/json\" -d '{\"username\":\"superadmin\",\"password\":\"ChangeMe123!\"}' $base/api/auth/login\n";
echo "curl -H \"Authorization: Bearer <TOKEN>\" $base/api/admin/super-only\n";
echo "curl -H \"Authorization: Bearer <TOKEN>\" $base/api/ktp\n";

?>
