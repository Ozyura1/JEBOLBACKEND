# AI Assistant Instructions for JEBOL Mobile Government System

**Last Updated**: February 2026  
**Status**: Production-Ready Single-Backend Architecture  
**Security Classification**: Government System - Audit Compliant

## Architecture Overview

**CRITICAL**: This is a **government system** requiring strict architectural adherence.

### System Design
- **Only Backend**: Laravel API (`backend-laravel/`) with Sanctum token authentication
- **Deprecated**: Node.js Express backend (`backend/`) is disabled—DO NOT modify or reference
- **Mobile Frontend**: Flutter app (`jebol_mobile/`) using Provider state management
- **Authentication**: Token-based (access + refresh tokens), single auth surface
- **Database**: MySQL with Eloquent ORM
- **Authorization**: Role-based (SUPER_ADMIN, ADMIN_KTP, ADMIN_IKD, ADMIN_PERKAWINAN, RT)

### Why Single Backend Matters
Government systems mandate:
1. **Single authentication surface** for auditing
2. **Unified audit trail** across all operations
3. **Consistent RBAC** enforcement (not scattered across backends)
4. **One security perimeter** to defend and certify

**Dual backends violate government compliance requirements**. Previous architecture (Node.js + Laravel) is now legacy.

---

## Key Files & Architecture

### Backend (Laravel) - `backend-laravel/`
```
app/
  ├── Http/Controllers/    # API endpoints organized by feature
  ├── Models/              # Eloquent models (User, KtpSubmission, etc.)
  ├── Policies/            # Authorization policies (gate-based access)
  └── Middleware/          # RoleMiddleware, auth checks
routes/
  └── api.php              # REST API routes (token-authenticated)
config/
  ├── auth.php             # Sanctum config
  └── app.php              # APP_URL, debug flags
database/migrations/       # Schema definitions
```

**Key Entry Point**: [routes/api.php](routes/api.php) - All API routes start here

### Mobile (Flutter) - `jebol_mobile/`
```
lib/
  ├── services/
  │   ├── api_service.dart      # HTTP client wrapping base URLs
  │   ├── auth_service.dart     # Login/refresh/logout API calls
  │   └── secure_storage.dart   # Token persistence (secure)
  ├── providers/
  │   └── auth_provider.dart    # State management (Provider package)
  ├── modules/                  # Feature modules (admin_ktp, admin_ikd, etc.)
  ├── core/
  │   ├── auth/                 # Auth initialization
  │   ├── routing/              # GoRouter navigation
  │   └── hardening/            # Security checks (root detection)
  └── main.dart                 # App entry point
```

**Key Entry Point**: [lib/main.dart](lib/main.dart) - Startup & Provider setup  
**State Management**: Provider package (not Riverpod or GetX)

---

## Development Workflows

### Running the Backend
```bash
cd backend-laravel

# Fresh database (dev only)
php artisan migrate:fresh --seed

# Start server (port 8000)
php artisan serve

# Access API: http://localhost:8000/api
# Test with Postman: backend-laravel/postman/JEBOL-Complete-Testing.postman_collection.json
```

### Running the Mobile App
```bash
cd jebol_mobile

# Ensure backend is running at http://localhost:8000/api
flutter run

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

### Running Tests
**Laravel/PHPUnit**:
```bash
cd backend-laravel
php artisan test  # Runs 64+ unit tests
```

**Postman Collection**:
- Import: `backend-laravel/postman/JEBOL-Complete-Testing.postman_collection.json`
- Run: 60+ API tests across all 5 roles
- See [TESTING_README.md](../../TESTING_README.md) for details

---

## Authentication & Authorization Pattern

### Login Flow (Mobile → Backend)
```
1. POST /api/auth/login
   Body: { username, password, device_name: "mobile" }
   Response: { access_token, refresh_token, expires_in, user }

2. Store tokens in secure storage (platform-specific)

3. Use access_token in all subsequent requests
   Header: Authorization: Bearer {access_token}

4. When expired: POST /api/auth/refresh
   Header: Authorization: Bearer {refresh_token}
```

**Implementation**: [services/auth_service.dart](lib/services/auth_service.dart)

### Role-Based Access (Backend)
```php
// In routes/api.php:
Route::middleware('auth:sanctum', 'role:ADMIN_KTP')
    ->post('/ktp/submit', [AdminKtpController::class, 'submit']);

// SUPER_ADMIN bypasses role checks (god mode)
// Other roles require explicit match
```

**Implementation**: [app/Http/Middleware/RoleMiddleware.php](app/Http/Middleware/RoleMiddleware.php)

---

## Common Patterns

### API Service (Flutter)
```dart
// lib/services/api_service.dart
final baseUrl = AppConfig.instance.apiUrl;  // http://localhost:8000/api
final response = await http.get(
  Uri.parse('$baseUrl/endpoint'),
  headers: { 'Authorization': 'Bearer $token' }
);
```

### Controller Endpoint (Laravel)
```php
// app/Http/Controllers/AdminKtpController.php
public function store(Request $request)
{
    $this->authorize('create', KtpSubmission::class);  // Policy-based
    return response()->json($ktpSubmission, 201);
}
```

### Provider State (Flutter)
```dart
// lib/core/auth/auth_provider.dart uses Provider pattern
class AuthProvider extends ChangeNotifier {
  Future<void> login(String username, String password) async {
    final tokens = await _authService.login(username, password);
    _user = tokens.user;
    notifyListeners();  // Rebuild UI
  }
}
```

---

## Critical Conventions

### Never Break the Single-Backend Assumption
- ❌ Don't use Node.js backend (`backend/`)—it's intentionally disabled
- ❌ Don't add dual database logic
- ✅ Always route through Laravel Sanctum for auth

### Token Management
- Store tokens in **secure storage**, never SharedPreferences on Android
- Access tokens valid ~60 min, refresh tokens ~7 days (configurable)
- Always send `Authorization: Bearer {token}` header
- Refresh tokens automatically when access token expires

### Government Compliance
- Every API call should be audit-logged (Laravel auto-logs via middleware)
- Role checks must be explicit in routes (no "assume authorized")
- Sensitive data (passwords) never logged
- All API responses follow consistent JSON structure: `{ success, message, data }`

### Naming & Structure
- Controllers: `{Feature}Controller` (e.g., `AdminKtpController`)
- Models: Singular, PascalCase (e.g., `KtpSubmission`)
- API routes: `/api/{resource}/{action}` (RESTful)
- Dart files: snake_case (e.g., `auth_service.dart`)
- Classes in Dart: PascalCase (e.g., `AuthService`)

---

## Debugging & Logs

### Backend (Laravel)
```bash
# View logs
tail -f storage/logs/laravel.log

# Database queries (in .env)
DB_LOG=true

# Clear cache if config changes
php artisan config:cache
```

### Mobile (Flutter)
```bash
# View logs in terminal
flutter run  # See debugPrint() output

# Clear app data
flutter clean
flutter pub get
```

### Common Issues
1. **401 Unauthorized**: Token expired or invalid—refresh or re-login
2. **403 Forbidden**: User's role lacks permission—check Route middleware
3. **CORS errors**: Ensure FRONTEND_URL in `.env` matches mobile app origin
4. **Token not persisting**: Verify secure_storage implementation for platform

---

## Documentation References
- [ARCHITECTURE.md](../../ARCHITECTURE.md) - Complete system design
- [README.md](../../README.md) - Project overview & setup
- [backend-laravel/README.md](../../backend-laravel/README.md) - Backend API docs
- [TESTING_README.md](../../TESTING_README.md) - Full test coverage guide
- [TESTING_PLAN.md](../../TESTING_PLAN.md) - 87+ test cases by module

---

## Quick Decision Tree

**Need to add an API endpoint?**
- Add route in `backend-laravel/routes/api.php`
- Create/update Controller in `app/Http/Controllers/`
- Define Policy for authorization in `app/Policies/`
- Update Postman collection for testing

**Need to add UI for a feature?**
- Create module in `jebol_mobile/lib/modules/{feature}/`
- Create Provider for state in `providers/`
- Call API via `api_service.dart` with proper token handling
- Test with actual backend running

**Token/Auth issues?**
- Check `backend-laravel/.env` for `ACCESS_TOKEN_TTL` & `REFRESH_TOKEN_TTL`
- Verify middleware in routes: `middleware('auth:sanctum')`
- Check Flutter app sends correct header: `Authorization: Bearer {token}`

**Something broken?**
1. Check [TESTING_README.md](../../TESTING_README.md) for step-by-step reproduction
2. Review Postman collection for expected API behavior
3. Look at [ARCHITECTURE.md](../../ARCHITECTURE.md) for design intent
4. Check `storage/logs/laravel.log` for backend errors
