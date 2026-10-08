import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  static const String appName = 'SyncPoint';
  static const String appTagline = 'Ponto Eletrônico Inteligente & Seguro';
  static const String appVersion = '1.0.0';

  // Geofencing Requirement - Max 100 meters
  static const double maxAllowedDistanceMeters = 100.0;

  // Default Headquarters Location (Av. Paulista, São Paulo)
  static const String defaultWorkplaceId = 'headquarters-main';
  static const String defaultWorkplaceName = 'Sede Central Corporativa';
  static const String defaultWorkplaceAddress = 'Av. Paulista, 1000 - Bela Vista, São Paulo - SP';
  static const double defaultWorkplaceLatitude = -23.561684;
  static const double defaultWorkplaceLongitude = -46.655981;

  // SharedPreferences Keys
  static const String keySavedUser = 'syncpoint_saved_user';
  static const String keyBiometricEnabled = 'syncpoint_biometric_enabled';
  static const String keyLastAuthMethod = 'syncpoint_last_auth_method';
  static const String keyLocalRecords = 'syncpoint_local_records';
  static const String keyCustomWorkplace = 'syncpoint_custom_workplace';
  static const String keyRememberEmailOrNif = 'syncpoint_remember_login';
  static const String keyApiBaseUrl = 'syncpoint_api_base_url';

  // REST API Endpoints (json-server / Node.js)
  static const String defaultAndroidEmulatorUrl = 'http://10.0.2.2:3000';
  static const String defaultLocalhostUrl = 'http://localhost:3000';

  static String get defaultBaseUrl {
    if (kIsWeb) return defaultLocalhostUrl;
    try {
      if (Platform.isAndroid) return defaultAndroidEmulatorUrl;
    } catch (_) {}
    return defaultLocalhostUrl;
  }

  static const String endpointUsers = '/users';
  static const String endpointTimeRecords = '/time_records';
  static const String endpointWorkplaces = '/workplaces';
  static const String endpointStatus = '/status';
}
