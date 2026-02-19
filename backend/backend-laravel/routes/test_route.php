<?php

// Simple test to verify router works
use Illuminate\Support\Facades\Route;

Route::get('/test-simple', function () {
    return response()->json([
        'success' => true,
        'message' => 'Simple test works',
    ]);
});
