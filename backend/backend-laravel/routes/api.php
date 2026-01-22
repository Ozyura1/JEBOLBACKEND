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
Route::prefix('admin')->middleware(['auth:sanctum'])->group(function () {
    // SUPER_ADMIN only
    Route::middleware([\App\Http\Middleware\RoleMiddleware::class . ':SUPER_ADMIN'])->group(function () {
        Route::get('super-only', function () {
            return ApiResponder::success(null, 'SUPER_ADMIN access granted');
        });
    });

    // Admin KTP
    Route::prefix('ktp')->middleware([\App\Http\Middleware\RoleMiddleware::class . ':SUPER_ADMIN,ADMIN_KTP'])->group(function () {
        Route::get('/', function () {
            return ApiResponder::success(null, 'KTP module index');
        });
    });

    // Admin IKD
    Route::prefix('ikd')->middleware([\App\Http\Middleware\RoleMiddleware::class . ':SUPER_ADMIN,ADMIN_IKD'])->group(function () {
        Route::get('/', function () {
            return ApiResponder::success(null, 'IKD module index');
        });
    });

    // Admin Perkawinan
    Route::prefix('perkawinan')->middleware([\App\Http\Middleware\RoleMiddleware::class . ':SUPER_ADMIN,ADMIN_PERKAWINAN'])->group(function () {
        Route::get('/', [\App\Http\Controllers\Perkawinan\AdminPerkawinanController::class, 'index']);
        Route::get('{uuid}', [\App\Http\Controllers\Perkawinan\AdminPerkawinanController::class, 'show']);
        Route::post('{uuid}/verify', [\App\Http\Controllers\Perkawinan\AdminPerkawinanController::class, 'verify']);
        Route::post('{uuid}/reject', [\App\Http\Controllers\Perkawinan\AdminPerkawinanController::class, 'reject']);
    });
});

// --- RT-only endpoints (auth required) ---
// No RT routes defined yet. Ensure RT endpoints are grouped under /api/rt/*
// with middleware('auth:sanctum', 'role:RT') when added.
