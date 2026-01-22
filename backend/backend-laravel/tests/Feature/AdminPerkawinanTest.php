<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\PerkawinanRequest;
use App\Models\User;

class AdminPerkawinanTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_verify_and_reject_request()
    {
        // create a public submission
        $req = PerkawinanRequest::create([
            'nama_pemohon' => 'Pemohon Admin',
            'nik_pemohon' => '1111111111111111',
            'no_hp_pemohon' => '081111111111',
            'nama_pasangan' => 'Pasangan Admin',
            'nik_pasangan' => '2222222222222222',
            'no_hp_pasangan' => '082222222222',
            'alamat_domisili' => 'Alamat Admin',
            'tanggal_perkawinan' => now()->addDays(5)->toDateString(),
            'tempat_perkawinan' => 'KUA Admin',
            'status' => 'PENDING',
        ]);

        // create admin user (users table uses 'username' as identifier)
        $admin = User::create([
            'username' => 'admin_perkawinan',
            'password' => bcrypt('secret'),
            'role' => 'ADMIN_PERKAWINAN',
            'is_active' => true,
        ]);

        // authenticate as admin (sanctum)
        $this->actingAs($admin, 'sanctum');
        $res = $this->postJson("/api/admin/perkawinan/{$req->uuid}/verify", ['catatan_admin' => 'OK']);
        $res->assertStatus(200);
        $res->assertJsonPath('data.status', 'VERIFIED');

        // audit log created
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'VERIFY_PERKAWINAN',
            'auditable_type' => \App\Models\PerkawinanRequest::class,
            'auditable_id' => $req->id,
            'user_id' => $admin->id,
        ]);

        // create another pending request to reject
        $req2 = PerkawinanRequest::create([
            'nama_pemohon' => 'Pemohon 2',
            'nik_pemohon' => '3333333333333333',
            'no_hp_pemohon' => '083333333333',
            'nama_pasangan' => 'Pasangan 2',
            'nik_pasangan' => '4444444444444444',
            'no_hp_pasangan' => '084444444444',
            'alamat_domisili' => 'Alamat 2',
            'tanggal_perkawinan' => now()->addDays(10)->toDateString(),
            'tempat_perkawinan' => 'KUA 2',
            'status' => 'PENDING',
        ]);

        $res2 = $this->postJson("/api/admin/perkawinan/{$req2->uuid}/reject", ['catatan_admin' => 'Dokumen tidak lengkap']);
        $res2->assertStatus(200);
        $res2->assertJsonPath('data.status', 'REJECTED');

        $this->assertDatabaseHas('audit_logs', [
            'action' => 'REJECT_PERKAWINAN',
            'auditable_type' => \App\Models\PerkawinanRequest::class,
            'auditable_id' => $req2->id,
            'user_id' => $admin->id,
        ]);
    }
}
