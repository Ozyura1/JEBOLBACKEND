<?php

namespace App\Http\Controllers;

use App\Models\KtpSubmission;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminKtpController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $status = $request->query('status', 'pending');
        $perPage = (int) ($request->query('per_page', 15));
        $page = (int) ($request->query('page', 1));

        $query = KtpSubmission::with('user');

        // Filter by status if specified
        if ($status && $status !== 'all') {
            $query->where('status', $status);
        }

        $submissions = $query->orderBy('created_at', 'desc')->paginate($perPage, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'message' => 'KTP submissions retrieved',
            'data' => $submissions->items(),
            'meta' => [
                'current_page' => $submissions->currentPage(),
                'last_page' => $submissions->lastPage(),
                'per_page' => $submissions->perPage(),
                'total' => $submissions->total(),
                'from' => $submissions->firstItem(),
                'to' => $submissions->lastItem(),
            ],
        ]);
    }

    public function show(string $id): JsonResponse
    {
        $submission = KtpSubmission::with('user', 'approvedBy')->find($id);

        if (!$submission) {
            return response()->json([
                'success' => false,
                'message' => 'KTP submission not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $submission,
        ]);
    }

    public function approve(Request $request, string $id): JsonResponse
    {
        $submission = KtpSubmission::find($id);

        if (!$submission) {
            return response()->json([
                'success' => false,
                'message' => 'KTP submission not found',
            ], 404);
        }

        if ($submission->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Only pending submissions can be approved',
            ], 400);
        }

        $submission->update([
            'status' => 'approved',
            'approved_at' => now(),
            'approved_by' => $request->user()->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'KTP submission approved',
            'data' => $submission,
        ]);
    }

    public function reject(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'rejection_reason' => 'required|string|max:500',
        ]);

        $submission = KtpSubmission::find($id);

        if (!$submission) {
            return response()->json([
                'success' => false,
                'message' => 'KTP submission not found',
            ], 404);
        }

        if ($submission->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Only pending submissions can be rejected',
            ], 400);
        }

        $submission->update([
            'status' => 'rejected',
            'rejection_reason' => $validated['rejection_reason'],
            'rejected_at' => now(),
            'approved_by' => $request->user()->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'KTP submission rejected',
            'data' => $submission,
        ]);
    }

    public function schedule(Request $request, string $id): JsonResponse
    {
        // Accept both ISO8601 and Y-m-d H:i:s formats
        $validated = $request->validate([
            'scheduled_at' => 'required|date:Y-m-d H:i:s,c,U|after:now',
            'schedule_notes' => 'nullable|string|max:500',
        ]);

        $submission = KtpSubmission::find($id);

        if (!$submission) {
            return response()->json([
                'success' => false,
                'message' => 'KTP submission not found',
            ], 404);
        }

        if ($submission->status !== 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'Only approved submissions can be scheduled',
            ], 400);
        }

        $submission->update([
            'status' => 'scheduled',
            'scheduled_at' => $validated['scheduled_at'],
            'schedule_notes' => $validated['schedule_notes'] ?? null,
        ]);

        // Create notification for RT user
        Notification::create([
            'user_id' => $submission->user_id,
            'type' => 'ktp_scheduled',
            'title' => 'Jadwal Pelayanan KTP',
            'message' => 'Permohonan KTP Anda telah dijadwalkan. Silakan datang pada tanggal dan waktu yang telah ditentukan: ' . $submission->scheduled_at->format('d/m/Y H:i'),
            'submission_id' => $submission->id,
            'submission_type' => 'ktp',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'KTP submission scheduled successfully',
            'data' => $submission,
        ]);
    }
}
