import 'package:equatable/equatable.dart';

class VehicleLocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String placa;
  final DateTime timestamp;
  final String routeCode;
  final int color;

  const VehicleLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.placa,
    required this.timestamp,
    this.routeCode = '',
    this.color = 0xFFFF5722,
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    placa,
    timestamp,
    routeCode,
    color,
  ];
}
