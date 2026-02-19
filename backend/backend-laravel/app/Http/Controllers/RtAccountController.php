<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class RtAccountController extends Controller
{
    // Middleware is handled in routes/api.php

    /**
     * Display a listing of RT accounts
     */
    public function index()
    {
        $accounts = User::where('role', 'RT')
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return response()->json([
            'success' => true,
            'message' => 'Data akun RT berhasil diambil',
            'data' => $accounts->items(),
            'pagination' => [
                'total' => $accounts->total(),
                'per_page' => $accounts->perPage(),
                'current_page' => $accounts->currentPage(),
                'last_page' => $accounts->lastPage(),
            ]
        ]);
    }

    /**
     * Store a newly created RT account
     */
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'username' => 'required|string|max:100|unique:users,username',
                'phone' => 'required|string|max:20',
                'village' => 'required|string|max:255',
                'sub_district' => 'required|string|max:255',
                'district' => 'required|string|max:255',
                'province' => 'required|string|max:255',
                'password' => 'required|string|min:6',
            ]);

            // Create user
            $user = User::create([
                'uuid' => Str::uuid(),
                'username' => $validated['username'],
                'email' => null,
                'password' => Hash::make($validated['password']),
                'role' => 'RT',
                'is_active' => true,
            ]);

            // Log the action (if AuditLog model exists)
            try {
                \App\Models\AuditLog::create([
                    'user_id' => auth()->id(),
                    'action' => 'CREATE_RT_ACCOUNT',
                    'resource' => 'RT Account',
                    'resource_id' => $user->id,
                    'details' => "Membuat akun RT untuk {$validated['username']}",
                ]);
            } catch (\Exception $logError) {
                // Log silently if AuditLog fails
            }

            return response()->json([
                'success' => true,
                'message' => 'Akun RT berhasil dibuat',
                'data' => [
                    'id' => $user->id,
                    'uuid' => $user->uuid,
                    'name' => $validated['name'],
                    'username' => $user->username,
                    'phone' => $validated['phone'],
                    'village' => $validated['village'],
                    'sub_district' => $validated['sub_district'],
                    'district' => $validated['district'],
                    'province' => $validated['province'],
                    'role' => $user->role,
                    'is_active' => $user->is_active,
                    'created_at' => $user->created_at,
                ]
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            \Log::error('RT Account Creation Error: ' . $e->getMessage(), [
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString(),
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat akun RT: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Display the specified RT account
     */
    public function show($id)
    {
        $user = User::where('role', 'RT')->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Data akun RT berhasil diambil',
            'data' => $user,
        ]);
    }

    /**
     * Update the specified RT account
     */
    public function update(Request $request, $id)
    {
        $user = User::where('role', 'RT')->findOrFail($id);

        $validated = $request->validate([
            'username' => ['sometimes', 'string', 'max:100', Rule::unique('users')->ignore($user->id)],
            'email' => ['sometimes', 'email', Rule::unique('users')->ignore($user->id)],
            'password' => 'sometimes|string|min:6',
            'is_active' => 'sometimes|boolean',
        ]);

        try {
            if (isset($validated['password'])) {
                $validated['password'] = Hash::make($validated['password']);
            }

            $user->update($validated);

            try {
                \App\Models\AuditLog::create([
                    'user_id' => auth()->id(),
                    'action' => 'UPDATE_RT_ACCOUNT',
                    'resource' => 'RT Account',
                    'resource_id' => $user->id,
                    'details' => "Memperbarui akun RT {$user->username}",
                ]);
            } catch (\Exception $logError) {
                // Log silently if AuditLog fails
            }

            return response()->json([
                'success' => true,
                'message' => 'Akun RT berhasil diperbarui',
                'data' => $user,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui akun RT: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete the specified RT account
     */
    public function destroy($id)
    {
        $user = User::where('role', 'RT')->findOrFail($id);

        try {
            $username = $user->username;
            $user->delete();

            try {
                \App\Models\AuditLog::create([
                    'user_id' => auth()->id(),
                    'action' => 'DELETE_RT_ACCOUNT',
                    'resource' => 'RT Account',
                    'resource_id' => $id,
                    'details' => "Menghapus akun RT $username",
                ]);
            } catch (\Exception $logError) {
                // Log silently if AuditLog fails
            }

            return response()->json([
                'success' => true,
                'message' => 'Akun RT berhasil dihapus',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus akun RT: ' . $e->getMessage(),
            ], 500);
        }
    }
}
