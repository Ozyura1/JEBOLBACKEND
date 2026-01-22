<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PerkawinanRequest extends Model
{
    protected $table = 'perkawinan_requests';
    protected $fillable = [
        'nama_pemohon',
        'nik_pemohon',
        'no_hp_pemohon',
        'nama_pasangan',
        'nik_pasangan',
        'no_hp_pasangan',
        'alamat_domisili',
        'tanggal_perkawinan',
        'tempat_perkawinan',
        'dokumen',
        'status',
        'catatan_admin',
        'verified_by_user_id',
        'verified_at',
    ];

    protected $casts = [
        'tanggal_perkawinan' => 'date',
        'verified_at' => 'datetime',
        'dokumen' => 'array',
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

    public function verifiedBy()
    {
        return $this->belongsTo(\App\Models\User::class, 'verified_by_user_id');
    }
}
