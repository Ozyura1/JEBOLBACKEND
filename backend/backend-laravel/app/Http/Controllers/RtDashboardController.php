<?php

namespace App\Http\Controllers;

use App\Models\KtpSubmission;
use App\Models\IkdSubmission;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RtDashboardController extends Controller
{
    /**
     * Get notifications for RT dashboard
     */
    public function notifications(Request $request): JsonResponse
    {
        $perPage = (int) ($request->query('per_page', 15));
        $unreadOnly = $request->query('unread_only', false);

        $query = Notification::where('user_id', $request->user()->id);

        // Filter unread if requested
        if ($unreadOnly) {
            $query->whereNull('read_at');
        }

        $notifications = $query->orderBy('created_at', 'desc')->paginate($perPage);

        return response()->json([
            'success' => true,
            'message' => 'Notifications retrieved',
            'data' => $notifications->items(),
            'meta' => [
                'current_page' => $notifications->currentPage(),
                'last_page' => $notifications->lastPage(),
                'per_page' => $notifications->perPage(),
                'total' => $notifications->total(),
                'unread_count' => Notification::where('user_id', $request->user()->id)
                    ->whereNull('read_at')
                    ->count(),
            ],
        ]);
    }

    /**
     * Mark notification as read
     */
    public function markAsRead(Request $request, string $notificationId): JsonResponse
    {
        $notification = Notification::where('user_id', $request->user()->id)
            ->find($notificationId);

        if (!$notification) {
            return response()->json([
                'success' => false,
                'message' => 'Notification not found',
            ], 404);
        }

        $notification->markAsRead();

        return response()->json([
            'success' => true,
            'message' => 'Notification marked as read',
            'data' => $notification,
        ]);
    }

    /**
     * Mark all notifications as read
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        Notification::where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => 'All notifications marked as read',
        ]);
    }

    /**
     * Get dashboard summary for RT (unread counts, recent submissions)
     */
    public function summary(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        return response()->json([
            'success' => true,
            'data' => [
                'unread_notifications' => Notification::where('user_id', $userId)
                    ->whereNull('read_at')
                    ->count(),
            ],
        ]);
    }

    /**
     * Get scheduled submissions (KTP and IKD) for RT's agenda
     */
    public function schedules(Request $request): JsonResponse
    {
        $userId = $request->user()->id;
        $perPage = (int) ($request->query('per_page', 20));

        // Debug logging
        \Log::info('RtDashboard::schedules called', [
            'user_id' => $userId,
            'username' => $request->user()->username,
        ]);

        // Fetch scheduled KTP submissions
        $ktpSubmissions = KtpSubmission::where('user_id', $userId)
            ->where('status', 'scheduled')
            ->whereNotNull('scheduled_at')
            ->get()
            ->map(function ($submission) {
                return [
                    'id' => $submission->id,
                    'title' => $submission->nama,
                    'submission_type' => 'ktp',
                    'kategori' => $submission->kategori,
                    'jumlah_pemohon' => $submission->jumlah_pemohon,
                    'scheduled_at' => $submission->scheduled_at->toIso8601String(),
                    'schedule_notes' => $submission->schedule_notes,
                    'created_at' => $submission->created_at->toIso8601String(),
                ];
            });

        // Fetch scheduled IKD submissions
        $ikdSubmissions = IkdSubmission::where('user_id', $userId)
            ->where('status', 'scheduled')
            ->whereNotNull('scheduled_at')
            ->get()
            ->map(function ($submission) {
                return [
                    'id' => $submission->id,
                    'title' => $submission->nama,
                    'submission_type' => 'ikd',
                    'jumlah_pemohon' => $submission->jumlah_pemohon,
                    'scheduled_at' => $submission->scheduled_at->toIso8601String(),
                    'schedule_notes' => $submission->schedule_notes,
                    'created_at' => $submission->created_at->toIso8601String(),
                ];
            });

        // Merge and sort by scheduled_at (nearest first)
        $schedules = collect($ktpSubmissions)
            ->merge($ikdSubmissions)
            ->sortBy('scheduled_at')
            ->values()
            ->toArray();

        // Debug logging
        \Log::info('RtDashboard::schedules result', [
            'ktp_count' => count($ktpSubmissions),
            'ikd_count' => count($ikdSubmissions),
            'total_count' => count($schedules),
            'schedules' => $schedules,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Scheduled submissions retrieved',
            'data' => $schedules,
            'meta' => [
                'total' => count($schedules),
            ],
        ]);
    }
}
