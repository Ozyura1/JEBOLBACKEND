<?php

namespace Tests\Feature\Perkawinan;

use App\Models\PerkawinanRequest;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminPerkawinanTest extends TestCase
{
    use RefreshDatabase;

    private function makeAdmin(): User
    {
        return User::create([
            'uuid' => (string) Str::uuid(),
            'username' => 'admin_perkawinan',
            'password' => Hash::make('Secret123!'),
            'role' => 'ADMIN_PERKAWINAN',
            'is_active' => true,
        ]);
    }

    private function makePendingRequest(array $overrides = []): PerkawinanRequest
    {
        return PerkawinanRequest::create(array_merge([
            'nama_pemohon' => 'Budi Santoso',
            'nik_pemohon' => '3201123456789012',
            'no_hp_pemohon' => '081234567890',
            'nama_pasangan' => 'Siti Aminah',
            'nik_pasangan' => '3201123456789013',
            'no_hp_pasangan' => '081298765432',
            'alamat_domisili' => 'Jl. Merdeka No.1',
            'tanggal_perkawinan' => '2026-02-20',
            'tempat_perkawinan' => 'KUA Kecamatan',
            'status' => 'PENDING',
        ], $overrides));
    }

    public function test_admin_can_list_pending_requests()
    {
        $admin = $this->makeAdmin();
        Sanctum::actingAs($admin);

        $pending = $this->makePendingRequest();
        $this->makePendingRequest(['status' => 'VERIFIED']);

        $response = $this->getJson('/api/admin/perkawinan');

        $response->assertStatus(200);
        $response->assertJson(['success' => true]);
        $response->assertJsonFragment(['uuid' => $pending->uuid]);
        $response->assertJsonStructure(['meta' => ['current_page', 'last_page', 'per_page', 'total']]);

        $this->assertSame(1, $response->json('meta.total'));
    }

    public function test_admin_can_verify_pending_request()
    {
        $admin = $this->makeAdmin();
        Sanctum::actingAs($admin);

        $req = $this->makePendingRequest();

        $response = $this->postJson("/api/admin/perkawinan/{$req->uuid}/verify", [
            'catatan_admin' => 'Checked',
        ]);

        $response->assertStatus(200);
        $response->assertJson(['data' => ['uuid' => $req->uuid, 'status' => 'VERIFIED']]);

        $this->assertDatabaseHas('perkawinan_requests', [
            'uuid' => $req->uuid,
            'status' => 'VERIFIED',
            'verified_by_user_id' => $admin->id,
        ]);
    }

    public function test_verifying_twice_fails()
    {
        $admin = $this->makeAdmin();
        Sanctum::actingAs($admin);

        $req = $this->makePendingRequest();

        $this->postJson("/api/admin/perkawinan/{$req->uuid}/verify", [])->assertStatus(200);

        $response = $this->postJson("/api/admin/perkawinan/{$req->uuid}/verify", []);
        $response->assertStatus(400);
        $response->assertJson(['success' => false]);
    }
}
