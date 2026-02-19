# JEBOL Mobile - Handover & SOP Document

## Version: 1.0.0
## Date: January 2025

---

## 1. Project Overview

### 1.1 Application Description
JEBOL (Jemput Bola) is a mobile application for civil registration services in Indonesia. The app enables citizens to submit registration requests for:
- Marriage (Perkawinan)
- Birth (Kelahiran)
- Death (Kematian)
- Divorce (Perceraian)
- Child Acknowledgment (Pengakuan Anak)
- Child Legitimation (Pengesahan Anak)

### 1.2 Technology Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Laravel (PHP)
- **Database:** MySQL/PostgreSQL
- **Authentication:** Laravel Sanctum (Token-based)
- **State Management:** Provider
- **Navigation:** go_router

### 1.3 Repository Structure
```
JEBOL/
├── jebol_mobile/          # Flutter mobile app
├── backend/
│   └── backend-laravel/   # Laravel API backend
└── docs/                  # Documentation
```

---

## 2. Development Environment Setup

### 2.1 Prerequisites
- Flutter SDK 3.19.0+
- Dart SDK 3.3.0+
- Android Studio / VS Code
- PHP 8.2+
- Composer
- MySQL 8.0+ / PostgreSQL 15+

### 2.2 Mobile App Setup
```bash
cd jebol_mobile
flutter pub get
flutter run
```

### 2.3 Backend Setup
```bash
cd backend/backend-laravel
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

### 2.4 Environment Variables
Mobile app API URL is configured in:
- `lib/services/api_service.dart` - baseUrl constant
- `lib/core/hardening/app_config.dart` - Environment configurations

---

## 3. Architecture Overview

### 3.1 Mobile App Architecture
```
lib/
├── core/                 # Core infrastructure
│   ├── api/             # API client
│   ├── auth/            # Authentication
│   ├── error/           # Error handling
│   ├── hardening/       # Security & stability
│   ├── network/         # Network management
│   └── routing/         # Navigation
├── models/              # Data models
├── modules/             # Feature modules (admin)
├── pages/               # Screen widgets
├── providers/           # State management
├── services/            # Business logic services
└── widgets/             # Reusable widgets
```

### 3.2 Key Components
| Component | Location | Purpose |
|-----------|----------|---------|
| AuthProvider | `core/auth/` | Authentication state |
| ApiService | `services/` | HTTP client |
| SessionManager | `core/network/` | Session lifecycle |
| AppRouter | `core/routing/` | Navigation |
| GlobalErrorHandler | `core/error/` | Error boundary |

---

## 4. Standard Operating Procedures

### 4.1 Daily Monitoring SOP

**Frequency:** Daily at 09:00 WIB

**Steps:**
1. Check crash reporting dashboard
2. Review API error logs
3. Monitor server resource usage
4. Check app store reviews for issues
5. Document any anomalies

**Escalation:**
- Crash rate >1%: Notify development team
- API error rate >5%: Notify backend team
- Server down: Immediate escalation to DevOps

### 4.2 Bug Fixing SOP

**Priority Levels:**
| Level | Description | Response Time |
|-------|-------------|---------------|
| P0 - Critical | App crash, data loss, security | 4 hours |
| P1 - High | Major feature broken | 24 hours |
| P2 - Medium | Minor feature issue | 3 days |
| P3 - Low | Cosmetic, UX improvement | Next sprint |

**Process:**
1. Triage incoming issue
2. Assign priority level
3. Create ticket with reproduction steps
4. Assign to developer
5. Code review required
6. QA verification
7. Deploy to staging
8. Deploy to production

### 4.3 Release SOP

**Pre-Release:**
1. Complete Go-Live Checklist
2. Run full test suite
3. Build release artifacts
4. Internal testing (2 days minimum)
5. Stakeholder approval

**Release:**
1. Create git tag
2. Upload to Play Store (staged rollout 10%)
3. Monitor for 24 hours
4. Increase rollout to 50%
5. Monitor for 24 hours
6. Full rollout (100%)

**Post-Release:**
1. Monitor crash rates
2. Monitor user feedback
3. Document lessons learned

### 4.4 Incident Response SOP

**Detection:**
- Automated alerts from monitoring
- User reports
- Manual discovery

**Response:**
1. Acknowledge incident
2. Assess severity
3. Notify stakeholders
4. Investigate root cause
5. Implement fix or rollback
6. Verify resolution
7. Post-mortem documentation

---

## 5. Key Contacts

| Role | Name | Contact |
|------|------|---------|
| Project Manager | [Name] | [Email] |
| Tech Lead | [Name] | [Email] |
| Backend Lead | [Name] | [Email] |
| Mobile Lead | [Name] | [Email] |
| DevOps | [Name] | [Email] |
| QA Lead | [Name] | [Email] |

---

## 6. Common Tasks

### 6.1 Adding New Registration Type
1. Create model in `lib/models/`
2. Add form page in `lib/pages/`
3. Create service methods in `lib/services/`
4. Add route in `lib/core/routing/app_router.dart`
5. Update API contract documentation

### 6.2 Updating API Base URL
1. Edit `lib/services/api_service.dart` - baseUrl
2. Or use environment config in `lib/core/hardening/app_config.dart`
3. Rebuild app

### 6.3 Debugging Session Issues
1. Check `SessionManager` logs
2. Verify token storage in secure storage
3. Check token expiry time
4. Test refresh token flow
5. Check backend auth logs

### 6.4 Building Release APK
```bash
flutter clean
flutter pub get
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### 6.5 Building Release AAB (Play Store)
```bash
flutter clean
flutter pub get
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 7. Troubleshooting Guide

### 7.1 Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Login fails | Invalid credentials or server down | Check credentials, verify server status |
| Session expired frequently | Token expiry too short | Check backend token configuration |
| Document upload fails | File too large or wrong format | Check file size (<2MB) and format (jpg/png/pdf) |
| Blank screen after login | Router misconfiguration | Check AuthProvider state and router guards |
| API timeout | Slow network or server overload | Check connectivity, increase timeout |

### 7.2 Debug Commands
```bash
# Check Flutter logs
flutter logs

# Run with verbose
flutter run -v

# Analyze code
flutter analyze

# Run tests
flutter test

# Check outdated packages
flutter pub outdated
```

---

## 8. Security Guidelines

### 8.1 Do's
- Use secure storage for sensitive data
- Validate all user inputs
- Use HTTPS for all API calls
- Log security events for audit
- Keep dependencies updated

### 8.2 Don'ts
- Never log passwords or tokens
- Never hardcode credentials
- Never store sensitive data in shared preferences
- Never trust client-side validation alone
- Never disable SSL verification in production

---

## 9. Backup & Recovery

### 9.1 Code Repository
- Primary: [Git repository URL]
- Backup: [Backup location]
- Frequency: Real-time (push to remote)

### 9.2 Database
- Backup frequency: Daily
- Retention: 30 days
- Recovery procedure: [Document link]

### 9.3 App Signing Keys
- Location: [Secure storage location]
- Backup: [Offline backup location]
- Access: [Limited to authorized personnel]

---

## 10. Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2025-01-08 | Team | Initial handover document |

---

*This document should be kept updated with any significant changes to procedures or architecture.*
