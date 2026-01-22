<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AdminKtpSeeder extends Seeder
{
    public function run(): void
    {
        $username = env('JEBOL_ADMIN_KTP_USERNAME', 'admin_ktp');
        $password = env('JEBOL_ADMIN_KTP_PASSWORD', 'SecretPass123!');

        User::updateOrCreate([
            'username' => $username,
        ], [
            'uuid' => (string) Str::uuid(),
            'password' => Hash::make($password),
            'role' => 'ADMIN_KTP',
            'is_active' => true,
        ]);
    }
}
