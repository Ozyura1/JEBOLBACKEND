# JEBOL Project - Comprehensive Testing Plan

**Date**: January 30, 2026  
**Project**: JEBOL (Jaminan dan Penerbitan Surat Online)  
**Status**: Complete Testing Strategy

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Testing Scope](#testing-scope)
3. [Test Cases by Module](#test-cases-by-module)
4. [Whitebox Testing](#whitebox-testing)
5. [Blackbox Testing](#blackbox-testing)
6. [Postman Testing Guide](#postman-testing-guide)
7. [Test Report Template](#test-report-template)

---

## Executive Summary

JEBOL adalah sistem manajemen permohonan surat online untuk Rumah Tangga (RT) dengan fitur:
- **Authentication**: Login, Logout, Token Refresh
- **Admin Modules**: KTP, IKD, Perkawinan
- **RT Module**: Submit KTP/IKD, Dashboard, Notifications
- **Public Module**: Pendaftaran Perkawinan tanpa login

**Testing Coverage**: 
- 40+ API endpoints
- 5+ User roles
- Whitebox, Blackbox, dan Postman testing

---

## Testing Scope

### In Scope:
✅ Authentication flow (login, logout, token refresh)  
✅ Role-based access control (RBAC)  
✅ Admin KTP management (list, view, approve, reject, schedule)  
✅ Admin IKD management (list, view, approve, reject, schedule)  
✅ Admin Perkawinan (list, view, verify, reject)  
✅ RT Submission (KTP, IKD)  
✅ RT Dashboard (summary, notifications, schedules)  
✅ Public Perkawinan (submit, track status)  
✅ Pagination and filtering  
✅ Error handling and validation  
✅ Data consistency and persistence  

### Out of Scope:
❌ Frontend UI testing (covered by Flutter integration tests)  
❌ Performance/load testing  
❌ Security penetration testing  
❌ Email delivery verification  

---

## Test Cases by Module

### 🔐 1. AUTHENTICATION MODULE

#### 1.1 Login Endpoint
- **Endpoint**: `POST /api/auth/login`
- **Test Cases**:
  
| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 1.1.1 | Valid login - SUPER_ADMIN | username: superadmin, password: ChangeMe123! | 200, token generated | ⏳ |
| 1.1.2 | Valid login - ADMIN_KTP | username: admin_ktp, password: pass123 | 200, token generated | ⏳ |
| 1.1.3 | Valid login - ADMIN_IKD | username: admin_ikd, password: pass123 | 200, token generated | ⏳ |
| 1.1.4 | Valid login - ADMIN_PERKAWINAN | username: admin_perkawinan, password: pass123 | 200, token generated | ⏳ |
| 1.1.5 | Valid login - RT user | username: rt_user, password: pass123 | 200, token generated | ⏳ |
| 1.1.6 | Invalid username | username: invalid_user, password: ChangeMe123! | 401, Unauthenticated | ⏳ |
| 1.1.7 | Invalid password | username: superadmin, password: wrongpass | 401, Unauthenticated | ⏳ |
| 1.1.8 | Inactive user | username: inactive_user, password: pass123 | 403, Forbidden | ⏳ |
| 1.1.9 | Empty username | username: "", password: ChangeMe123! | 422, Validation error | ⏳ |
| 1.1.10 | Empty password | username: superadmin, password: "" | 422, Validation error | ⏳ |
| 1.1.11 | Missing device_name | username: superadmin, password: ChangeMe123! | 200, defaults to "mobile" | ⏳ |
| 1.1.12 | Custom device_name | username: superadmin, password: ChangeMe123!, device_name: postman | 200, token with device name | ⏳ |

#### 1.2 Token Refresh Endpoint
- **Endpoint**: `POST /api/auth/refresh`
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 1.2.1 | Valid refresh token | Bearer: valid_refresh_token | 200, new token generated | ⏳ |
| 1.2.2 | Expired refresh token | Bearer: expired_token | 401, Unauthorized | ⏳ |
| 1.2.3 | Invalid refresh token | Bearer: invalid_token | 401, Unauthorized | ⏳ |
| 1.2.4 | No refresh token | (empty Bearer) | 401, Unauthenticated | ⏳ |
| 1.2.5 | Access token as refresh | Bearer: access_token_value | 401, token not refresh | ⏳ |

#### 1.3 Logout Endpoint
- **Endpoint**: `POST /api/auth/logout`
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 1.3.1 | Valid logout | Bearer: valid_token | 200, token revoked | ⏳ |
| 1.3.2 | Logout without token | (empty Bearer) | 401, Unauthenticated | ⏳ |
| 1.3.3 | Logout with expired token | Bearer: expired_token | 401, Unauthorized | ⏳ |

#### 1.4 Me Endpoint
- **Endpoint**: `GET /api/auth/me`
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 1.4.1 | Get current user | Bearer: valid_token | 200, user data | ⏳ |
| 1.4.2 | Without token | (empty Bearer) | 401, Unauthenticated | ⏳ |

---

### 📋 2. ADMIN KTP MODULE

#### 2.1 List KTP Submissions
- **Endpoint**: `GET /api/admin/ktp`
- **Required Role**: SUPER_ADMIN, ADMIN_KTP
- **Test Cases**:

| TC# | Case | Parameters | Expected | Status |
|-----|------|------------|----------|--------|
| 2.1.1 | List all - default | - | 200, pending submissions | ⏳ |
| 2.1.2 | Filter by status: pending | status=pending | 200, only pending | ⏳ |
| 2.1.3 | Filter by status: approved | status=approved | 200, only approved | ⏳ |
| 2.1.4 | Filter by status: scheduled | status=scheduled | 200, only scheduled | ⏳ |
| 2.1.5 | Filter by status: rejected | status=rejected | 200, only rejected | ⏳ |
| 2.1.6 | Filter all statuses | status=all | 200, all items | ⏳ |
| 2.1.7 | Pagination page 1 | page=1, per_page=15 | 200, items 1-15 | ⏳ |
| 2.1.8 | Pagination page 2 | page=2, per_page=15 | 200, items 16-30 | ⏳ |
| 2.1.9 | Custom per_page | per_page=5 | 200, 5 items | ⏳ |
| 2.1.10 | Invalid page | page=999 | 200, empty array | ⏳ |
| 2.1.11 | Without auth | (no token) | 401, Unauthenticated | ⏳ |
| 2.1.12 | RT user (forbidden) | Bearer: rt_token | 403, Forbidden | ⏳ |

#### 2.2 View KTP Submission Detail
- **Endpoint**: `GET /api/admin/ktp/{id}`
- **Required Role**: SUPER_ADMIN, ADMIN_KTP
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 2.2.1 | Valid KTP ID | id: existing_id | 200, full submission data | ⏳ |
| 2.2.2 | Non-existent KTP ID | id: fake_id | 404, Not found | ⏳ |
| 2.2.3 | Without auth | id: valid_id, no token | 401, Unauthenticated | ⏳ |

#### 2.3 Approve KTP Submission
- **Endpoint**: `POST /api/admin/ktp/{id}/approve`
- **Required Role**: SUPER_ADMIN, ADMIN_KTP
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 2.3.1 | Approve pending | id: pending_id | 200, status=approved | ⏳ |
| 2.3.2 | Approve non-existent | id: fake_id | 404, Not found | ⏳ |
| 2.3.3 | Approve already approved | id: approved_id | 400, "Only pending can be approved" | ⏳ |
| 2.3.4 | Approve rejected | id: rejected_id | 400, "Only pending can be approved" | ⏳ |
| 2.3.5 | Without auth | id: valid_id, no token | 401, Unauthenticated | ⏳ |

#### 2.4 Reject KTP Submission
- **Endpoint**: `POST /api/admin/ktp/{id}/reject`
- **Required Role**: SUPER_ADMIN, ADMIN_KTP
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 2.4.1 | Reject pending | id: pending_id, reason: "dokumen kurang lengkap" | 200, status=rejected | ⏳ |
| 2.4.2 | Reject without reason | id: pending_id, reason: "" | 422, Validation error | ⏳ |
| 2.4.3 | Reject non-existent | id: fake_id, reason: "x" | 404, Not found | ⏳ |
| 2.4.4 | Reject already approved | id: approved_id, reason: "x" | 400, "Only pending can be rejected" | ⏳ |
| 2.4.5 | Without auth | id: valid_id, no token | 401, Unauthenticated | ⏳ |

#### 2.5 Schedule KTP Submission
- **Endpoint**: `POST /api/admin/ktp/{id}/schedule`
- **Required Role**: SUPER_ADMIN, ADMIN_KTP
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 2.5.1 | Schedule approved | id: approved_id, scheduled_at: "2026-02-15 10:00:00" | 200, status=scheduled | ⏳ |
| 2.5.2 | Schedule without date | id: approved_id, scheduled_at: "" | 422, Validation error | ⏳ |
| 2.5.3 | Schedule past date | id: approved_id, scheduled_at: "2025-01-01 10:00:00" | 422, "after:now" | ⏳ |
| 2.5.4 | Schedule pending (not approved) | id: pending_id, scheduled_at: "2026-02-15 10:00:00" | 400, "Only approved can be scheduled" | ⏳ |
| 2.5.5 | Schedule with notes | id: approved_id, scheduled_at: "2026-02-15 10:00:00", schedule_notes: "Bawa KK" | 200, notes saved | ⏳ |
| 2.5.6 | Schedule non-existent | id: fake_id, scheduled_at: "2026-02-15 10:00:00" | 404, Not found | ⏳ |

---

### 📋 3. ADMIN IKD MODULE

Same test structure as Admin KTP:
- List IKD submissions
- View IKD detail
- Approve IKD
- Reject IKD
- Schedule IKD

**Note**: Refer to test cases 2.1 - 2.5, replace "ktp" with "ikd" and "KTP" with "IKD"

---

### 💍 4. ADMIN PERKAWINAN MODULE

#### 4.1 List Perkawinan Requests
- **Endpoint**: `GET /api/admin/perkawinan`
- **Required Role**: SUPER_ADMIN, ADMIN_PERKAWINAN
- **Test Cases**:

| TC# | Case | Parameters | Expected | Status |
|-----|------|------------|----------|--------|
| 4.1.1 | List all requests | - | 200, all requests | ⏳ |
| 4.1.2 | Without auth | (no token) | 401, Unauthenticated | ⏳ |
| 4.1.3 | ADMIN_KTP (forbidden) | Bearer: admin_ktp_token | 403, Forbidden | ⏳ |

#### 4.2 View Perkawinan Detail
- **Endpoint**: `GET /api/admin/perkawinan/{uuid}`
- **Required Role**: SUPER_ADMIN, ADMIN_PERKAWINAN
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 4.2.1 | Valid UUID | uuid: valid_uuid | 200, full request data | ⏳ |
| 4.2.2 | Non-existent UUID | uuid: fake_uuid | 404, Not found | ⏳ |

#### 4.3 Verify Perkawinan Request
- **Endpoint**: `POST /api/admin/perkawinan/{uuid}/verify`
- **Required Role**: SUPER_ADMIN, ADMIN_PERKAWINAN
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 4.3.1 | Verify PENDING | uuid: pending_uuid, catatan_admin: "Dokumen OK" | 200, status=VERIFIED | ⏳ |
| 4.3.2 | Verify already VERIFIED | uuid: verified_uuid, catatan_admin: "x" | 400, "Already processed" | ⏳ |
| 4.3.3 | Verify REJECTED request | uuid: rejected_uuid, catatan_admin: "x" | 400, "Already processed" | ⏳ |
| 4.3.4 | Without catatan_admin | uuid: pending_uuid, catatan_admin: "" | 200 or 422 (check validation) | ⏳ |

#### 4.4 Reject Perkawinan Request
- **Endpoint**: `POST /api/admin/perkawinan/{uuid}/reject`
- **Required Role**: SUPER_ADMIN, ADMIN_PERKAWINAN
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 4.4.1 | Reject PENDING | uuid: pending_uuid, catatan_admin: "Data tidak sesuai" | 200, status=REJECTED | ⏳ |
| 4.4.2 | Reject VERIFIED | uuid: verified_uuid, catatan_admin: "x" | 400, "Already processed" | ⏳ |

---

### 🏘️ 5. RT SUBMISSION MODULE

#### 5.1 Submit KTP Request
- **Endpoint**: `POST /api/rt/ktp/submit`
- **Required Role**: RT
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 5.1.1 | Valid KTP submission | nama, nomor_telp, alamat_manual, lat, lng, kategori, jumlah_pemohon, minimal_usia | 201, submission created | ⏳ |
| 5.1.2 | With attachment | (all fields) + attachment: pdf | 201, file stored | ⏳ |
| 5.1.3 | Missing nama | (without nama) | 422, Required field | ⏳ |
| 5.1.4 | Invalid nomor_telp (too short) | nomor_telp: "123" | 422, min:10 | ⏳ |
| 5.1.5 | Invalid kategori | kategori: "invalid" | 422, in validation | ⏳ |
| 5.1.6 | Kategori khusus without type | kategori: "khusus", kategori_khusus: null | 422, required when khusus | ⏳ |
| 5.1.7 | Invalid latitude | latitude: "abc" | 422, numeric validation | ⏳ |
| 5.1.8 | Invalid file type | attachment: docx file | 422, mimes validation | ⏳ |
| 5.1.9 | Without auth | (no token) | 401, Unauthenticated | ⏳ |

#### 5.2 Submit IKD Request
- **Endpoint**: `POST /api/rt/ikd/submit`
- **Test Cases**: Similar to 5.1 but for IKD fields

#### 5.3 RT Dashboard Summary
- **Endpoint**: `GET /api/rt/dashboard/summary`
- **Required Role**: RT
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 5.3.1 | Get summary | Bearer: rt_token | 200, pending/approved/rejected counts | ⏳ |
| 5.3.2 | Without auth | (no token) | 401, Unauthenticated | ⏳ |

#### 5.4 RT Notifications
- **Endpoint**: `GET /api/rt/dashboard/notifications`
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 5.4.1 | Get notifications | Bearer: rt_token | 200, notification list | ⏳ |
| 5.4.2 | Mark as read | notification_id: valid_id | 200, marked as read | ⏳ |
| 5.4.3 | Mark all read | - | 200, all marked | ⏳ |

#### 5.5 RT Schedules
- **Endpoint**: `GET /api/rt/dashboard/schedules`
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 5.5.1 | Get schedules | Bearer: rt_token | 200, scheduled items | ⏳ |
| 5.5.2 | Without auth | (no token) | 401, Unauthenticated | ⏳ |

---

### 🌐 6. PUBLIC PERKAWINAN MODULE

#### 6.1 Submit Perkawinan Request (Public)
- **Endpoint**: `POST /api/public/perkawinan/submit`
- **Required Role**: None (public)
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 6.1.1 | Valid submission | All required fields | 201, uuid generated | ⏳ |
| 6.1.2 | Missing nama_pemohon | (without nama_pemohon) | 422, Required | ⏳ |
| 6.1.3 | Invalid NIK format | nik_pemohon: "12345" (too short) | 422, min validation | ⏳ |
| 6.1.4 | Invalid phone format | no_hp_pemohon: "123" | 422, min validation | ⏳ |
| 6.1.5 | Invalid tanggal | tanggal_perkawinan: "invalid_date" | 422, date validation | ⏳ |
| 6.1.6 | With all fields | Complete data | 201, request created | ⏳ |

#### 6.2 Track Perkawinan Status (Public)
- **Endpoint**: `GET /api/public/perkawinan/{uuid}/status`
- **Required Role**: None (public)
- **Test Cases**:

| TC# | Case | Input | Expected | Status |
|-----|------|-------|----------|--------|
| 6.2.1 | Valid UUID and NIK | uuid: valid_uuid, nik_pemohon: correct_nik | 200, status returned | ⏳ |
| 6.2.2 | Invalid UUID | uuid: fake_uuid, nik_pemohon: any_nik | 404, Not found | ⏳ |
| 6.2.3 | Wrong NIK | uuid: valid_uuid, nik_pemohon: wrong_nik | 404, Not found | ⏳ |
| 6.2.4 | Without NIK | uuid: valid_uuid | 422, Required field | ⏳ |

---

## Whitebox Testing

### Unit Testing (Laravel)

**Framework**: PHPUnit  
**Location**: `/backend/backend-laravel/tests`

#### Test Structure:
```php
Feature/
├── Auth/
│   ├── LoginTest.php
│   ├── LogoutTest.php
│   ├── RefreshTokenTest.php
│   └── MeTest.php
├── AdminKtp/
│   ├── ListTest.php
│   ├── ShowTest.php
│   ├── ApproveTest.php
│   ├── RejectTest.php
│   └── ScheduleTest.php
├── AdminIkd/
│   ├── ListTest.php
│   ├── ShowTest.php
│   ├── ApproveTest.php
│   ├── RejectTest.php
│   └── ScheduleTest.php
├── AdminPerkawinan/
│   ├── ListTest.php
│   ├── VerifyTest.php
│   └── RejectTest.php
├── RtSubmission/
│   ├── SubmitKtpTest.php
│   ├── SubmitIkdTest.php
│   └── DashboardTest.php
└── PublicPerkawinan/
    ├── SubmitTest.php
    └── StatusTest.php

Unit/
├── Models/
│   ├── UserTest.php
│   ├── KtpSubmissionTest.php
│   ├── IkdSubmissionTest.php
│   └── PerkawinanRequestTest.php
├── Requests/
│   ├── LoginRequestTest.php
│   ├── SubmitKtpRequestTest.php
│   └── SubmitPerkawinanRequestTest.php
└── Services/
    ├── AuthServiceTest.php
    └── NotificationServiceTest.php
```

#### Key Test Categories:

1. **Authentication Tests**:
   - Token generation and validation
   - Token expiration
   - Role-based access
   - Token refresh mechanism

2. **Authorization Tests**:
   - Role middleware verification
   - Policy enforcement
   - Resource ownership

3. **Validation Tests**:
   - Input validation
   - Business logic validation
   - Constraint checks

4. **Data Integrity Tests**:
   - Database transactions
   - State consistency
   - Cascade operations

5. **Error Handling Tests**:
   - 401/403/404 responses
   - Exception handling
   - Logging verification

### How to Run:
```bash
cd /backend/backend-laravel
php artisan test                          # Run all tests
php artisan test --filter=LoginTest       # Run specific test
php artisan test --filter=AdminKtp --coverage # With coverage
```

---

## Blackbox Testing

### Flutter Integration Testing

**Framework**: Flutter Integration Tests  
**Location**: `/jebol_mobile/integration_test`

#### Test Coverage:

1. **Auth Flow**:
   - Login screen interaction
   - Token persistence
   - Logout flow
   - Session expiry handling

2. **Admin KTP Screen**:
   - List loading and rendering
   - Filter by status
   - Pagination (scroll)
   - Detail view
   - Approve/Reject actions
   - Schedule action
   - Refresh button functionality

3. **Admin IKD Screen**:
   - Same as Admin KTP

4. **Admin Perkawinan Screen**:
   - List and detail views
   - Verify/Reject actions

5. **RT Dashboard**:
   - Summary display
   - Notifications
   - Schedule view
   - Submit functionality

### Test Example:
```dart
void main() {
  testWidgets('Admin KTP List - Load and Filter', (WidgetTester tester) async {
    // Setup
    await tester.pumpWidget(const MyApp());
    
    // Find and tap login button
    await tester.tap(find.byType(LoginButton));
    await tester.pumpAndSettle();
    
    // Verify KTP list loaded
    expect(find.byType(AdminKtpListScreen), findsOneWidget);
    
    // Tap filter
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    
    // Select "approved"
    await tester.tap(find.text('Disetujui'));
    await tester.pumpAndSettle();
    
    // Verify filtered results
    expect(find.byType(StatusBadge), findsWidgets);
  });
}
```

---

## Postman Testing Guide

### Collection Structure:
```
JEBOL API Testing/
├── Environment Setup
├── Authentication
│   ├── Login
│   ├── Token Refresh
│   ├── Logout
│   └── Me
├── Admin KTP
│   ├── List KTP
│   ├── View KTP Detail
│   ├── Approve KTP
│   ├── Reject KTP
│   └── Schedule KTP
├── Admin IKD
│   ├── List IKD
│   ├── View IKD Detail
│   ├── Approve IKD
│   ├── Reject IKD
│   └── Schedule IKD
├── Admin Perkawinan
│   ├── List Perkawinan
│   ├── View Perkawinan Detail
│   ├── Verify Perkawinan
│   └── Reject Perkawinan
├── RT Submission
│   ├── Submit KTP
│   ├── Submit IKD
│   ├── Dashboard Summary
│   ├── Get Notifications
│   ├── Mark as Read
│   └── Get Schedules
├── Public Perkawinan
│   ├── Submit Perkawinan
│   └── Track Status
└── Test Scenarios
    ├── Happy Path
    ├── Error Cases
    ├── Role-based Access
    └── Data Refresh
```

### Running Tests:
1. Import Postman collection
2. Set environment variables (base_url, token, etc.)
3. Run collection with Newman or Postman runner
4. Generate report

---

## Test Report Template

### Format: Markdown

```markdown
# JEBOL Project - Test Execution Report

**Execution Date**: [Date]  
**Executed By**: [Name]  
**Environment**: [Dev/Staging/Prod]  

## Executive Summary
- Total Test Cases: XXX
- Passed: XXX (XX%)
- Failed: XXX (XX%)
- Blocked: XXX (XX%)

## Test Results by Module

### 1. Authentication (XX/XX)
- ✅ Login: XX/XX
- ✅ Refresh: XX/XX
- ✅ Logout: XX/XX
- ✅ Me: XX/XX

### 2. Admin KTP (XX/XX)
- ✅ List: XX/XX
- ✅ View: XX/XX
- ✅ Approve: XX/XX
- ✅ Reject: XX/XX
- ✅ Schedule: XX/XX

[Continue for all modules...]

## Failed Test Cases
| ID | Module | Test Case | Error | Severity |
|----|--------|-----------|-------|----------|
| 1  | ... | ... | ... | High |

## Issues Found
1. **Issue 1**: Description
   - Steps to reproduce
   - Expected vs Actual
   - Recommendation

## Recommendations
1. ...
2. ...

## Sign-Off
- QA Lead: ___________
- Dev Lead: ___________
- Date: ___________
```

---

## Testing Checklist

- [ ] All authentication flows tested
- [ ] All CRUD operations tested
- [ ] Role-based access verified
- [ ] Error handling validated
- [ ] Data consistency checked
- [ ] Pagination working correctly
- [ ] Token refresh functioning
- [ ] Notifications triggered properly
- [ ] Audit logs recorded
- [ ] Database transactions atomic
- [ ] API response formats consistent
- [ ] Status codes correct
- [ ] Validation rules enforced
- [ ] Business logic validated
- [ ] Performance acceptable
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] CORS properly configured
- [ ] Rate limiting working
- [ ] Logging functional

---

## Glossary

- **Whitebox Testing**: Testing internal logic and code paths (Unit Tests)
- **Blackbox Testing**: Testing from user perspective without code visibility (Integration Tests)
- **Postman Testing**: Manual/automated API testing via Postman client
- **TC**: Test Case
- **RBAC**: Role-Based Access Control
- **SUPER_ADMIN**: Administrator with all permissions
- **ADMIN_KTP**: Administrator for KTP submissions
- **ADMIN_IKD**: Administrator for IKD submissions
- **ADMIN_PERKAWINAN**: Administrator for marriage requests
- **RT**: Rumah Tangga (household representative)
- **KTP**: Kartu Tanda Penduduk (ID Card)
- **IKD**: Izin Kunjungan Domisili (Domicile Permit)

