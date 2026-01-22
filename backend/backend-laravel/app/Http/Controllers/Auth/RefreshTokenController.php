<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class RefreshTokenController extends Controller
{
    public function refresh(Request $request)
    {
        $token = $request->bearerToken();
        if (! $token) {
            return $this->errorResponse('Unauthenticated', 401);
        }

        // find the token model by token string
        $plain = $token;
        // Sanctum tokens are stored as hashed; use ability to find current token via user
        $user = $request->user();
        if (! $user) {
            return $this->errorResponse('Unauthenticated', 401);
        }

        $current = $user->currentAccessToken();
        if (! $current || ! in_array('refresh', (array) json_decode($current->abilities ?? '[]'), true)) {
            return $this->errorResponse('Unauthenticated', 401);
        }

        if ($current->expires_at && now()->greaterThan($current->expires_at)) {
            return $this->errorResponse('Unauthenticated', 401);
        }

        // create new access token
        $accessTtl = (int) env('ACCESS_TOKEN_TTL', 60);
        $deviceName = $current->name ?? 'mobile';
        $accessTokenResult = $user->createToken($deviceName . ':access', ['access']);
        $accessToken = $accessTokenResult->accessToken;
        $accessToken->expires_at = now()->addMinutes($accessTtl);
        $accessToken->save();

        return $this->successResponse([
            'access_token' => $accessTokenResult->plainTextToken,
            'expires_in' => $accessTtl * 60,
        ]);
    }
}
