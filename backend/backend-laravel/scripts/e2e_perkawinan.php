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
            if (preg_match('#HTTP/\d+\.\d+\s+(\d+)#', $h, $m)) { $status = (int)$m[1]; break; }
        }
    }
    return [$status, $body];
}

echo "1) Public submit...\n";
list($s1, $b1) = request('POST', $base . '/api/perkawinan/submit', [
    'nama_pemohon' => 'Budi',
    'nama_pasangan' => 'Ani',
    'tanggal_perkawinan' => '2026-02-01',
    'nik_pemohon' => '1234567890123456',
    'nik_pasangan' => '6543210987654321',
    'alamat' => 'Jl. Merdeka 1',
    'no_hp_pemohon' => '081234567890'
]);
echo "Status: $s1\nBody: $b1\n\n";

$parsed = json_decode($b1, true);
$uuid = $parsed['data']['uuid'] ?? null;
if (! $uuid) { echo "No UUID returned, aborting.\n"; exit(1); }

echo "2) Admin login...\n";
list($s2, $b2) = request('POST', $base . '/api/auth/login', [
    'username' => 'admin_perkawinan',
    'password' => 'SecretPass123!',
    'device_name' => 'e2e-script'
]);
echo "Status: $s2\nBody: $b2\n\n";
$parsed2 = json_decode($b2, true);
$token = $parsed2['data']['token'] ?? null;
if (! $token) { echo "No token, aborting.\n"; exit(1); }

echo "3) Admin list (status=SUBMITTED)...\n";
list($s3, $b3) = request('GET', $base . '/api/admin/perkawinan?status=SUBMITTED&per_page=10', null, $token);
echo "Status: $s3\nBody: $b3\n\n";

echo "4) Admin verify...\n";
list($s4, $b4) = request('POST', $base . '/api/admin/perkawinan/' . $uuid . '/verify', ['catatan_admin' => 'Verified in e2e test'], $token);
echo "Status: $s4\nBody: $b4\n\n";

echo "E2E done.\n";
