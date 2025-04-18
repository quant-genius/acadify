
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'environment.dart';

/// Configuration class for the application
/// 
/// This class holds all configuration settings for the app,
/// loaded from environment variables or .env file
class AppConfig {
  final String apiUrl;
  final String appName;
  final Environment environment;
  final bool enableCrashlytics;
  final bool enablePerformanceMonitoring;
  final int postPageSize;
  final int messagePageSize;
  
  /// Creates an instance of AppConfig with the given parameters
  AppConfig({
    required this.apiUrl,
    required this.appName,
    required this.environment,
    required this.enableCrashlytics,
    required this.enablePerformanceMonitoring,
    required this.postPageSize,
    required this.messagePageSize,
  });
  
  /// Creates an AppConfig from environment variables
  factory AppConfig.fromEnvironment() {
    return AppConfig(
      apiUrl: dotenv.get('API_URL', fallback: 'https://api.acadify.com'),
      appName: dotenv.get('APP_NAME', fallback: 'Acadify'),
      environment: _getEnvironment(dotenv.get('ENVIRONMENT', fallback: 'development')),
      enableCrashlytics: dotenv.get('ENABLE_CRASHLYTICS', fallback: 'false') == 'true',
      enablePerformanceMonitoring: dotenv.get('ENABLE_PERFORMANCE_MONITORING', fallback: 'false') == 'true',
      postPageSize: int.parse(dotenv.get('POST_PAGE_SIZE', fallback: '20')),
      messagePageSize: int.parse(dotenv.get('MESSAGE_PAGE_SIZE', fallback: '50')),
    );
  }
  
  /// Determines the environment from the environment string
  static Environment _getEnvironment(String envString) {
    switch (envString.toLowerCase()) {
      case 'production':
        return Environment.production;
      case 'staging':
        return Environment.staging;
      case 'development':
      default:
        return Environment.development;
    }
  }
  
  /// Returns true if the app is running in development mode
  bool get isDevelopment => environment == Environment.development;
  
  /// Returns true if the app is running in staging mode
  bool get isStaging => environment == Environment.staging;
  
  /// Returns true if the app is running in production mode
  bool get isProduction => environment == Environment.production;
}
