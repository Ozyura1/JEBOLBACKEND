# JEBOL Mobile - Release Preparation Guide

## 📱 Build Configuration

### Android Release Build

```bash
# Clean build
flutter clean
flutter pub get

# Build APK with obfuscation and minification
flutter build apk --release --obfuscate --split-debug-info=build/symbols

# Build App Bundle for Play Store
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

### Key Configuration Files

#### `android/app/build.gradle.kts`
```kotlin
android {
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

#### `android/app/proguard-rules.pro`
```proguard
# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep your model classes
-keep class com.example.jebol_mobile.** { *; }
```

---

## 🔐 Signing Configuration

### Generate Keystore (First Time Only)
```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Configure Signing
Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=../upload-keystore.jks
```

⚠️ **IMPORTANT**: Never commit `key.properties` or keystore files to git!

---

## 🌐 API Environment Configuration

### Production API Endpoint
Update `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  // Production
  static const String baseUrl = 'https://api.jebol.disdukcapil.go.id';
  
  // Public API (NO AUTH)
  static const String publicBaseUrl = 'https://api.jebol.disdukcapil.go.id/public';
}
```

### Environment Variables (Recommended)
Use `flutter_dotenv` for environment-specific configs:

```dart
// .env.production
API_BASE_URL=https://api.jebol.disdukcapil.go.id
PUBLIC_API_URL=https://api.jebol.disdukcapil.go.id/public
```

---

## 📋 Play Store Requirements

### App Information
| Field | Value |
|-------|-------|
| App Name | JEBOL - Layanan Kependudukan |
| Package Name | id.go.disdukcapil.jebol |
| Category | Government |
| Content Rating | Everyone |

### Required Assets

#### App Icon
- **Format**: PNG (no alpha for Play Store icon)
- **Size**: 512x512 px
- **Location**: `android/app/src/main/res/`

#### Feature Graphic
- **Size**: 1024x500 px
- **Format**: PNG or JPG

#### Screenshots
- Phone: 2-8 screenshots (min 320px, max 3840px)
- Tablet 7": 2-8 screenshots (optional)
- Tablet 10": 2-8 screenshots (optional)

### Store Listing Description (Indonesian)
```
JEBOL - Sistem Layanan Kependudukan Online

Aplikasi resmi Dinas Kependudukan dan Pencatatan Sipil untuk layanan administrasi kependudukan.

FITUR UTAMA:
✓ Pendaftaran Perkawinan Online
✓ Pelacakan Status Permohonan
✓ Validasi Data sesuai Standar Dukcapil
✓ Upload Dokumen Persyaratan
✓ Notifikasi Status Terkini

MODUL PETUGAS (Khusus Pegawai):
✓ Dashboard Monitoring
✓ Verifikasi Dokumen
✓ Penjadwalan Akad Nikah
✓ Manajemen Permohonan

Dikembangkan oleh Dinas Kependudukan dan Pencatatan Sipil.
```

---

## ✅ Pre-Release Checklist

### Code Quality
- [ ] `flutter analyze lib` shows no issues
- [ ] All unit tests pass (`flutter test`)
- [ ] Widget tests pass
- [ ] Role permission matrix verified

### Security
- [ ] No hardcoded credentials
- [ ] API keys stored securely
- [ ] Obfuscation enabled
- [ ] Debug logs removed from release
- [ ] ProGuard rules configured

### Performance
- [ ] App size optimized (< 50MB APK)
- [ ] Lazy loading for large lists
- [ ] Image compression applied
- [ ] Unused assets removed

### Accessibility
- [ ] All interactive elements have semantic labels
- [ ] Color contrast meets WCAG guidelines
- [ ] Font scaling works properly

### Localization
- [ ] Indonesian (ID) translations complete
- [ ] English (EN) translations complete
- [ ] Date/number formats localized

---

## 🧪 Test Coverage Summary

### Unit Tests
| Component | Status |
|-----------|--------|
| PublicLocaleProvider | ✅ Passing |
| PublicStrings | ✅ Passing |
| Role Permission Matrix | ✅ Passing (28 tests) |
| PublicAppBar Widget | ✅ Passing |

### Test Commands
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/core/rbac/role_permission_matrix_test.dart

# Run tests with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 🚀 Deployment Steps

### 1. Final Build
```bash
flutter clean
flutter pub get
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

### 2. Upload to Play Console
1. Go to Google Play Console
2. Select app → Release → Production
3. Upload `build/app/outputs/bundle/release/app-release.aab`
4. Complete store listing
5. Submit for review

### 3. Post-Release
- Monitor crash reports in Firebase Crashlytics
- Respond to user reviews
- Track analytics in Firebase Analytics

---

## 📱 Version Management

### Versioning Format
```
version: 1.0.0+1
         │ │ │  └── Build number (increment each release)
         │ │ └────── Patch (bug fixes)
         │ └──────── Minor (new features)
         └────────── Major (breaking changes)
```

### Update Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Update before each release
```

---

## 🔗 Related Documentation

- [ARCHITECTURE.md](../ARCHITECTURE.md) - System architecture
- [Backend API Docs](../backend/backend-laravel/docs/api/) - API documentation
- [Role Matrix](../test/core/rbac/role_permission_matrix_test.dart) - Permission tests

---

**Last Updated**: Phase 7 - Public User Flow Complete
