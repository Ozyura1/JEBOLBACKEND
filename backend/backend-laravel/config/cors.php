<?php

return [
    /*
    |--------------------------------------------------------------------------
    | CORS Configuration for Government API
    |--------------------------------------------------------------------------
    |
    | SECURITY CRITICAL:
    | - Production MUST define FRONTEND_URL with exact allowed origins
    | - Wildcard (*) is ONLY allowed in local development
    | - Mobile apps should be explicitly whitelisted if using web views
    |
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    // Use FRONTEND_URL env var to restrict origin in production.
    // If running in local dev and FRONTEND_URL is not set, allow all origins
    // FRONTEND_URL may contain comma-separated origins for dev (e.g. "http://localhost:3000,http://localhost:62127")
    //
    // PRODUCTION REQUIREMENT:
    // Set FRONTEND_URL to comma-separated list of allowed origins:
    // FRONTEND_URL="https://app.jebol.go.id,https://admin.jebol.go.id"
    'allowed_origins' => (function () {
        $front = env('FRONTEND_URL', '');
        $list = array_filter(array_map('trim', explode(',', $front)));
        if (env('APP_ENV', 'production') === 'local' && empty($list)) {
            return ['*'];
        }
        // Production safety: If no origins specified, deny all instead of allowing all
        if (env('APP_ENV') === 'production' && empty($list)) {
            throw new \RuntimeException('FRONTEND_URL must be set in production environment for CORS security');
        }
        return $list;
    })(),

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    // If your frontend needs cookies (sanctum), set this to true and ensure
    // FRONTEND_URL includes scheme and host.
    'supports_credentials' => env('CORS_SUPPORTS_CREDENTIALS', false),
];
