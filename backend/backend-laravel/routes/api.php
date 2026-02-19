<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Support\ApiResponder;

// --- Authentication (only /api/auth/*) ---
Route::prefix('auth')->group(function () {
    Route::post('login', [AuthController::class, 'login'])->middleware('throttle:login');

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('me', [AuthController::class, 'me']);
    });

    // token refresh endpoint (requires refresh token as Bearer token)
    Route::post('refresh', [\App\Http\Controllers\Auth\RefreshTokenController::class, 'refresh']);
});

// --- Public (no-auth) endpoints ---
Route::prefix('public')->group(function () {
    // Public submission endpoint (warga do NOT login; no auth)
    Route::post('perkawinan/submit', [\App\Http\Controllers\Perkawinan\PublicPerkawinanController::class, 'submit']);
    // Public status tracking by UUID + NIK
    Route::get('perkawinan/{uuid}/status', [\App\Http\Controllers\Perkawinan\PublicPerkawinanController::class, 'status']);
});

// --- Admin endpoints (auth required) ---
Route::prefix('admin')->middleware('auth:sanctum')->group(function () {
    // SUPER_ADMIN only
    Route::get('super-only', function () {
        return ApiResponder::success(null, 'SUPER_ADMIN access granted');
    })->middleware(\App\Http\Middleware\RoleMiddleware::class . ':SUPER_ADMIN');

    // Admin User Management (SUPER_ADMIN only)
    Route::prefix('users')->middleware(\App\Http\Middleware\RoleMiddleware::class . ':SUPER_ADMIN')->group(function () {
        // RT user management
        Route::prefix('rt')->group(function () {
            Route::post('create', [\App\Http\Controllers\Admin\AdminUserController::class, 'createRt']); // Create new RT user
            Route::get('/', [\App\Http\Controllers\Admin\AdminUserController::class, 'listRt']); // List all RT users
            Route::get('{id}', [\App\Http\Controllers\Admin\AdminUserController::class, 'showRt']); // Get single RT user
            Route::patch('{id}', [\App\Http\Controllers\Admin\AdminUserController::class, 'updateRt']); // Update RT user
            Route::delete('{id}', [\App\Http\Controllers\Admin\AdminUserController::class, 'deleteRt']); // Delete RT user
            Route::post('{id}/reset-password', [\App\Http\Controllers\Admin\AdminUserController::class, 'resetPassword']); // Reset RT user password
        });
    });

    // Admin KTP
    Route::prefix('ktp')->middleware(\App\Http\Middleware\RoleMiddleware::class . ':SUPER_ADMIN|ADMIN_KTP')->group(function () {
        Route::get('/', [\App\Http\Controllers\AdminKtpController::class, 'index']);
        Route::get('{id}', [\App\Http\Controllers\AdminKtpController::class, 'show']);
        Route::post('{id}/approve', [\App\Http\Controllers\AdminKtpController::class, 'approve']);
        Route::post('{id}/reject', [\App\Http\Controllers\AdminKtpController::class, 'reject']);
        Route::post('{id}/schedule', [\App\Http\Controllers\AdminKtpController::class, 'schedule']);
    });

    // Admin IKD
    Route::prefix('ikd')->middleware(\App\Http\Middleware\RoleMiddleware::class . ':SUPER_ADMIN|ADMIN_IKD')->group(function () {
        Route::get('/', [\App\Http\Controllers\AdminIkdController::class, 'index']);
        Route::get('{id}', [\App\Http\Controllers\AdminIkdController::class, 'show']);
        Route::post('{id}/approve', [\App\Http\Controllers\AdminIkdController::class, 'approve']);
        Route::post('{id}/reject', [\App\Http\Controllers\AdminIkdController::class, 'reject']);
        Route::post('{id}/schedule', [\App\Http\Controllers\AdminIkdController::class, 'schedule']);
    });

    // Admin Perkawinan
    Route::prefix('perkawinan')->middleware(\App\Http\Middleware\RoleMiddleware::class . ':SUPER_ADMIN|ADMIN_PERKAWINAN')->group(function () {
        Route::get('/', [\App\Http\Controllers\Perkawinan\AdminPerkawinanController::class, 'index']);
        Route::get('{uuid}', [\App\Http\Controllers\Perkawinan\AdminPerkawinanController::class, 'show']);
        Route::post('{uuid}/verify', [\App\Http\Controllers\Perkawinan\AdminPerkawinanController::class, 'verify']);
        Route::post('{uuid}/reject', [\App\Http\Controllers\Perkawinan\AdminPerkawinanController::class, 'reject']);
    });
});

// --- RT-only endpoints (auth required) ---
Route::prefix('rt')->middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':RT'])->group(function () {
    // Submissions
    Route::post('ktp/submit', [\App\Http\Controllers\RtSubmissionController::class, 'submitKtp']);
    Route::post('ikd/submit', [\App\Http\Controllers\RtSubmissionController::class, 'submitIkd']);

    // Dashboard notifications
    Route::prefix('dashboard')->group(function () {
        Route::get('summary', [\App\Http\Controllers\RtDashboardController::class, 'summary']);
        Route::get('notifications', [\App\Http\Controllers\RtDashboardController::class, 'notifications']);
        Route::post('notifications/{notificationId}/read', [\App\Http\Controllers\RtDashboardController::class, 'markAsRead']);
        Route::post('notifications/mark-all-read', [\App\Http\Controllers\RtDashboardController::class, 'markAllAsRead']);
        Route::get('schedules', [\App\Http\Controllers\RtDashboardController::class, 'schedules']);
        
        // DEBUG: Show all submissions for current user
        Route::get('all-submissions-debug', function () {
            $userId = auth()->id();
            $ktp = \App\Models\KtpSubmission::where('user_id', $userId)->get();
            $ikd = \App\Models\IkdSubmission::where('user_id', $userId)->get();
            return response()->json([
                'user_id' => $userId,
                'ktp_count' => $ktp->count(),
                'ikd_count' => $ikd->count(),
                'ktp_submissions' => $ktp->map(fn($s) => [
                    'id' => $s->id,
                    'nama' => $s->nama,
                    'status' => $s->status,
                    'scheduled_at' => $s->scheduled_at,
                    'schedule_notes' => $s->schedule_notes,
                ]),
                'ikd_submissions' => $ikd->map(fn($s) => [
                    'id' => $s->id,
                    'nama' => $s->nama,
                    'status' => $s->status,
                    'scheduled_at' => $s->scheduled_at,
                    'schedule_notes' => $s->schedule_notes,
                ]),
            ]);
        });
    });
});
