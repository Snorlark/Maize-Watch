enum Environment { development, staging, production }

class AppConfig {
  static Environment _environment = Environment.development;

  static Environment get environment => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://10.125.93.206:8080';
      case Environment.staging:
        return 'https://staging-api.maizewatch.com';
      case Environment.production:
        return 'https://api.maizewatch.com';
    }
  }

  static String get apiVersion => '/api/';

  static String get fullApiUrl => '$baseUrl$apiVersion';

  // API Endpoints
  static String get loginEndpoint => '$fullApiUrl/auth/login';
  static String get registerEndpoint => '$fullApiUrl/auth/register';
  static String get refreshTokenEndpoint => '$fullApiUrl/auth/refresh';
  static String get logoutEndpoint => '$fullApiUrl/auth/logout';

  static String get usersEndpoint => '$fullApiUrl/users';
  static String get profileEndpoint => '$fullApiUrl/users/profile';

  static String get farmsEndpoint => '$fullApiUrl/farms';
  static String get sensorsEndpoint => '$fullApiUrl/sensors';
  static String get analyticsEndpoint => '$fullApiUrl/analytics';

  // Security settings
  static bool get enableSSLPinning => _environment == Environment.production;
  static Duration get requestTimeout => const Duration(seconds: 30);
  static int get maxRetries => 3;
}
