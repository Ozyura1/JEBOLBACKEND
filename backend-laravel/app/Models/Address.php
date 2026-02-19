<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Address Model
 *
 * Represents a saved address location with coordinates.
 * Users can save multiple addresses and use them for service ordering.
 *
 * @property string $id
 * @property string $user_id
 * @property string $address
 * @property float $latitude
 * @property float $longitude
 * @property string|null $note
 * @property bool $is_default
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 * @property User $user
 */
class Address extends Model
{
    use HasUuids;

    protected $fillable = [
        'user_id',
        'address',
        'latitude',
        'longitude',
        'note',
        'is_default',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'is_default' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Get the user that owns this address.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
