import 'package:cliente/domain/entities/vehicle_location_entity.dart';

class VehicleLocationModel {
  final double latitude;
  final double longitude;
  final String placa;
  final DateTime timestamp;

  VehicleLocationModel({
    required this.latitude,
    required this.longitude,
    required this.placa,
    required this.timestamp,
  });

  factory VehicleLocationModel.fromJson(Map<String, dynamic> json) {
    return VehicleLocationModel(
      latitude: (json['latitude'] ?? 0.0) is String
          ? double.parse(json['latitude'])
          : (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0) is String
          ? double.parse(json['longitude'])
          : (json['longitude'] ?? 0.0).toDouble(),
      placa: json['placa'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'placa': placa,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  VehicleLocationEntity toEntity() {
    return VehicleLocationEntity(
      latitude: latitude,
      longitude: longitude,
      placa: placa,
      timestamp: timestamp,
    );
  }
}
