/// Application configuration for environment management.
/// 
/// This configuration allows switching between different environments
/// and data sources (local, Firebase, production) for development and testing.

enum AppEnvironment {
  development,
  staging,
  production,
}

enum DataSource {
  local,      // Local storage only (offline testing)
  firebase,   // Firebase backend
  hybrid,     // Local cache with Firebase sync
}

class AppConfig {
  static AppEnvironment environment = AppEnvironment.development;
  static DataSource dataSource = DataSource.firebase;
  
  /// Enable/disable features based on environment
  static bool get useRealData => environment != AppEnvironment.development;
  static bool get useFirebase => dataSource == DataSource.firebase || dataSource == DataSource.hybrid;
  static bool get useLocalCache => dataSource == DataSource.local || dataSource == DataSource.hybrid;
  
  /// Firebase configuration
  static bool get enableAnalytics => environment == AppEnvironment.production;
  static bool get enableCrashlytics => environment != AppEnvironment.development;
  static bool get enablePerformanceMonitoring => environment == AppEnvironment.production;
  
  /// API endpoints based on environment
  static String get exerciseDbApiUrl {
    switch (environment) {
      case AppEnvironment.development:
        return 'https://exercisedb.p.rapidapi.com'; // Test API
      case AppEnvironment.staging:
        return 'https://exercisedb.p.rapidapi.com'; // Staging API
      case AppEnvironment.production:
        return 'https://exercisedb.p.rapidapi.com'; // Production API
    }
  }
  
  static String get nutritionApiUrl {
    switch (environment) {
      case AppEnvironment.development:
        return 'https://api.nal.usda.gov/fdc/v1'; // Test API
      case AppEnvironment.staging:
        return 'https://api.nal.usda.gov/fdc/v1'; // Staging API
      case AppEnvironment.production:
        return 'https://api.nal.usda.gov/fdc/v1'; // Production API
    }
  }
  
  /// Feature flags
  static bool get enableRivalMode => true;
  static bool get enableChallenges => true;
  static bool get enableNutritionTracking => true;
  static bool get enableSocialFeatures => environment != AppEnvironment.development;
  static bool get enablePushNotifications => useFirebase && environment != AppEnvironment.development;
  
  /// Debug settings
  static bool get showDebugBanner => environment == AppEnvironment.development;
  static bool get enableLogging => environment != AppEnvironment.production;
  
  /// Configure app for specific environment
  static void configure({
    required AppEnvironment env,
    required DataSource source,
  }) {
    environment = env;
    dataSource = source;
    
    print('App configured for $environment with $dataSource data source');
  }
}