<?php

namespace App\Policies;

use App\Models\PerkawinanRequest;
use App\Models\User;

class PerkawinanRequestPolicy
{
    public function view(User $user, PerkawinanRequest $request): bool
    {
        if (! $user->is_active) {
            return false;
        }

        return in_array($user->role, ['SUPER_ADMIN', 'ADMIN_PERKAWINAN'], true);
    }

    public function verify(User $user, PerkawinanRequest $request): bool
    {
        if (! $user->is_active) {
            return false;
        }

        return in_array($user->role, ['SUPER_ADMIN', 'ADMIN_PERKAWINAN'], true);
    }
}
