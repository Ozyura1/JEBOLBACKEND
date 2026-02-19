<?php

namespace App\Http\Controllers;

use App\Models\KtpSubmission;
use App\Models\IkdSubmission;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class RtSubmissionController extends Controller
{
    public function submitKtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'nomor_telp' => 'required|string|min:10|max:15',
            'alamat_manual' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'kategori' => 'required|string|in:umum,khusus',
            'kategori_khusus' => 'nullable|string|in:lansia,odgj',
            'jumlah_pemohon' => 'required|integer|min:1',
            'minimal_usia' => 'required|integer|min:16',
            'attachment' => 'nullable|file|mimes:pdf,jpg,jpeg,png|max:5120',
        ]);

        // Custom validation: if kategori is khusus, kategori_khusus must be provided
        if ($validated['kategori'] === 'khusus' && empty($validated['kategori_khusus'])) {
            return response()->json([
                'success' => false,
                'message' => 'Kategori khusus wajib dipilih ketika memilih kategori Khusus',
                'errors' => ['kategori_khusus' => ['Kategori khusus wajib dipilih']],
            ], 422);
        }

        try {
            $attachmentPath = null;
            if ($request->hasFile('attachment')) {
                $file = $request->file('attachment');
                $filename = 'ktp_' . $request->user()->id . '_' . Str::uuid() . '.' . $file->getClientOriginalExtension();
                $attachmentPath = $file->storeAs('submissions/ktp', $filename, 'public');
            }

            $submission = KtpSubmission::create([
                'user_id' => $request->user()->id,
                'nama' => $validated['nama'],
                'nomor_telp' => $validated['nomor_telp'],
                'kategori' => $validated['kategori'],
                'kategori_khusus' => $validated['kategori_khusus'] ?? null,
                'minimal_usia' => $validated['minimal_usia'],
                'alamat_manual' => $validated['alamat_manual'],
                'latitude' => $validated['latitude'],
                'longitude' => $validated['longitude'],
                'jumlah_pemohon' => $validated['jumlah_pemohon'],
                'attachment_path' => $attachmentPath,
                'status' => 'pending',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'KTP submission created successfully',
                'data' => $submission,
            ], 201);
        } catch (\Exception $e) {
            \Log::error('KTP Submission Error', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to create KTP submission',
                'error' => $e->getMessage(),
                'debug' => config('app.debug') ? $e->getTrace() : null,
            ], 500);
        }
    }

    public function submitIkd(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'nomor_telp' => 'required|string|min:10|max:15',
            'alamat_manual' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'jumlah_pemohon' => 'required|integer|min:1',
            'attachment' => 'nullable|file|mimes:pdf,jpg,jpeg,png|max:5120',
        ]);

        try {
            $attachmentPath = null;
            if ($request->hasFile('attachment')) {
                $file = $request->file('attachment');
                $filename = 'ikd_' . $request->user()->id . '_' . Str::uuid() . '.' . $file->getClientOriginalExtension();
                $attachmentPath = $file->storeAs('submissions/ikd', $filename, 'public');
            }

            $submission = IkdSubmission::create([
                'user_id' => $request->user()->id,
                'nama' => $validated['nama'],
                'nomor_telp' => $validated['nomor_telp'],
                'alamat_manual' => $validated['alamat_manual'],
                'jumlah_pemohon' => $validated['jumlah_pemohon'],
                'latitude' => $validated['latitude'],
                'longitude' => $validated['longitude'],
                'attachment_path' => $attachmentPath,
                'status' => 'pending',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'IKD submission created successfully',
                'data' => $submission,
            ], 201);
        } catch (\Exception $e) {
            \Log::error('IKD Submission Error', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to create IKD submission',
                'error' => $e->getMessage(),
                'debug' => config('app.debug') ? $e->getTrace() : null,
            ], 500);
        }
    }
}
