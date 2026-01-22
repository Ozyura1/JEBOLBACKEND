# JEBOL Mobile - Government System

**Status:** ✅ Production-Ready | Single-Backend Architecture  
**Date:** January 22, 2026

## ⚠️ CRITICAL NOTICE: Architectural Change

This system has been **refactored from a dual-backend architecture** to a **single, secure Laravel API backend**.

### What Changed:
- ❌ **Node.js/Express backend (`backend/`) is DEPRECATED**
- ✅ **Laravel API (`backend-laravel/`) is the ONLY authorized backend**
- ✅ Single authentication surface (Laravel Sanctum)
- ✅ Unified audit trail
- ✅ Production-grade security

### Why This Matters:
Government systems require:
- Single source of truth for authentication
- Centralized audit logging
- One security surface to audit
- Consistent role-based access control

**The dual-backend pattern was a critical architectural flaw that has been eliminated.**

---

## 📂 Project Structure

```
JEBOLMobile/
├── backend/                    # ❌ DEPRECATED - DO NOT USE
│   ├── server.js              # Process exits immediately
│   ├── package.json           # Scripts disabled
│   └── README.DEPRECATED.md   # Migration guide
│
├── backend-laravel/           # ✅ THE ONLY ACTIVE BACKEND
│   ├── app/
│   │   ├── Http/Controllers/  # API controllers
│   │   ├── Models/            # Eloquent models
│   │   ├── Policies/          # Authorization policies
│   │   └── Middleware/        # Custom middleware
│   ├── routes/
│   │   └── api.php            # All API routes
│   ├── database/
│   │   ├── migrations/        # Database schema
│   │   └── seeders/           # Initial data
│   ├── config/                # Security configs
│   ├── postman/               # API testing
│   └── README.md              # Laravel setup guide
│
├── jebol_mobile/              # Flutter mobile app
│   ├── lib/
│   │   ├── services/          # API services
│   │   ├── models/            # Data models
│   │   ├── pages/             # UI screens
│   │   └── providers/         # State management
│   └── pubspec.yaml
│
├── ARCHITECTURE.md            # 📘 Complete architecture docs
└── README.md                  # This file
```

---

## 🚀 Quick Start

### Prerequisites
- PHP 8.2+
- Composer
- MySQL 8.0+
- Flutter SDK 3.x

### 1. Setup Laravel Backend (REQUIRED)

```bash
cd backend-laravel

# Install dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Configure database in .env
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_DATABASE=jebol
# DB_USERNAME=root
# DB_PASSWORD=

# Run migrations
php artisan migrate

# Seed initial data (creates admin user)
php artisan db:seed

# Start server
php artisan serve
# API available at: http://localhost:8000/api
```

### 2. Setup Flutter Mobile App

```bash
cd jebol_mobile

# Get dependencies
flutter pub get

# Update API URL in lib/services/api_service.dart
# const String baseUrl = 'http://localhost:8000/api';

# Run app
flutter run
```

### 3. DO NOT Start Node.js Backend

```bash
cd backend
npm start  # ❌ This will exit with error (intentional)
```

The Node.js backend is disabled and will not start. This is intentional.

---

## 🔐 Authentication

### Login Example

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "password",
    "device_name": "mobile"
  }'
```

**Response:**
```json
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

### Using the API

All subsequent requests must include the access token:

```bash
curl -X GET http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## 👥 User Roles

| Role | Description | Access Level |
|------|-------------|--------------|
| `SUPER_ADMIN` | System administrator | Full access to all modules |
| `ADMIN_KTP` | KTP department staff | KTP module only |
| `ADMIN_IKD` | IKD department staff | IKD module only |
| `ADMIN_PERKAWINAN` | Marriage dept staff | Marriage module only |
| `RT` | Community officer | Limited community access |

---

## 📡 API Endpoints

### Base URL
- Development: `http://localhost:8000/api`
- Production: `https://api.jebol.go.id/api`

### Authentication
```
POST   /api/auth/login          - Login (public)
GET    /api/auth/me             - Get current user (auth required)
POST   /api/auth/logout         - Logout (auth required)
POST   /api/auth/refresh        - Refresh access token
```

### Perkawinan Module
```
# Public
POST   /api/perkawinan/submit                - Submit marriage registration
GET    /api/perkawinan/{uuid}/status         - Check status

# Admin only (SUPER_ADMIN)
GET    /api/admin/perkawinan/                - List all requests
GET    /api/admin/perkawinan/{uuid}          - View details
POST   /api/admin/perkawinan/{uuid}/verify   - Verify request
POST   /api/admin/perkawinan/{uuid}/reject   - Reject request
```

**See [ARCHITECTURE.md](ARCHITECTURE.md) for complete API documentation.**

---

## 🔒 Security Features

### Production-Grade Security

1. **Single Authentication Surface**
   - Laravel Sanctum token-based auth
   - No dual-backend security risks
   - Centralized access control

2. **Rate Limiting**
   - Login: 5 attempts per minute per IP
   - Prevents brute-force attacks

3. **CORS Protection**
   - Whitelist-only in production
   - Development allows localhost
   - Runtime exception if misconfigured in production

4. **Token Security**
   - Access tokens: 60 minutes (short-lived)
   - Refresh tokens: 7 days (long-lived)
   - Automatic expiration checking

5. **Session Security**
   - HTTPS-only cookies in production
   - HttpOnly flag (XSS prevention)
   - SameSite protection (CSRF prevention)

6. **Audit Logging**
   - All admin actions logged
   - Immutable audit trail
   - Tracks user, action, resource, IP, timestamp

7. **Database Security**
   - Eloquent ORM (SQL injection prevention)
   - Mass assignment protection
   - Password hashing: bcrypt 12 rounds

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Complete system architecture, security, and deployment guide |
| [backend-laravel/README.md](backend-laravel/README.md) | Laravel setup and development guide |
| [backend/README.DEPRECATED.md](backend/README.DEPRECATED.md) | Why Node.js backend was deprecated |
| Postman Collection | `backend-laravel/postman/JEBOL-Auth.postman_collection.json` |

---

## 🚦 Production Deployment

### Pre-Production Checklist

- [ ] Set `APP_ENV=production` in `.env`
- [ ] Set `APP_DEBUG=false` in `.env`
- [ ] Configure `FRONTEND_URL` with exact allowed origins
- [ ] Generate strong `APP_KEY`
- [ ] Use strong database credentials
- [ ] Enable HTTPS (required)
- [ ] Set `SESSION_SECURE_COOKIE=true`
- [ ] Configure proper logging (`LOG_CHANNEL=daily`)
- [ ] Run `php artisan config:cache`
- [ ] Run `php artisan route:cache`
- [ ] Set proper file permissions (755/644)
- [ ] Ensure `backend/` is not deployed or is disabled
- [ ] Test all API endpoints with Postman
- [ ] Verify rate limiting works
- [ ] Verify CORS configuration
- [ ] Review audit logs

**See [ARCHITECTURE.md](ARCHITECTURE.md) for complete deployment guide.**

---

## 🧪 Testing

### API Testing with Postman

Import the collection:
```
backend-laravel/postman/JEBOL-Auth.postman_collection.json
```

### Laravel Unit Tests

```bash
cd backend-laravel
php artisan test
```

---

## 📞 Support

### For Developers
- Review [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- Review [backend-laravel/README.md](backend-laravel/README.md) for Laravel setup
- Check `routes/api.php` for available endpoints

### For Security Auditors
- All security configs: `backend-laravel/config/`
- Database schema: `backend-laravel/database/migrations/`
- Audit log model: `backend-laravel/app/Models/AuditLog.php`
- Authentication: `backend-laravel/app/Http/Controllers/AuthController.php`

### For DevOps
- Environment template: `backend-laravel/.env.example`
- Deployment guide: [ARCHITECTURE.md](ARCHITECTURE.md) → "Production Deployment"

---

## ⚠️ Common Mistakes to Avoid

### ❌ DO NOT:
- Start the Node.js backend (`backend/`)
- Add new endpoints to `backend/`
- Point Flutter app to `localhost:5000`
- Use `allowedOrigins: ['*']` in production
- Disable HTTPS in production
- Hardcode secrets in code
- Bypass authentication middleware

### ✅ DO:
- Use Laravel backend (`backend-laravel/`)
- Point Flutter app to `localhost:8000/api`
- Set explicit CORS whitelist in production
- Enable HTTPS in production
- Use `.env` for configuration
- Follow authentication patterns
- Log admin actions to audit trail

---

## 📊 System Status

| Component | Status | Version |
|-----------|--------|---------|
| Laravel API | ✅ Active | 11.x |
| Node.js Backend | ❌ Deprecated | N/A |
| Flutter App | ✅ Active | 3.x |
| Database | ✅ Active | MySQL 8.0 |
| Authentication | ✅ Sanctum | Token-based |
| Architecture | ✅ Single-Backend | Audit-Ready |

---

## 🎯 Architecture Goals Achieved

- ✅ Single authentication surface (Laravel Sanctum only)
- ✅ Unified audit trail (no fragmentation)
- ✅ Production-grade security (CORS, rate limiting, HTTPS)
- ✅ Role-based access control (5 roles, policy-driven)
- ✅ Audit-ready (government compliance)
- ✅ Maintainable (one codebase, one tech stack)
- ✅ Documented (architecture, API, deployment)

---

**"Menghilangkan dosa terbesar: dua backend dalam satu sistem pemerintah."**

*The greatest sin eliminated: two backends in one government system.*

---

## License

Government System - Restricted Use

## Revision History

| Date | Version | Changes |
|------|---------|---------|
| 2026-01-22 | 2.0.0 | Eliminated Node.js backend, established single-backend architecture |
| 2026-01-XX | 1.0.0 | Initial dual-backend version (deprecated) |
