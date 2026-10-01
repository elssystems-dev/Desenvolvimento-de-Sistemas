import 'dart:convert';
import '../utils/app_constants.dart';

class WorkplaceModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double allowedRadiusMeters;

  const WorkplaceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.allowedRadiusMeters = AppConstants.maxAllowedDistanceMeters,
  });

  static WorkplaceModel get defaultHeadquarters => const WorkplaceModel(
        id: AppConstants.defaultWorkplaceId,
        name: AppConstants.defaultWorkplaceName,
        address: AppConstants.defaultWorkplaceAddress,
        latitude: AppConstants.defaultWorkplaceLatitude,
        longitude: AppConstants.defaultWorkplaceLongitude,
        allowedRadiusMeters: AppConstants.maxAllowedDistanceMeters,
      );

  WorkplaceModel copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? allowedRadiusMeters,
  }) {
    return WorkplaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      allowedRadiusMeters: allowedRadiusMeters ?? this.allowedRadiusMeters,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'allowedRadiusMeters': allowedRadiusMeters,
    };
  }

  factory WorkplaceModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return WorkplaceModel(
      id: documentId ?? map['id']?.toString() ?? AppConstants.defaultWorkplaceId,
      name: map['name']?.toString() ?? AppConstants.defaultWorkplaceName,
      address: map['address']?.toString() ?? AppConstants.defaultWorkplaceAddress,
      latitude: (map['latitude'] as num?)?.toDouble() ?? AppConstants.defaultWorkplaceLatitude,
      longitude: (map['longitude'] as num?)?.toDouble() ?? AppConstants.defaultWorkplaceLongitude,
      allowedRadiusMeters: (map['allowedRadiusMeters'] as num?)?.toDouble() ??
          AppConstants.maxAllowedDistanceMeters,
    );
  }

  String toJson() => json.encode(toMap());

  factory WorkplaceModel.fromJson(String source) =>
      WorkplaceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
