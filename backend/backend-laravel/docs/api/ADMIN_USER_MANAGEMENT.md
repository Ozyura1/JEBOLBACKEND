# 📘 Fitur: Admin RT User Management (SUPER_ADMIN)

## 🎯 Overview
Fitur ini memungkinkan SUPER_ADMIN untuk mengelola akun RT (Rukun Tetangga) melalui API endpoints:
- ✅ Create RT user (dengan validation)
- ✅ List RT users (dengan pagination, search, sorting)
- ✅ View single RT user
- ✅ Update RT user (username, notes, is_active status)
- ✅ Delete RT user
- ✅ Reset RT user password

## 🔒 Authorization
- **Endpoint Group:** `/api/admin/users/rt/*`
- **Middleware:** `auth:sanctum` + `RoleMiddleware:SUPER_ADMIN`
- **Akses:** Hanya SUPER_ADMIN yang bisa menjalankan operasi ini

## 📁 Files Created/Modified

### 1. **Request Validator**
**File:** `app/Http/Requests/Admin/CreateRtUserRequest.php`

Validator untuk create RT user dengan rules:
```php
- username: required, unique, 3-255 chars, alphanumeric + dash/underscore/dot
- password: required, min 8 chars, confirmed (password_confirmation field)
- notes: optional, max 500 chars
```

### 2. **Controller**
**File:** `app/Http/Controllers/Admin/AdminUserController.php`

Controller dengan 6 methods:
- `createRt()` - Create new RT user
- `listRt()` - List RT users dengan pagination & search
- `showRt()` - Get single RT user (by id atau uuid)
- `updateRt()` - Update RT user (username, notes, is_active)
- `deleteRt()` - Delete RT user
- `resetPassword()` - Reset RT user password

### 3. **Routes**
**File:** `routes/api.php`

```php
Route::prefix('admin/users/rt')->middleware(['auth:sanctum', RoleMiddleware::class . ':SUPER_ADMIN'])->group(function () {
    Route::post('create', 'createRt');        // POST /api/admin/users/rt/create
    Route::get('/', 'listRt');               // GET /api/admin/users/rt
    Route::get('{id}', 'showRt');            // GET /api/admin/users/rt/{id}
    Route::patch('{id}', 'updateRt');        // PATCH /api/admin/users/rt/{id}
    Route::delete('{id}', 'deleteRt');       // DELETE /api/admin/users/rt/{id}
    Route::post('{id}/reset-password', 'resetPassword'); // POST /api/admin/users/rt/{id}/reset-password
});
```

### 4. **Database Migration**
**File:** `database/migrations/2026_01_20_000000_add_notes_to_users_table.php`

Menambahkan `notes` column ke tabel `users`:
```sql
ALTER TABLE users ADD COLUMN notes LONGTEXT NULL AFTER is_active;
```

### 5. **Model Update**
**File:** `app/Models/User.php`

Update fillable array untuk include `notes`:
```php
protected $fillable = [
    'uuid',
    'username',
    'password',
    'role',
    'is_active',
    'notes', // NEW
];
```

### 6. **ApiResponder Update**
**File:** `app/Support/ApiResponder.php`

Tambah method `successResponse()` sebagai alias untuk `success()`.

## 🚀 API Endpoints

### 1. Create RT User
```
POST /api/admin/users/rt/create
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "username": "rt_001",
  "password": "SecurePass123",
  "password_confirmation": "SecurePass123",
  "notes": "RT untuk Kelurahan ABC"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "RT user created successfully",
  "data": {
    "id": 1,
    "uuid": "550e8400-e29b-41d4-a716-446655440000",
    "username": "rt_001",
    "role": "RT",
    "is_active": true,
    "created_at": "2026-01-20T10:30:00Z"
  },
  "errors": []
}
```

**Validation Error Response (422):**
```json
{
  "success": false,
  "message": "Validation failed",
  "data": null,
  "errors": {
    "username": ["Username sudah terdaftar"],
    "password": ["Password minimal 8 karakter"]
  }
}
```

### 2. List RT Users
```
GET /api/admin/users/rt?page=1&per_page=15&search=rt_001&sort_by=created_at&sort_order=desc
Authorization: Bearer {token}
```

**Query Parameters:**
- `page` (default: 1) - Page number
- `per_page` (default: 15, max: 100) - Items per page
- `search` (optional) - Search by username or uuid
- `sort_by` (default: created_at) - Field to sort by (id, uuid, username, is_active, created_at)
- `sort_order` (default: desc) - ASC or DESC

**Success Response (200):**
```json
{
  "success": true,
  "message": "RT users retrieved successfully",
  "data": [
    {
      "id": 1,
      "uuid": "550e8400-e29b-41d4-a716-446655440000",
      "username": "rt_001",
      "is_active": true,
      "created_at": "2026-01-20T10:30:00Z"
    },
    {
      "id": 2,
      "uuid": "660e8400-e29b-41d4-a716-446655440001",
      "username": "rt_002",
      "is_active": true,
      "created_at": "2026-01-20T10:35:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 15,
    "total": 2,
    "last_page": 1
  },
  "errors": []
}
```

### 3. Get Single RT User
```
GET /api/admin/users/rt/{id}
Authorization: Bearer {token}
```

**Path Parameters:**
- `id` - User ID atau UUID

**Success Response (200):**
```json
{
  "success": true,
  "message": "RT user retrieved successfully",
  "data": {
    "id": 1,
    "uuid": "550e8400-e29b-41d4-a716-446655440000",
    "username": "rt_001",
    "is_active": true,
    "notes": "RT untuk Kelurahan ABC",
    "created_at": "2026-01-20T10:30:00Z",
    "updated_at": "2026-01-20T10:30:00Z"
  },
  "errors": []
}
```

**Not Found Response (404):**
```json
{
  "success": false,
  "message": "RT user not found",
  "data": null,
  "errors": []
}
```

### 4. Update RT User
```
PATCH /api/admin/users/rt/{id}
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body (all optional):**
```json
{
  "username": "rt_001_updated",
  "is_active": false,
  "notes": "Updated notes"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "RT user updated successfully",
  "data": {
    "id": 1,
    "uuid": "550e8400-e29b-41d4-a716-446655440000",
    "username": "rt_001_updated",
    "is_active": false,
    "notes": "Updated notes",
    "updated_at": "2026-01-20T11:00:00Z"
  },
  "errors": []
}
```

### 5. Delete RT User
```
DELETE /api/admin/users/rt/{id}
Authorization: Bearer {token}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "RT user deleted successfully",
  "data": {
    "username": "rt_001",
    "deleted_at": "2026-01-20T11:05:00Z"
  },
  "errors": []
}
```

### 6. Reset RT User Password
```
POST /api/admin/users/rt/{id}/reset-password
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "password": "NewSecurePass123",
  "password_confirmation": "NewSecurePass123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "RT user password reset successfully",
  "data": {
    "id": 1,
    "uuid": "550e8400-e29b-41d4-a716-446655440000",
    "username": "rt_001",
    "message": "Password has been reset"
  },
  "errors": []
}
```

## 🔄 Migration Instructions

1. **Run migration untuk tambah `notes` column:**
   ```bash
   php artisan migrate
   ```

2. **Test endpoints dengan Postman atau curl**

3. **Contoh curl create RT user:**
   ```bash
   curl -X POST http://localhost:8000/api/admin/users/rt/create \
     -H "Authorization: Bearer YOUR_SUPER_ADMIN_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "username": "rt_001",
       "password": "SecurePass123",
       "password_confirmation": "SecurePass123",
       "notes": "RT untuk Kelurahan ABC"
     }'
   ```

## ✅ Testing Steps

1. **Login sebagai SUPER_ADMIN untuk dapat token**
2. **Create RT user dengan valid data**
3. **List RT users dan verifikasi pagination**
4. **Get single RT user**
5. **Update RT user (username/notes/is_active)**
6. **Reset RT user password**
7. **Delete RT user**
8. **Try dengan non-SUPER_ADMIN role → harus return 403 Forbidden**

## 🛡️ Security Notes

- ✅ Password tidak pernah di-return dalam response
- ✅ Password di-hash menggunakan Laravel Hash::make()
- ✅ Username harus unique di database
- ✅ Password minimal 8 karakter
- ✅ Hanya SUPER_ADMIN yang bisa access endpoint ini
- ✅ Semua input di-validate sebelum process
- ✅ Rate limiting dapat ditambahkan ke middleware jika perlu

## 🔗 Related Files
- User Model: `app/Models/User.php`
- Auth Controller: `app/Http/Controllers/AuthController.php`
- RoleMiddleware: `app/Http/Middleware/RoleMiddleware.php`
- API Routes: `routes/api.php`

## 📝 Todo (Optional Enhancements)
- [ ] Add admin user management untuk ADMIN_KTP, ADMIN_IKD, ADMIN_PERKAWINAN roles
- [ ] Add audit logging untuk track user creation/deletion/modification
- [ ] Add bulk import RT users (CSV)
- [ ] Add email notification when RT account created
- [ ] Add change password by RT user (separate endpoint)
- [ ] Add user activity log endpoint
