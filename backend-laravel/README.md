# JEBOL Backend API - Laravel

Backend API untuk aplikasi mobile Jemput Bola (JEBOL) - Dinas Kependudukan dan Pencatatan Sipil Kota Tegal.

## Technology Stack

- **Framework**: Laravel 12
- **Authentication**: Laravel Sanctum (Personal Access Tokens)
- **Database**: MySQL
- **Environment**: Laragon (Local Development)

## Project Structure

```
backend-laravel/
├── database/
│   └── migrations/
│       ├── 2026_01_16_000000_create_users_table.php
│       ├── 2026_01_16_000010_create_password_reset_tokens_table.php
│       └── 2026_01_16_080535_create_personal_access_tokens_table.php (Sanctum)
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   ├── Middleware/
│   │   └── Requests/
│   ├── Models/
│   └── Policies/
└── routes/
    └── api.php
```

## Database Schema

### Users Table
- `id` - Primary Key
- `uuid` - Unique identifier (char 36, nullable)
- `username` - Unique username (string 191)
- `password` - Hashed password (string 255)
- `role` - ENUM: `SUPER_ADMIN`, `ADMIN_KTP`, `ADMIN_IKD`, `ADMIN_PERKAWINAN`, `RT`
- `is_active` - Boolean (default: true)
- `created_at`, `updated_at` - Timestamps

### Password Reset Tokens Table
- `email` - Primary Key
- `token` - Reset token
- `created_at` - Timestamp

### Personal Access Tokens Table (Sanctum)
- `id` - Primary Key
- `tokenable_type`, `tokenable_id` - Polymorphic relation
- `name` - Token name
- `token` - Hashed token (string 64, unique)
- `abilities` - JSON abilities
- `last_used_at` - Timestamp
- `expires_at` - Timestamp (indexed)
- `created_at`, `updated_at` - Timestamps

## Setup Instructions

### 1. Install Dependencies
```bash
cd backend-laravel
composer install
```

### 2. Configure Environment
Copy `.env.example` to `.env` and update database settings:
```env
APP_NAME=JEBOL
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=jebol
DB_USERNAME=root
DB_PASSWORD=
```

### 3. Create Database
Buka Laragon → Database (HeidiSQL/phpMyAdmin) dan buat database:
```sql
CREATE DATABASE jebol CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

**PENTING**: Jika mengalami error MySQL authentication (`auth_gssapi_client`), gunakan salah satu cara berikut:

#### Opsi A: Ubah MySQL Authentication Plugin
```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';
FLUSH PRIVILEGES;
```

#### Opsi B: Gunakan MySQL di Laragon Menu
1. Buka Laragon
2. Menu → MySQL → Console
3. Ketik: `CREATE DATABASE jebol;`

### 4. Run Migrations
```bash
php artisan migrate
```

### 5. Generate Application Key
```bash
php artisan key:generate
```

### 6. Run Development Server
```bash
php artisan serve
```

Server akan berjalan di: `http://localhost:8000`

## API Authentication (Sanctum)

### Token-Based Authentication
- Mobile app menggunakan Personal Access Tokens
- Token dikirim via header: `Authorization: Bearer {token}`
- Token per-device, dapat di-revoke kapan saja
- Tidak ada refresh token mechanism

### Login Flow
```
POST /api/auth/login
{
  "username": "admin",
  "password": "password",
  "device_name": "Mobile App"
}

Response:
{
  "token": "1|abc123...",
  "user": { ... }
}
```

### Logout Flow
```
POST /api/auth/logout
Authorization: Bearer {token}

Response: 204 No Content
```

## Roles & Permissions

### Role Types (Single Role per User)
1. **SUPER_ADMIN** - Full access to all features
2. **ADMIN_KTP** - Manage KTP requests
3. **ADMIN_IKD** - Manage IKD activations
4. **ADMIN_PERKAWINAN** - Manage marriage registrations
5. **RT** - Submit and verify requests

### Public Access
- Marriage registration: NO login required
- KTP & IKD requests: RT authentication required

## Next Steps

1. ✅ Database migrations created
2. ✅ Sanctum installed and configured
3. ⏳ Create AuthController (login/logout)
4. ⏳ Create role-based middleware
5. ⏳ Create API routes per role
6. ⏳ Create workflow models (KtpRequest, IkdActivation, Marriage)
7. ⏳ Create controllers and validation

## Development Notes

- **No audit logging** (removed from scope)
- **No virus scanning** (removed from scope)
- **No signed URLs** (removed from scope)
- **No CI/static analysis** (removed from scope)
- Focus: Functional, secure, production-ready API only

## Troubleshooting

### MySQL Connection Error
Jika terjadi error `SQLSTATE[HY000] [2054]`, pastikan:
1. MySQL service di Laragon sudah running
2. Database `jebol` sudah dibuat
3. Username/password di `.env` sudah benar
4. Authentication plugin sudah diubah (lihat Setup Instructions #3)

### Port Already in Use
Jika port 8000 sudah digunakan:
```bash
php artisan serve --port=8001
```

## Support

Untuk pertanyaan atau issues, hubungi tim development.
