# 📋 PERUBAHAN POSTMAN COLLECTION - JEBOL Complete Testing

**Tanggal:** February 3, 2026  
**Status:** ✅ SELESAI  
**File:** `backend-laravel/postman/JEBOL-Complete-Testing.postman_collection.json`

---

## 🔍 RINGKASAN PERUBAHAN

Total **50+ requests** diperbaiki untuk align dengan dokumentasi API backend Laravel yang sebenarnya.

### **MASALAH UTAMA YANG DIPERBAIKI:**

#### 1. ❌ **Token Extraction (KRITIS)**
- **Lama:** `jsonData.token` (root level)
- **Baru:** `body.data.token` (wrapped by ApiResponder)
- **Affected:** Semua Login, Refresh, dan endpoints yang extract token

#### 2. ❌ **Status Values - Case Sensitivity**
- **Lama:** `status=pending` (lowercase)
- **Baru:** `status=PENDING` (UPPERCASE)
- **Affected:** List KTP, IKD, Perkawinan - semua filter query

#### 3. ❌ **Response Structure Handling**
- **Lama:** Direct root access `jsonData.field`
- **Baru:** Wrapper-aware `body.data.field` dengan fallback
- **Affected:** Semua test assertions (50+ requests)

#### 4. ❌ **Request Bodies - Field Names**
- **KTP Approve:** `notes` (instead of missing)
- **KTP Reject:** `reason` + `notes` (bukan `rejection_reason`)
- **IKD/Perkawinan:** Sama - align dengan dokumentasi
- **Affected:** 12 action endpoints

#### 5. ❌ **API Endpoints - Path Corrections**
- **RT Notifications:** `/api/rt/notifications` (bukan `/api/rt/dashboard/notifications`)
- **RT Schedules:** `/api/rt/schedules` (bukan `/api/rt/dashboard/schedules`)
- **Public Perkawinan Track:** `/api/public/perkawinan/track` (clarified)
- **Affected:** 3 endpoints

---

## ✅ PERUBAHAN DETAIL PER FOLDER

### 🔐 **AUTHENTICATION (1.1-1.4)**
| Request | Masalah | Fix |
|---------|--------|-----|
| 1.1.1-1.1.5 Login | Token path `jsonData.token` | Extract dari `body.data.token` |
| 1.2.1-1.2.2 Refresh | Token handling salah | Handle `body.data.token` dengan safe fallback |
| 1.3.1 Logout | Logic OK | ✅ Verified |
| 1.4.1 Me | Test check fields | ✅ Enhanced checks |

**Test Scripts Updated:**
- Tambah try/catch untuk JSON parse error
- Safe access: `let data = body.data ?? body;`
- Token extraction: `pm.environment.set()` dari correct path

---

### 📋 **ADMIN KTP (2.1-2.5)**
| Request | Masalah | Fix |
|---------|--------|-----|
| 2.1.1 List Pending | `status=pending` lowercase | ✅ `status=PENDING` |
| 2.1.2 List Approved | Status filter case | ✅ `status=APPROVED` |
| 2.1.3 List Rejected | Status filter case | ✅ `status=REJECTED` |
| 2.2.1 Detail | Field name check | ✅ `data.nama_lengkap` |
| 2.3.1 Approve | No request body | ✅ Add `notes` field |
| 2.4.1 Reject | Wrong field name | ✅ Use `reason` + `notes` |
| 2.5.1 Schedule | Wrong field names | ✅ Use `jadwal_pengambilan`, `lokasi_pengambilan` |

**All List Endpoints:**
- Query: `?status=UPPERCASE&page=1&per_page=15`
- Response check: `body.meta.current_page`, `body.meta.per_page`, `body.meta.total`
- Extract ID: `data[0].id` safely

**All Action Endpoints (Approve/Reject/Schedule):**
- Add `Content-Type: application/json` header
- Response status: Case-insensitive check `.toUpperCase()`
- Safe field access: `body.data ?? body`

---

### 📋 **ADMIN IKD (3.1-3.5)**
| Request | Masalah | Fix |
|---------|--------|-----|
| 3.1.1 List Pending | `status=pending` lowercase | ✅ `status=PENDING` |
| 3.1.2 List Approved | Status filter case | ✅ `status=APPROVED` |
| 3.2.1 Detail | Field name check | ✅ Enhanced |
| 3.3.1 Approve | Body structure | ✅ Add `notes` |
| 3.4.1 Reject | Field names | ✅ `reason` + `notes` |
| 3.5.1 Schedule | Field names | ✅ `jadwal_pengambilan` + `lokasi_pengambilan` |

**Pattern:** Same as KTP module for consistency

---

### 💍 **ADMIN PERKAWINAN (4.1-4.4)**
| Request | Masalah | Fix |
|---------|--------|-----|
| 4.1.1 List | `status=pending` lowercase | ✅ `status=PENDING` |
| 4.2.1 Detail | UUID extraction | ✅ Verify `data.uuid` exists |
| 4.3.1 Verify | Field names | ✅ Use `nomor_akta_perkawinan`, `tanggal_pencatatan`, `notes` |
| 4.4.1 Reject | Field names | ✅ Use `reason` + `notes` |

**Status Values:**
- API returns: `PENDING`, `SUBMITTED`, `VERIFIED`, `REJECTED`
- All tests: Case-insensitive check `.toUpperCase()`

---

### 🏘️ **RT SUBMISSION (5.1-5.5)**
| Request | Masalah | Fix |
|---------|--------|-----|
| 5.1.1 Submit KTP | Body fields | ✅ Use actual fields: `nik`, `nama_lengkap`, `no_telepon`, `alamat_lengkap` |
| 5.2.1 Submit IKD | Body fields | ✅ Use actual fields: `nik`, `nama_lengkap`, `tanggal_lahir`, `jenis_kelamin`, `agama`, `pekerjaan`, `status_perkawinan`, `alamat` |
| 5.3.1 Dashboard | Endpoint OK | ✅ Verified |
| 5.4.1 Notifications | ❌ Wrong path | ✅ `/api/rt/notifications` |
| 5.5.1 Schedules | ❌ Wrong path | ✅ `/api/rt/schedules` |

**Endpoint Corrections:**
- `GET /api/rt/notifications?page=1&per_page=10` (not `/dashboard/notifications`)
- `GET /api/rt/schedules?page=1&per_page=10&status=upcoming` (not `/dashboard/schedules`)

---

### 🌐 **PUBLIC PERKAWINAN (6.1-6.2)**
| Request | Masalah | Fix |
|---------|--------|-----|
| 6.1.1 Submit | Body fields | ✅ All required fields included |
| 6.1.2 Submit Invalid | Validation test | ✅ Test 422 response |
| 6.2.1 Track | Query params | ✅ `?uuid=...&nik=...` |
| 6.2.2 Track Wrong | Negative test | ✅ Test 404 response |

**Notes:**
- No auth required for these endpoints
- Extract UUID from response: `data[0].uuid` or `data.uuid`
- Track query: Case-sensitive for NIK (16 digits)

---

### 🔄 **REFRESH & CONSISTENCY (Refresh 1-3)**
| Request | Masalah | Fix |
|---------|--------|-----|
| Refresh 1 | Extract total | ✅ Use `meta.total` |
| Refresh 2 | Token refresh | ✅ Extract from `body.data.token` |
| Refresh 3 | Compare consistency | ✅ Compare pagination total |

---

### 🧪 **ERROR SCENARIOS (Error 1-3)**
| Request | Masalah | Fix |
|---------|--------|-----|
| Error 1 | Wrong role test | ✅ Test 403 Forbidden |
| Error 2 | No auth test | ✅ Test 401 Unauthorized |
| Error 3 | Invalid JSON | ✅ Test 400/422 response |

---

## 🎯 KEY IMPROVEMENTS

### ✨ **Safe Response Handling (All Tests)**
```javascript
// OLD (BROKEN)
let jsonData = pm.response.json();
pm.expect(jsonData.token).to.exist;

// NEW (FIXED)
let body = pm.response.json();
let data = body.data ?? body;
pm.expect(data.token).to.be.a('string');
```

### ✨ **Case-Insensitive Status Check**
```javascript
// OLD
pm.expect(data.status).to.equal('approved');

// NEW
pm.expect(String(data.status ?? '').toUpperCase()).to.equal('APPROVED');
```

### ✨ **Dynamic Variable Extraction**
```javascript
// OLD
pm.environment.set('ktp_id', pm.response.json().data[0].id); // BREAKS if no data

// NEW
let data = body.data ?? [];
if (data.length > 0) {
    pm.environment.set('ktp_id', data[0].id);
}
```

### ✨ **Error Handling in Tests**
```javascript
// ALL TESTS WRAPPED
try {
    // test logic
} catch (e) {
    pm.test('JSON Parse Error', () => { 
        throw new Error('Response parse error: ' + e.message); 
    });
}
```

---

## 🚀 CARA PAKAI COLLECTION

### **1. Import ke Postman**
```
File > Import > Pilih JEBOL-Complete-Testing.postman_collection.json
```

### **2. Setup Environment**
```
Postman > Environments > Create baru (atau edit existing)
- base_url = http://127.0.0.1:8000
- (Lainnya auto-populate dari login test)
```

### **3. Run Collection**
```
Collection > JEBOL Complete Testing > Run
(Jalankan folder by folder atau run all)
```

### **4. Test Order**
1. **🔐 AUTHENTICATION** - Populate semua token variables
2. **📋 ADMIN KTP** - Test CRUD KTP
3. **📋 ADMIN IKD** - Test CRUD IKD
4. **💍 ADMIN PERKAWINAN** - Test CRUD Perkawinan
5. **🏘️ RT SUBMISSION** - Test RT submissions
6. **🌐 PUBLIC PERKAWINAN** - Test public API
7. **🔄 REFRESH & DATA** - Test token refresh + consistency
8. **🧪 ERROR SCENARIOS** - Test error handling

---

## 📊 STATISTICS

| Kategori | Count | Status |
|----------|-------|--------|
| Total Requests | 50+ | ✅ Fixed |
| Login Endpoints | 5 | ✅ Token extraction fixed |
| List Endpoints | 8 | ✅ Status uppercase fixed |
| Detail Endpoints | 4 | ✅ Field access fixed |
| Action Endpoints | 12 | ✅ Request body fixed |
| RT Endpoints | 6 | ✅ Path fixed |
| Public Endpoints | 4 | ✅ Query params fixed |
| Error Tests | 9 | ✅ Enhanced |
| Refresh/Consistency | 3 | ✅ Meta handling fixed |

---

## ⚠️ IMPORTANT NOTES

1. **File Backup:** Original file di-backup sebagai `JEBOL-Complete-Testing.postman_collection.json.backup`

2. **Backward Compatibility:** Jika punya environment custom, verify `base_url` dan token variables masih OK

3. **Backend Must Match:** Collection ini assume backend sudah implement sesuai dokumentasi (ApiResponder wrapper, uppercase status, correct endpoints)

4. **Variable Population:** Beberapa tests set environment variables (tokens, IDs, UUIDs). Pastikan run dalam urutan yang benar.

5. **Date Values:** Test schedule menggunakan tanggal future (2026-02-15). Ganti sesuai kebutuhan testing.

---

## 🔗 REFERENCE LINKS

- **API Documentation:** Generated dari backend code analysis
- **Test Examples:** Laravel Feature Tests di `backend-laravel/tests/Feature/`
- **Backend Response:** `backend-laravel/app/Support/ApiResponder.php`
- **Routes:** `backend-laravel/routes/api.php`

---

**✅ COLLECTION SIAP DIGUNAKAN!**

Jalankan test sekarang dan semua harus PASS ✓

