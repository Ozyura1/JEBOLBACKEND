<?php

namespace App\Http\Controllers\Perkawinan;

use App\Http\Controllers\Controller;
use App\Http\Requests\Perkawinan\IndexPerkawinanRequest;
use App\Http\Requests\Perkawinan\RejectPerkawinanRequest;
use App\Http\Requests\Perkawinan\VerifyPerkawinanRequest;
use App\Models\PerkawinanRequest;
use App\Models\AuditLog;

class AdminPerkawinanController extends Controller
{
    // Show details of a specific request
    public function show($uuid)
    {
        $req = PerkawinanRequest::where('uuid', $uuid)->first();
        if (! $req) {
            return $this->errorResponse('Not found', 404);
        }

        $this->authorize('view', $req);

        return $this->successResponse($req, 'Perkawinan request detail');
    }

    // Verify a request (ADMIN_PERKAWINAN required)
    public function verify(VerifyPerkawinanRequest $request, $uuid)
    {
        $req = PerkawinanRequest::where('uuid', $uuid)->first();
        if (! $req) {
            return $this->errorResponse('Not found', 404);
        }

        $this->authorize('verify', $req);

        if ($req->status !== 'PENDING') {
            return $this->errorResponse('Already processed', 400);
        }

        $req->status = 'VERIFIED';
        // ensure we store the user's primary key (id), not the auth identifier (username)
        $req->verified_by_user_id = auth()->user() ? auth()->user()->getKey() : null;
        $req->verified_at = now();
        $req->catatan_admin = $request->input('catatan_admin');
        $req->save();

        // record audit log
        try {
            AuditLog::create([
                'user_id' => auth()->user() ? auth()->user()->getKey() : null,
                'action' => 'VERIFY_PERKAWINAN',
                'auditable_type' => PerkawinanRequest::class,
                'auditable_id' => $req->id,
                'old_values' => null,
                'new_values' => [
                    'status' => $req->status,
                    'verified_by_user_id' => $req->verified_by_user_id,
                    'verified_at' => $req->verified_at ? $req->verified_at->toDateTimeString() : null,
                    'catatan_admin' => $req->catatan_admin,
                ],
                'ip_address' => request()->ip(),
                'user_agent' => request()->userAgent(),
            ]);
        } catch (\Throwable $e) {
            // don't break the main flow if audit logging fails
        }

        return $this->successResponse([
            'uuid' => $req->uuid,
            'status' => $req->status,
        ], 'Perkawinan verified');
    }

    // Reject a request (ADMIN_PERKAWINAN required)
    public function reject(RejectPerkawinanRequest $request, $uuid)
    {
        $req = PerkawinanRequest::where('uuid', $uuid)->first();
        if (! $req) {
            return $this->errorResponse('Not found', 404);
        }

        $this->authorize('verify', $req);

        if ($req->status !== 'PENDING') {
            return $this->errorResponse('Already processed', 400);
        }

        $req->status = 'REJECTED';
        $req->verified_by_user_id = auth()->user() ? auth()->user()->getKey() : null;
        $req->verified_at = now();
        $req->catatan_admin = $request->input('catatan_admin');
        $req->save();

        // record audit log for rejection
        try {
            AuditLog::create([
                'user_id' => auth()->user() ? auth()->user()->getKey() : null,
                'action' => 'REJECT_PERKAWINAN',
                'auditable_type' => PerkawinanRequest::class,
                'auditable_id' => $req->id,
                'old_values' => null,
                'new_values' => [
                    'status' => $req->status,
                    'verified_by_user_id' => $req->verified_by_user_id,
                    'verified_at' => $req->verified_at ? $req->verified_at->toDateTimeString() : null,
                    'catatan_admin' => $req->catatan_admin,
                ],
                'ip_address' => request()->ip(),
                'user_agent' => request()->userAgent(),
            ]);
        } catch (\Throwable $e) {
            // ignore audit failures
        }

        return $this->successResponse([
            'uuid' => $req->uuid,
            'status' => $req->status,
        ], 'Perkawinan rejected');
    }

    // Admin listing with pagination and optional status filter
    public function index(IndexPerkawinanRequest $request)
    {
        $data = $request->validated();
        $query = PerkawinanRequest::query();
        $status = $data['status'];
        if ($status === 'SUBMITTED') {
            $status = 'PENDING';
        }
        $query->where('status', $status);

        $perPage = (int) ($data['per_page'] ?? 15);
        $items = $query->orderBy('created_at', 'desc')->paginate($perPage);

        $meta = [
            'current_page' => $items->currentPage(),
            'last_page' => $items->lastPage(),
            'per_page' => $items->perPage(),
            'total' => $items->total(),
            'path' => $items->path(),
            'from' => $items->firstItem(),
            'to' => $items->lastItem(),
        ];

        return $this->successResponse($items->items(), 'Perkawinan requests retrieved', 200, $meta);
    }
}
