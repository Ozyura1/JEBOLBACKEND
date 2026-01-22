<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use App\Support\ApiResponder;
use Symfony\Component\HttpFoundation\Response;

class EnsureTokenNotExpired
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next)
    {
        $token = $request->user()?->currentAccessToken();
        if ($token && $token->expires_at) {
            $now = Carbon::now();
            if ($now->greaterThan($token->expires_at)) {
                return ApiResponder::error('Unauthenticated', Response::HTTP_UNAUTHORIZED);
            }
        }

        return $next($request);
    }
}
