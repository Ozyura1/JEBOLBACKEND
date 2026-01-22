<?php

namespace App\Traits;

use App\Support\ApiResponder;

trait ApiResponse
{
    protected function successResponse(mixed $data = null, string $message = '', int $status = 200, array $meta = null)
    {
        return ApiResponder::success($data, $message, $status, $meta);
    }

    protected function errorResponse(string $message, int $status = 400, array $errors = null)
    {
        return ApiResponder::error($message, $status, $errors);
    }
}
