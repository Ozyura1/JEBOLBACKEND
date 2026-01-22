<?php

namespace App\Support;

class ApiResponder
{
    public static function success(mixed $data = null, string $message = '', int $status = 200, array $meta = null)
    {
        $payload = [
            'success' => true,
            'message' => $message,
            'data' => $data,
            'errors' => [],
        ];

        if (! empty($meta)) {
            $payload['meta'] = $meta;
        }

        return response()->json($payload, $status);
    }

    public static function error(string $message, int $status = 400, array $errors = null, mixed $data = null)
    {
        $payload = [
            'success' => false,
            'message' => $message,
            'data' => $data,
            'errors' => $errors ?? [],
        ];

        return response()->json($payload, $status);
    }
}
