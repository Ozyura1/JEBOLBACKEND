<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminPerkawinanSeeder extends Seeder
{
    public function run()
    {
        User::updateOrCreate([
            'username' => 'admin_perkawinan'
        ], [
            'uuid' => (string) \Illuminate\Support\Str::uuid(),
            'password' => Hash::make('SecretPass123!'),
            'role' => 'ADMIN_PERKAWINAN',
            'is_active' => true,
        ]);
    }
}
