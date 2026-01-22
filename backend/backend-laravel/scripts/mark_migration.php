<?php
$vendor = __DIR__ . '/../vendor/autoload.php';
if (! file_exists($vendor)) {
    echo "vendor autoload not found: $vendor\n";
    exit(1);
}
require $vendor;
$app = require __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();
use Illuminate\Support\Facades\DB;

$migration = '2026_01_17_101000_update_perkawinan_requests_add_audit_and_identity';
$exists = DB::table('migrations')->where('migration', $migration)->exists();
if (! $exists) {
    DB::table('migrations')->insert(['migration' => $migration, 'batch' => 1]);
    echo "Inserted migration entry: $migration\n";
} else {
    echo "Migration already recorded: $migration\n";
}
