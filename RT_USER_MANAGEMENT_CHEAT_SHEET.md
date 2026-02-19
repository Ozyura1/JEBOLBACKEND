# 🚀 Quick Reference - RT User Management API

## Endpoints Cheat Sheet

### Create RT User
```bash
POST /api/admin/users/rt/create
{"username": "rt_001", "password": "Pass123", "password_confirmation": "Pass123", "notes": "..."}
→ 201 Created
```

### List RT Users
```bash
GET /api/admin/users/rt?page=1&per_page=15&search=rt&sort_by=created_at&sort_order=desc
→ 200 OK + meta pagination
```

### Get Single RT User
```bash
GET /api/admin/users/rt/{id}
→ 200 OK
```

### Update RT User
```bash
PATCH /api/admin/users/rt/{id}
{"username": "new_name", "is_active": true, "notes": "..."}
→ 200 OK
```

### Reset Password
```bash
POST /api/admin/users/rt/{id}/reset-password
{"password": "NewPass123", "password_confirmation": "NewPass123"}
→ 200 OK
```

### Delete RT User
```bash
DELETE /api/admin/users/rt/{id}
→ 200 OK
```

---

## Files Changed/Created

| File | Type | Status |
|------|------|--------|
| `app/Http/Requests/Admin/CreateRtUserRequest.php` | ✨ NEW | ✅ |
| `app/Http/Controllers/Admin/AdminUserController.php` | ✨ NEW | ✅ |
| `routes/api.php` | 📝 MODIFIED | ✅ |
| `database/migrations/2026_01_20_000000_add_notes_to_users_table.php` | ✨ NEW | ✅ |
| `app/Models/User.php` | 📝 MODIFIED | ✅ |
| `app/Support/ApiResponder.php` | 📝 MODIFIED | ✅ |
| `docs/api/ADMIN_USER_MANAGEMENT.md` | 📖 DOCS | ✅ |
| `docs/POSTMAN_RT_USER_MANAGEMENT.md` | 📖 DOCS | ✅ |

---

## Authorization

✅ Only `SUPER_ADMIN` role can access  
✅ Bearer token required (Sanctum)  
✅ All endpoints protected with middleware  

---

## Request/Response Format

**Success (200/201):**
```json
{
  "success": true,
  "message": "...",
  "data": {...},
  "meta": {...}
}
```

**Error (4xx/5xx):**
```json
{
  "success": false,
  "message": "...",
  "data": null,
  "errors": {...}
}
```

---

## Validation Rules

| Field | Rules |
|-------|-------|
| username | required, unique, 3-255 chars, alphanumeric+dash/underscore/dot |
| password | required, min 8 chars, confirmed |
| notes | optional, max 500 chars |
| is_active | optional, boolean |

---

## Common HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success (list, get, update, delete) |
| 201 | Created (create) |
| 400 | Bad request |
| 403 | Forbidden (not SUPER_ADMIN) |
| 404 | Not found |
| 422 | Validation error |
| 500 | Server error |

---

## cURL Examples

```bash
# Create
curl -X POST http://localhost:8000/api/admin/users/rt/create \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"username":"rt_001","password":"Pass123","password_confirmation":"Pass123"}'

# List
curl -X GET http://localhost:8000/api/admin/users/rt \
  -H "Authorization: Bearer $TOKEN"

# Get
curl -X GET http://localhost:8000/api/admin/users/rt/1 \
  -H "Authorization: Bearer $TOKEN"

# Update
curl -X PATCH http://localhost:8000/api/admin/users/rt/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_active":false}'

# Reset Password
curl -X POST http://localhost:8000/api/admin/users/rt/1/reset-password \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"password":"NewPass123","password_confirmation":"NewPass123"}'

# Delete
curl -X DELETE http://localhost:8000/api/admin/users/rt/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

## Environment Variables (Postman)

```
base_url = http://localhost:8000/api
superadmin_token = <your_super_admin_token>
rt_user_id = <auto_populated_after_create>
```

---

## Testing with Postman

1. Import requests from `POSTMAN_RT_USER_MANAGEMENT.md`
2. Set environment variables
3. Run in Collection Runner
4. All assertions should pass ✅

---

## Key Features

✅ UUID support for secure identification  
✅ Pagination with filtering & sorting  
✅ Password hashing with Laravel Hash  
✅ Notes field for metadata  
✅ Soft authorization checks  
✅ Input validation  
✅ Consistent response format  

---

## Dependencies

- Laravel 11
- Sanctum (authentication)
- RoleMiddleware (authorization)
- ApiResponder (response formatting)
- User model with fillable fields

---

## Documentation References

- Full API: `docs/api/ADMIN_USER_MANAGEMENT.md`
- Postman: `docs/POSTMAN_RT_USER_MANAGEMENT.md`
- Implementation: `FITUR_RT_USER_MANAGEMENT_IMPLEMENTATION.md`

---

## Implementation Status

✅ Backend API complete  
✅ Database migrations applied  
✅ Request validators implemented  
✅ Authorization checks in place  
✅ Documentation written  
✅ Postman test cases ready  

**Ready for production!** 🎉
