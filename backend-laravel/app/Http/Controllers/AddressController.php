<?php

namespace App\Http\Controllers;

use App\Models\Address;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

/**
 * AddressController
 *
 * Handles CRUD operations for user addresses.
 * All operations are scoped to the authenticated user.
 */
class AddressController extends Controller
{
    /**
     * Get all addresses for the authenticated user.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $user = auth()->user();

            $addresses = Address::where('user_id', $user->id)
                ->orderByDesc('is_default')
                ->orderByDesc('created_at')
                ->get();

            return response()->json([
                'success' => true,
                'message' => 'Alamat berhasil diambil',
                'data' => $addresses,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil alamat: ' . $e->getMessage(),
                'data' => null,
            ], 500);
        }
    }

    /**
     * Store a new address for the authenticated user.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'address' => 'required|string|max:500',
                'latitude' => 'required|numeric|between:-90,90',
                'longitude' => 'required|numeric|between:-180,180',
                'note' => 'nullable|string|max:500',
                'is_default' => 'nullable|boolean',
            ]);

            $user = auth()->user();

            // If marking as default, unset default on other addresses
            if ($validated['is_default'] ?? false) {
                Address::where('user_id', $user->id)->update(['is_default' => false]);
            }

            $address = Address::create([
                'user_id' => $user->id,
                'address' => $validated['address'],
                'latitude' => $validated['latitude'],
                'longitude' => $validated['longitude'],
                'note' => $validated['note'] ?? null,
                'is_default' => $validated['is_default'] ?? false,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Alamat berhasil disimpan',
                'data' => $address,
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan alamat: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get a single address by ID.
     *
     * @param string $id
     * @return JsonResponse
     */
    public function show(string $id): JsonResponse
    {
        try {
            $user = auth()->user();
            $address = Address::where('id', $id)
                ->where('user_id', $user->id)
                ->firstOrFail();

            return response()->json([
                'success' => true,
                'message' => 'Alamat berhasil diambil',
                'data' => $address,
            ]);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Alamat tidak ditemukan',
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil alamat: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update an address.
     *
     * @param Request $request
     * @param string $id
     * @return JsonResponse
     */
    public function update(Request $request, string $id): JsonResponse
    {
        try {
            $user = auth()->user();
            $address = Address::where('id', $id)
                ->where('user_id', $user->id)
                ->firstOrFail();

            $validated = $request->validate([
                'address' => 'nullable|string|max:500',
                'latitude' => 'nullable|numeric|between:-90,90',
                'longitude' => 'nullable|numeric|between:-180,180',
                'note' => 'nullable|string|max:500',
                'is_default' => 'nullable|boolean',
            ]);

            // If marking as default, unset default on other addresses
            if ($validated['is_default'] ?? false) {
                Address::where('user_id', $user->id)
                    ->where('id', '!=', $id)
                    ->update(['is_default' => false]);
            }

            $address->update($validated);

            return response()->json([
                'success' => true,
                'message' => 'Alamat berhasil diperbarui',
                'data' => $address,
            ]);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Alamat tidak ditemukan',
            ], 404);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui alamat: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete an address.
     *
     * @param string $id
     * @return JsonResponse
     */
    public function destroy(string $id): JsonResponse
    {
        try {
            $user = auth()->user();
            $address = Address::where('id', $id)
                ->where('user_id', $user->id)
                ->firstOrFail();

            $address->delete();

            return response()->json([
                'success' => true,
                'message' => 'Alamat berhasil dihapus',
            ]);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Alamat tidak ditemukan',
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus alamat: ' . $e->getMessage(),
            ], 500);
        }
    }
}
