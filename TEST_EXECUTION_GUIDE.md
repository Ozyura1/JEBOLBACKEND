# JEBOL Project - Test Execution Guide & Report Template

**Project**: JEBOL (Jaminan dan Penerbitan Surat Online)  
**Date Created**: January 30, 2026  
**Current Status**: Complete Testing Framework Ready

---

## 📊 Quick Start: Running All Tests

### Prerequisites:
```bash
# 1. Laravel Environment
cd backend/backend-laravel
composer install
php artisan migrate:fresh --seed
php artisan serve  # Runs on http://127.0.0.1:8000

# 2. Postman
- Download: https://www.postman.com/downloads/
- Import: backend/backend-laravel/postman/JEBOL-Complete-Testing.postman_collection.json

# 3. Flutter (Optional)
cd jebol_mobile
flutter pub get
flutter test integration_test/
```

---

## 🔬 Whitebox Testing (PHPUnit)

### A. Setup Unit & Feature Tests

**Location**: `/backend/backend-laravel/tests`

```bash
# Run all tests
php artisan test

# Run specific test file
php artisan test tests/Feature/Auth/LoginTest.php

# Run tests with coverage
php artisan test --coverage

# Run tests matching pattern
php artisan test --filter="AdminKtp"
```

### B. Test Files to Create

#### 1. **Authentication Tests**
**File**: `tests/Feature/Auth/LoginTest.php`
```php
<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Tests\TestCase;

class LoginTest extends TestCase
{
    /**
     * Test successful login for SUPER_ADMIN
     */
    public function test_login_with_valid_superadmin_credentials()
    {
        $response = $this->postJson('/api/auth/login', [
            'username' => 'superadmin',
            'password' => 'ChangeMe123!',
            'device_name' => 'test-device',
        ]);

        $response->assertStatus(200)
                 ->assertJsonStructure(['token', 'refresh_token', 'user']);
        
        $this->assertNotEmpty($response->json('token'));
        $this->assertEqual('SUPER_ADMIN', $response->json('user.role'));
    }

    /**
     * Test login with invalid credentials
     */
    public function test_login_with_invalid_credentials()
    {
        $response = $this->postJson('/api/auth/login', [
            'username' => 'invalid_user',
            'password' => 'wrongpassword',
            'device_name' => 'test-device',
        ]);

        $response->assertStatus(401);
        $response->assertJson(['success' => false]);
    }

    /**
     * Test login with missing fields
     */
    public function test_login_with_missing_username()
    {
        $response = $this->postJson('/api/auth/login', [
            'password' => 'ChangeMe123!',
            'device_name' => 'test-device',
        ]);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors('username');
    }

    /**
     * Test all role logins
     */
    public function test_login_with_all_roles()
    {
        $roles = [
            'admin_ktp' => 'AdminKtp123!',
            'admin_ikd' => 'AdminIkd123!',
            'admin_perkawinan' => 'AdminPerkawinan123!',
            'rt_user' => 'RtUser123!',
        ];

        foreach ($roles as $username => $password) {
            $response = $this->postJson('/api/auth/login', [
                'username' => $username,
                'password' => $password,
                'device_name' => 'test-device',
            ]);

            $response->assertStatus(200);
            $this->assertNotEmpty($response->json('token'));
        }
    }
}
```

#### 2. **Admin KTP Tests**
**File**: `tests/Feature/AdminKtp/ListTest.php`
```php
<?php

namespace Tests\Feature\AdminKtp;

use App\Models\User;
use App\Models\KtpSubmission;
use Tests\TestCase;

class ListTest extends TestCase
{
    private User $admin;
    private User $rtUser;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Create test users
        $this->admin = User::factory()->create(['role' => 'ADMIN_KTP']);
        $this->rtUser = User::factory()->create(['role' => 'RT']);
        
        // Create test submissions
        KtpSubmission::factory(5)->create([
            'status' => 'pending',
            'user_id' => $this->rtUser->id,
        ]);
        
        KtpSubmission::factory(3)->create([
            'status' => 'approved',
            'user_id' => $this->rtUser->id,
        ]);
    }

    /**
     * Test list KTP submissions as authorized admin
     */
    public function test_list_ktp_as_admin_ktp()
    {
        $response = $this->actingAs($this->admin)
                         ->getJson('/api/admin/ktp');

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'success',
                     'data' => ['*' => ['id', 'nama', 'status']],
                     'meta' => ['current_page', 'total', 'per_page'],
                 ]);
    }

    /**
     * Test list KTP with status filter
     */
    public function test_list_ktp_with_status_filter()
    {
        $response = $this->actingAs($this->admin)
                         ->getJson('/api/admin/ktp?status=pending');

        $response->assertStatus(200);
        
        foreach ($response->json('data') as $item) {
            $this->assertEqual('pending', $item['status']);
        }
    }

    /**
     * Test list KTP without authentication
     */
    public function test_list_ktp_without_auth()
    {
        $response = $this->getJson('/api/admin/ktp');

        $response->assertStatus(401);
    }

    /**
     * Test list KTP with RT user (should be forbidden)
     */
    public function test_list_ktp_as_rt_user()
    {
        $response = $this->actingAs($this->rtUser)
                         ->getJson('/api/admin/ktp');

        $response->assertStatus(403);
    }

    /**
     * Test pagination
     */
    public function test_list_ktp_pagination()
    {
        $response = $this->actingAs($this->admin)
                         ->getJson('/api/admin/ktp?page=1&per_page=2');

        $response->assertStatus(200);
        $this->assertCount(2, $response->json('data'));
        $this->assertEqual(1, $response->json('meta.current_page'));
    }
}
```

#### 3. **Approval/Rejection Tests**
**File**: `tests/Feature/AdminKtp/ApproveTest.php`
```php
<?php

namespace Tests\Feature\AdminKtp;

use App\Models\User;
use App\Models\KtpSubmission;
use Tests\TestCase;

class ApproveTest extends TestCase
{
    private User $admin;
    private KtpSubmission $pendingSubmission;
    private KtpSubmission $approvedSubmission;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->admin = User::factory()->create(['role' => 'ADMIN_KTP']);
        
        $rtUser = User::factory()->create(['role' => 'RT']);
        
        $this->pendingSubmission = KtpSubmission::factory()->create([
            'status' => 'pending',
            'user_id' => $rtUser->id,
        ]);
        
        $this->approvedSubmission = KtpSubmission::factory()->create([
            'status' => 'approved',
            'user_id' => $rtUser->id,
        ]);
    }

    /**
     * Test approve pending KTP
     */
    public function test_approve_pending_ktp()
    {
        $response = $this->actingAs($this->admin)
                         ->postJson(
                             "/api/admin/ktp/{$this->pendingSubmission->id}/approve"
                         );

        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'data' => ['status' => 'approved'],
                 ]);

        $this->assertEqual(
            'approved',
            $this->pendingSubmission->fresh()->status
        );
    }

    /**
     * Test cannot approve already approved KTP
     */
    public function test_cannot_approve_already_approved_ktp()
    {
        $response = $this->actingAs($this->admin)
                         ->postJson(
                             "/api/admin/ktp/{$this->approvedSubmission->id}/approve"
                         );

        $response->assertStatus(400)
                 ->assertJson(['success' => false]);
    }

    /**
     * Test approve non-existent KTP
     */
    public function test_approve_nonexistent_ktp()
    {
        $response = $this->actingAs($this->admin)
                         ->postJson('/api/admin/ktp/invalid_id/approve');

        $response->assertStatus(404);
    }
}
```

#### 4. **RT Submission Tests**
**File**: `tests/Feature/RtSubmission/SubmitKtpTest.php`
```php
<?php

namespace Tests\Feature\RtSubmission;

use App\Models\User;
use App\Models\KtpSubmission;
use Tests\TestCase;

class SubmitKtpTest extends TestCase
{
    private User $rtUser;

    protected function setUp(): void
    {
        parent::setUp();
        $this->rtUser = User::factory()->create(['role' => 'RT']);
    }

    /**
     * Test valid KTP submission
     */
    public function test_submit_valid_ktp()
    {
        $response = $this->actingAs($this->rtUser)
                         ->postJson('/api/rt/ktp/submit', [
                             'nama' => 'John Doe',
                             'nomor_telp' => '081234567890',
                             'alamat_manual' => 'Jl. Test No. 123',
                             'latitude' => -6.2088,
                             'longitude' => 106.8456,
                             'kategori' => 'umum',
                             'jumlah_pemohon' => 2,
                             'minimal_usia' => 17,
                         ]);

        $response->assertStatus(201)
                 ->assertJson(['success' => true])
                 ->assertJsonStructure(['data' => ['id', 'status']]);

        $this->assertDatabaseHas('ktp_submissions', [
            'nama' => 'John Doe',
            'user_id' => $this->rtUser->id,
            'status' => 'pending',
        ]);
    }

    /**
     * Test KTP submission with missing required field
     */
    public function test_submit_ktp_without_nama()
    {
        $response = $this->actingAs($this->rtUser)
                         ->postJson('/api/rt/ktp/submit', [
                             'nomor_telp' => '081234567890',
                             'alamat_manual' => 'Jl. Test No. 123',
                             'latitude' => -6.2088,
                             'longitude' => 106.8456,
                             'kategori' => 'umum',
                             'jumlah_pemohon' => 2,
                             'minimal_usia' => 17,
                         ]);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors('nama');
    }

    /**
     * Test KTP submission with invalid phone number
     */
    public function test_submit_ktp_with_invalid_phone()
    {
        $response = $this->actingAs($this->rtUser)
                         ->postJson('/api/rt/ktp/submit', [
                             'nama' => 'John Doe',
                             'nomor_telp' => '123', // Too short
                             'alamat_manual' => 'Jl. Test No. 123',
                             'latitude' => -6.2088,
                             'longitude' => 106.8456,
                             'kategori' => 'umum',
                             'jumlah_pemohon' => 2,
                             'minimal_usia' => 17,
                         ]);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors('nomor_telp');
    }

    /**
     * Test KTP submission with special category
     */
    public function test_submit_ktp_with_special_category()
    {
        $response = $this->actingAs($this->rtUser)
                         ->postJson('/api/rt/ktp/submit', [
                             'nama' => 'Jane Doe',
                             'nomor_telp' => '081234567891',
                             'alamat_manual' => 'Jl. Special No. 456',
                             'latitude' => -6.2100,
                             'longitude' => 106.8470,
                             'kategori' => 'khusus',
                             'kategori_khusus' => 'lansia',
                             'jumlah_pemohon' => 1,
                             'minimal_usia' => 60,
                         ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('ktp_submissions', [
            'kategori' => 'khusus',
            'kategori_khusus' => 'lansia',
        ]);
    }

    /**
     * Test RT cannot submit without authentication
     */
    public function test_submit_ktp_without_auth()
    {
        $response = $this->postJson('/api/rt/ktp/submit', [
            'nama' => 'John Doe',
        ]);

        $response->assertStatus(401);
    }
}
```

#### 5. **Public Perkawinan Tests**
**File**: `tests/Feature/PublicPerkawinan/SubmitTest.php`
```php
<?php

namespace Tests\Feature\PublicPerkawinan;

use App\Models\PerkawinanRequest;
use Tests\TestCase;

class SubmitTest extends TestCase
{
    /**
     * Test valid perkawinan submission (no auth required)
     */
    public function test_submit_valid_perkawinan()
    {
        $response = $this->postJson('/api/public/perkawinan/submit', [
            'nama_pemohon' => 'Ahmad Wijaya',
            'nik_pemohon' => '1234567890123456',
            'no_hp_pemohon' => '081234567890',
            'nama_pasangan' => 'Siti Nurhaliza',
            'nik_pasangan' => '6543210987654321',
            'no_hp_pasangan' => '081234567891',
            'alamat_domisili' => 'Jl. Raya No. 123',
            'tanggal_perkawinan' => '2026-03-15',
            'tempat_perkawinan' => 'KUA Kecamatan Kebayoran',
        ]);

        $response->assertStatus(201)
                 ->assertJson(['success' => true])
                 ->assertJsonStructure(['data' => ['uuid', 'status']]);

        $this->assertDatabaseHas('perkawinan_requests', [
            'nama_pemohon' => 'Ahmad Wijaya',
            'status' => 'PENDING',
        ]);
    }

    /**
     * Test missing required field
     */
    public function test_submit_perkawinan_without_nama_pemohon()
    {
        $response = $this->postJson('/api/public/perkawinan/submit', [
            'nik_pemohon' => '1234567890123456',
        ]);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors('nama_pemohon');
    }

    /**
     * Test invalid NIK format
     */
    public function test_submit_perkawinan_with_invalid_nik()
    {
        $response = $this->postJson('/api/public/perkawinan/submit', [
            'nama_pemohon' => 'Test',
            'nik_pemohon' => '123', // Too short
            'no_hp_pemohon' => '081234567890',
        ]);

        $response->assertStatus(422)
                 ->assertJsonValidationErrors('nik_pemohon');
    }
}
```

#### 6. **Status Tracking Tests**
**File**: `tests/Feature/PublicPerkawinan/StatusTest.php`
```php
<?php

namespace Tests\Feature\PublicPerkawinan;

use App\Models\PerkawinanRequest;
use Tests\TestCase;

class StatusTest extends TestCase
{
    private PerkawinanRequest $request;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->request = PerkawinanRequest::factory()->create([
            'nik_pemohon' => '1234567890123456',
            'status' => 'PENDING',
        ]);
    }

    /**
     * Test track status with valid UUID and NIK
     */
    public function test_track_status_with_valid_data()
    {
        $response = $this->getJson(
            "/api/public/perkawinan/{$this->request->uuid}/status?nik_pemohon={$this->request->nik_pemohon}"
        );

        $response->assertStatus(200)
                 ->assertJson([
                     'success' => true,
                     'data' => [
                         'uuid' => $this->request->uuid,
                         'status' => 'PENDING',
                     ],
                 ]);
    }

    /**
     * Test track status with wrong NIK
     */
    public function test_track_status_with_wrong_nik()
    {
        $response = $this->getJson(
            "/api/public/perkawinan/{$this->request->uuid}/status?nik_pemohon=9999999999999999"
        );

        $response->assertStatus(404);
    }

    /**
     * Test track status with invalid UUID
     */
    public function test_track_status_with_invalid_uuid()
    {
        $response = $this->getJson(
            '/api/public/perkawinan/invalid-uuid/status?nik_pemohon=1234567890123456'
        );

        $response->assertStatus(404);
    }

    /**
     * Test track status without NIK
     */
    public function test_track_status_without_nik()
    {
        $response = $this->getJson(
            "/api/public/perkawinan/{$this->request->uuid}/status"
        );

        $response->assertStatus(422)
                 ->assertJsonValidationErrors('nik_pemohon');
    }
}
```

### C. Run All Tests

```bash
cd backend/backend-laravel

# Run all tests
php artisan test

# Output should show:
# PASSED  Tests\Feature\Auth\LoginTest
# PASSED  Tests\Feature\AdminKtp\ListTest
# PASSED  Tests\Feature\AdminKtp\ApproveTest
# PASSED  Tests\Feature\RtSubmission\SubmitKtpTest
# PASSED  Tests\Feature\PublicPerkawinan\SubmitTest
# PASSED  Tests\Feature\PublicPerkawinan\StatusTest
```

---

## 🖥️ Blackbox Testing (Postman)

### A. Setup Postman Environment

1. **Import Collection**:
   - Open Postman
   - Click "Import"
   - Select: `backend/backend-laravel/postman/JEBOL-Complete-Testing.postman_collection.json`

2. **Configure Variables**:
   - Create Environment named "JEBOL Testing"
   - Set variables:
     ```
     base_url: http://127.0.0.1:8000
     token: (empty - filled by tests)
     refresh_token: (empty - filled by tests)
     superadmin_token: (empty)
     admin_ktp_token: (empty)
     admin_ikd_token: (empty)
     admin_perkawinan_token: (empty)
     rt_token: (empty)
     ```

### B. Run Tests in Postman

**Method 1: Manual Testing**
1. Open Collection
2. Select "🔐 AUTHENTICATION" folder
3. Run each request sequentially
4. Verify response matches expected (200, 401, etc)

**Method 2: Automated Collection Runner**
1. Click "▶ Run" button
2. Select collection and environment
3. Click "Run JEBOL Complete API Testing"
4. View report with pass/fail summary

**Method 3: CLI with Newman**
```bash
# Install Newman (npm required)
npm install -g newman

# Run collection
newman run \
  "backend/backend-laravel/postman/JEBOL-Complete-Testing.postman_collection.json" \
  -e "path/to/environment.json" \
  --reporters cli,json \
  --reporter-json-export "test-results.json"

# Generate HTML report
npm install -g newman-reporter-html
newman run ... --reporters cli,html --reporter-html-export "report.html"
```

---

## 📊 Test Execution Report Template

Create file: `TEST_REPORT_[DATE].md`

```markdown
# JEBOL Project - Test Execution Report

**Execution Date**: January 30, 2026  
**Executed By**: [Your Name]  
**Environment**: Local Dev (127.0.0.1:8000)  
**Duration**: [X hours]  

---

## 📈 Executive Summary

| Metric | Count | % |
|--------|-------|---|
| Total Test Cases | 87 | 100% |
| Passed | 85 | 97.7% |
| Failed | 2 | 2.3% |
| Blocked/Skipped | 0 | 0% |

**Overall Result**: ✅ **PASSED WITH MINOR ISSUES**

---

## 🔐 Authentication Tests (13 cases)

### Whitebox (PHPUnit)
- ✅ Login with valid SUPER_ADMIN credentials
- ✅ Login with valid ADMIN_KTP credentials
- ✅ Login with valid ADMIN_IKD credentials
- ✅ Login with valid ADMIN_PERKAWINAN credentials
- ✅ Login with valid RT credentials
- ✅ Login with invalid username
- ✅ Login with invalid password
- ✅ Login with missing password field
- ✅ Token refresh with valid refresh_token
- ✅ Token refresh with invalid token
- ✅ Logout with valid token
- ✅ Get current user (me endpoint)
- ✅ Access denied without authentication

**Result**: 13/13 PASSED ✅

### Blackbox (Postman)
- ✅ Login - SUPER_ADMIN (200)
- ✅ Login - ADMIN_KTP (200)
- ✅ Login - Invalid credentials (401)
- ✅ Token Refresh (200)
- ✅ Logout (200)
- ✅ Me endpoint (200)

**Result**: 6/6 PASSED ✅

---

## 📋 Admin KTP Tests (18 cases)

### Whitebox Results
- ✅ List KTP - Default (pending)
- ✅ List KTP - With status filter
- ✅ List KTP - Pagination
- ✅ List KTP - Without auth (401)
- ✅ List KTP - Wrong role (403)
- ✅ View KTP detail - Valid ID
- ✅ View KTP detail - Invalid ID
- ✅ Approve KTP - Valid pending
- ✅ Approve KTP - Already approved (400)
- ✅ Approve non-existent (404)
- ❌ **ISSUE**: Reject KTP - Missing reason validation (Expected 422, got 400)
- ✅ Reject KTP - Valid pending
- ✅ Schedule KTP - Valid approved
- ✅ Schedule KTP - Past date rejected
- ✅ Schedule KTP - Non-existent (404)

**Result**: 14/15 PASSED ⚠️

### Blackbox Results
- ✅ List KTP - Default (200)
- ✅ List KTP - Filter approved (200)
- ✅ List KTP - Forbidden role (403)
- ✅ View KTP detail (200)
- ✅ Approve KTP (200)
- ✅ Reject KTP (200)
- ✅ Schedule KTP (200)

**Result**: 7/7 PASSED ✅

---

## 📋 Admin IKD Tests (18 cases)

### Whitebox Results
- ✅ All tests similar to KTP module
- ✅ List IKD - Default
- ✅ List IKD - Pagination
- ✅ View IKD detail
- ✅ Approve IKD
- ✅ Reject IKD
- ✅ Schedule IKD

**Result**: 16/16 PASSED ✅

### Blackbox Results
- ✅ All API calls successful
- ✅ Status codes correct
- ✅ Response structure valid

**Result**: 8/8 PASSED ✅

---

## 💍 Admin Perkawinan Tests (10 cases)

### Whitebox Results
- ✅ List perkawinan requests
- ✅ View perkawinan detail
- ✅ Verify PENDING request
- ✅ Verify already processed (400)
- ✅ Reject PENDING request
- ✅ Reject already processed (400)

**Result**: 6/6 PASSED ✅

### Blackbox Results
- ✅ List perkawinan (200)
- ✅ View detail (200)
- ✅ Verify request (200)
- ✅ Reject request (200)

**Result**: 4/4 PASSED ✅

---

## 🏘️ RT Submission Tests (12 cases)

### Whitebox Results
- ✅ Submit KTP - Valid data
- ✅ Submit KTP - Missing nama field
- ✅ Submit KTP - Invalid phone number
- ✅ Submit KTP - Special category
- ✅ Submit KTP - Without auth (401)
- ✅ Submit IKD - Valid data
- ✅ Dashboard summary
- ✅ Get notifications
- ✅ Mark notification as read

**Result**: 9/9 PASSED ✅

### Blackbox Results
- ✅ Submit KTP (201)
- ✅ Get dashboard summary (200)
- ✅ Get notifications (200)

**Result**: 3/3 PASSED ✅

---

## 🌐 Public Perkawinan Tests (8 cases)

### Whitebox Results
- ✅ Submit perkawinan - Valid data (no auth)
- ✅ Submit perkawinan - Invalid NIK
- ✅ Track status - Valid UUID & NIK
- ✅ Track status - Wrong NIK (404)
- ✅ Track status - Invalid UUID (404)

**Result**: 5/5 PASSED ✅

### Blackbox Results
- ✅ Submit perkawinan (201)
- ✅ Track status - Valid (200)
- ✅ Track status - Invalid (404)

**Result**: 3/3 PASSED ✅

---

## 🔄 Data Refresh & Consistency Tests (3 cases)

### Test Sequence:
1. ✅ Get initial KTP list (total: 10)
2. ✅ Refresh token
3. ✅ Get KTP list after refresh (total: 10)
   - **RESULT**: Data consistent ✅
   - **Note**: No data loss observed

---

## ⚠️ Issues Found

### Issue #1: Reject Validation Error Message
- **Severity**: LOW
- **Component**: Admin KTP Reject
- **Steps to Reproduce**:
  1. Send reject request without `rejection_reason`
  2. Expected: 422 with validation error
  3. Actual: 400 with generic error
- **Impact**: Confusing error response to client
- **Status**: NEEDS FIX
- **Recommendation**: Ensure validation happens before business logic

### Issue #2: Token Expiry Not Tested
- **Severity**: MEDIUM
- **Component**: Auth Token Refresh
- **Issue**: Cannot fully test expired token scenarios in test environment
- **Recommendation**: Add token TTL configuration to test environment

---

## 🎯 Testing Coverage Summary

| Module | Whitebox | Blackbox | Coverage |
|--------|----------|----------|----------|
| Authentication | 13/13 | 6/6 | 100% |
| Admin KTP | 15/15 | 7/7 | 100% |
| Admin IKD | 16/16 | 8/8 | 100% |
| Admin Perkawinan | 6/6 | 4/4 | 100% |
| RT Submission | 9/9 | 3/3 | 100% |
| Public Perkawinan | 5/5 | 3/3 | 100% |
| Data Consistency | - | 3/3 | 100% |
| **TOTAL** | **64/65** | **34/34** | **99.5%** |

---

## 🔍 Detailed Test Results by Endpoint

### GET /api/admin/ktp
- ✅ Status 200 with valid token
- ✅ Status 401 without token
- ✅ Status 403 with RT role
- ✅ Filtering by status works
- ✅ Pagination returns correct items

### POST /api/admin/ktp/{id}/approve
- ✅ Status 200 when approving pending
- ✅ Status 400 when already approved
- ✅ Status 404 when not found

[Continue for all endpoints...]

---

## 📋 Recommendations

1. **Fix Validation Error Responses**
   - Ensure all validation errors return 422 consistently
   - Include detailed error messages in response

2. **Add Token TTL Testing**
   - Configure shorter token TTL for testing
   - Test actual expiration scenarios

3. **Add More Edge Cases**
   - Test concurrent requests
   - Test very large pagination requests
   - Test special characters in input

4. **Performance Testing**
   - Load test admin list endpoints
   - Measure response times with pagination

5. **Integration Testing**
   - Test notification triggers after approval
   - Test audit log creation
   - Test email notifications (mock)

---

## ✅ Testing Checklist

- [x] All authentication flows tested
- [x] All CRUD operations tested
- [x] Role-based access control verified
- [x] Error handling validated
- [x] Data consistency checked
- [x] Pagination working correctly
- [x] Token refresh functioning
- [x] Validation rules enforced
- [x] Business logic validated
- [x] Logging functional
- [ ] Performance acceptable
- [ ] Load testing completed
- [ ] Security penetration testing

---

## 📊 Test Metrics

| Metric | Value |
|--------|-------|
| Total Test Cases | 99 |
| Pass Rate | 97.7% |
| Average Response Time | 250ms |
| Slowest Endpoint | /api/admin/ktp (with pagination) |
| API Uptime | 99.9% |

---

## 👥 Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| QA Lead | __________ | Jan 30, 2026 | __________ |
| Dev Lead | __________ | Jan 30, 2026 | __________ |
| PM | __________ | Jan 30, 2026 | __________ |

---

## 📌 Appendix

### A. Test Data Used
- SUPER_ADMIN: superadmin/ChangeMe123!
- ADMIN_KTP: admin_ktp/AdminKtp123!
- ADMIN_IKD: admin_ikd/AdminIkd123!
- ADMIN_PERKAWINAN: admin_perkawinan/AdminPerkawinan123!
- RT_USER: rt_user/RtUser123!

### B. Test Environment
- Laravel: 11.x
- PHP: 8.2
- MySQL: 8.0
- Server: Local (127.0.0.1:8000)

### C. Tools Used
- PHPUnit 11.x
- Postman 11.x
- Newman (CLI)
- Git for version control

### D. References
- API Documentation: /backend/backend-laravel/docs/api/
- Testing Guidelines: /TESTING_PLAN.md
- Postman Collection: /backend/backend-laravel/postman/JEBOL-Complete-Testing.postman_collection.json
```

---

## 🚀 Quick Commands Summary

```bash
# 1. Run all PHPUnit tests
php artisan test

# 2. Run specific test
php artisan test tests/Feature/Auth/LoginTest.php

# 3. Run with coverage
php artisan test --coverage

# 4. Run Postman via Newman
newman run backend/backend-laravel/postman/JEBOL-Complete-Testing.postman_collection.json

# 5. Check Laravel routes
php artisan route:list | grep api

# 6. Database check
php artisan tinker
> DB::table('ktp_submissions')->count()
> DB::table('users')->pluck('role')

# 7. View logs
tail -f storage/logs/laravel.log
```

---

## 📞 Support & Troubleshooting

### Database Connection Error
```bash
php artisan migrate:fresh --seed
```

### Token Validation Issues
```bash
# Check token in database
php artisan tinker
> \Laravel\Sanctum\PersonalAccessToken::where('name', 'device:access')->first()
```

### Test Database Not Resetting
```bash
# Force reset
php artisan migrate:fresh --seed --env=testing
```

---

**Last Updated**: January 30, 2026  
**Next Review**: After each sprint  
**Owner**: QA Team

