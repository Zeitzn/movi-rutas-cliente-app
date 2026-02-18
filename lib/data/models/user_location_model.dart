import 'package:cliente/domain/entities/user_location_entity.dart';

class UserLocationModel {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  UserLocationModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      latitude: (json['latitude'] ?? 0.0) is String
          ? double.parse(json['latitude'])
          : (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0) is String
          ? double.parse(json['longitude'])
          : (json['longitude'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  UserLocationEntity toEntity() {
    return UserLocationEntity(
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
    );
  }
}
