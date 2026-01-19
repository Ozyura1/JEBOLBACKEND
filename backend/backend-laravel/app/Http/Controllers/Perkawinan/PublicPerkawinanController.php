<?php

namespace App\Http\Controllers\Perkawinan;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\PerkawinanRequest;
use Illuminate\Support\Facades\Validator;

class PublicPerkawinanController extends Controller
{
    // No auth: warga submit requests
    public function submit(Request $request)
    {
        $v = Validator::make($request->all(), [
            'nama_pemohon' => 'required|string|max:255',
            'nama_pasangan' => 'required|string|max:255',
            'tanggal_perkawinan' => 'required|date',
            'tempat' => 'nullable|string|max:255',
            'dokumen' => 'nullable|array',
            'nik_pemohon' => 'required|string|max:32',
            'nik_pasangan' => 'required|string|max:32',
            'alamat' => 'required|string',
            'no_hp_pemohon' => 'required|string|max:32',
        ]);

        if ($v->fails()) {
            return response()->json(['success' => false, 'errors' => $v->errors()], 422);
        }

        $data = $v->validated();
        // ensure status default handled by DB; allow explicit status override only if present
        $req = PerkawinanRequest::create([
            'uuid' => $data['uuid'] ?? null,
            'nama_pemohon' => $data['nama_pemohon'],
            'nama_pasangan' => $data['nama_pasangan'],
            'tanggal_perkawinan' => $data['tanggal_perkawinan'],
            'tempat' => $data['tempat'] ?? null,
            'dokumen' => $data['dokumen'] ?? null,
            'nik_pemohon' => $data['nik_pemohon'],
            'nik_pasangan' => $data['nik_pasangan'],
            'alamat' => $data['alamat'],
            'no_hp_pemohon' => $data['no_hp_pemohon'],
        ]);

        return response()->json(['success' => true, 'data' => ['uuid' => $req->uuid, 'status' => $req->status]], 201);
    }
}
