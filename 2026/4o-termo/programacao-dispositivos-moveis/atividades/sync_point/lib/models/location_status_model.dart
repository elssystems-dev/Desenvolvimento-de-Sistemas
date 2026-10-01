class LocationStatusModel {
  final double? currentLatitude;
  final double? currentLongitude;
  final double? distanceToWorkplaceMeters;
  final bool isWithinAllowedRadius;
  final double? accuracy;
  final bool isGpsEnabled;
  final bool hasPermission;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const LocationStatusModel({
    this.currentLatitude,
    this.currentLongitude,
    this.distanceToWorkplaceMeters,
    this.isWithinAllowedRadius = false,
    this.accuracy,
    this.isGpsEnabled = false,
    this.hasPermission = false,
    this.isLoading = false,
    this.errorMessage,
    this.lastUpdated,
  });

  LocationStatusModel copyWith({
    double? currentLatitude,
    double? currentLongitude,
    double? distanceToWorkplaceMeters,
    bool? isWithinAllowedRadius,
    double? accuracy,
    bool? isGpsEnabled,
    bool? hasPermission,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return LocationStatusModel(
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      distanceToWorkplaceMeters:
          distanceToWorkplaceMeters ?? this.distanceToWorkplaceMeters,
      isWithinAllowedRadius:
          isWithinAllowedRadius ?? this.isWithinAllowedRadius,
      accuracy: accuracy ?? this.accuracy,
      isGpsEnabled: isGpsEnabled ?? this.isGpsEnabled,
      hasPermission: hasPermission ?? this.hasPermission,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  static LocationStatusModel initial() {
    return const LocationStatusModel(
      isLoading: true,
      hasPermission: false,
      isGpsEnabled: false,
      isWithinAllowedRadius: false,
    );
  }
}
