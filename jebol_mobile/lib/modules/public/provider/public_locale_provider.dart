import 'package:flutter/foundation.dart';
import '../l10n/public_strings.dart';

/// Locale provider for public module ONLY.
///
/// IMPORTANT: This is completely isolated from app-wide state.
/// Does NOT use AuthProvider or any admin state.
class PublicLocaleProvider extends ChangeNotifier {
  PublicLocale _locale = PublicLocale.id;

  PublicLocale get locale => _locale;

  bool get isIndonesian => _locale == PublicLocale.id;
  bool get isEnglish => _locale == PublicLocale.en;

  /// Get localized string by key.
  String tr(String key) {
    final strings = PublicStrings.get(_locale);
    return strings[key] ?? key;
  }

  /// Toggle between Indonesian and English.
  void toggleLocale() {
    _locale = _locale == PublicLocale.id ? PublicLocale.en : PublicLocale.id;
    notifyListeners();
  }

  /// Set specific locale.
  void setLocale(PublicLocale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }

  /// Get current locale code for API calls.
  String get localeCode => _locale == PublicLocale.id ? 'id' : 'en';
}
