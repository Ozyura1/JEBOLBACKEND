<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PerkawinanRequest extends Model
{
    protected $table = 'perkawinan_requests';
    protected $fillable = [
        'uuid', 'nama_pemohon', 'nama_pasangan', 'tanggal_perkawinan', 'tempat', 'dokumen', 'status',
        'nik_pemohon', 'nik_pasangan', 'alamat', 'no_hp_pemohon', 'catatan_admin', 'verified_by_user_id', 'verified_at',
    ];

    protected $casts = [
        'dokumen' => 'array',
        'tanggal_perkawinan' => 'date',
        'verified_at' => 'datetime',
    ];

    public static function boot()
    {
        parent::boot();
        static::creating(function ($model) {
            if (empty($model->uuid)) {
                $model->uuid = (string) \Illuminate\Support\Str::uuid();
            }
        });
    }
}
