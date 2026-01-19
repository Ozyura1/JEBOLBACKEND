<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * Usage:
     *  - role:SUPER_ADMIN
     *  - role:ADMIN_KTP|SUPER_ADMIN
     *  - role:module:ktp  => maps to ADMIN_KTP
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
            return response()->json(['message' => 'Unauthenticated'], Response::HTTP_UNAUTHORIZED);
        }

        // SUPER_ADMIN always allowed
        if (isset($user->role) && $user->role === 'SUPER_ADMIN') {
            return $next($request);
        }

        if (empty($roles)) {
            return response()->json(['message' => 'Forbidden'], Response::HTTP_FORBIDDEN);
        }

        // Roles can be provided as pipe-separated list
        $candidates = explode('|', $roles);

        foreach ($candidates as $candidate) {
            $candidate = trim($candidate);

            if (stripos($candidate, 'module:') === 0) {
                $module = strtoupper(substr($candidate, 7));
                $required = 'ADMIN_' . $module;
                if (isset($user->role) && $user->role === $required) {
                    return $next($request);
                }
                continue;
            }

            // direct role match
            if (isset($user->role) && $user->role === $candidate) {
                return $next($request);
            }
        }

        return response()->json(['message' => 'Forbidden'], Response::HTTP_FORBIDDEN);
    }
}
