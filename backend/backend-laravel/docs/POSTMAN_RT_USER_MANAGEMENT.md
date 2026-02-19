# Postman Collection Update - Admin RT User Management

Berikut adalah requests untuk ditambahkan ke Postman collection untuk testing RT user management endpoints.

## 1. Create RT User

**Type:** POST  
**URL:** `{{base_url}}/api/admin/users/rt/create`  
**Auth:** Bearer Token (SUPER_ADMIN)

### Headers
```
Authorization: Bearer {{superadmin_token}}
Content-Type: application/json
```

### Body (raw JSON)
```json
{
  "username": "rt_kelurahan_abc",
  "password": "SecurePass123",
  "password_confirmation": "SecurePass123",
  "notes": "RT untuk Kelurahan ABC, Kecamatan XYZ"
}
```

### Test Script
```javascript
if (pm.response.code === 201) {
    let data = pm.response.json().data;
    pm.environment.set("rt_user_id", data.id);
    pm.environment.set("rt_user_uuid", data.uuid);
    pm.test("RT user created successfully", function () {
        pm.expect(data.username).to.equal("rt_kelurahan_abc");
        pm.expect(data.role).to.equal("RT");
        pm.expect(data.is_active).to.equal(true);
    });
}
```

---

## 2. List RT Users

**Type:** GET  
**URL:** `{{base_url}}/api/admin/users/rt?page=1&per_page=10&sort_by=created_at&sort_order=desc`  
**Auth:** Bearer Token (SUPER_ADMIN)

### Headers
```
Authorization: Bearer {{superadmin_token}}
```

### Test Script
```javascript
let body = pm.response.json();
if (pm.response.code === 200) {
    pm.test("RT users retrieved successfully", function () {
        pm.expect(body.success).to.equal(true);
        pm.expect(body.meta).to.exist;
        pm.expect(body.meta.current_page).to.equal(1);
        pm.expect(Array.isArray(body.data)).to.equal(true);
    });
    
    // Store first RT user ID for next tests
    if (body.data.length > 0) {
        pm.environment.set("rt_user_id", body.data[0].id);
    }
}
```

---

## 3. Get Single RT User

**Type:** GET  
**URL:** `{{base_url}}/api/admin/users/rt/{{rt_user_id}}`  
**Auth:** Bearer Token (SUPER_ADMIN)

### Headers
```
Authorization: Bearer {{superadmin_token}}
```

### Test Script
```javascript
let data = pm.response.json().data;
if (pm.response.code === 200) {
    pm.test("RT user retrieved successfully", function () {
        pm.expect(data.role).to.equal("RT");
        pm.expect(data.uuid).to.exist;
        pm.expect(data.notes).to.be.a('string');
    });
}
```

---

## 4. Update RT User

**Type:** PATCH  
**URL:** `{{base_url}}/api/admin/users/rt/{{rt_user_id}}`  
**Auth:** Bearer Token (SUPER_ADMIN)

### Headers
```
Authorization: Bearer {{superadmin_token}}
Content-Type: application/json
```

### Body (raw JSON)
```json
{
  "is_active": false,
  "notes": "Updated: RT untuk Kelurahan ABC - Updated on 2026-01-20"
}
```

### Test Script
```javascript
let data = pm.response.json().data;
if (pm.response.code === 200) {
    pm.test("RT user updated successfully", function () {
        pm.expect(data.is_active).to.equal(false);
        pm.expect(data.notes).to.include("Updated");
    });
}
```

---

## 5. Reset RT User Password

**Type:** POST  
**URL:** `{{base_url}}/api/admin/users/rt/{{rt_user_id}}/reset-password`  
**Auth:** Bearer Token (SUPER_ADMIN)

### Headers
```
Authorization: Bearer {{superadmin_token}}
Content-Type: application/json
```

### Body (raw JSON)
```json
{
  "password": "NewSecurePass456",
  "password_confirmation": "NewSecurePass456"
}
```

### Test Script
```javascript
let data = pm.response.json().data;
if (pm.response.code === 200) {
    pm.test("RT user password reset successfully", function () {
        pm.expect(data.message).to.include("Password has been reset");
        pm.expect(data.username).to.exist;
    });
}
```

---

## 6. Delete RT User

**Type:** DELETE  
**URL:** `{{base_url}}/api/admin/users/rt/{{rt_user_id}}`  
**Auth:** Bearer Token (SUPER_ADMIN)

### Headers
```
Authorization: Bearer {{superadmin_token}}
```

### Test Script
```javascript
let data = pm.response.json().data;
if (pm.response.code === 200) {
    pm.test("RT user deleted successfully", function () {
        pm.expect(data.username).to.exist;
        pm.expect(data.deleted_at).to.exist;
    });
}
```

---

## 7. Test Authorization (Should Fail)

**Type:** GET  
**URL:** `{{base_url}}/api/admin/users/rt`  
**Auth:** Bearer Token (NON-SUPER_ADMIN, e.g., RT token)

### Expected Response (403)
```json
{
  "success": false,
  "message": "Forbidden",
  "data": null,
  "errors": []
}
```

---

## 🔧 Setup Variables in Postman

Add these to your environment variables:
```
base_url: http://localhost:8000/api
superadmin_token: [Your SUPER_ADMIN token from login]
rt_user_id: [Will be auto-populated after creating RT user]
rt_user_uuid: [Will be auto-populated after creating RT user]
```

---

## 📝 Execution Order (Collection Runner)

1. **Login SUPER_ADMIN** → Get token
2. **Create RT User** → Populate rt_user_id
3. **List RT Users** → Verify list works
4. **Get Single RT User** → Verify details
5. **Update RT User** → Verify update works
6. **Reset Password** → Verify password reset
7. **Delete RT User** → Verify deletion
8. **Test Forbidden** → Verify authorization

---

## ✅ Test Assertions Summary

| Endpoint | Method | Expected Code | Key Assertions |
|----------|--------|---|---|
| Create RT User | POST | 201 | `role === "RT"`, `is_active === true` |
| List RT Users | GET | 200 | `meta.current_page`, `data.length >= 0` |
| Get Single RT | GET | 200 | `data.role === "RT"`, `data.uuid` exists |
| Update RT User | PATCH | 200 | `is_active` updated, `notes` updated |
| Reset Password | POST | 200 | `message` includes "reset" |
| Delete RT User | DELETE | 200 | `deleted_at` exists |
| Unauthorized | GET | 403 | `success === false` |

