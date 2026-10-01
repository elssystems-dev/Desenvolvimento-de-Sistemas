import 'package:flutter_test/flutter_test.dart';
import 'package:sync_point/models/time_record_model.dart';
import 'package:sync_point/models/workplace_model.dart';
import 'package:sync_point/services/auth_service.dart';
import 'package:sync_point/utils/app_constants.dart';
import 'package:sync_point/utils/geolocation_helper.dart';

void main() {
  group('Geofencing & 100m Rule Tests', () {
    const workplaceLat = AppConstants.defaultWorkplaceLatitude;
    const workplaceLng = AppConstants.defaultWorkplaceLongitude;

    test('Point inside 100 meters must be authorized', () {
      // 30 meters displacement approx
      const currentLat = workplaceLat + 0.0002;
      const currentLng = workplaceLng + 0.0002;

      final distance = GeolocationHelper.calculateDistanceInMeters(
        startLatitude: currentLat,
        startLongitude: currentLng,
        endLatitude: workplaceLat,
        endLongitude: workplaceLng,
      );

      final isAllowed = GeolocationHelper.isWithinAllowedRadius(
        currentLatitude: currentLat,
        currentLongitude: currentLng,
        workplaceLatitude: workplaceLat,
        workplaceLongitude: workplaceLng,
        maxRadius: 100.0,
      );

      expect(distance, lessThanOrEqualTo(100.0));
      expect(isAllowed, isTrue);
    });

    test('Point outside 100 meters (e.g. 500m away) must be blocked', () {
      // ~2.2 km away
      const currentLat = workplaceLat + 0.02;
      const currentLng = workplaceLng + 0.02;

      final distance = GeolocationHelper.calculateDistanceInMeters(
        startLatitude: currentLat,
        startLongitude: currentLng,
        endLatitude: workplaceLat,
        endLongitude: workplaceLng,
      );

      final isAllowed = GeolocationHelper.isWithinAllowedRadius(
        currentLatitude: currentLat,
        currentLongitude: currentLng,
        workplaceLatitude: workplaceLat,
        workplaceLongitude: workplaceLng,
        maxRadius: 100.0,
      );

      expect(distance, greaterThan(100.0));
      expect(isAllowed, isFalse);
    });

    test('SHA-256 Digital Stamp must generate reproducible deterministic hash', () {
      final now = DateTime(2026, 10, 1, 8, 30, 0);
      final hash1 = TimeRecordModel.generateSignature(
        userId: 'usr-123',
        nif: '98412',
        timestamp: now,
        lat: -23.561684,
        lng: -46.655981,
        type: 'entry',
      );

      final hash2 = TimeRecordModel.generateSignature(
        userId: 'usr-123',
        nif: '98412',
        timestamp: now,
        lat: -23.561684,
        lng: -46.655981,
        type: 'entry',
      );

      expect(hash1, isNotEmpty);
      expect(hash1, equals(hash2));
      expect(hash1.length, equals(64)); // SHA-256 hex length
    });

    test('NIF normalization converts numeric NIF to valid corporate email', () {
      final email1 = AuthService.normalizeLoginToEmail('98412');
      final email2 = AuthService.normalizeLoginToEmail('NIF-98412');
      final email3 = AuthService.normalizeLoginToEmail('carlos@empresa.com');

      expect(email1, equals('98412@syncpoint.internal'));
      expect(email2, equals('nif98412@syncpoint.internal'));
      expect(email3, equals('carlos@empresa.com'));
    });

    test('WorkplaceModel default headquarters matches specification', () {
      final defaultWp = WorkplaceModel.defaultHeadquarters;
      expect(defaultWp.allowedRadiusMeters, equals(100.0));
      expect(defaultWp.latitude, equals(AppConstants.defaultWorkplaceLatitude));
      expect(defaultWp.longitude, equals(AppConstants.defaultWorkplaceLongitude));
    });
  });
}
