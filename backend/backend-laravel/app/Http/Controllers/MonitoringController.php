<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Support\ApiResponder;
use Illuminate\Http\Request;

class MonitoringController extends Controller
{
    /**
     * Get all admin accounts (SUPER_ADMIN only)
     */
    public function adminAccounts()
    {
        $admins = User::whereIn('role', ['SUPER_ADMIN', 'ADMIN_KTP', 'ADMIN_IKD', 'ADMIN_PERKAWINAN'])
            ->select('id', 'uuid', 'username', 'role', 'is_active', 'created_at')
            ->orderBy('created_at', 'desc')
            ->get();

        return ApiResponder::success($admins, 'Admin accounts retrieved successfully');
    }

    /**
     * Get all RT accounts (SUPER_ADMIN only)
     */
    public function rtAccounts()
    {
        $rtAccounts = User::where('role', 'RT')
            ->select('id', 'uuid', 'username', 'role', 'is_active', 'created_at')
            ->orderBy('created_at', 'desc')
            ->get();

        return ApiResponder::success($rtAccounts, 'RT accounts retrieved successfully');
    }

    /**
     * Update admin account (password/username)
     */
    public function updateAdminAccount(Request $request, $id)
    {
        $admin = User::findOrFail($id);

        // Ensure it's an admin account
        if (!in_array($admin->role, ['SUPER_ADMIN', 'ADMIN_KTP', 'ADMIN_IKD', 'ADMIN_PERKAWINAN'])) {
            return ApiResponder::error('Target akun bukan akun admin', 403);
        }

        $validated = $request->validate([
            'username' => 'sometimes|string|unique:users,username,' . $admin->id,
            'password' => 'sometimes|string|min:6',
        ]);

        if (isset($validated['username'])) {
            $admin->username = $validated['username'];
        }

        if (isset($validated['password'])) {
            $admin->password = $validated['password'];
        }

        $admin->save();

        return ApiResponder::success([
            'id' => $admin->id,
            'username' => $admin->username,
            'role' => $admin->role,
            'is_active' => $admin->is_active,
        ], 'Admin account updated successfully');
    }

    /**
     * Update RT account (password/username)
     */
    public function updateRtAccount(Request $request, $id)
    {
        $rtAccount = User::findOrFail($id);

        // Ensure it's an RT account
        if ($rtAccount->role !== 'RT') {
            return ApiResponder::error('Target akun bukan akun RT', 403);
        }

        $validated = $request->validate([
            'username' => 'sometimes|string|unique:users,username,' . $rtAccount->id,
            'password' => 'sometimes|string|min:6',
        ]);

        if (isset($validated['username'])) {
            $rtAccount->username = $validated['username'];
        }

        if (isset($validated['password'])) {
            $rtAccount->password = $validated['password'];
        }

        $rtAccount->save();

        return ApiResponder::success([
            'id' => $rtAccount->id,
            'username' => $rtAccount->username,
            'role' => $rtAccount->role,
            'is_active' => $rtAccount->is_active,
        ], 'RT account updated successfully');
    }

    /**
     * Delete RT account (SUPER_ADMIN only)
     */
    public function deleteRtAccount($id)
    {
        $rtAccount = User::findOrFail($id);

        // Ensure it's an RT account
        if ($rtAccount->role !== 'RT') {
            return ApiResponder::error('Target akun bukan akun RT', 403);
        }

        $rtAccount->delete();

        return ApiResponder::success(null, 'RT account deleted successfully');
    }

    /**
     * Get monitoring stats (for legacy monitoring page)
     */
    public function stats()
    {
        $adminCount = User::whereIn('role', ['SUPER_ADMIN', 'ADMIN_KTP', 'ADMIN_IKD', 'ADMIN_PERKAWINAN'])->count();
        $rtCount = User::where('role', 'RT')->count();

        $stats = [
            ['label' => 'Total Admin', 'value' => (string) $adminCount],
            ['label' => 'Total RT', 'value' => (string) $rtCount],
        ];

        return ApiResponder::success($stats, 'Monitoring stats retrieved successfully');
    }
}
