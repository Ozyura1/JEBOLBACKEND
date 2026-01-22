# JEBOL Mobile - Laravel API Backend

**Status:** ✅ Production-Ready | The ONLY Authorized Backend  
**Framework:** Laravel 11.x  
**Authentication:** Sanctum (Token-based)  
**Date:** January 22, 2026

---

## ⚠️ CRITICAL: This is the ONLY Backend

**The Node.js backend (`../backend/`) has been DEPRECATED.**

This Laravel API is the **single, unified backend** for the JEBOL Mobile government system.

### Why Laravel Only?
- ✅ Single authentication surface (Sanctum)
- ✅ Unified audit trail
- ✅ Production-grade security
- ✅ Government compliance ready
- ✅ Role-based access control (RBAC)

**See [../ARCHITECTURE.md](../ARCHITECTURE.md) for complete system architecture.**

---

## 🚀 Quick Start

### Prerequisites
- PHP 8.2 or higher
- Composer
- MySQL 8.0 or higher
- PHP Extensions: BCMath, Ctype, Fileinfo, JSON, Mbstring, OpenSSL, PDO, Tokenizer, XML

### 1. Install Dependencies

```bash
composer install
```

### 2. Environment Configuration

```bash
# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate
```

### 3. Configure Database

Edit `.env`:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=jebol
DB_USERNAME=root
DB_PASSWORD=your_password

# Authentication tokens (adjust as needed)
ACCESS_TOKEN_TTL=60
REFRESH_TOKEN_TTL=10080

# CORS (for development)
FRONTEND_URL=http://localhost:3000
```

### 4. Run Migrations & Seed

```bash
# Run migrations
php artisan migrate

# Seed initial data (creates admin user)
php artisan db:seed

# Default admin credentials:
# Username: admin
# Password: password
```

### 5. Start Development Server

```bash
php artisan serve

# API available at: http://localhost:8000/api
```

---

## 📡 API Endpoints

### Base URL
```
http://localhost:8000/api
```

### Authentication

#### Login
```bash
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "password",
  "device_name": "mobile"
}

Response:
{
  "success": true,
  "message": "Authenticated",
  "data": {
    "access_token": "1|...",
    "refresh_token": "2|...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "user": {
      "id": 1,
      "uuid": "...",
      "username": "admin",
      "role": "SUPER_ADMIN",
      "is_active": true
    }
  }
}
```

#### Get Current User
```bash
GET /api/auth/me
Authorization: Bearer {access_token}
```

#### Logout
```bash
POST /api/auth/logout
Authorization: Bearer {access_token}
```

#### Refresh Token
```bash
POST /api/auth/refresh
Authorization: Bearer {refresh_token}

Response:
{
  "success": true,
  "data": {
    "access_token": "3|...",
    "expires_in": 3600
  }
}
```

### Perkawinan Module

#### Public Endpoints (No Auth)
```bash
# Submit marriage registration
POST /api/perkawinan/submit

# Check status (requires NIK verification)
GET /api/perkawinan/{uuid}/status?nik=xxx
```

#### Admin Endpoints (SUPER_ADMIN only)
```bash
GET    /api/admin/perkawinan/           # List all
GET    /api/admin/perkawinan/{uuid}     # View details
POST   /api/admin/perkawinan/{uuid}/verify   # Verify
POST   /api/admin/perkawinan/{uuid}/reject   # Reject
```

**See [routes/api.php](routes/api.php) for all endpoints.**

---

## 🔐 Authentication & Authorization

### Token-Based Authentication (Sanctum)

This API uses **Laravel Sanctum** for token-based authentication, ideal for mobile apps.

**Token Lifetimes:**
- Access Token: 60 minutes (configurable via `ACCESS_TOKEN_TTL`)
- Refresh Token: 7 days (configurable via `REFRESH_TOKEN_TTL`)

**Flow:**
1. User logs in → receives access_token + refresh_token
2. User makes API calls with access_token
3. When access_token expires → use refresh_token to get new access_token
4. When refresh_token expires → user must re-login

### Role-Based Access Control (RBAC)

**5 User Roles:**

| Role | Access Level |
|------|--------------|
| `SUPER_ADMIN` | Full system access (god mode) |
| `ADMIN_KTP` | KTP module only |
| `ADMIN_IKD` | IKD module only |
| `ADMIN_PERKAWINAN` | Marriage module only |
| `RT` | Community level (limited) |

**Middleware Usage:**
```php
// In routes/api.php
Route::middleware(['auth:sanctum', 'role:SUPER_ADMIN'])->group(function () {
    // Only SUPER_ADMIN can access
});

// Multiple roles (OR logic)
Route::middleware(['auth:sanctum', 'role:ADMIN_KTP|SUPER_ADMIN'])->group(function () {
    // ADMIN_KTP or SUPER_ADMIN can access
});
```

**Middleware Class:** `App\Http\Middleware\RoleMiddleware`

---

## 🔒 Security Features

### 1. Rate Limiting
- Login endpoint: **5 attempts per minute per IP**
- Prevents brute-force attacks
- Configured in: `app/Providers/AppServiceProvider.php`

### 2. CORS Protection
- Development: Allows `FRONTEND_URL` or wildcard if not set
- Production: **MUST** set `FRONTEND_URL` or system throws exception
- Configured in: `config/cors.php`

```env
# Development
FRONTEND_URL=http://localhost:3000

# Production (comma-separated for multiple)
FRONTEND_URL=https://app.jebol.go.id,https://admin.jebol.go.id
```

### 3. Token Expiration
- Automatic check on every API request
- Middleware: `App\Http\Middleware\EnsureTokenNotExpired`
- Returns 401 if token expired

### 4. Session Security
- HTTPS-only cookies in production
- HttpOnly flag (XSS prevention)
- SameSite protection (CSRF prevention)
- Configured in: `config/session.php`

### 5. Exception Handling
- All exceptions return JSON (API-first)
- Production hides stack traces
- Consistent error format via `App\Support\ApiResponder`
- Configured in: `bootstrap/app.php`

### 6. Database Security
- Eloquent ORM (SQL injection prevention)
- Mass assignment protection via `$fillable`
- Password hashing: bcrypt with 12 rounds
- UUID for public-facing IDs

---

## 📁 Project Structure

```
backend-laravel/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── AuthController.php          # Authentication
│   │   │   ├── Auth/
│   │   │   │   └── RefreshTokenController.php
│   │   │   └── Perkawinan/
│   │   │       ├── PublicPerkawinanController.php
│   │   │       └── AdminPerkawinanController.php
│   │   ├── Middleware/
│   │   │   ├── RoleMiddleware.php          # RBAC
│   │   │   └── EnsureTokenNotExpired.php   # Token validation
│   │   └── Requests/
│   │       └── Auth/
│   │           └── LoginRequest.php
│   ├── Models/
│   │   ├── User.php                        # User model
│   │   ├── PerkawinanRequest.php          # Marriage requests
│   │   └── AuditLog.php                   # Audit trail
│   ├── Policies/
│   │   └── PerkawinanRequestPolicy.php    # Authorization policies
│   └── Support/
│       └── ApiResponder.php               # Consistent API responses
├── config/
│   ├── auth.php                           # Auth configuration
│   ├── sanctum.php                        # Sanctum settings
│   ├── cors.php                           # CORS configuration
│   └── session.php                        # Session security
├── database/
│   ├── migrations/                        # Database schema
│   └── seeders/                           # Initial data
├── routes/
│   ├── api.php                            # All API routes
│   └── web.php                            # Web routes (minimal)
├── postman/
│   └── JEBOL-Auth.postman_collection.json # API testing
└── README.md                              # This file
```

---

## 🧪 Testing

### Run Tests
```bash
php artisan test
```

### API Testing with Postman

Import the collection: `postman/JEBOL-Auth.postman_collection.json`

**Test Flow:**
1. Login → Get tokens
2. Test authenticated endpoints with access_token
3. Test token refresh
4. Test role-based access (try accessing admin endpoints with RT role)
5. Test rate limiting (attempt 6 logins rapidly)

---

## 📚 Development Guidelines

### Adding New Endpoints

1. **Define Route** in `routes/api.php`:
```php
Route::middleware(['auth:sanctum', 'role:SUPER_ADMIN'])
    ->get('/new-endpoint', [MyController::class, 'method']);
```

2. **Create Controller**:
```php
namespace App\Http\Controllers;

class MyController extends Controller
{
    public function method(Request $request)
    {
        return $this->successResponse($data, 'Success message');
    }
}
```

3. **Use ApiResponder** for consistent responses:
```php
// Success
return $this->successResponse($data, 'Message');

// Error
return $this->errorResponse('Error message', 400);
```

### Validation

Use Form Requests:
```php
namespace App\Http\Requests;

use App\Http\Requests\ApiRequest;

class MyRequest extends ApiRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'field' => ['required', 'string', 'max:255'],
        ];
    }
}
```

### Audit Logging

Log important actions:
```php
use App\Models\AuditLog;

AuditLog::create([
    'user_id' => $request->user()->id,
    'action' => 'verify_perkawinan',
    'resource_type' => 'PerkawinanRequest',
    'resource_id' => $uuid,
    'changes' => json_encode($changes),
    'ip_address' => $request->ip(),
]);
```

---

## 🚀 Production Deployment

### Pre-Production Checklist

```env
# .env (Production)
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.jebol.go.id

DB_CONNECTION=mysql
DB_HOST=<production-host>
DB_DATABASE=jebol_production
DB_USERNAME=<secure-user>
DB_PASSWORD=<strong-password>

FRONTEND_URL=https://app.jebol.go.id,https://admin.jebol.go.id
SESSION_SECURE_COOKIE=true
SESSION_HTTP_ONLY=true

LOG_CHANNEL=daily
LOG_LEVEL=warning
```

### Deployment Steps

```bash
# 1. Install dependencies
composer install --optimize-autoloader --no-dev

# 2. Generate key (if not set)
php artisan key:generate

# 3. Run migrations
php artisan migrate --force

# 4. Seed initial data
php artisan db:seed --force

# 5. Cache configs
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 6. Set permissions
chmod -R 755 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# 7. Configure web server (Nginx/Apache)
# Document root: /path/to/backend-laravel/public
```

### Web Server Configuration

**Nginx Example:**
```nginx
server {
    listen 443 ssl http2;
    server_name api.jebol.go.id;

    root /var/www/jebol/backend-laravel/public;
    index index.php;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

**See [../ARCHITECTURE.md](../ARCHITECTURE.md) for complete deployment guide.**

---

## 🐛 Troubleshooting

### Issue: "SQLSTATE[HY000] [2002] Connection refused"
**Solution:** Check MySQL is running and `.env` DB credentials are correct.

### Issue: "419 CSRF token mismatch"
**Solution:** This API is stateless and doesn't use CSRF. Ensure you're using Bearer tokens, not cookies.

### Issue: "CORS error from mobile app"
**Solution:** Set `FRONTEND_URL` in `.env` or verify CORS middleware is loaded.

### Issue: "401 Unauthenticated"
**Solution:** 
- Check token is included: `Authorization: Bearer {token}`
- Check token hasn't expired (use refresh token)
- Check user exists and is active

### Issue: "403 Forbidden"
**Solution:** User doesn't have required role. Check `RoleMiddleware` usage.

---

## 📞 Support

### Documentation
- System Architecture: [../ARCHITECTURE.md](../ARCHITECTURE.md)
- Root README: [../README.md](../README.md)
- Deprecated Backend: [../backend/README.DEPRECATED.md](../backend/README.DEPRECATED.md)

### Laravel Resources
- Official Docs: https://laravel.com/docs
- Sanctum Docs: https://laravel.com/docs/sanctum

### Code References
- All routes: `routes/api.php`
- Authentication: `app/Http/Controllers/AuthController.php`
- RBAC: `app/Http/Middleware/RoleMiddleware.php`
- API responses: `app/Support/ApiResponder.php`

---

## 📊 Database Schema

**Key Tables:**
- `users` - System users (admin, officers)
- `personal_access_tokens` - Sanctum tokens
- `perkawinan_requests` - Marriage registration requests
- `audit_logs` - System audit trail
- `sessions` - Session storage

**See:** `database/migrations/` for complete schema.

---

## ⚙️ Configuration Files

| File | Purpose |
|------|---------|
| `config/auth.php` | Authentication guards and providers |
| `config/sanctum.php` | Sanctum token configuration |
| `config/cors.php` | CORS security settings |
| `config/session.php` | Session and cookie security |
| `config/logging.php` | Log channels and rotation |
| `app/Http/Kernel.php` | Middleware configuration |

---

## 🎯 What Makes This Backend Secure

1. ✅ **Single authentication surface** (no dual-backend chaos)
2. ✅ **Token-based auth** (no session cookies for mobile)
3. ✅ **Role-based access control** (5 explicit roles)
4. ✅ **Rate limiting** (brute-force prevention)
5. ✅ **CORS whitelist** (production requires explicit origins)
6. ✅ **Token expiration** (automatic validation)
7. ✅ **Audit logging** (complete trail)
8. ✅ **SQL injection prevention** (Eloquent ORM)
9. ✅ **XSS prevention** (HttpOnly cookies)
10. ✅ **CSRF prevention** (SameSite cookies)

---

**This is the ONLY authorized backend for JEBOL Mobile government system.**

Last Updated: January 22, 2026

In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
