<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PerkawinanFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_public_submit_and_status()
    {
        $payload = [
            'nama_pemohon' => 'Test Pemohon',
            'nik_pemohon' => '1234567890123456',
            'no_hp_pemohon' => '081234567890',
            'nama_pasangan' => 'Test Pasangan',
            'nik_pasangan' => '6543210987654321',
            'no_hp_pasangan' => '081234567891',
            'alamat_domisili' => 'Jl Test No 1',
            'tanggal_perkawinan' => now()->addDays(2)->toDateString(),
            'tempat_perkawinan' => 'KUA Test',
        ];

        $resp = $this->postJson('/api/perkawinan/submit', $payload);
        $resp->assertStatus(201);
        $resp->assertJsonStructure(['success', 'message', 'data' => ['uuid', 'status']]);

        $uuid = $resp->json('data.uuid');
        $this->assertNotEmpty($uuid);

        $statusResp = $this->getJson("/api/perkawinan/{$uuid}/status?nik_pemohon={$payload['nik_pemohon']}");
        $statusResp->assertStatus(200);
        $statusResp->assertJsonPath('data.status', 'PENDING');
        $statusResp->assertJsonPath('data.uuid', $uuid);
    }
}
