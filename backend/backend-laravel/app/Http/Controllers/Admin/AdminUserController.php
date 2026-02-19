<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\CreateRtUserRequest;
use App\Models\User;
use App\Support\ApiResponder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Hash;

class AdminUserController extends Controller
{
    /**
     * Create a new RT user account.
     * 
     * Only SUPER_ADMIN can create RT accounts.
     */
    public function createRt(CreateRtUserRequest $request): JsonResponse
    {
        $validated = $request->validated();

        // Create new RT user
        $user = User::create([
            'uuid' => (string) Str::uuid(),
            'username' => $validated['username'],
            'password' => Hash::make($validated['password']),
            'role' => 'RT',
            'is_active' => true, // New accounts are active by default
            'notes' => $validated['notes'] ?? null,
        ]);

        // Return created user (without password)
        return ApiResponder::successResponse(
            [
                'id' => $user->id,
                'uuid' => $user->uuid,
                'username' => $user->username,
                'role' => $user->role,
                'is_active' => $user->is_active,
                'created_at' => $user->created_at,
            ],
            'RT user created successfully',
            201
        );
    }

    /**
     * List all RT users.
     * 
     * Only SUPER_ADMIN can list RT users.
     * Supports filtering, sorting, and pagination.
     */
    public function listRt(Request $request): JsonResponse
    {
        $perPage = (int) $request->query('per_page', 15);
        $page = (int) $request->query('page', 1);
        $search = $request->query('search', '');
        $sortBy = $request->query('sort_by', 'created_at');
        $sortOrder = $request->query('sort_order', 'desc');

        // Validate pagination and sort parameters
        $perPage = min(max($perPage, 1), 100);
        $sortOrder = in_array(strtolower($sortOrder), ['asc', 'desc']) ? strtolower($sortOrder) : 'desc';
        $sortableFields = ['id', 'uuid', 'username', 'is_active', 'created_at'];
        $sortBy = in_array($sortBy, $sortableFields) ? $sortBy : 'created_at';

        // Build query
        $query = User::where('role', 'RT');

        if (! empty($search)) {
            $query->where(function ($q) use ($search) {
                $q->where('username', 'like', "%{$search}%")
                    ->orWhere('uuid', 'like', "%{$search}%");
            });
        }

        // Paginate
        $users = $query->orderBy($sortBy, $sortOrder)
            ->paginate($perPage, ['id', 'uuid', 'username', 'is_active', 'created_at']);

        return ApiResponder::successResponse(
            $users->items(),
            'RT users retrieved successfully',
            200,
            [
                'current_page' => $users->currentPage(),
                'per_page' => $users->perPage(),
                'total' => $users->total(),
                'last_page' => $users->lastPage(),
            ]
        );
    }

    /**
     * Get single RT user details.
     * 
     * Only SUPER_ADMIN can view RT user details.
     */
    public function showRt(string $id): JsonResponse
    {
        // Accept both id and uuid
        $user = User::where('role', 'RT')
            ->where(function ($q) use ($id) {
                $q->where('id', $id)->orWhere('uuid', $id);
            })
            ->first();

        if (! $user) {
            return ApiResponder::error('RT user not found', 404);
        }

        return ApiResponder::successResponse(
            [
                'id' => $user->id,
                'uuid' => $user->uuid,
                'username' => $user->username,
                'is_active' => $user->is_active,
                'notes' => $user->notes,
                'created_at' => $user->created_at,
                'updated_at' => $user->updated_at,
            ],
            'RT user retrieved successfully'
        );
    }

    /**
     * Update RT user (username, notes, is_active status).
     * 
     * Only SUPER_ADMIN can update RT users.
     * Password changes not allowed through this endpoint (separate endpoint needed).
     */
    public function updateRt(string $id, Request $request): JsonResponse
    {
        $user = User::where('role', 'RT')
            ->where(function ($q) use ($id) {
                $q->where('id', $id)->orWhere('uuid', $id);
            })
            ->first();

        if (! $user) {
            return ApiResponder::error('RT user not found', 404);
        }

        // Validate input
        $validated = $request->validate([
            'username' => [
                'sometimes',
                'string',
                'min:3',
                'max:255',
                'unique:users,username,' . $user->id,
                'regex:/^[a-zA-Z0-9_\-\.]+$/',
            ],
            'is_active' => ['sometimes', 'boolean'],
            'notes' => ['nullable', 'string', 'max:500'],
        ], [
            'username.unique' => 'Username sudah terdaftar',
            'username.regex' => 'Username hanya boleh mengandung huruf, angka, dash, underscore, dan titik',
            'notes.max' => 'Catatan maksimal 500 karakter',
        ]);

        $user->update($validated);

        return ApiResponder::successResponse(
            [
                'id' => $user->id,
                'uuid' => $user->uuid,
                'username' => $user->username,
                'is_active' => $user->is_active,
                'notes' => $user->notes,
                'updated_at' => $user->updated_at,
            ],
            'RT user updated successfully'
        );
    }

    /**
     * Delete RT user.
     * 
     * Only SUPER_ADMIN can delete RT users.
     */
    public function deleteRt(string $id): JsonResponse
    {
        $user = User::where('role', 'RT')
            ->where(function ($q) use ($id) {
                $q->where('id', $id)->orWhere('uuid', $id);
            })
            ->first();

        if (! $user) {
            return ApiResponder::error('RT user not found', 404);
        }

        // Store username for response
        $username = $user->username;
        $user->delete();

        return ApiResponder::successResponse(
            [
                'username' => $username,
                'deleted_at' => now(),
            ],
            'RT user deleted successfully'
        );
    }

    /**
     * Reset RT user password.
     * 
     * Only SUPER_ADMIN can reset RT user passwords.
     */
    public function resetPassword(string $id, Request $request): JsonResponse
    {
        $user = User::where('role', 'RT')
            ->where(function ($q) use ($id) {
                $q->where('id', $id)->orWhere('uuid', $id);
            })
            ->first();

        if (! $user) {
            return ApiResponder::error('RT user not found', 404);
        }

        $validated = $request->validate([
            'password' => [
                'required',
                'string',
                'min:8',
                'max:255',
                'confirmed',
            ],
        ], [
            'password.min' => 'Password minimal 8 karakter',
            'password.confirmed' => 'Konfirmasi password tidak cocok',
        ]);

        $user->update(['password' => Hash::make($validated['password'])]);

        return ApiResponder::successResponse(
            [
                'id' => $user->id,
                'uuid' => $user->uuid,
                'username' => $user->username,
                'message' => 'Password has been reset',
            ],
            'RT user password reset successfully'
        );
    }
}
