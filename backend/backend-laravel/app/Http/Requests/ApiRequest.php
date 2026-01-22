<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;
use App\Support\ApiResponder;

abstract class ApiRequest extends FormRequest
{
    protected function failedValidation(Validator $validator): void
    {
        throw new HttpResponseException(
            ApiResponder::error('Validation failed', 422, $validator->errors()->toArray()
)
        );
    }

    protected function failedAuthorization(): void
    {
        throw new HttpResponseException(
            ApiResponder::error('Forbidden', 403)
        );
    }
}
