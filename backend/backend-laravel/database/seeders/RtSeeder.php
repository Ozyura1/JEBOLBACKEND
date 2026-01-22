<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class RtSeeder extends Seeder
{
    public function run(): void
    {
        $username = env('JEBOL_RT_USERNAME', 'rt_user');
        $password = env('JEBOL_RT_PASSWORD', 'SecretPass123!');

        User::updateOrCreate([
            'username' => $username,
        ], [
            'uuid' => (string) Str::uuid(),
            'password' => Hash::make($password),
            'role' => 'RT',
            'is_active' => true,
        ]);
    }
}
