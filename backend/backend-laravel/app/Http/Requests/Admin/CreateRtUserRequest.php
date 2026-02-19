<?php

namespace App\Http\Requests\Admin;

use App\Http\Requests\ApiRequest;

class CreateRtUserRequest extends ApiRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return auth()->check() && auth()->user()->role === 'SUPER_ADMIN';
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'username' => [
                'required',
                'string',
                'min:3',
                'max:255',
                'unique:users,username', // Ensure username is unique
                'regex:/^[a-zA-Z0-9_\-\.]+$/', // Only alphanumeric, dash, underscore, dot
            ],
            'password' => [
                'required',
                'string',
                'min:8',
                'max:255',
                'confirmed', // password_confirmation field must match
            ],
            'notes' => [
                'nullable',
                'string',
                'max:500',
            ],
        ];
    }

    /**
     * Custom error messages.
     */
    public function messages(): array
    {
        return [
            'username.required' => 'Username harus diisi',
            'username.unique' => 'Username sudah terdaftar',
            'username.regex' => 'Username hanya boleh mengandung huruf, angka, dash, underscore, dan titik',
            'password.required' => 'Password harus diisi',
            'password.min' => 'Password minimal 8 karakter',
            'password.confirmed' => 'Konfirmasi password tidak cocok',
            'notes.max' => 'Catatan maksimal 500 karakter',
        ];
    }
}
