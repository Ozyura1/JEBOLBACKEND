<?php

namespace App\Http\Requests\Perkawinan;

use App\Http\Requests\ApiRequest;

class RejectPerkawinanRequest extends ApiRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'catatan_admin' => ['nullable', 'string', 'max:500'],
        ];
    }
}
