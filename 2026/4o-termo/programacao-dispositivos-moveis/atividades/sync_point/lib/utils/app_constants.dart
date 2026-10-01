class AppConstants {
  static const String appName = 'SyncPoint';
  static const String appTagline = 'Ponto Eletrônico Inteligente & Seguro';
  static const String appVersion = '1.0.0';

  // Geofencing Requirement - Max 100 meters
  static const double maxAllowedDistanceMeters = 100.0;

  // Default Headquarters Location (e.g., Corporate Campus / Tech Center)
  // Latitude & Longitude for default workplace
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

  // Firestore Collections
  static const String collectionUsers = 'users';
  static const String collectionTimeRecords = 'time_records';
  static const String collectionWorkplaces = 'workplaces';
}
