<?php

namespace App\Http\Requests\Perkawinan;

use App\Http\Requests\ApiRequest;

class TrackPerkawinanRequest extends ApiRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'nik_pemohon' => ['required', 'regex:/^[1-9][0-9]{15}$/'],
        ];
    }

    public function messages(): array
    {
        return [
            'nik_pemohon.required' => 'NIK pemohon wajib diisi',
            'nik_pemohon.regex' => 'NIK pemohon harus 16 digit angka',
        ];
    }
}
