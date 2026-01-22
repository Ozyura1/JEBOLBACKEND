<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Support\ApiResponder;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * Usage:
     *  - role:SUPER_ADMIN
    *  - role:SUPER_ADMIN,ADMIN_KTP
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @param  string|null  $roles
     * @return mixed
     */
    public function handle(Request $request, Closure $next, $roles = null)
    {
        $user = $request->user();

        if (! $user) {
            return ApiResponder::error('Unauthenticated', Response::HTTP_UNAUTHORIZED);
        }

        if (empty($roles)) {
            return ApiResponder::error('Forbidden', Response::HTTP_FORBIDDEN);
        }

        // Roles are provided as comma-separated list
        $candidates = array_filter(array_map('trim', explode(',', $roles)));

        // SUPER_ADMIN can access all admin routes
        if (isset($user->role) && $user->role === 'SUPER_ADMIN') {
            return $next($request);
        }

        foreach ($candidates as $candidate) {
            // direct role match only (no fallback)
            if (isset($user->role) && $user->role === $candidate) {
                return $next($request);
            }
        }

        return ApiResponder::error('Forbidden', Response::HTTP_FORBIDDEN);
    }
}
