<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AdminIkdSeeder extends Seeder
{
    public function run(): void
    {
        $username = env('JEBOL_ADMIN_IKD_USERNAME', 'admin_ikd');
        $password = env('JEBOL_ADMIN_IKD_PASSWORD', 'SecretPass123!');

        User::updateOrCreate([
            'username' => $username,
        ], [
            'uuid' => (string) Str::uuid(),
            'password' => Hash::make($password),
            'role' => 'ADMIN_IKD',
            'is_active' => true,
        ]);
    }
}
