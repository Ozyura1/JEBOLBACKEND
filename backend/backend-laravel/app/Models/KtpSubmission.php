<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class KtpSubmission extends Model
{
    use HasUuids;

    protected $fillable = [
        'user_id',
        'nama',
        'nomor_telp',
        'kategori',
        'kategori_khusus',
        'minimal_usia',
        'alamat_manual',
        'latitude',
        'longitude',
        'jumlah_pemohon',
        'attachment_path',
        'status',
        'rejection_reason',
        'approved_at',
        'rejected_at',
        'approved_by',
        'scheduled_at',
        'schedule_notes',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'jumlah_pemohon' => 'integer',
        'approved_at' => 'datetime',
        'rejected_at' => 'datetime',
        'scheduled_at' => 'datetime',
    ];

    public $timestamps = true;

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function approvedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by');
    }
}
