import 'package:equatable/equatable.dart';

class UserLocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const UserLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [latitude, longitude, timestamp];
}
