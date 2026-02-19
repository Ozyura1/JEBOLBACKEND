/// Environment configuration for different build flavors.
enum Environment { development, staging, production }

/// App configuration based on environment.
class AppConfig {
  static late AppConfig _instance;
  static AppConfig get instance => _instance;

  final Environment environment;
  final String apiBaseUrl;
  final String appName;
  final bool enableLogging;
  final bool enableCrashReporting;
  final bool enableAnalytics;
  final bool enableDebugBanner;
  final Duration apiTimeout;
  final int maxRetries;

  AppConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.appName,
    required this.enableLogging,
    required this.enableCrashReporting,
    required this.enableAnalytics,
    required this.enableDebugBanner,
    required this.apiTimeout,
    required this.maxRetries,
  });

  /// Initialize for development environment.
  static void initDevelopment() {
    _instance = AppConfig._(
      environment: Environment.development,
      apiBaseUrl: 'http://localhost:8000/api',
      appName: 'JEBOL (Dev)',
      enableLogging: true,
      enableCrashReporting: false,
      enableAnalytics: false,
      enableDebugBanner: true,
      apiTimeout: const Duration(seconds: 30),
      maxRetries: 3,
    );
  }

  /// Initialize for staging environment.
  static void initStaging() {
    _instance = AppConfig._(
      environment: Environment.staging,
      apiBaseUrl: 'https://staging-api.jebol.go.id/api',
      appName: 'JEBOL (Staging)',
      enableLogging: true,
      enableCrashReporting: true,
      enableAnalytics: false,
      enableDebugBanner: true,
      apiTimeout: const Duration(seconds: 30),
      maxRetries: 3,
    );
  }

  /// Initialize for production environment.
  static void initProduction() {
    _instance = AppConfig._(
      environment: Environment.production,
      apiBaseUrl: 'https://api.jebol.go.id/api',
      appName: 'JEBOL',
      enableLogging: false,
      enableCrashReporting: true,
      enableAnalytics: true,
      enableDebugBanner: false,
      apiTimeout: const Duration(seconds: 60),
      maxRetries: 3,
    );
  }

  /// Initialize based on build flavor/environment variable.
  static void initFromEnv(String envName) {
    switch (envName.toLowerCase()) {
      case 'production':
      case 'prod':
        initProduction();
        break;
      case 'staging':
      case 'stg':
        initStaging();
        break;
      case 'development':
      case 'dev':
      default:
        initDevelopment();
        break;
    }
  }

  /// Check if running in production.
  bool get isProduction => environment == Environment.production;

  /// Check if running in development.
  bool get isDevelopment => environment == Environment.development;

  /// Check if running in staging.
  bool get isStaging => environment == Environment.staging;

  /// Get environment name as string.
  String get environmentName {
    switch (environment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  @override
  String toString() {
    return 'AppConfig('
        'environment: $environmentName, '
        'apiBaseUrl: $apiBaseUrl, '
        'appName: $appName'
        ')';
  }
}

/// API endpoints configuration.
class ApiEndpoints {
  static AppConfig get _config => AppConfig.instance;

  // Auth
  static String get login => '${_config.apiBaseUrl}/auth/login';
  static String get logout => '${_config.apiBaseUrl}/auth/logout';
  static String get refreshToken => '${_config.apiBaseUrl}/auth/refresh';
  static String get register => '${_config.apiBaseUrl}/auth/register';
  static String get forgotPassword =>
      '${_config.apiBaseUrl}/auth/forgot-password';

  // User
  static String get profile => '${_config.apiBaseUrl}/user/profile';
  static String get updateProfile => '${_config.apiBaseUrl}/user/profile';

  // Perkawinan
  static String get perkawinanList => '${_config.apiBaseUrl}/perkawinan';
  static String perkawinanDetail(String id) =>
      '${_config.apiBaseUrl}/perkawinan/$id';
  static String get perkawinanSubmit => '${_config.apiBaseUrl}/perkawinan';

  // Kelahiran
  static String get kelahiranList => '${_config.apiBaseUrl}/kelahiran';
  static String kelahiranDetail(String id) =>
      '${_config.apiBaseUrl}/kelahiran/$id';
  static String get kelahiranSubmit => '${_config.apiBaseUrl}/kelahiran';

  // Kematian
  static String get kematianList => '${_config.apiBaseUrl}/kematian';
  static String kematianDetail(String id) =>
      '${_config.apiBaseUrl}/kematian/$id';
  static String get kematianSubmit => '${_config.apiBaseUrl}/kematian';

  // Perceraian
  static String get perceraianList => '${_config.apiBaseUrl}/perceraian';
  static String perceraianDetail(String id) =>
      '${_config.apiBaseUrl}/perceraian/$id';
  static String get perceraianSubmit => '${_config.apiBaseUrl}/perceraian';

  // Pengakuan Anak
  static String get pengakuanAnakList => '${_config.apiBaseUrl}/pengakuan-anak';
  static String pengakuanAnakDetail(String id) =>
      '${_config.apiBaseUrl}/pengakuan-anak/$id';
  static String get pengakuanAnakSubmit =>
      '${_config.apiBaseUrl}/pengakuan-anak';

  // Pengesahan Anak
  static String get pengesahanAnakList =>
      '${_config.apiBaseUrl}/pengesahan-anak';
  static String pengesahanAnakDetail(String id) =>
      '${_config.apiBaseUrl}/pengesahan-anak/$id';
  static String get pengesahanAnakSubmit =>
      '${_config.apiBaseUrl}/pengesahan-anak';

  // Documents
  static String get uploadDocument => '${_config.apiBaseUrl}/documents/upload';
  static String downloadDocument(String id) =>
      '${_config.apiBaseUrl}/documents/$id/download';

  // Notifications
  static String get notifications => '${_config.apiBaseUrl}/notifications';
  static String markNotificationRead(String id) =>
      '${_config.apiBaseUrl}/notifications/$id/read';
}
