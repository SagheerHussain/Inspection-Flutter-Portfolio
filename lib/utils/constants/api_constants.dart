import 'package:get_storage/get_storage.dart';

/// API Configuration with Dev/Prod switching
class ApiConstants {
  ApiConstants._();

  static const String _devBaseUrl =
      'https://otobix-app-backend-development.onrender.com/api/';
  static const String _prodBaseUrl =
      'https://ob-dealerapp-kong.onrender.com/api/';

  static final _storage = GetStorage();
  static const String _envKey = 'API_ENVIRONMENT';

  /// Get current environment: 'development' or 'production'
  static String get environment => _storage.read(_envKey) ?? 'development';

  /// Check if using production
  static bool get isProduction => environment == 'production';

  /// Get the active base URL — always use production
  static String get baseUrl => _prodBaseUrl;

  /// Switch to production
  static Future<void> switchToProduction() async {
    await _storage.write(_envKey, 'production');
  }

  /// Switch to development
  static Future<void> switchToDevelopment() async {
    await _storage.write(_envKey, 'development');
  }

  /// Toggle environment
  static Future<void> toggleEnvironment() async {
    if (isProduction) {
      await switchToDevelopment();
    } else {
      await switchToProduction();
    }
  }

  // ──────────────────────────────────────────
  // AUTH ENDPOINTS
  // ──────────────────────────────────────────
  static String get loginUrl => '${baseUrl}user/login';

  // ──────────────────────────────────────────
  // SCHEDULE / TELECALLING ENDPOINTS
  // ──────────────────────────────────────────
  static String schedulesUrl({int page = 1, int limit = 5}) =>
      '${baseUrl}admin/telecallings/get-list?page=$page&limit=$limit';

  /// Aggregation URL — fetches all records for totals computation
  static String get schedulesAggregationUrl =>
      '${baseUrl}admin/telecallings/get-list?page=1&limit=1000';

  // ──────────────────────────────────────────
  // CAR DETAILS ENDPOINT
  // ──────────────────────────────────────────
  static String carDetailsUrl(String appointmentId) =>
      '${baseUrl}car/details/carId?appointmentId=$appointmentId';
}
