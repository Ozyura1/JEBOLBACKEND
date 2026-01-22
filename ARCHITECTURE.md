# JEBOL Mobile - Government System Architecture

## Executive Summary

**Date:** January 22, 2026  
**Status:** Production-Ready Single-Backend Architecture  
**Security Classification:** Government System - Audit Compliant

This document describes the unified backend architecture for JEBOL Mobile government system following the elimination of the dual-backend architecture flaw.

---

## Critical Architectural Decision: Single Backend

### The Problem (Before)

This system previously suffered from a **critical architectural flaw** common in rapid development: **two separate backends running simultaneously**.

```
┌─────────────────────────────────────────┐
│  PREVIOUS ARCHITECTURE (FLAWED)         │
├─────────────────────────────────────────┤
│                                         │
│  Flutter Mobile App                     │
│         │                               │
│         ├──► Node.js/Express (Port 5000)│  ❌ UNAUTHORIZED
│         │    - MongoDB                  │  ❌ No audit logs
│         │    - Basic auth               │  ❌ No RBAC
│         │                               │  ❌ Security risk
│         │                               │
│         └──► Laravel API (Port 8000)    │  ✓  Government-grade
│              - MySQL                    │  ✓  Sanctum auth
│              - Sanctum RBAC             │  ✓  Audit logs
│              - Audit logging            │  ✓  Policy-based
│                                         │
└─────────────────────────────────────────┘
```

**Problems:**
1. ❌ **Multiple Authentication Surfaces** - Security nightmare for auditors
2. ❌ **Inconsistent Authorization** - RBAC only in Laravel, not in Node.js
3. ❌ **Audit Trail Fragmentation** - Logs in two separate systems
4. ❌ **Data Integrity Risks** - Two databases (MongoDB + MySQL)
5. ❌ **Compliance Violations** - Government systems require single source of truth
6. ❌ **Maintenance Burden** - Two tech stacks, two security surfaces
7. ❌ **Attack Surface Doubled** - Attackers have two targets

### The Solution (Current)

```
┌─────────────────────────────────────────┐
│  CURRENT ARCHITECTURE (CORRECT)         │
├─────────────────────────────────────────┤
│                                         │
│  Flutter Mobile App                     │
│         │                               │
│         │                               │
│         └──► Laravel API (Port 8000)    │  ✓  ONLY backend
│              ├── MySQL Database         │  ✓  Single DB
│              ├── Sanctum Auth           │  ✓  Token-based
│              ├── RBAC (5 roles)         │  ✓  Policy-driven
│              ├── Audit Logs             │  ✓  Complete trail
│              ├── Rate Limiting          │  ✓  Brute-force protection
│              └── CORS Security          │  ✓  Whitelist-only
│                                         │
│  Node.js Backend (Deprecated)           │
│  - Process.exit(1) on startup           │  🔒 Disabled
│  - Documentation only                   │  📚 Reference
│                                         │
└─────────────────────────────────────────┘
```

---

## Authentication & Authorization

### Single Authentication Surface: Laravel Sanctum

**Token-Based Authentication (No Sessions for Mobile)**

#### Flow:
```
1. Login:    POST /api/auth/login
             → Returns: access_token + refresh_token
             → Access Token: 60 minutes (configurable)
             → Refresh Token: 7 days (configurable)

2. Use API:  Authorization: Bearer {access_token}
             → Middleware: auth:sanctum + role check
             → Token expiration checked automatically

3. Refresh:  POST /api/auth/refresh
             → Header: Authorization: Bearer {refresh_token}
             → Returns: new access_token

4. Logout:   POST /api/auth/logout
             → Deletes current access token
```

### Role-Based Access Control (RBAC)

**5 Government Roles:**

| Role | Access Level | Use Case |
|------|-------------|----------|
| `SUPER_ADMIN` | Full system access | System administrators |
| `ADMIN_KTP` | KTP module only | KTP department staff |
| `ADMIN_IKD` | IKD module only | IKD department staff |
| `ADMIN_PERKAWINAN` | Marriage module only | Marriage registration staff |
| `RT` | Community level | RT officers (limited access) |

**Implementation:**
- Middleware: `App\Http\Middleware\RoleMiddleware`
- Usage: `->middleware('role:SUPER_ADMIN')`
- SUPER_ADMIN bypasses all role checks (god mode)
- Explicit role matching for other roles

---

## API Endpoints

### Base URL
- Development: `http://localhost:8000/api`
- Production: `https://api.jebol.go.id/api` *(example)*

### Authentication Endpoints

```
POST   /api/auth/login
Body:  { "username": "admin", "password": "***", "device_name": "mobile" }
Auth:  None (public)
Returns: { access_token, refresh_token, expires_in, user }

GET    /api/auth/me
Auth:  Bearer token (access)
Returns: { id, uuid, username, role, is_active }

POST   /api/auth/logout
Auth:  Bearer token (access)
Returns: { success: true }

POST   /api/auth/refresh
Auth:  Bearer token (refresh)
Returns: { access_token, expires_in }
```

### Perkawinan (Marriage) Module

**Public Endpoints (No Authentication):**
```
POST   /api/perkawinan/submit
Body:  Marriage registration data
Auth:  None
Returns: { uuid, message }

GET    /api/perkawinan/{uuid}/status?nik=xxx
Auth:  None (but requires NIK verification)
Returns: { uuid, status, data }
```

**Admin Endpoints (SUPER_ADMIN only):**
```
GET    /api/admin/perkawinan/
Auth:  Bearer + SUPER_ADMIN
Returns: Paginated list of requests

GET    /api/admin/perkawinan/{uuid}
Auth:  Bearer + SUPER_ADMIN
Returns: Full request details

POST   /api/admin/perkawinan/{uuid}/verify
Auth:  Bearer + SUPER_ADMIN
Returns: { success, message }

POST   /api/admin/perkawinan/{uuid}/reject
Body:  { reason: "..." }
Auth:  Bearer + SUPER_ADMIN
Returns: { success, message }
```

### Admin-Only Endpoints

```
GET    /api/admin/super-only
Auth:  Bearer + SUPER_ADMIN

GET    /api/ktp/
Auth:  Bearer + SUPER_ADMIN (or ADMIN_KTP in future)

GET    /api/ikd/
Auth:  Bearer + SUPER_ADMIN (or ADMIN_IKD in future)
```

---

## Security Hardening

### 1. CORS Configuration
**File:** `backend-laravel/config/cors.php`

```php
// ✓ Development: Wildcard allowed if FRONTEND_URL not set
// ✓ Production: MUST set FRONTEND_URL or system throws exception
// ✓ Multiple origins: Comma-separated in .env
```

**Production Requirement:**
```env
FRONTEND_URL=https://app.jebol.go.id,https://admin.jebol.go.id
```

### 2. Session Security
**File:** `backend-laravel/config/session.php`

```php
'secure' => env('SESSION_SECURE_COOKIE', env('APP_ENV') === 'production')
// ✓ Auto-enables HTTPS-only cookies in production

'http_only' => true
// ✓ Prevents JavaScript access (XSS protection)

'same_site' => 'lax'
// ✓ CSRF protection while allowing normal links
```

### 3. Rate Limiting
**File:** `backend-laravel/app/Providers/AppServiceProvider.php`

```php
RateLimiter::for('login', function (Request $request) {
    return Limit::perMinute(5)->by($request->ip());
});
// ✓ Prevents brute-force attacks: 5 attempts per minute per IP
```

### 4. Token Expiration
**Middleware:** `App\Http\Middleware\EnsureTokenNotExpired`

```php
// ✓ Automatically checks token expiration on every API request
// ✓ Returns 401 if token expired
// ✓ Applied to all 'api' middleware group
```

### 5. Exception Handling
**File:** `backend-laravel/bootstrap/app.php`

```php
// ✓ All exceptions return JSON (API-first)
// ✓ Production hides stack traces
// ✓ Consistent error format via ApiResponder
// ✓ HTTP status codes properly mapped
```

### 6. Database Security
- ✓ All queries use Eloquent ORM (SQL injection prevention)
- ✓ Mass assignment protection via `$fillable`
- ✓ Password hashing: bcrypt with 12 rounds
- ✓ UUID for public-facing IDs (not sequential integers)

---

## Production Deployment Checklist

### Environment Configuration

```env
# CRITICAL: Set these before production deployment

APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.jebol.go.id

# Database
DB_CONNECTION=mysql
DB_HOST=<production-db-host>
DB_PORT=3306
DB_DATABASE=jebol_production
DB_USERNAME=<secure-user>
DB_PASSWORD=<strong-password>

# Security
FRONTEND_URL=https://app.jebol.go.id,https://admin.jebol.go.id
SESSION_SECURE_COOKIE=true
SESSION_HTTP_ONLY=true
CORS_SUPPORTS_CREDENTIALS=false

# Token lifetimes (tune as needed)
ACCESS_TOKEN_TTL=60
REFRESH_TOKEN_TTL=10080

# Logging
LOG_CHANNEL=daily
LOG_LEVEL=warning
```

### Pre-Production Steps

1. ✓ **Remove Node.js Backend**
   - Ensure `backend/` directory is not deployed
   - Or ensure `server.js` has `process.exit(1)`

2. ✓ **Generate APP_KEY**
   ```bash
   cd backend-laravel
   php artisan key:generate
   ```

3. ✓ **Run Migrations**
   ```bash
   php artisan migrate --force
   ```

4. ✓ **Seed Admin User**
   ```bash
   php artisan db:seed
   ```

5. ✓ **Clear Caches**
   ```bash
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

6. ✓ **Set Permissions**
   ```bash
   chmod -R 755 storage bootstrap/cache
   chown -R www-data:www-data storage bootstrap/cache
   ```

7. ✓ **Configure Web Server**
   - Point document root to: `backend-laravel/public`
   - Enable HTTPS (Let's Encrypt or commercial cert)
   - Set `max_upload_filesize` for document uploads

8. ✓ **Enable Audit Logging**
   - Ensure `audit_logs` table exists
   - Configure log rotation

9. ✓ **Test All Endpoints**
   - Use Postman collection: `backend-laravel/postman/`
   - Test authentication flow
   - Test role-based access
   - Test rate limiting

10. ✓ **Security Scan**
    - Run `php artisan route:list` and audit exposed endpoints
    - Verify no debug routes in production
    - Check CORS configuration
    - Verify error messages don't leak info

---

## Audit Compliance

### What Auditors Need to Know

1. **Single Authentication Surface**
   - Only Laravel Sanctum is used
   - All API traffic flows through one backend
   - Audit logs capture all actions

2. **Role-Based Access Control**
   - 5 defined roles with explicit permissions
   - SUPER_ADMIN god mode for emergency access
   - All role checks logged

3. **Data Integrity**
   - Single MySQL database
   - Transactions used for critical operations
   - Foreign key constraints enforced

4. **Audit Trail**
   - Table: `audit_logs`
   - Captures: user_id, action, resource, changes, IP, timestamp
   - Immutable (no delete operations)

5. **Security Hardening**
   - HTTPS enforced in production
   - CORS whitelist-only
   - Rate limiting on authentication
   - Token expiration enforced
   - Password policy: bcrypt, 12 rounds

### Audit Log Query Examples

```sql
-- All actions by a specific user
SELECT * FROM audit_logs WHERE user_id = ?;

-- All actions on a resource
SELECT * FROM audit_logs WHERE resource_type = 'PerkawinanRequest' AND resource_id = ?;

-- Failed authentication attempts
SELECT * FROM audit_logs WHERE action = 'login' AND result = 'failed';

-- Admin actions in date range
SELECT * FROM audit_logs 
WHERE user_role = 'SUPER_ADMIN' 
AND created_at BETWEEN ? AND ?;
```

---

## Mobile App Integration

### Flutter Configuration

**Update API base URL:**

```dart
// lib/services/api_service.dart
class ApiService {
  static const String baseUrl = 'https://api.jebol.go.id/api';
  
  // ❌ DO NOT use Node.js backend
  // static const String baseUrl = 'http://localhost:5000/api';  // DEPRECATED
  
  // ✓ ONLY use Laravel API
}
```

### Authentication Flow in Flutter

```dart
// 1. Login
final response = await http.post(
  Uri.parse('$baseUrl/auth/login'),
  body: jsonEncode({
    'username': username,
    'password': password,
    'device_name': 'flutter_app',
  }),
);

final data = jsonDecode(response.body);
final accessToken = data['data']['access_token'];
final refreshToken = data['data']['refresh_token'];

// Store securely (flutter_secure_storage)
await secureStorage.write(key: 'access_token', value: accessToken);
await secureStorage.write(key: 'refresh_token', value: refreshToken);

// 2. Authenticated requests
final response = await http.get(
  Uri.parse('$baseUrl/auth/me'),
  headers: {
    'Authorization': 'Bearer $accessToken',
    'Accept': 'application/json',
  },
);

// 3. Handle 401 (expired token)
if (response.statusCode == 401) {
  // Refresh token or re-login
}
```

---

## Migration Notes (From Node.js Backend)

If any code was pointing to the Node.js backend:

### Before (WRONG):
```javascript
// ❌ This backend is DEPRECATED
const API_URL = 'http://localhost:5000/api';
```

### After (CORRECT):
```dart
// ✓ Laravel is the ONLY backend
const String API_URL = 'http://localhost:8000/api';  // Development
// const String API_URL = 'https://api.jebol.go.id/api';  // Production
```

### Endpoint Mapping

| Old Node.js Endpoint | New Laravel Endpoint | Notes |
|---------------------|---------------------|-------|
| N/A (minimal functionality) | `/api/auth/login` | Use Laravel auth |
| `/api/users` | `/api/auth/me` | Different structure |
| N/A | `/api/perkawinan/*` | Only exists in Laravel |

**Important:** The Node.js backend had minimal functionality (just a stub). All real features are in Laravel.

---

## Architecture Principles

### Why This Architecture is Correct for Government Systems

1. **Single Source of Truth**
   - One backend = one security audit surface
   - One database = data consistency guaranteed
   - One authentication system = unified access control

2. **Audit Compliance**
   - Centralized logging
   - Immutable audit trail
   - Role-based access tracked

3. **Security**
   - Token-based auth (no session cookies for mobile)
   - RBAC with explicit permissions
   - Rate limiting on sensitive endpoints
   - CORS whitelist-only in production

4. **Maintainability**
   - One tech stack to maintain
   - One codebase to secure
   - One deployment pipeline

5. **Scalability**
   - Laravel scales horizontally
   - Database read replicas possible
   - Queue system for async tasks
   - Cache layer (Redis) ready

---

## Developer Guidelines

### DO:
✓ Use Laravel backend for ALL new features  
✓ Follow existing authentication patterns  
✓ Add endpoints to `routes/api.php`  
✓ Use middleware for authorization  
✓ Log important actions to audit_logs  
✓ Write unit tests for controllers  
✓ Follow PSR-12 coding standards  
✓ Use FormRequest for validation  

### DO NOT:
❌ Start the Node.js backend  
❌ Add endpoints to `backend/`  
❌ Bypass authentication middleware  
❌ Hardcode secrets in code  
❌ Expose debug info in production  
❌ Use raw SQL queries (use Eloquent)  
❌ Store passwords unhashed  
❌ Allow wildcard CORS in production  

---

## Support & Questions

### For Developers:
- Laravel docs: https://laravel.com/docs
- Sanctum docs: https://laravel.com/docs/sanctum
- Project README: `backend-laravel/README.md`

### For Auditors:
- Database schema: `backend-laravel/database/migrations/`
- Security config: `backend-laravel/config/`
- Audit log model: `backend-laravel/app/Models/AuditLog.php`

### For DevOps:
- Environment template: `backend-laravel/.env.example`
- Deployment checklist: See "Production Deployment Checklist" above

---

## Revision History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2026-01-22 | 1.0 | Initial architecture document after removing Node.js backend | System Architect |

---

**Status: APPROVED FOR PRODUCTION**  
**Next Review: 2026-07-22** (6 months)
