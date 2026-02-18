import 'package:equatable/equatable.dart';

class VehicleLocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String placa;
  final DateTime timestamp;

  const VehicleLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.placa,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [latitude, longitude, placa, timestamp];
}
