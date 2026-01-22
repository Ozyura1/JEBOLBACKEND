<?php

namespace App\Http\Requests\Perkawinan;

use App\Http\Requests\ApiRequest;

class SubmitPerkawinanRequest extends ApiRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'nama_pemohon' => ['required', 'string', 'max:255', 'regex:/^[A-Za-z\s\'\.\-]+$/u'],
            'nik_pemohon' => ['required', 'regex:/^[1-9][0-9]{15}$/'],
            'no_hp_pemohon' => ['required', 'regex:/^08[0-9]{8,11}$/'],

            'nama_pasangan' => ['required', 'string', 'max:255', 'regex:/^[A-Za-z\s\'\.\-]+$/u'],
            'nik_pasangan' => ['required', 'regex:/^[1-9][0-9]{15}$/', 'different:nik_pemohon'],
            'no_hp_pasangan' => ['required', 'regex:/^08[0-9]{8,11}$/'],

            'alamat_domisili' => ['required', 'string', 'max:500', 'regex:/^[A-Za-z0-9\s\,\.\-\/\#]+$/u'],

            'tanggal_perkawinan' => ['required', 'date_format:Y-m-d', 'after_or_equal:today'],
            'tempat_perkawinan' => ['required', 'string', 'max:255', 'regex:/^[A-Za-z0-9\s\,\.\-\/]+$/u'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('tanggal_perkawinan')) {
            $this->merge([
                'tanggal_perkawinan' => trim((string) $this->input('tanggal_perkawinan')),
            ]);
        }
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            // prevent duplicate pending submissions for same pair
            $nikPemohon = $this->input('nik_pemohon');
            $nikPasangan = $this->input('nik_pasangan');
            if ($nikPemohon && $nikPasangan) {
                $exists = \App\Models\PerkawinanRequest::where(function ($q) use ($nikPemohon, $nikPasangan) {
                    $q->where('nik_pemohon', $nikPemohon)
                      ->where('nik_pasangan', $nikPasangan);
                })->whereIn('status', ['PENDING'])->exists();

                if ($exists) {
                    $validator->errors()->add('nik_pemohon', 'Sudah ada permohonan menunggu untuk pasangan ini');
                }
            }
        });
    }

    public function messages(): array
    {
        return [
            'nama_pemohon.required' => 'Nama pemohon wajib diisi',
            'nama_pemohon.regex' => 'Nama pemohon hanya boleh huruf dan spasi',
            'nik_pemohon.required' => 'NIK pemohon wajib diisi',
            'nik_pemohon.regex' => 'NIK pemohon harus 16 digit angka',
            'no_hp_pemohon.required' => 'Nomor HP pemohon wajib diisi',
            'no_hp_pemohon.regex' => 'Nomor HP pemohon tidak valid',

            'nama_pasangan.required' => 'Nama pasangan wajib diisi',
            'nama_pasangan.regex' => 'Nama pasangan hanya boleh huruf dan spasi',
            'nik_pasangan.required' => 'NIK pasangan wajib diisi',
            'nik_pasangan.regex' => 'NIK pasangan harus 16 digit angka',
            'nik_pasangan.different' => 'NIK pasangan harus berbeda dengan NIK pemohon',
            'no_hp_pasangan.required' => 'Nomor HP pasangan wajib diisi',
            'no_hp_pasangan.regex' => 'Nomor HP pasangan tidak valid',

            'alamat_domisili.required' => 'Alamat domisili wajib diisi',
            'alamat_domisili.regex' => 'Alamat domisili mengandung karakter tidak valid',

            'tanggal_perkawinan.required' => 'Tanggal perkawinan wajib diisi',
            'tanggal_perkawinan.date_format' => 'Format tanggal perkawinan harus YYYY-MM-DD',
            'tanggal_perkawinan.after_or_equal' => 'Tanggal perkawinan tidak boleh sebelum hari ini',

            'tempat_perkawinan.required' => 'Tempat perkawinan wajib diisi',
            'tempat_perkawinan.regex' => 'Tempat perkawinan mengandung karakter tidak valid',
        ];
    }
}
