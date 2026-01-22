# =====================================================
# DEPRECATED NODE.JS BACKEND
# =====================================================
# This directory contains a deprecated Express.js backend
# DO NOT USE - For reference only
# 
# Use Laravel backend: ../backend-laravel/
# =====================================================

## Why This Backend is Deprecated

This Node.js/Express backend was creating a **critical architectural flaw** in this government system:

### Problems:
1. **Multiple Authentication Surfaces**: Two separate backends meant two places to secure, audit, and maintain authentication
2. **Security Audit Nightmare**: Auditors must verify security in TWO different tech stacks (Node.js + Laravel)
3. **Inconsistent Authorization**: Role-based access control (RBAC) was difficult to enforce consistently
4. **Data Integrity Risks**: Two backends could access data differently, causing inconsistencies
5. **Compliance Violations**: Government systems require single source of truth for audit trails

### Solution:
**Laravel Backend is Now the ONLY Authorized API**

Location: `../backend-laravel/`
Base URL: `http://localhost:8000/api` (development)

## Migration Instructions

If you were using this Node.js backend, migrate to Laravel:

### Available Laravel Endpoints:

#### Authentication (Sanctum-based)
```
POST /api/auth/login - Login with username/password
POST /api/auth/logout - Logout (requires auth)
GET /api/auth/me - Get current user (requires auth)
POST /api/auth/refresh - Refresh access token using refresh token
```

#### Admin Endpoints (Role-protected)
```
GET /api/admin/super-only - SUPER_ADMIN only
GET /api/ktp/ - KTP module (SUPER_ADMIN)
GET /api/ikd/ - IKD module (SUPER_ADMIN)
```

#### Perkawinan Module
```
POST /api/perkawinan/submit - Public submission (no auth)
GET /api/perkawinan/{uuid}/status - Check status (no auth, requires NIK)
GET /api/admin/perkawinan/ - List all (SUPER_ADMIN)
GET /api/admin/perkawinan/{uuid} - View detail (SUPER_ADMIN)
POST /api/admin/perkawinan/{uuid}/verify - Verify request (SUPER_ADMIN)
POST /api/admin/perkawinan/{uuid}/reject - Reject request (SUPER_ADMIN)
```

## DO NOT:
- Start this server (`npm start` will fail intentionally)
- Add new endpoints here
- Use this for any production or development work
- Connect mobile apps to this backend

## Date Deprecated:
January 22, 2026

## Questions?
Refer to: `../backend-laravel/README.md`
