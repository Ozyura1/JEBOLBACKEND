<?php

namespace App\Http\Controllers\Perkawinan;

use App\Http\Controllers\Controller;
use App\Http\Requests\Perkawinan\SubmitPerkawinanRequest;
use App\Http\Requests\Perkawinan\TrackPerkawinanRequest;
use App\Models\PerkawinanRequest;

class PublicPerkawinanController extends Controller
{
    // No auth: warga submit requests
    public function submit(SubmitPerkawinanRequest $request)
    {
        $data = $request->validated();

        $req = PerkawinanRequest::create([
            'nama_pemohon'       => $data['nama_pemohon'],
            'nik_pemohon'        => $data['nik_pemohon'],
            'no_hp_pemohon'      => $data['no_hp_pemohon'],

            'nama_pasangan'      => $data['nama_pasangan'],
            'nik_pasangan'       => $data['nik_pasangan'],
            'no_hp_pasangan'     => $data['no_hp_pasangan'],

            'alamat_domisili'    => $data['alamat_domisili'],
            'tanggal_perkawinan' => $data['tanggal_perkawinan'],
            'tempat_perkawinan'  => $data['tempat_perkawinan'],

            'status'             => 'PENDING',
        ]);

        return $this->successResponse([
            'uuid'   => $req->uuid,
            'status' => $req->status,
        ], 'Perkawinan request submitted', 201);
    }

    // Public status check with UUID + NIK validation
    public function status(TrackPerkawinanRequest $request, string $uuid)
    {
        $data = $request->validated();
        $req = PerkawinanRequest::where('uuid', $uuid)
            ->where('nik_pemohon', $data['nik_pemohon'])
            ->first();

        if (! $req) {
            return $this->errorResponse('Data tidak ditemukan', 404);
        }

        return $this->successResponse([
            'uuid' => $req->uuid,
            'status' => $req->status,
        ], 'Perkawinan status retrieved');
    }
}
