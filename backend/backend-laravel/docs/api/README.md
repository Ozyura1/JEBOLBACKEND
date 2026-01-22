Perkawinan API (short)

Base URL: http://localhost:8000/api

Endpoints:

- POST /api/perkawinan/submit
  - Public submission. Body: nama_pemohon, nik_pemohon(16), no_hp_pemohon, nama_pasangan, nik_pasangan(16), no_hp_pasangan, alamat_domisili, tanggal_perkawinan (YYYY-MM-DD, today or future), tempat_perkawinan
  - Returns: { success, message, data: { uuid, status } }

- GET /api/perkawinan/{uuid}/status?nik_pemohon=...
  - Public status check. Requires UUID and matching nik_pemohon.
  - Returns status, verified_at, catatan_admin

- GET /api/admin/perkawinan (auth)
  - Admin listing with status filter and pagination

- GET /api/admin/perkawinan/{uuid} (auth)
  - Admin view details

- POST /api/admin/perkawinan/{uuid}/verify (auth)
  - Admin verify request

- POST /api/admin/perkawinan/{uuid}/reject (auth)
  - Admin reject request

Authentication:
- Use /api/auth/login to obtain token, include Authorization: Bearer <token> header for protected endpoints.

Notes:
- Login is rate-limited.
- CORS: In development CORS allows all origins. For production set `FRONTEND_URL` in your environment and ensure `CORS_SUPPORTS_CREDENTIALS` is `true` if using cookies/sanctum. Example in `.env`:

  FRONTEND_URL=https://app.jebol.example
  CORS_SUPPORTS_CREDENTIALS=false

  After updating `.env`, run `php artisan config:clear` or restart the app to apply.
