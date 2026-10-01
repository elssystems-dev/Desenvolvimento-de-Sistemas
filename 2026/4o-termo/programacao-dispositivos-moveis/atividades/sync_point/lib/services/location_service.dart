import 'package:geolocator/geolocator.dart';
import '../models/location_status_model.dart';
import '../models/workplace_model.dart';
import '../utils/geolocation_helper.dart';

class LocationService {
  /// Checks if location services (GPS) are enabled and permissions are granted
  Future<LocationPermission> checkAndRequestPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Os serviços de localização (GPS) estão desativados no dispositivo.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('A permissão de localização foi negada pelo usuário.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'A permissão de localização foi permanentemente negada. Abra as configurações do app para habilitar.',
      );
    }

    return permission;
  }

  /// Gets current high-accuracy GPS position
  Future<Position> getCurrentPosition() async {
    await checkAndRequestPermission();
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  /// Evaluates device position against the targeted workplace
  Future<LocationStatusModel> evaluateWorkplaceGeofence(WorkplaceModel workplace) async {
    try {
      final isGpsEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isGpsEnabled) {
        return LocationStatusModel(
          isLoading: false,
          isGpsEnabled: false,
          hasPermission: false,
          errorMessage: 'GPS desativado. Ative a localização nas configurações do dispositivo.',
        );
      }

      final permission = await Geolocator.checkPermission();
      final hasPerm = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      final Position position = await getCurrentPosition();

      final double distance = GeolocationHelper.calculateDistanceInMeters(
        startLatitude: position.latitude,
        startLongitude: position.longitude,
        endLatitude: workplace.latitude,
        endLongitude: workplace.longitude,
      );

      final bool isWithin = distance <= workplace.allowedRadiusMeters;

      return LocationStatusModel(
        currentLatitude: position.latitude,
        currentLongitude: position.longitude,
        distanceToWorkplaceMeters: distance,
        isWithinAllowedRadius: isWithin,
        accuracy: position.accuracy,
        isGpsEnabled: true,
        hasPermission: hasPerm,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return LocationStatusModel(
        isLoading: false,
        isGpsEnabled: false,
        hasPermission: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Listens to live position stream
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters moved
      ),
    );
  }
}
