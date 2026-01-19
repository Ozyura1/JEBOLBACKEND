<?php

namespace App\Http\Controllers\Perkawinan;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\PerkawinanRequest;

class AdminPerkawinanController extends Controller
{
    // Verify a request (ADMIN_PERKAWINAN required)
    public function verify(Request $request, $uuid)
    {
        $req = PerkawinanRequest::where('uuid', $uuid)->first();
        if (! $req) {
            return response()->json(['success' => false, 'message' => 'Not found'], 404);
        }

        if ($req->status === 'VERIFIED') {
            return response()->json(['success' => false, 'message' => 'Already verified'], 400);
        }

        $req->status = 'VERIFIED';
        $req->verified_by_user_id = auth()->id();
        $req->verified_at = now();
        $req->catatan_admin = $request->input('catatan_admin');
        $req->save();

        return response()->json(['success' => true, 'data' => ['uuid' => $req->uuid, 'status' => $req->status]]);
    }

    // Admin listing with pagination and optional status filter
    public function index(Request $request)
    {
        $query = PerkawinanRequest::query();
        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        $perPage = (int) $request->input('per_page', 15);
        $items = $query->orderBy('created_at', 'desc')->paginate($perPage);

        return response()->json($items);
    }
}
