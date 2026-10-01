import 'package:geolocator/geolocator.dart';
import 'app_constants.dart';

class GeolocationHelper {
  /// Calculates geodesic distance between device position and target workplace in meters
  static double calculateDistanceInMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Verifies if user is within the 100-meter radius requirement
  static bool isWithinAllowedRadius({
    required double currentLatitude,
    required double currentLongitude,
    required double workplaceLatitude,
    required double workplaceLongitude,
    double maxRadius = AppConstants.maxAllowedDistanceMeters,
  }) {
    final distance = calculateDistanceInMeters(
      startLatitude: currentLatitude,
      startLongitude: currentLongitude,
      endLatitude: workplaceLatitude,
      endLongitude: workplaceLongitude,
    );
    return distance <= maxRadius;
  }
}
