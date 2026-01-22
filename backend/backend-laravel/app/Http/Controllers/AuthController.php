<?php

namespace App\Http\Controllers;

use App\Http\Requests\Auth\LoginRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    /**
     * Allowed roles for authentication.
     */
    private const ALLOWED_ROLES = [
        'SUPER_ADMIN',
        'ADMIN_KTP',
        'ADMIN_IKD',
        'ADMIN_PERKAWINAN',
        'RT',
    ];

    /**
     * Login user with username and password. Returns Bearer token.
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $data = $request->validated();

        // Attempt authentication using username + password
        if (! Auth::attempt(['username' => $data['username'], 'password' => $data['password']])) {
            return $this->errorResponse('Unauthenticated', 401);
        }

        /** @var \App\Models\User $user */
        $user = Auth::user();

        if (! $user->is_active) {
            return $this->errorResponse('Forbidden', 403);
        }

        // Prevent public users from logging in: enforce role whitelist
        if (! in_array($user->role, self::ALLOWED_ROLES, true)) {
            return $this->errorResponse('Forbidden', 403);
        }

        $deviceName = $data['device_name'] ?? 'mobile';

        // Token lifetimes (minutes)
        $accessTtl = (int) env('ACCESS_TOKEN_TTL', 60); // minutes
        $refreshTtl = (int) env('REFRESH_TOKEN_TTL', 60 * 24 * 7); // minutes (default 7 days)

        // Create access token
        $accessTokenResult = $user->createToken($deviceName . ':access', ['access']);
        $accessToken = $accessTokenResult->accessToken;
        $accessToken->expires_at = now()->addMinutes($accessTtl);
        $accessToken->save();

        // Create refresh token
        $refreshTokenResult = $user->createToken($deviceName . ':refresh', ['refresh']);
        $refreshToken = $refreshTokenResult->accessToken;
        $refreshToken->expires_at = now()->addMinutes($refreshTtl);
        $refreshToken->save();

        return $this->successResponse([
            // Strict contract fields
            'token' => $accessTokenResult->plainTextToken,
            'user' => [
                'id' => $user->id,
                'name' => $user->username,
                'role' => $user->role,
            ],
            // Legacy fields preserved to avoid breaking existing clients
            'access_token' => $accessTokenResult->plainTextToken,
            'refresh_token' => $refreshTokenResult->plainTextToken,
            'token_type' => 'Bearer',
            'expires_in' => $accessTtl * 60, // seconds
        ], 'Authenticated');
    }

    /**
     * Logout current token.
     */
    public function logout(Request $request): JsonResponse
    {
        if ($user = $request->user()) {
            $token = $user->currentAccessToken();
            if ($token) {
                $token->delete();
            }
        }

        return $this->successResponse(null, 'Logged out');
    }

    /**
     * Return authenticated user.
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return $this->errorResponse('Unauthenticated', 401);
        }

        return $this->successResponse([
            'user' => [
                'id' => $user->id,
                'name' => $user->username,
                'role' => $user->role,
                // Legacy fields preserved to avoid breaking existing clients
                'uuid' => $user->uuid,
                'username' => $user->username,
                'is_active' => (bool) $user->is_active,
            ],
        ]);
    }
}
