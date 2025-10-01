// This file should be added to .gitignore and never committed
// Use environment variables or secure configuration management in production

class AppSecrets {
  // API Keys (should be loaded from environment variables)
  static const String? apiKey = String.fromEnvironment('API_KEY');
  static const String? encryptionKey = String.fromEnvironment('ENCRYPTION_KEY');


  // Third-party service keys
  static const String? weatherApiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
  );
  static const String? mapApiKey = String.fromEnvironment('MAP_API_KEY');

  // Validation methods
  static bool get hasRequiredSecrets {
    return apiKey != null && apiKey!.isNotEmpty;
  }

  static void validateSecrets() {
    if (!hasRequiredSecrets) {
      throw Exception(
        'Required API secrets are missing. Please check your environment configuration.',
      );
    }
  }
}
