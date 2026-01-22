<?php

namespace App\Http\Requests\Perkawinan;

use App\Http\Requests\ApiRequest;

class IndexPerkawinanRequest extends ApiRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'status' => ['sometimes', 'string', 'in:PENDING,SUBMITTED,VERIFIED,REJECTED'],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
            'page' => ['sometimes', 'integer', 'min:1'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('status')) {
            $this->merge([
                'status' => strtoupper((string) $this->input('status')),
            ]);
        } else {
            $this->merge([
                'status' => 'PENDING',
            ]);
        }
    }
}
