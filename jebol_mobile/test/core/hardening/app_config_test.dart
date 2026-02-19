import 'package:flutter_test/flutter_test.dart';
import 'package:jebol_mobile/core/hardening/app_config.dart';

void main() {
  group('AppConfig', () {
    group('Environment Initialization', () {
      test('initDevelopment sets correct values', () {
        AppConfig.initDevelopment();

        expect(AppConfig.instance.environment, equals(Environment.development));
        expect(AppConfig.instance.appName, equals('JEBOL (Dev)'));
        expect(AppConfig.instance.enableLogging, isTrue);
        expect(AppConfig.instance.enableCrashReporting, isFalse);
        expect(AppConfig.instance.enableAnalytics, isFalse);
        expect(AppConfig.instance.enableDebugBanner, isTrue);
      });

      test('initStaging sets correct values', () {
        AppConfig.initStaging();

        expect(AppConfig.instance.environment, equals(Environment.staging));
        expect(AppConfig.instance.appName, equals('JEBOL (Staging)'));
        expect(AppConfig.instance.enableLogging, isTrue);
        expect(AppConfig.instance.enableCrashReporting, isTrue);
        expect(AppConfig.instance.enableAnalytics, isFalse);
        expect(AppConfig.instance.enableDebugBanner, isTrue);
      });

      test('initProduction sets correct values', () {
        AppConfig.initProduction();

        expect(AppConfig.instance.environment, equals(Environment.production));
        expect(AppConfig.instance.appName, equals('JEBOL'));
        expect(AppConfig.instance.enableLogging, isFalse);
        expect(AppConfig.instance.enableCrashReporting, isTrue);
        expect(AppConfig.instance.enableAnalytics, isTrue);
        expect(AppConfig.instance.enableDebugBanner, isFalse);
      });
    });

    group('initFromEnv', () {
      test('recognizes production', () {
        AppConfig.initFromEnv('production');
        expect(AppConfig.instance.environment, equals(Environment.production));
      });

      test('recognizes prod', () {
        AppConfig.initFromEnv('prod');
        expect(AppConfig.instance.environment, equals(Environment.production));
      });

      test('recognizes staging', () {
        AppConfig.initFromEnv('staging');
        expect(AppConfig.instance.environment, equals(Environment.staging));
      });

      test('recognizes stg', () {
        AppConfig.initFromEnv('stg');
        expect(AppConfig.instance.environment, equals(Environment.staging));
      });

      test('recognizes development', () {
        AppConfig.initFromEnv('development');
        expect(AppConfig.instance.environment, equals(Environment.development));
      });

      test('defaults to development for unknown', () {
        AppConfig.initFromEnv('unknown');
        expect(AppConfig.instance.environment, equals(Environment.development));
      });
    });

    group('Helper getters', () {
      test('isProduction returns correct value', () {
        AppConfig.initProduction();
        expect(AppConfig.instance.isProduction, isTrue);
        expect(AppConfig.instance.isDevelopment, isFalse);
        expect(AppConfig.instance.isStaging, isFalse);
      });

      test('isDevelopment returns correct value', () {
        AppConfig.initDevelopment();
        expect(AppConfig.instance.isDevelopment, isTrue);
        expect(AppConfig.instance.isProduction, isFalse);
        expect(AppConfig.instance.isStaging, isFalse);
      });

      test('isStaging returns correct value', () {
        AppConfig.initStaging();
        expect(AppConfig.instance.isStaging, isTrue);
        expect(AppConfig.instance.isProduction, isFalse);
        expect(AppConfig.instance.isDevelopment, isFalse);
      });

      test('environmentName returns correct strings', () {
        AppConfig.initDevelopment();
        expect(AppConfig.instance.environmentName, equals('Development'));

        AppConfig.initStaging();
        expect(AppConfig.instance.environmentName, equals('Staging'));

        AppConfig.initProduction();
        expect(AppConfig.instance.environmentName, equals('Production'));
      });
    });
  });

  group('ApiEndpoints', () {
    test('login endpoint uses configured baseUrl', () {
      AppConfig.initDevelopment();
      expect(ApiEndpoints.login, contains('/api/auth/login'));
    });

    test('perkawinan endpoints are correct', () {
      AppConfig.initDevelopment();

      expect(ApiEndpoints.perkawinanList, contains('/api/perkawinan'));
      expect(
        ApiEndpoints.perkawinanDetail('123'),
        contains('/api/perkawinan/123'),
      );
      expect(ApiEndpoints.perkawinanSubmit, contains('/api/perkawinan'));
    });

    test('endpoints change with environment', () {
      AppConfig.initDevelopment();
      final devLogin = ApiEndpoints.login;
      expect(devLogin, contains('localhost'));

      AppConfig.initProduction();
      final prodLogin = ApiEndpoints.login;
      expect(prodLogin, contains('api.jebol.go.id'));
    });
  });
}
