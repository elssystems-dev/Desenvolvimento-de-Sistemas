import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/location_status_model.dart';
import '../models/time_record_model.dart';
import '../models/user_model.dart';
import '../models/workplace_model.dart';
import '../services/biometric_service.dart';
import '../services/record_api_service.dart';
import '../utils/formatters.dart';

class PunchClockResult {
  final bool success;
  final String message;
  final TimeRecordModel? record;

  PunchClockResult({
    required this.success,
    required this.message,
    this.record,
  });
}

class PunchClockController extends ChangeNotifier {
  final RecordApiService _recordApiService = RecordApiService();
  final BiometricService _biometricService = BiometricService();
  final Uuid _uuid = const Uuid();

  bool _isProcessing = false;
  PunchType _selectedType = PunchType.entry;
  TimeRecordModel? _lastPunchRecorded;

  bool get isProcessing => _isProcessing;
  PunchType get selectedType => _selectedType;
  TimeRecordModel? get lastPunchRecorded => _lastPunchRecorded;

  void setSelectedType(PunchType type) {
    _selectedType = type;
    notifyListeners();
  }

  /// Executes punch registration adhering to the 100m geofence and biometric requirements
  Future<PunchClockResult> registerPunch({
    required UserModel user,
    required WorkplaceModel workplace,
    required LocationStatusModel locationStatus,
    required bool requireBiometrics,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // 1. Mandatory Requirement: Geofencing validation (<= 100 meters)
      if (locationStatus.currentLatitude == null ||
          locationStatus.currentLongitude == null ||
          locationStatus.distanceToWorkplaceMeters == null) {
        return PunchClockResult(
          success: false,
          message: 'Localização GPS não disponível. Aguarde o sinal de satélite ou ative o GPS.',
        );
      }

      final distance = locationStatus.distanceToWorkplaceMeters!;
      if (distance > workplace.allowedRadiusMeters) {
        return PunchClockResult(
          success: false,
          message:
              'Registro bloqueado: você está a ${Formatters.formatDistance(distance)} do local de trabalho.\n'
              'O raio máximo permitido para registro é de ${Formatters.formatDistance(workplace.allowedRadiusMeters)}.',
        );
      }

      // 2. Hardware Requirement: Biometric / Facial Authentication
      AuthMethod usedAuthMethod = AuthMethod.password;

      if (requireBiometrics || user.isBiometricEnabled) {
        final isBioAvailable = await _biometricService.isBiometricAvailable();
        if (isBioAvailable) {
          final bioSuccess = await _biometricService.authenticate(
            reason: 'Confirme seu reconhecimento facial/biometria para registrar o ponto (${_selectedType.label})',
          );

          if (!bioSuccess) {
            return PunchClockResult(
              success: false,
              message: 'Falha na validação biométrica/facial. Registro de ponto cancelado.',
            );
          }
          usedAuthMethod = await _biometricService.getPrimaryAuthMethod();
        } else if (requireBiometrics) {
          return PunchClockResult(
            success: false,
            message: 'Biometria/Reconhecimento facial não disponível no dispositivo.',
          );
        }
      }

      // 3. Create cryptographically signed time record
      final now = DateTime.now();
      final recordId = 'punch-${_uuid.v4()}';

      final signature = TimeRecordModel.generateSignature(
        userId: user.id,
        nif: user.nif,
        timestamp: now,
        lat: locationStatus.currentLatitude!,
        lng: locationStatus.currentLongitude!,
        type: _selectedType.name,
      );

      final record = TimeRecordModel(
        id: recordId,
        userId: user.id,
        userNif: user.nif,
        userName: user.name,
        timestamp: now,
        type: _selectedType,
        latitude: locationStatus.currentLatitude!,
        longitude: locationStatus.currentLongitude!,
        workplaceId: workplace.id,
        workplaceName: workplace.name,
        distanceMeters: distance,
        isWithinRadius: true,
        authMethod: usedAuthMethod,
        hashSignature: signature,
      );

      // 4. Save to json-server & Local Storage
      final savedRecord = await _recordApiService.recordPunch(record);
      _lastPunchRecorded = savedRecord;

      // Automatically advance to the next recommended punch type
      _selectedType = _getNextRecommendedPunchType(_selectedType);

      return PunchClockResult(
        success: true,
        message: 'Ponto (${savedRecord.type.label}) registrado com sucesso!',
        record: savedRecord,
      );
    } catch (e) {
      return PunchClockResult(
        success: false,
        message: 'Erro ao registrar ponto: $e',
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  PunchType _getNextRecommendedPunchType(PunchType current) {
    switch (current) {
      case PunchType.entry:
        return PunchType.lunchOut;
      case PunchType.lunchOut:
        return PunchType.lunchIn;
      case PunchType.lunchIn:
        return PunchType.exit;
      case PunchType.exit:
        return PunchType.entry;
    }
  }
}
