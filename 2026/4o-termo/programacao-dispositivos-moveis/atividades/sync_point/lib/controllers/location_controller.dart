import 'dart:async';
import 'package:flutter/material.dart';
import '../models/location_status_model.dart';
import '../models/workplace_model.dart';
import '../services/location_service.dart';

class LocationController extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  LocationStatusModel _status = LocationStatusModel.initial();
  StreamSubscription? _positionSubscription;
  bool _isAutoTracking = false;

  LocationStatusModel get status => _status;
  bool get isWithinAllowedRadius => _status.isWithinAllowedRadius;
  bool get isLoading => _status.isLoading;
  bool get hasValidCoordinates =>
      _status.currentLatitude != null && _status.currentLongitude != null;

  /// Performs a full GPS acquisition and calculates geofencing against workplace
  Future<void> checkLocation(WorkplaceModel workplace) async {
    _status = _status.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final evaluated = await _locationService.evaluateWorkplaceGeofence(workplace);
      _status = evaluated;
    } catch (e) {
      _status = _status.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      notifyListeners();
    }
  }

  /// Starts continuous GPS tracking stream for real-time radar updates
  void startTracking(WorkplaceModel workplace) {
    if (_isAutoTracking) return;
    _isAutoTracking = true;

    // First manual check
    checkLocation(workplace);

    _positionSubscription = _locationService.getPositionStream().listen(
      (position) {
        checkLocation(workplace);
      },
      onError: (err) {
        _status = _status.copyWith(
          isLoading: false,
          errorMessage: 'Erro no rastreamento GPS: $err',
        );
        notifyListeners();
      },
    );
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isAutoTracking = false;
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
