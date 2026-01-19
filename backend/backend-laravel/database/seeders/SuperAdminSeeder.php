<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class SuperAdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $username = env('JEBOL_SUPERADMIN_USERNAME', 'superadmin');
        $password = env('JEBOL_SUPERADMIN_PASSWORD', 'ChangeMe123!');

        if (User::where('username', $username)->exists()) {
            $this->command->info('SUPER_ADMIN already exists, skipping.');
            return;
        }

        User::create([
            'uuid' => (string) Str::uuid(),
            'username' => $username,
            'password' => Hash::make($password),
            'role' => 'SUPER_ADMIN',
            'is_active' => true,
        ]);

        $this->command->info('SUPER_ADMIN created: ' . $username);
    }
}
