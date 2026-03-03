import 'api_constants.dart';

/// App-wide constants (non-API)
class AppConstants {
  AppConstants._();

  /// OneSignal App ID
  static const String oneSignalAppId = '00fc519e-1881-4ec2-b806-f1a094cdbb74';

  /// Current environment name — matches ApiConstants toggle
  static String get envName => ApiConstants.isProduction ? 'prod' : 'dev';

  /// Build a namespaced external-id for OneSignal login
  static String externalIdForNotifications(String userId) => '$envName:$userId';
}
