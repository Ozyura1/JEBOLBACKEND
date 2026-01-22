<?php

namespace Tests\Feature\Perkawinan;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PublicSubmitTest extends TestCase
{
    use RefreshDatabase;

    public function test_successful_public_submission_returns_201_and_uuid_status()
    {
        $payload = [
            'nama_pemohon' => 'Budi Santoso',
            'nik_pemohon' => '3201123456789012',
            'no_hp_pemohon' => '081234567890',

            'nama_pasangan' => 'Siti Aminah',
            'nik_pasangan' => '3201123456789013',
            'no_hp_pasangan' => '081298765432',

            'alamat_domisili' => 'Jl. Merdeka No.1',
            'tanggal_perkawinan' => '2026-02-20',
            'tempat_perkawinan' => 'KUA Kecamatan',
        ];

        $response = $this->postJson('/api/perkawinan/submit', $payload);

        $response->assertStatus(201);
        $response->assertJson(['success' => true]);
        $response->assertJsonStructure([
            'data' => ['uuid', 'status'],
        ]);

        $this->assertDatabaseHas('perkawinan_requests', [
            'nama_pemohon' => 'Budi Santoso',
            'nik_pemohon' => '3201123456789012',
        ]);
    }

    public function test_validation_failure_returns_422_and_errors()
    {
        // missing nama_pasangan and wrong nik length
        $payload = [
            'nama_pemohon' => 'Budi Santoso',
            'nik_pemohon' => '123', // invalid length
            'no_hp_pemohon' => '081234567890',

            // 'nama_pasangan' => missing
            'nik_pasangan' => '3201123456789013',
            'no_hp_pasangan' => '081298765432',

            'alamat_domisili' => 'Jl. Merdeka No.1',
            'tanggal_perkawinan' => '2026-02-20',
            'tempat_perkawinan' => 'KUA Kecamatan',
        ];

        $response = $this->postJson('/api/perkawinan/submit', $payload);

        $response->assertStatus(422);
        $response->assertJson(['success' => false, 'message' => 'Validation failed']);
        $response->assertJsonStructure(['errors']);
    }
}
