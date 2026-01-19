<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;

Route::prefix('auth')->group(function () {
    Route::post('login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('me', [AuthController::class, 'me']);
    });
});

// --- Example role-protected routes (Authorization Level 2.3) ---

// SUPER_ADMIN can access everything
Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':SUPER_ADMIN'])->group(function () {
    Route::get('admin/super-only', function () {
        return response()->json(['message' => 'SUPER_ADMIN access granted']);
    });
});

// ADMIN_KTP can access KTP module endpoints; SUPER_ADMIN also allowed
Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':module:ktp|SUPER_ADMIN'])->prefix('ktp')->group(function () {
    Route::get('/', function () {
        return response()->json(['message' => 'KTP module index']);
    });
});

// ADMIN_IKD can access IKD module endpoints; demonstrate explicit role match
Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':ADMIN_IKD|SUPER_ADMIN'])->prefix('ikd')->group(function () {
    Route::get('/', function () {
        return response()->json(['message' => 'IKD module index']);
    });
});

// RT role will not match ADMIN_* rules above, so RT users are forbidden from admin endpoints

// --- Perkawinan module ---

// Public submission endpoint (warga do NOT login; no auth)
Route::post('perkawinan/submit', [\App\Http\Controllers\Perkawinan\PublicPerkawinanController::class, 'submit']);

// Admin routes for perkawinan verification (ADMIN_PERKAWINAN only)
Route::middleware(['auth:sanctum', \App\Http\Middleware\RoleMiddleware::class . ':ADMIN_PERKAWINAN'])->prefix('admin/perkawinan')->group(function () {
    Route::get('/', [\App\Http\Controllers\Perkawinan\AdminPerkawinanController::class, 'index']);
    Route::post('{uuid}/verify', [\App\Http\Controllers\Perkawinan\AdminPerkawinanController::class, 'verify']);
});
