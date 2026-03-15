import 'package:equatable/equatable.dart';

class VehicleLocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String placa;
  final DateTime timestamp;
  final String routeCode;
  final int mainColor;
  final int secondaryColor;

  const VehicleLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.placa,
    required this.timestamp,
    this.routeCode = '',
    this.mainColor = 0xFFFF5722,
    this.secondaryColor = 0xFFFF8A65,
  });

  int get color => mainColor;

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    placa,
    timestamp,
    routeCode,
    mainColor,
    secondaryColor,
  ];
}
