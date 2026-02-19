import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jebol_mobile/modules/public/provider/public_locale_provider.dart';
import 'package:jebol_mobile/modules/public/l10n/public_strings.dart';

void main() {
  group('PublicLocaleProvider', () {
    late PublicLocaleProvider provider;

    setUp(() {
      provider = PublicLocaleProvider();
    });

    test('initial locale should be Indonesian', () {
      expect(provider.locale, PublicLocale.id);
      expect(provider.isIndonesian, true);
      expect(provider.isEnglish, false);
    });

    test('toggleLocale should switch between Indonesian and English', () {
      // Initial: Indonesian
      expect(provider.locale, PublicLocale.id);

      // Toggle to English
      provider.toggleLocale();
      expect(provider.locale, PublicLocale.en);
      expect(provider.isEnglish, true);
      expect(provider.isIndonesian, false);

      // Toggle back to Indonesian
      provider.toggleLocale();
      expect(provider.locale, PublicLocale.id);
      expect(provider.isIndonesian, true);
    });

    test('setLocale should set specific locale', () {
      provider.setLocale(PublicLocale.en);
      expect(provider.locale, PublicLocale.en);

      provider.setLocale(PublicLocale.id);
      expect(provider.locale, PublicLocale.id);
    });

    test('tr should return Indonesian translation by default', () {
      expect(provider.tr('app_title'), 'Pendaftaran Perkawinan Online');
      expect(provider.tr('home_welcome'), 'Selamat Datang');
    });

    test('tr should return English translation after toggle', () {
      provider.toggleLocale();
      expect(provider.tr('app_title'), 'Online Marriage Registration');
      expect(provider.tr('home_welcome'), 'Welcome');
    });

    test('tr should return key for unknown translation', () {
      expect(provider.tr('unknown_key'), 'unknown_key');
    });

    test('localeCode should return correct code', () {
      expect(provider.localeCode, 'id');

      provider.toggleLocale();
      expect(provider.localeCode, 'en');
    });

    test('notifyListeners should be called when locale changes', () {
      int notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      provider.toggleLocale();
      expect(notificationCount, 1);

      provider.setLocale(PublicLocale.id);
      expect(notificationCount, 2);
    });

    test('setLocale should not notify if locale is same', () {
      int notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      // Setting same locale should not notify
      provider.setLocale(PublicLocale.id);
      expect(notificationCount, 0);
    });
  });

  group('PublicStrings', () {
    test('should return map for Indonesian locale', () {
      final idStrings = PublicStrings.get(PublicLocale.id);
      expect(idStrings['app_title'], 'Pendaftaran Perkawinan Online');
    });

    test('should return map for English locale', () {
      final enStrings = PublicStrings.get(PublicLocale.en);
      expect(enStrings['app_title'], 'Online Marriage Registration');
    });

    test('should have all required keys in Indonesian', () {
      final idStrings = PublicStrings.get(PublicLocale.id);
      final requiredKeys = [
        'app_title',
        'home_welcome',
        'home_start_registration',
        'home_check_status',
        'step1_title',
        'step2_title',
        'step3_title',
        'step4_title',
        'field_nik',
        'field_nama_lengkap',
        'field_tanggal_lahir',
        'field_tempat_lahir',
        'field_no_hp',
        'field_alamat',
        'field_agama',
        'field_pekerjaan',
      ];

      for (final key in requiredKeys) {
        expect(
          idStrings.containsKey(key),
          isTrue,
          reason: 'Key "$key" should exist in Indonesian strings',
        );
      }
    });
  });
}
