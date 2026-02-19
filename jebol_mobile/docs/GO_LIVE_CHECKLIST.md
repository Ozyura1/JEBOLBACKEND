# JEBOL Mobile - Go-Live Checklist

## Version: 1.0.0
## Target Release Date: ____________

---

## 1. Code & Build Quality

### 1.1 Static Analysis
- [ ] `flutter analyze` passes with zero issues
- [ ] `dart fix --apply` has been run
- [ ] No TODO/FIXME comments in production code
- [ ] No debug print statements in production code
- [ ] No hardcoded test credentials

### 1.2 Testing
- [ ] All unit tests passing (target: >80% coverage)
- [ ] All widget tests passing
- [ ] Integration tests passing on target devices
- [ ] Manual QA testing completed
- [ ] UAT sign-off received

### 1.3 Build Verification
- [ ] Release APK builds successfully
- [ ] Release AAB builds successfully
- [ ] iOS archive builds successfully
- [ ] App size is within acceptable limits (<50MB APK)
- [ ] ProGuard/R8 configured correctly (Android)

---

## 2. Security & Compliance

### 2.1 Authentication
- [ ] Token refresh mechanism working
- [ ] Session expiry handling tested
- [ ] Logout clears all sensitive data
- [ ] Biometric auth working (if implemented)

### 2.2 Data Protection
- [ ] Sensitive data encrypted at rest
- [ ] Secure storage used for tokens
- [ ] No sensitive data in logs
- [ ] Certificate pinning configured
- [ ] Screenshot blocking on sensitive screens

### 2.3 Device Security
- [ ] Root/jailbreak detection implemented
- [ ] Emulator detection implemented (if required)
- [ ] Clipboard cleared after sensitive operations

### 2.4 Compliance
- [ ] Privacy policy published and accessible
- [ ] Terms of service published and accessible
- [ ] Data retention policy documented
- [ ] PDP (UU 27/2022) compliance verified

---

## 3. API & Backend

### 3.1 API Readiness
- [ ] All endpoints documented in API_CONTRACT.md
- [ ] API versioning implemented
- [ ] Error responses standardized
- [ ] Rate limiting configured

### 3.2 Environment
- [ ] Production API URL configured
- [ ] Production database ready
- [ ] SSL certificates valid (not expiring soon)
- [ ] Backup systems in place

### 3.3 Monitoring
- [ ] Server monitoring enabled
- [ ] Error alerting configured
- [ ] Performance metrics dashboard ready
- [ ] Logging infrastructure ready

---

## 4. App Store Readiness

### 4.1 Google Play Store
- [ ] App signing key secured and backed up
- [ ] Play Console listing complete
- [ ] Screenshots uploaded (all device sizes)
- [ ] App description in Bahasa Indonesia
- [ ] Privacy policy URL added
- [ ] Content rating questionnaire completed
- [ ] Target API level meets requirements (API 33+)
- [ ] Data safety section completed

### 4.2 Apple App Store (if applicable)
- [ ] App Store Connect listing complete
- [ ] Certificates and provisioning profiles valid
- [ ] Screenshots for all device sizes
- [ ] App privacy details completed
- [ ] Review guidelines compliance verified

### 4.3 Release Materials
- [ ] App icon finalized (all sizes)
- [ ] Feature graphic ready
- [ ] Promotional screenshots ready
- [ ] Release notes prepared

---

## 5. Operational Readiness

### 5.1 Support
- [ ] Support email configured
- [ ] Support phone line ready
- [ ] FAQ documentation ready
- [ ] User guide available

### 5.2 Monitoring & Response
- [ ] Crash reporting enabled (Firebase/Sentry)
- [ ] On-call rotation established
- [ ] Incident response procedure documented
- [ ] Rollback plan documented

### 5.3 Communication
- [ ] Announcement materials ready
- [ ] Stakeholder notification list prepared
- [ ] Press release (if needed)

---

## 6. Performance & UX

### 6.1 Performance
- [ ] App launch time <3 seconds
- [ ] API response handling <5 seconds timeout
- [ ] Smooth scrolling (60fps)
- [ ] Memory usage within limits
- [ ] Battery usage acceptable

### 6.2 Accessibility
- [ ] Font scaling supported (0.8x - 1.5x)
- [ ] Screen reader compatibility tested
- [ ] Touch targets minimum 48x48dp
- [ ] Color contrast WCAG AA compliant

### 6.3 Offline Handling
- [ ] Offline detection working
- [ ] Offline banner displayed
- [ ] Graceful degradation for offline mode
- [ ] Queue mechanism for offline submissions (if implemented)

---

## 7. Dependencies

### 7.1 Package Audit
- [ ] All dependencies on stable versions
- [ ] No deprecated packages
- [ ] No known security vulnerabilities
- [ ] Dependency versions locked in pubspec.lock

### 7.2 Third-Party Services
- [ ] All API keys secured (not in source code)
- [ ] Service accounts configured for production
- [ ] Rate limits understood and acceptable

---

## 8. Final Verification

### 8.1 Smoke Test on Production
- [ ] Login works
- [ ] Registration flow works
- [ ] Document upload works
- [ ] Status checking works
- [ ] Logout works
- [ ] Session expiry handled correctly

### 8.2 Device Testing
- [ ] Tested on low-end Android device
- [ ] Tested on mid-range Android device
- [ ] Tested on high-end Android device
- [ ] Tested on iPhone (if applicable)
- [ ] Tested on tablet (if applicable)

### 8.3 Sign-offs
- [ ] Development lead sign-off
- [ ] QA lead sign-off
- [ ] Security review sign-off
- [ ] Product owner sign-off
- [ ] Stakeholder sign-off

---

## Approvals

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Development Lead | | | |
| QA Lead | | | |
| Security Officer | | | |
| Product Owner | | | |
| Project Manager | | | |

---

## Release Notes

### Version 1.0.0

**New Features:**
- Initial release
- Marriage (Perkawinan) registration
- Birth (Kelahiran) registration
- Death (Kematian) registration
- Divorce (Perceraian) registration
- Child acknowledgment (Pengakuan Anak)
- Child legitimation (Pengesahan Anak)

**Known Issues:**
- (List any known issues that won't block release)

---

## Post-Release Monitoring

### Day 1
- [ ] Monitor crash rate (<1%)
- [ ] Monitor API error rate
- [ ] Check user feedback/reviews
- [ ] Verify all features working

### Week 1
- [ ] Review analytics dashboard
- [ ] Address critical bugs if any
- [ ] Collect user feedback
- [ ] Performance review

---

*This checklist must be fully completed before production release.*
