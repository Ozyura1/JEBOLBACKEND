# RT Account Management Feature - Complete Setup Guide

## Status: PRODUCTION READY ✅

Fitur "Tambah Akun RT" untuk Super Admin sudah siap digunakan dengan testing lengkap di Postman.

---

## Prerequisites

Backend Laravel harus running dengan database yang sudah di-setup.

---

## ⚙️ Backend Setup (Laravel)

### 1. Navigate to Backend Directory
```bash
cd C:\laragon\www\JEBOL\backend\backend-laravel
```

### 2. Clear All Cache
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### 3. Setup Database (Fresh Installation)
```bash
# Create database & run migrations with seeds
php artisan migrate:fresh --seed

# Verify SUPER_ADMIN user created:
# Username: superadmin
# Password: ChangeMe123!
```

### 4. Start Laravel Development Server
```bash
php artisan serve --host=127.0.0.1 --port=8000
```

Expected output:
```
Laravel development server started: http://127.0.0.1:8000
```

✅ Backend now running at: **http://localhost:8000/api**

---

## 📱 Mobile App Setup (Flutter)

### 1. Navigate to Mobile Directory
```bash
cd C:\laragon\www\JEBOL\jebol_mobile
```

### 2. Get Dependencies
```bash
flutter pub get
```

### 3. Run App
```bash
flutter run
```

The app will connect to backend at `http://localhost:8000/api` (configured in `lib/core/hardening/app_config.dart`)

---

## 🧪 Testing with Postman

### 1. Import Collection
- File: `backend-laravel/postman/JEBOL-Complete-Testing.postman_collection.json`
- Import into Postman

### 2. RT Account Management Tests (NEW)
Folder: **🔐 SUPER ADMIN MANAGEMENT**

Tests included:
- ✅ **7.1.1** - Create RT Account (Valid)
- ✅ **7.1.2** - Create RT Account (Duplicate Username)
- ✅ **7.1.3** - Create RT Account (Missing Field)
- ✅ **7.1.4** - Create RT Account (Weak Password)
- ✅ **7.2.1** - List RT Accounts
- ✅ **7.2.2** - Get RT Account Detail
- ✅ **7.3.1** - Update RT Account (Change Password)
- ✅ **7.3.2** - Update RT Account (Deactivate)
- ✅ **7.4.1** - Delete RT Account
- ✅ **7.5.1** - Authorization Test (RT User Cannot Create)

### 3. Test Flow
1. **Login** as SUPER_ADMIN (Test 1.1.1)
   - Token auto-stored in `{{superadmin_token}}`
2. **Create RT Account** (Test 7.1.1)
   - RT Account ID stored in `{{rt_account_id}}`
3. **List/Update/Delete** RT Accounts (Tests 7.2.x - 7.4.x)
4. **Test Authorization** (Test 7.5.1)

---

## 📲 Testing in Mobile App

### Step 1: Login
- Dashboard screen shows login form
- Username: `superadmin`
- Password: `ChangeMe123!`
- Tap **Login**

Expected: Redirected to **Dashboard Super Admin**

### Step 2: Navigate to "Tambah Akun RT"
- From Dashboard Super Admin
- Menu: **"Tambah Akun RT"**
- Tap the menu item

### Step 3: Fill Form
Form fields:
- **Nama Lengkap**: John Doe
- **Username**: rt_user_001
- **Nomor Telepon**: 081234567890
- **Kelurahan**: Kelurahan Test
- **Kecamatan**: Kecamatan Test
- **Kabupaten**: Kabupaten Test
- **Provinsi**: Provinsi Test
- **Password**: RtTest123!
- **Konfirmasi Password**: RtTest123!

### Step 4: Submit
- Tap **"Buat Akun RT"** button
- Wait for response

Expected result:
```
✅ Akun RT berhasil dibuat
```

---

## 🐛 Troubleshooting

### Error: "Not found" (404)
**Cause**: Backend routes not registered or route cache active

**Solution**:
```bash
php artisan route:clear
php artisan cache:clear
php artisan serve
```

### Error: "Terjadi kesalahan pada server" (500)
**Cause**: Server-side error (validation, database, etc.)

**Solution**:
1. Check Laravel logs:
   ```bash
   tail -f storage/logs/laravel.log
   ```

2. Common issues:
   - **Duplicate username/email**: Test with unique values
   - **Database not setup**: Run `php artisan migrate:fresh --seed`
   - **Password too short**: Must be 6+ characters
   - **Invalid email format**: Use proper email format

### Error: 401 Unauthorized
**Cause**: Token invalid or expired

**Solution**:
1. Login again to get fresh token
2. Mobile app auto-refreshes token on 401

### Error: 403 Forbidden
**Cause**: User role not authorized

**Solution**:
- Only SUPER_ADMIN can create RT accounts
- Verify logged-in user has SUPER_ADMIN role

---

## 📊 API Endpoints Reference

### Create RT Account
```
POST /api/admin/rt-accounts
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "string (required, max 255)",
  "username": "string (required, unique, max 100)",
  "phone": "string (required, max 20)",
  "village": "string (required, max 255)",
  "sub_district": "string (required, max 255)",
  "district": "string (required, max 255)",
  "province": "string (required, max 255)",
  "password": "string (required, min 6)"
}

Response 201:
{
  "success": true,
  "message": "Akun RT berhasil dibuat",
  "data": {
    "id": "integer",
    "uuid": "uuid",
    "name": "string",
    "username": "string",
    "phone": "string",
    "village": "string",
    "sub_district": "string",
    "district": "string",
    "province": "string",
    "role": "RT",
    "is_active": true,
    "created_at": "timestamp"
  }
}
```

### List RT Accounts
```
GET /api/admin/rt-accounts
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "message": "Data akun RT berhasil diambil",
  "data": [...],
  "pagination": {
    "total": 10,
    "per_page": 10,
    "current_page": 1,
    "last_page": 1
  }
}
```

### Get RT Account Detail
```
GET /api/admin/rt-accounts/{id}
Authorization: Bearer {token}
```

### Update RT Account
```
PUT /api/admin/rt-accounts/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "password": "string (optional, min 6)",
  "is_active": "boolean (optional)"
}
```

### Delete RT Account
```
DELETE /api/admin/rt-accounts/{id}
Authorization: Bearer {token}
```

---

## 🔒 Security Notes

1. **Token Management**:
   - Access tokens valid ~60 minutes
   - Refresh tokens valid ~7 days
   - Auto-refresh on 401 response

2. **Authorization**:
   - Only SUPER_ADMIN can manage RT accounts
   - Middleware enforces role check
   - Audit log created for each action

3. **Data Validation**:
   - Unique username & email
   - Password minimum 6 characters
   - All required fields validated
   - Invalid data returns 422 error

4. **Password Security**:
   - Hashed with bcrypt
   - Never logged or returned in responses
   - Minimum 6 characters required

---

## 📝 Postman Collection Variables

Auto-populated during tests:
- `{{base_url}}` = http://127.0.0.1:8000
- `{{superadmin_token}}` = Auth token for SUPER_ADMIN
- `{{rt_account_id}}` = Created RT account ID

---

## ✨ Feature Complete Checklist

- ✅ Backend API endpoint (POST /api/admin/rt-accounts)
- ✅ Flutter UI form with validation
- ✅ Error handling & user feedback
- ✅ Token authentication & authorization
- ✅ Database model & migrations
- ✅ Audit logging
- ✅ Postman testing suite
- ✅ Security & validation
- ✅ Documentation

---

## 🚀 Next Steps

1. **Deploy to Staging**: Test with real data
2. **User Training**: Admin staff training on feature
3. **Monitor Logs**: Check audit logs for activity
4. **Performance**: Monitor database performance

---

**Last Updated**: February 4, 2026
**Status**: Production Ready
**Support**: Check logs at `storage/logs/laravel.log`

