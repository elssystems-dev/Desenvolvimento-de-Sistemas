import 'package:flutter/material.dart';
import '../models/workplace_model.dart';
import '../services/storage_service.dart';

class WorkplaceController extends ChangeNotifier {
  WorkplaceModel _activeWorkplace = WorkplaceModel.defaultHeadquarters;
  bool _isLoading = false;

  WorkplaceModel get activeWorkplace => _activeWorkplace;
  bool get isLoading => _isLoading;

  Future<void> loadWorkplace() async {
    _isLoading = true;
    notifyListeners();
    try {
      final storage = await StorageService.getInstance();
      _activeWorkplace = storage.getWorkplace();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateWorkplace(WorkplaceModel workplace) async {
    _isLoading = true;
    notifyListeners();
    try {
      final storage = await StorageService.getInstance();
      await storage.saveCustomWorkplace(workplace);
      _activeWorkplace = workplace;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setWorkplaceCoordinates({
    required double latitude,
    required double longitude,
    String? name,
    String? address,
    double radius = 100.0,
  }) async {
    final updated = WorkplaceModel(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Local de Trabalho Customizado',
      address: address ?? 'Localização Definida via GPS',
      latitude: latitude,
      longitude: longitude,
      allowedRadiusMeters: radius,
    );
    await updateWorkplace(updated);
  }

  Future<void> resetToDefault() async {
    _isLoading = true;
    notifyListeners();
    try {
      final storage = await StorageService.getInstance();
      await storage.resetWorkplaceToDefault();
      _activeWorkplace = WorkplaceModel.defaultHeadquarters;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
