<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class IkdSubmission extends Model
{
    use HasUuids;

    protected $fillable = [
        'user_id',
        'nama',
        'nomor_telp',
        'alamat_manual',
        'jumlah_pemohon',
        'latitude',
        'longitude',
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
