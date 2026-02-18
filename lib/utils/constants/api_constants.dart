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

  /// Get the active base URL — switched to Development by default as requested
  static String get baseUrl => isProduction ? _prodBaseUrl : _devBaseUrl;

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
  static String get inspectionEngineerSchedulesUrl =>
      '${baseUrl}inspection/telecallings/get-list-by-inspection-engineer';

  static String get updateTelecallingUrl =>
      '${baseUrl}inspection/telecallings/update';

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

  // ──────────────────────────────────────────
  // INSPECTION SUBMISSION ENDPOINTS (Dev)
  // ──────────────────────────────────────────
  static String get inspectionSubmitUrl =>
      '${_devBaseUrl}inspection/car/add-car-through-inspection';

  static String get fetchVehicleDetailsUrl =>
      '${_devBaseUrl}customer/sell-my-car/fetch-vehicle-registration-details';

  static String get getAllDropdownsUrl =>
      '${baseUrl}inspection/dropdowns/get-all-dropdowns-list';

  // Cloudinary Upload/Delete
  static String get uploadImagesUrl =>
      '${baseUrl}inspection/car/upload-car-images-to-cloudinary';
  static String get deleteImageUrl =>
      '${baseUrl}inspection/car/delete-image-from-cloudinary';
  static String get uploadVideoUrl =>
      '${baseUrl}inspection/car/upload-car-video-to-cloudinary';
  static String get deleteVideoUrl =>
      '${baseUrl}inspection/car/delete-video-from-cloudinary';
}
