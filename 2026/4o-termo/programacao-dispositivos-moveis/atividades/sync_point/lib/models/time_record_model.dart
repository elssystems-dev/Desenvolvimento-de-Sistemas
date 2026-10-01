import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

enum PunchType {
  entry,
  lunchOut,
  lunchIn,
  exit;

  String get label {
    switch (this) {
      case PunchType.entry:
        return 'Entrada';
      case PunchType.lunchOut:
        return 'Saída Intervalo';
      case PunchType.lunchIn:
        return 'Retorno Intervalo';
      case PunchType.exit:
        return 'Saída';
    }
  }

  String get fullDescription {
    switch (this) {
      case PunchType.entry:
        return 'Início de Expediente';
      case PunchType.lunchOut:
        return 'Saída para Almoço / Intervalo';
      case PunchType.lunchIn:
        return 'Retorno do Almoço / Intervalo';
      case PunchType.exit:
        return 'Encerramento de Expediente';
    }
  }

  IconData get icon {
    switch (this) {
      case PunchType.entry:
        return Icons.login_rounded;
      case PunchType.lunchOut:
        return Icons.restaurant_rounded;
      case PunchType.lunchIn:
        return Icons.timer_rounded;
      case PunchType.exit:
        return Icons.logout_rounded;
    }
  }

  Color get color {
    switch (this) {
      case PunchType.entry:
        return AppColors.punchEntry;
      case PunchType.lunchOut:
        return AppColors.punchLunchOut;
      case PunchType.lunchIn:
        return AppColors.punchLunchIn;
      case PunchType.exit:
        return AppColors.punchExit;
    }
  }

  static PunchType fromString(String value) {
    switch (value) {
      case 'entry':
        return PunchType.entry;
      case 'lunchOut':
        return PunchType.lunchOut;
      case 'lunchIn':
        return PunchType.lunchIn;
      case 'exit':
        return PunchType.exit;
      default:
        return PunchType.entry;
    }
  }
}

enum AuthMethod {
  password,
  biometricFace,
  biometricFingerprint;

  String get label {
    switch (this) {
      case AuthMethod.password:
        return 'Senha / NIF';
      case AuthMethod.biometricFace:
        return 'Reconhecimento Facial';
      case AuthMethod.biometricFingerprint:
        return 'Biometria Digital';
    }
  }

  IconData get icon {
    switch (this) {
      case AuthMethod.password:
        return Icons.lock_outline_rounded;
      case AuthMethod.biometricFace:
        return Icons.face_rounded;
      case AuthMethod.biometricFingerprint:
        return Icons.fingerprint_rounded;
    }
  }

  static AuthMethod fromString(String value) {
    switch (value) {
      case 'biometricFace':
        return AuthMethod.biometricFace;
      case 'biometricFingerprint':
        return AuthMethod.biometricFingerprint;
      case 'password':
      default:
        return AuthMethod.password;
    }
  }
}

class TimeRecordModel {
  final String id;
  final String userId;
  final String userNif;
  final String userName;
  final DateTime timestamp;
  final PunchType type;
  final double latitude;
  final double longitude;
  final String workplaceId;
  final String workplaceName;
  final double distanceMeters;
  final bool isWithinRadius;
  final AuthMethod authMethod;
  final String hashSignature;
  final bool syncedWithServer;

  const TimeRecordModel({
    required this.id,
    required this.userId,
    required this.userNif,
    required this.userName,
    required this.timestamp,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.workplaceId,
    required this.workplaceName,
    required this.distanceMeters,
    required this.isWithinRadius,
    required this.authMethod,
    required this.hashSignature,
    this.syncedWithServer = false,
  });

  /// Generates a cryptographic SHA-256 digital stamp for legal integrity
  static String generateSignature({
    required String userId,
    required String nif,
    required DateTime timestamp,
    required double lat,
    required double lng,
    required String type,
  }) {
    final rawData = '$userId|$nif|${timestamp.toIso8601String()}|$lat|$lng|$type|SYNCPOINT_SECURE_SALT_2026';
    return sha256.convert(utf8.encode(rawData)).toString();
  }

  TimeRecordModel copyWith({
    String? id,
    String? userId,
    String? userNif,
    String? userName,
    DateTime? timestamp,
    PunchType? type,
    double? latitude,
    double? longitude,
    String? workplaceId,
    String? workplaceName,
    double? distanceMeters,
    bool? isWithinRadius,
    AuthMethod? authMethod,
    String? hashSignature,
    bool? syncedWithServer,
  }) {
    return TimeRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userNif: userNif ?? this.userNif,
      userName: userName ?? this.userName,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      workplaceId: workplaceId ?? this.workplaceId,
      workplaceName: workplaceName ?? this.workplaceName,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isWithinRadius: isWithinRadius ?? this.isWithinRadius,
      authMethod: authMethod ?? this.authMethod,
      hashSignature: hashSignature ?? this.hashSignature,
      syncedWithServer: syncedWithServer ?? this.syncedWithServer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userNif': userNif,
      'userName': userName,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'latitude': latitude,
      'longitude': longitude,
      'workplaceId': workplaceId,
      'workplaceName': workplaceName,
      'distanceMeters': distanceMeters,
      'isWithinRadius': isWithinRadius,
      'authMethod': authMethod.name,
      'hashSignature': hashSignature,
      'syncedWithServer': syncedWithServer,
    };
  }

  factory TimeRecordModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return TimeRecordModel(
      id: documentId ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userNif: map['userNif']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      type: PunchType.fromString(map['type']?.toString() ?? 'entry'),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      workplaceId: map['workplaceId']?.toString() ?? '',
      workplaceName: map['workplaceName']?.toString() ?? '',
      distanceMeters: (map['distanceMeters'] as num?)?.toDouble() ?? 0.0,
      isWithinRadius: map['isWithinRadius'] == true,
      authMethod: AuthMethod.fromString(map['authMethod']?.toString() ?? 'password'),
      hashSignature: map['hashSignature']?.toString() ?? '',
      syncedWithServer: map['syncedWithServer'] == true,
    );
  }

  String toJson() => json.encode(toMap());

  factory TimeRecordModel.fromJson(String source) =>
      TimeRecordModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
